import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix


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
# 4. RANDOM FOREST TANPA COST-SENSITIVE LEARNING
# ============================================================

rf_baseline = RandomForestClassifier(
    n_estimators=100,
    random_state=42,
    n_jobs=-1
)

rf_baseline.fit(X_train, y_train)

y_pred_baseline = rf_baseline.predict(X_test)


print("=" * 70)
print("RANDOM FOREST TANPA COST-SENSITIVE LEARNING")
print("=" * 70)

print("\nClassification Report:")
print(
    classification_report(
        y_test,
        y_pred_baseline,
        digits=4,
        zero_division=0
    )
)

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred_baseline))


# ============================================================
# 5. RANDOM FOREST DENGAN COST-SENSITIVE LEARNING
# ============================================================

rf_csl = RandomForestClassifier(
    n_estimators=100,
    class_weight="balanced",
    random_state=42,
    n_jobs=-1
)

rf_csl.fit(X_train, y_train)

y_pred_csl = rf_csl.predict(X_test)


print("\n")
print("=" * 70)
print("RANDOM FOREST DENGAN COST-SENSITIVE LEARNING")
print("=" * 70)

print("\nClassification Report:")
print(
    classification_report(
        y_test,
        y_pred_csl,
        digits=4,
        zero_division=0
    )
)

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred_csl))