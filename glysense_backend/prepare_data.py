import pandas as pd

from sklearn.model_selection import train_test_split


# ============================================================
# 1. MEMBACA DATASET
# ============================================================

file_path = "data/diabetes_012_health_indicators_BRFSS2015.csv"

df = pd.read_csv(file_path)


# ============================================================
# 2. MEMISAHKAN FITUR DAN TARGET
# ============================================================

X = df.drop(columns=["Diabetes_012"])

y = df["Diabetes_012"]


print("Jumlah data keseluruhan:")
print(df.shape)

print("\nJumlah fitur:")
print(X.shape[1])

print("\nTarget:")
print("Diabetes_012")


# ============================================================
# 3. TRAIN-TEST SPLIT 80:20 DENGAN STRATIFIKASI
# ============================================================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)


# ============================================================
# 4. MENAMPILKAN HASIL PEMBAGIAN DATA
# ============================================================

print("\nUkuran data training:")
print(X_train.shape)

print("\nUkuran data testing:")
print(X_test.shape)


print("\nDistribusi kelas data training:")
print(y_train.value_counts().sort_index())

print("\nPersentase kelas data training:")
print(
    y_train.value_counts(normalize=True)
    .sort_index()
    * 100
)


print("\nDistribusi kelas data testing:")
print(y_test.value_counts().sort_index())

print("\nPersentase kelas data testing:")
print(
    y_test.value_counts(normalize=True)
    .sort_index()
    * 100
)