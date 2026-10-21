import os
import joblib
import numpy as np
import pandas as pd

from sklearn.model_selection import StratifiedKFold, cross_val_predict
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    recall_score,
    f1_score,
    accuracy_score,
    confusion_matrix
)
from sklearn.utils.class_weight import compute_sample_weight

from xgboost import XGBClassifier


# ============================================================
# 1. MEMBACA DATA TRAIN FINAL
# ============================================================

train_path = "data/final_split/train_final.csv"

df_train = pd.read_csv(train_path)

X_train = df_train.drop(columns=["Diabetes_012"])
y_train = df_train["Diabetes_012"].astype(int)


print("=" * 75)
print("MEMBANGUN STACKING FINAL")
print("=" * 75)

print("\nJumlah data train:")
print(X_train.shape)


# ============================================================
# 2. PARAMETER RANDOM FOREST HASIL TUNING
# ============================================================

rf_params = {
    "n_estimators": 400,
    "min_samples_split": 10,
    "min_samples_leaf": 2,
    "max_features": "sqrt",
    "max_depth": 20,
    "bootstrap": False,
    "class_weight": "balanced",
    "random_state": 42,
    "n_jobs": -1
}


# ============================================================
# 3. PARAMETER XGBOOST HASIL TUNING
# ============================================================

xgb_params = {
    "n_estimators": 300,
    "min_child_weight": 5,
    "max_depth": 4,
    "learning_rate": 0.03,
    "subsample": 0.9,
    "colsample_bytree": 1.0,
    "objective": "multi:softprob",
    "num_class": 3,
    "eval_metric": "mlogloss",
    "random_state": 42,
    "n_jobs": -1
}


# ============================================================
# 4. STRATIFIED 5-FOLD
# ============================================================

skf = StratifiedKFold(
    n_splits=5,
    shuffle=True,
    random_state=42
)


# ============================================================
# 5. TEMPAT MENYIMPAN OUT-OF-FOLD PREDICTIONS
# ============================================================

rf_oof = np.zeros((len(X_train), 3))
xgb_oof = np.zeros((len(X_train), 3))


# ============================================================
# 6. MEMBUAT OUT-OF-FOLD PREDICTIONS
# ============================================================

for fold, (train_idx, valid_idx) in enumerate(
    skf.split(X_train, y_train),
    start=1
):
    print(f"\nMemproses Fold {fold}/5...")

    X_fold_train = X_train.iloc[train_idx]
    X_fold_valid = X_train.iloc[valid_idx]

    y_fold_train = y_train.iloc[train_idx]

    # --------------------------------------------------------
    # RANDOM FOREST + CSL
    # --------------------------------------------------------

    rf_model = RandomForestClassifier(
        **rf_params
    )

    rf_model.fit(
        X_fold_train,
        y_fold_train
    )

    rf_oof[valid_idx] = rf_model.predict_proba(
        X_fold_valid
    )


    # --------------------------------------------------------
    # XGBOOST + CSL
    # --------------------------------------------------------

    fold_sample_weight = compute_sample_weight(
        class_weight="balanced",
        y=y_fold_train
    )

    xgb_model = XGBClassifier(
        **xgb_params
    )

    xgb_model.fit(
        X_fold_train,
        y_fold_train,
        sample_weight=fold_sample_weight
    )

    xgb_oof[valid_idx] = xgb_model.predict_proba(
        X_fold_valid
    )


print("\nOut-of-fold prediction selesai.")


# ============================================================
# 7. MENGGABUNGKAN PROBABILITAS RF DAN XGB
# ============================================================

stacking_features = np.hstack(
    (
        rf_oof,
        xgb_oof
    )
)

print("\nUkuran data untuk meta-learner:")
print(stacking_features.shape)


# ============================================================
# 8. LOGISTIC REGRESSION SEBAGAI META-LEARNER
# ============================================================

meta_model = LogisticRegression(
    max_iter=2000,
    class_weight="balanced",
    random_state=42
)


# ============================================================
# 9. CROSS-VALIDATION META-LEARNER
# ============================================================

meta_oof_pred = cross_val_predict(
    meta_model,
    stacking_features,
    y_train,
    cv=skf,
    method="predict",
    n_jobs=-1
)


# ============================================================
# 10. EVALUASI STACKING PADA DATA TRAIN VIA CV
# ============================================================

recalls = recall_score(
    y_train,
    meta_oof_pred,
    labels=[0, 1, 2],
    average=None,
    zero_division=0
)

macro_f1 = f1_score(
    y_train,
    meta_oof_pred,
    average="macro",
    zero_division=0
)

accuracy = accuracy_score(
    y_train,
    meta_oof_pred
)

gmean = np.prod(recalls) ** (1 / len(recalls))


print("\n" + "=" * 75)
print("HASIL CROSS-VALIDATION STACKING")
print("=" * 75)

print(f"\nRecall Kelas 0 - Tidak Diabetes : {recalls[0]:.4f}")
print(f"Recall Kelas 1 - Prediabetes    : {recalls[1]:.4f}")
print(f"Recall Kelas 2 - Diabetes       : {recalls[2]:.4f}")

print(f"\nMacro F1 : {macro_f1:.4f}")
print(f"G-Mean   : {gmean:.4f}")
print(f"Accuracy : {accuracy:.4f}")

print("\nConfusion Matrix:")
print(
    confusion_matrix(
        y_train,
        meta_oof_pred
    )
)


# ============================================================
# 11. MELATIH META-LEARNER FINAL
# ============================================================

meta_model.fit(
    stacking_features,
    y_train
)


# ============================================================
# 12. MELATIH RF FINAL PADA SELURUH TRAIN FINAL
# ============================================================

rf_final = RandomForestClassifier(
    **rf_params
)

rf_final.fit(
    X_train,
    y_train
)


# ============================================================
# 13. MELATIH XGBOOST FINAL PADA SELURUH TRAIN FINAL
# ============================================================

final_sample_weight = compute_sample_weight(
    class_weight="balanced",
    y=y_train
)

xgb_final = XGBClassifier(
    **xgb_params
)

xgb_final.fit(
    X_train,
    y_train,
    sample_weight=final_sample_weight
)


# ============================================================
# 14. MENYIMPAN MODEL
# ============================================================

os.makedirs(
    "artifacts",
    exist_ok=True
)

joblib.dump(
    rf_final,
    "artifacts/random_forest_final.joblib"
)

joblib.dump(
    xgb_final,
    "artifacts/xgboost_final.joblib"
)

joblib.dump(
    meta_model,
    "artifacts/meta_logistic_regression.joblib"
)

joblib.dump(
    list(X_train.columns),
    "artifacts/feature_names.joblib"
)


print("\n" + "=" * 75)
print("MODEL BERHASIL DISIMPAN")
print("=" * 75)

print("\nRandom Forest:")
print("artifacts/random_forest_final.joblib")

print("\nXGBoost:")
print("artifacts/xgboost_final.joblib")

print("\nMeta-Learner:")
print("artifacts/meta_logistic_regression.joblib")

print("\nNama fitur:")
print("artifacts/feature_names.joblib")

print("\nCATATAN:")
print(
    "test_final_locked.csv masih TIDAK digunakan."
)