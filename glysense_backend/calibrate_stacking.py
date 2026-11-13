import os
import joblib
import numpy as np
import pandas as pd

from sklearn.model_selection import StratifiedKFold
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.calibration import CalibratedClassifierCV
from sklearn.metrics import (
    recall_score,
    f1_score,
    accuracy_score,
    confusion_matrix,
    log_loss
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
print("PROBABILITY CALIBRATION STACKING")
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


# Menyimpan probabilitas sebelum dan sesudah calibration
uncalibrated_oof_proba = np.zeros(
    (len(X), 3)
)

calibrated_oof_proba = np.zeros(
    (len(X), 3)
)


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

    X_outer_train = X.iloc[
        outer_train_idx
    ].reset_index(drop=True)

    y_outer_train = y.iloc[
        outer_train_idx
    ].reset_index(drop=True)

    X_outer_valid = X.iloc[
        outer_valid_idx
    ].reset_index(drop=True)


    # ========================================================
    # 6. INNER CV UNTUK MEMBUAT OOF BASE LEARNER
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
        # RANDOM FOREST
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
        # XGBOOST + CSL
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
    # 7. DATA UNTUK META-LEARNER
    # ========================================================

    meta_train_features = np.hstack(
        (
            rf_inner_oof,
            xgb_inner_oof
        )
    )


    # ========================================================
    # 8. META-LEARNER TANPA CALIBRATION
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
    # 9. META-LEARNER DENGAN PLATT SCALING
    # ========================================================

    calibrated_meta_model = CalibratedClassifierCV(
        estimator=LogisticRegression(
            max_iter=2000,
            class_weight="balanced",
            random_state=42
        ),
        method="sigmoid",
        cv=5
    )

    calibrated_meta_model.fit(
        meta_train_features,
        y_outer_train
    )


    # ========================================================
    # 10. MELATIH BASE MODEL PADA OUTER TRAIN
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
    # 11. PROBABILITAS OUTER VALIDATION
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


    # Sebelum calibration
    uncalibrated_oof_proba[
        outer_valid_idx
    ] = meta_model.predict_proba(
        meta_valid_features
    )


    # Sesudah calibration
    calibrated_oof_proba[
        outer_valid_idx
    ] = calibrated_meta_model.predict_proba(
        meta_valid_features
    )


print("\nProbabilitas OOF selesai dibuat.")


# ============================================================
# 12. FUNGSI EVALUASI
# ============================================================

def evaluate_probabilities(
    y_true,
    probabilities,
    label_name
):

    predictions = np.argmax(
        probabilities,
        axis=1
    )

    recalls = recall_score(
        y_true,
        predictions,
        labels=[0, 1, 2],
        average=None,
        zero_division=0
    )

    macro_f1 = f1_score(
        y_true,
        predictions,
        average="macro",
        zero_division=0
    )

    accuracy = accuracy_score(
        y_true,
        predictions
    )

    gmean = np.prod(
        recalls
    ) ** (1 / len(recalls))

    loss = log_loss(
        y_true,
        probabilities,
        labels=[0, 1, 2]
    )


    print("\n" + "=" * 75)
    print(label_name)
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

    print(
        f"Log Loss : {loss:.4f}"
    )

    print("\nConfusion Matrix:")

    print(
        confusion_matrix(
            y_true,
            predictions
        )
    )


# ============================================================
# 13. EVALUASI SEBELUM CALIBRATION
# ============================================================

evaluate_probabilities(
    y,
    uncalibrated_oof_proba,
    "SEBELUM PROBABILITY CALIBRATION"
)


# ============================================================
# 14. EVALUASI SETELAH PLATT SCALING
# ============================================================

evaluate_probabilities(
    y,
    calibrated_oof_proba,
    "SETELAH PLATT SCALING"
)


# ============================================================
# 15. MENYIMPAN PROBABILITAS CALIBRATED
# ============================================================

os.makedirs(
    "artifacts",
    exist_ok=True
)

np.save(
    "artifacts/stacking_oof_proba_calibrated.npy",
    calibrated_oof_proba
)

np.save(
    "artifacts/stacking_oof_proba_uncalibrated.npy",
    uncalibrated_oof_proba
)


print("\n" + "=" * 75)
print("PROBABILITAS BERHASIL DISIMPAN")
print("=" * 75)

print(
    "\nartifacts/"
    "stacking_oof_proba_calibrated.npy"
)

print(
    "artifacts/"
    "stacking_oof_proba_uncalibrated.npy"
)


print("\nCATATAN:")

print(
    "Calibration dilakukan hanya menggunakan "
    "train_final.csv."
)

print(
    "test_final_locked.csv masih TIDAK digunakan."
)