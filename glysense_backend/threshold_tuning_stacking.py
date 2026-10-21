import os
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
print("THRESHOLD TUNING STACKING - KELAS PREDIABETES")
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


# Menyimpan probabilitas Stacking untuk seluruh data train
stacking_oof_proba = np.zeros(
    (len(X), 3)
)


# ============================================================
# 5. MEMBUAT PROBABILITAS OOF STACKING
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
    # 6. INNER CV UNTUK OOF BASE LEARNER
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
    # 7. MEMBUAT DATA META-LEARNER
    # ========================================================

    meta_train_features = np.hstack(
        (
            rf_inner_oof,
            xgb_inner_oof
        )
    )


    # ========================================================
    # 8. MELATIH META-LEARNER
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
    # 9. MELATIH BASE MODEL PADA OUTER TRAIN
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
    # 10. PROBABILITAS OUTER VALIDATION
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

    stacking_oof_proba[
        outer_valid_idx
    ] = meta_model.predict_proba(
        meta_valid_features
    )


print("\nProbabilitas OOF Stacking selesai dibuat.")


# ============================================================
# 11. FUNGSI MENGHITUNG METRIK
# ============================================================

def calculate_metrics(y_true, y_pred):

    recalls = recall_score(
        y_true,
        y_pred,
        labels=[0, 1, 2],
        average=None,
        zero_division=0
    )

    macro_f1 = f1_score(
        y_true,
        y_pred,
        average="macro",
        zero_division=0
    )

    accuracy = accuracy_score(
        y_true,
        y_pred
    )

    gmean = np.prod(
        recalls
    ) ** (1 / len(recalls))

    return recalls, macro_f1, gmean, accuracy


# ============================================================
# 12. BASELINE SEBELUM THRESHOLD TUNING
# ============================================================

baseline_pred = np.argmax(
    stacking_oof_proba,
    axis=1
)

baseline_recalls, baseline_macro_f1, baseline_gmean, baseline_accuracy = (
    calculate_metrics(
        y,
        baseline_pred
    )
)


print("\n")
print("=" * 75)
print("SEBELUM THRESHOLD TUNING")
print("=" * 75)

print(
    f"\nRecall Kelas 0 - Tidak Diabetes : "
    f"{baseline_recalls[0]:.4f}"
)

print(
    f"Recall Kelas 1 - Prediabetes    : "
    f"{baseline_recalls[1]:.4f}"
)

print(
    f"Recall Kelas 2 - Diabetes       : "
    f"{baseline_recalls[2]:.4f}"
)

print(
    f"\nMacro F1 : {baseline_macro_f1:.4f}"
)

print(
    f"G-Mean   : {baseline_gmean:.4f}"
)

print(
    f"Accuracy : {baseline_accuracy:.4f}"
)


# ============================================================
# 13. MENCARI THRESHOLD PREDIABETES
# ============================================================

thresholds = np.arange(
    0.05,
    0.61,
    0.01
)

best_threshold = None
best_gmean = -1
best_recall_prediabetes = -1
best_macro_f1 = -1

best_predictions = None
best_metrics = None


for threshold in thresholds:

    predictions = []

    for probabilities in stacking_oof_proba:

        # Jika probabilitas prediabetes melewati threshold,
        # klasifikasikan sebagai prediabetes.
        if probabilities[1] >= threshold:

            predicted_class = 1

        else:

            # Jika tidak, pilih antara kelas 0 dan 2
            # berdasarkan probabilitas terbesar.

            if probabilities[0] >= probabilities[2]:

                predicted_class = 0

            else:

                predicted_class = 2

        predictions.append(
            predicted_class
        )


    predictions = np.array(
        predictions
    )


    recalls, macro_f1, gmean, accuracy = calculate_metrics(
        y,
        predictions
    )


    # Pilihan utama berdasarkan G-Mean.
    # Jika G-Mean sama, utamakan Recall Prediabetes.
    # Jika masih sama, lihat Macro F1.

    current_score = (
        gmean,
        recalls[1],
        macro_f1
    )

    best_score = (
        best_gmean,
        best_recall_prediabetes,
        best_macro_f1
    )


    if current_score > best_score:

        best_threshold = threshold

        best_gmean = gmean

        best_recall_prediabetes = recalls[1]

        best_macro_f1 = macro_f1

        best_predictions = predictions

        best_metrics = (
            recalls,
            macro_f1,
            gmean,
            accuracy
        )


# ============================================================
# 14. HASIL THRESHOLD TERBAIK
# ============================================================

recalls, macro_f1, gmean, accuracy = best_metrics


print("\n")
print("=" * 75)
print("HASIL THRESHOLD TUNING")
print("=" * 75)

print(
    f"\nThreshold Prediabetes terbaik : "
    f"{best_threshold:.2f}"
)

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
        best_predictions
    )
)


# ============================================================
# 15. MENYIMPAN THRESHOLD TERBAIK
# ============================================================

os.makedirs(
    "artifacts",
    exist_ok=True
)

threshold_path = (
    "artifacts/"
    "prediabetes_threshold.txt"
)

with open(
    threshold_path,
    "w"
) as file:

    file.write(
        str(
            round(
                float(best_threshold),
                2
            )
        )
    )


print("\nThreshold disimpan di:")
print(
    threshold_path
)


print("\nCATATAN:")

print(
    "Threshold ditentukan hanya dari "
    "train_final.csv menggunakan OOF predictions."
)

print(
    "test_final_locked.csv masih TIDAK digunakan."
)