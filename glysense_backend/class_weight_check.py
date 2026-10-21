import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.utils.class_weight import compute_class_weight


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


# ============================================================
# 3. TRAIN-TEST SPLIT
# ============================================================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)


# ============================================================
# 4. MENGHITUNG CLASS WEIGHT
# ============================================================

classes = np.unique(y_train)

weights = compute_class_weight(
    class_weight="balanced",
    classes=classes,
    y=y_train
)


class_weights = dict(zip(classes, weights))


# ============================================================
# 5. MENAMPILKAN HASIL
# ============================================================

print("Jumlah data training per kelas:")
print(y_train.value_counts().sort_index())

print("\nClass weight:")
for kelas, bobot in class_weights.items():
    print(f"Kelas {int(kelas)} = {bobot:.4f}")