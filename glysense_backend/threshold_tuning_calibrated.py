import os
import numpy as np
import pandas as pd

from sklearn.metrics import (
    recall_score,
    f1_score,
    accuracy_score,
    confusion_matrix
)


# ============================================================
# 1. MEMBACA TARGET TRAIN FINAL
# ============================================================

train_path = "data/final_split/train_final.csv"

df = pd.read_csv(train_path)

y = df["Diabetes_012"].astype(int)


# ============================================================
# 2. MEMBACA PROBABILITAS CALIBRATED
# ============================================================

proba_path = "artifacts/stacking_oof_proba_calibrated.npy"

calibrated_proba = np.load(proba_path)


print("=" * 75)
print("THRESHOLD TUNING SETELAH PLATT SCALING")
print("=" * 75)

print("\nJumlah data target:")
print(len(y))

print("\nUkuran probabilitas:")
print(calibrated_proba.shape)


# ============================================================
# 3. FUNGSI MENGHITUNG METRIK
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
# 4. BASELINE SETELAH CALIBRATION
# ============================================================

baseline_pred = np.argmax(
    calibrated_proba,
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
print("BASELINE SETELAH PLATT SCALING")
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
# 5. MENCARI THRESHOLD PREDIABETES BARU
# ============================================================

# Setelah calibration, probabilitas kelas 1 bisa jauh lebih kecil.
# Maka pencarian threshold dibuat lebih rendah dan lebih rapat.

thresholds = np.arange(
    0.01,
    0.41,
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

    for probabilities in calibrated_proba:

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


    # Prioritas:
    # 1. G-Mean tertinggi
    # 2. Recall Prediabetes tertinggi
    # 3. Macro F1 tertinggi

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
# 6. MENAMPILKAN HASIL TERBAIK
# ============================================================

recalls, macro_f1, gmean, accuracy = best_metrics


print("\n")
print("=" * 75)
print("HASIL THRESHOLD TUNING SETELAH CALIBRATION")
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
# 7. MENYIMPAN THRESHOLD TERBAIK
# ============================================================

os.makedirs(
    "artifacts",
    exist_ok=True
)

threshold_path = (
    "artifacts/"
    "prediabetes_threshold_calibrated.txt"
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


print("\nThreshold calibrated disimpan di:")
print(
    threshold_path
)

print("\nCATATAN:")

print(
    "Threshold ini ditentukan dari probabilitas "
    "OOF hasil Platt Scaling."
)

print(
    "test_final_locked.csv masih TIDAK digunakan."
)