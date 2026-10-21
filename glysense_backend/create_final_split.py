import os
import pandas as pd

from sklearn.model_selection import train_test_split


# ============================================================
# 1. MEMBACA DATASET ASLI
# ============================================================

file_path = "data/diabetes_012_health_indicators_BRFSS2015.csv"

df = pd.read_csv(file_path)


# ============================================================
# 2. MEMISAHKAN FITUR DAN TARGET
# ============================================================

X = df.drop(columns=["Diabetes_012"])

y = df["Diabetes_012"].astype(int)


# ============================================================
# 3. MEMBUAT TRAIN-TEST SPLIT FINAL
# ============================================================
# Random state ini digunakan sebagai pembagian FINAL penelitian.
# Test set setelah ini tidak digunakan sampai evaluasi akhir.

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=2026,
    stratify=y
)


# ============================================================
# 4. MENGGABUNGKAN FITUR DAN TARGET KEMBALI
# ============================================================

train_final = X_train.copy()
train_final["Diabetes_012"] = y_train

test_final = X_test.copy()
test_final["Diabetes_012"] = y_test


# ============================================================
# 5. MEMBUAT FOLDER DATA FINAL
# ============================================================

output_folder = "data/final_split"

os.makedirs(
    output_folder,
    exist_ok=True
)


# ============================================================
# 6. MENYIMPAN DATA TRAIN DAN TEST FINAL
# ============================================================

train_path = os.path.join(
    output_folder,
    "train_final.csv"
)

test_path = os.path.join(
    output_folder,
    "test_final_locked.csv"
)


train_final.to_csv(
    train_path,
    index=False
)

test_final.to_csv(
    test_path,
    index=False
)


# ============================================================
# 7. MENAMPILKAN INFORMASI TRAIN FINAL
# ============================================================

print("=" * 70)
print("FINAL TRAIN-TEST SPLIT BERHASIL DIBUAT")
print("=" * 70)

print("\nJumlah seluruh data:")
print(len(df))

print("\nJumlah data train final:")
print(len(train_final))

print("\nJumlah data test final:")
print(len(test_final))

print("\nDistribusi kelas TRAIN FINAL:")
print(
    train_final["Diabetes_012"]
    .value_counts()
    .sort_index()
)

print("\nPersentase kelas TRAIN FINAL:")
print(
    train_final["Diabetes_012"]
    .value_counts(normalize=True)
    .sort_index()
    * 100
)

print("\nFile train disimpan di:")
print(train_path)

print("\nFile test final disimpan di:")
print(test_path)

print("\nPERINGATAN:")
print(
    "test_final_locked.csv jangan digunakan untuk "
    "training, tuning, cross-validation, threshold tuning, "
    "atau calibration."
)           