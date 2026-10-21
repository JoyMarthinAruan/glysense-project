import numpy as np
import pandas as pd

from sklearn.model_selection import StratifiedKFold
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
# 1. MEMBACA TRAIN FINAL
# ============================================================

train_path = "data/final_split/train_final.csv"

df = pd.read_csv(train_path)

X = df.drop(columns=["Diabetes_012"])
y = df["Diabetes_012"].astype(int)


print("=" * 75)
print("PROPER CROSS-VALIDATION STACKING")
print("=" * 75)

print("\nJumlah data:")
print(X.shape)


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
# 4. OUTER CROSS-VALIDATION
# ============================================================

outer_cv = StratifiedKFold(
    n_splits=5,
    shuffle=True,
    random_state=42
)


# Menyimpan prediksi seluruh validation fold
final_predictions = np.zeros(len(X), dtype=int)


# ============================================================
# 5. PROSES OUTER FOLD
# ============================================================

for outer_fold, (outer_train_idx, outer_valid_idx) in enumerate(
    outer_cv.split(X, y),
    start=1
):

    print("\n" + "=" * 75)
    print(f"OUTER FOLD {outer_fold}/5")
    print("=" * 75)

    X_outer_train = X.iloc[outer_train_idx].reset_index(drop=True)
    y_outer_train = y.iloc[outer_train_idx].reset_index(drop=True)

    X_outer_valid = X.iloc[outer_valid_idx].reset_index(drop=True)
    y_outer_valid = y.iloc[outer_valid_idx].reset_index(drop=True)


    # ========================================================
    # 6. INNER CROSS-VALIDATION UNTUK MEMBUAT OOF
    # ========================================================

    inner_cv = StratifiedKFold(
        n_splits=5,
        shuffle=True,
        random_state=42
    )

    rf_inner_oof = np.zeros(
        (len(X_outer_train), 3)
    )

    xgb_inner_oof = np.zeros(
        (len(X_outer_train), 3)
    )


    for inner_fold, (inner_train_idx, inner_valid_idx) in enumerate(
        inner_cv.split(
            X_outer_train,
            y_outer_train
        ),
        start=1
    ):

        print(
            f"  Inner Fold {inner_fold}/5"
        )

        X_inner_train = X_outer_train.iloc[
            inner_train_idx
        ]

        X_inner_valid = X_outer_train.iloc[
            inner_valid_idx
        ]

        y_inner_train = y_outer_train.iloc[
            inner_train_idx
        ]


        # ----------------------------------------------------
        # RANDOM FOREST INNER
        # ----------------------------------------------------

        rf_inner = RandomForestClassifier(
            **rf_params
        )

        rf_inner.fit(
            X_inner_train,
            y_inner_train
        )

        rf_inner_oof[
            inner_valid_idx
        ] = rf_inner.predict_proba(
            X_inner_valid
        )


        # ----------------------------------------------------
        # XGBOOST INNER + CSL
        # ----------------------------------------------------

        inner_sample_weight = compute_sample_weight(
            class_weight="balanced",
            y=y_inner_train
        )

        xgb_inner = XGBClassifier(
            **xgb_params
        )

        xgb_inner.fit(
            X_inner_train,
            y_inner_train,
            sample_weight=inner_sample_weight
        )

        xgb_inner_oof[
            inner_valid_idx
        ] = xgb_inner.predict_proba(
            X_inner_valid
        )


    # ========================================================
    # 7. MEMBUAT DATA UNTUK META-LEARNER
    # ========================================================

    meta_train_features = np.hstack(
        (
            rf_inner_oof,
            xgb_inner_oof
        )
    )


    # ========================================================
    # 8. MELATIH LOGISTIC REGRESSION
    # ========================================================

    meta_model = LogisticRegression(
        max_iter=2000,
        class_weight="balanced",
        random_state=42
    )

    meta_model.fit(
        meta_train_features,
        y_outer_train
    )


    # ========================================================
    # 9. MELATIH BASE MODEL PADA SELURUH OUTER TRAIN
    # ========================================================

    rf_outer = RandomForestClassifier(
        **rf_params
    )

    rf_outer.fit(
        X_outer_train,
        y_outer_train
    )


    outer_sample_weight = compute_sample_weight(
        class_weight="balanced",
        y=y_outer_train
    )

    xgb_outer = XGBClassifier(
        **xgb_params
    )

    xgb_outer.fit(
        X_outer_train,
        y_outer_train,
        sample_weight=outer_sample_weight
    )


    # ========================================================
    # 10. PREDIKSI OUTER VALIDATION
    # ========================================================

    rf_valid_proba = rf_outer.predict_proba(
        X_outer_valid
    )

    xgb_valid_proba = xgb_outer.predict_proba(
        X_outer_valid
    )

    meta_valid_features = np.hstack(
        (
            rf_valid_proba,
            xgb_valid_proba
        )
    )

    outer_pred = meta_model.predict(
        meta_valid_features
    )


    # Simpan ke posisi asli
    final_predictions[
        outer_valid_idx
    ] = outer_pred


    # ========================================================
    # 11. HASIL SEMENTARA PER FOLD
    # ========================================================

    fold_recalls = recall_score(
        y_outer_valid,
        outer_pred,
        labels=[0, 1, 2],
        average=None,
        zero_division=0
    )

    fold_macro_f1 = f1_score(
        y_outer_valid,
        outer_pred,
        average="macro",
        zero_division=0
    )

    print(
        f"\nRecall Prediabetes Fold {outer_fold}: "
        f"{fold_recalls[1]:.4f}"
    )

    print(
        f"Macro F1 Fold {outer_fold}: "
        f"{fold_macro_f1:.4f}"
    )


# ============================================================
# 12. EVALUASI SELURUH OUTER FOLD
# ============================================================

recalls = recall_score(
    y,
    final_predictions,
    labels=[0, 1, 2],
    average=None,
    zero_division=0
)

macro_f1 = f1_score(
    y,
    final_predictions,
    average="macro",
    zero_division=0
)

accuracy = accuracy_score(
    y,
    final_predictions
)

gmean = np.prod(
    recalls
) ** (1 / len(recalls))


# ============================================================
# 13. MENAMPILKAN HASIL FINAL CV
# ============================================================

print("\n")
print("=" * 75)
print("HASIL PROPER CROSS-VALIDATION STACKING")
print("=" * 75)

print(
    f"\nRecall Kelas 0 - Tidak Diabetes : "
    f"{recalls[0]:.4f}"
)

print(
    f"Recall Kelas 1 - Prediabetes    : "
    f"{recalls[1]:.4f}"
)

print(
    f"Recall Kelas 2 - Diabetes       : "
    f"{recalls[2]:.4f}"
)

print(
    f"\nMacro F1 : {macro_f1:.4f}"
)

print(
    f"G-Mean   : {gmean:.4f}"
)

print(
    f"Accuracy : {accuracy:.4f}"
)

print("\nConfusion Matrix:")

print(
    confusion_matrix(
        y,
        final_predictions
    )
)


print("\nCATATAN:")

print(
    "Evaluasi ini hanya menggunakan "
    "train_final.csv."
)

print(
    "test_final_locked.csv masih TIDAK digunakan."
)