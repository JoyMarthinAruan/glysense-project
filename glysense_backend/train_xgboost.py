import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.utils.class_weight import compute_sample_weight

from xgboost import XGBClassifier


# ============================================================
# 1. MEMBACA DATASET
# ============================================================

file_path = "data/diabetes_012_health_indicators_BRFSS2015.csv"

df = pd.read_csv(file_path)


# ============================================================
# 2. MEMISAHKAN FITUR DAN TARGET
# ============================================================

X = df.drop(columns=["Diabetes_012"])

y = df["Diabetes_012"].astype(int)


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
# 4. XGBOOST TANPA COST-SENSITIVE LEARNING
# ============================================================

xgb_baseline = XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    objective="multi:softprob",
    num_class=3,
    eval_metric="mlogloss",
    random_state=42,
    n_jobs=-1
)

xgb_baseline.fit(X_train, y_train)

y_pred_baseline = xgb_baseline.predict(X_test)


print("=" * 70)
print("XGBOOST TANPA COST-SENSITIVE LEARNING")
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
# 5. MEMBUAT SAMPLE WEIGHT UNTUK COST-SENSITIVE LEARNING
# ============================================================

sample_weights = compute_sample_weight(
    class_weight="balanced",
    y=y_train
)


# ============================================================
# 6. XGBOOST DENGAN COST-SENSITIVE LEARNING
# ============================================================

xgb_csl = XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    objective="multi:softprob",
    num_class=3,
    eval_metric="mlogloss",
    random_state=42,
    n_jobs=-1
)

xgb_csl.fit(
    X_train,
    y_train,
    sample_weight=sample_weights
)

y_pred_csl = xgb_csl.predict(X_test)


print("\n")
print("=" * 70)
print("XGBOOST DENGAN COST-SENSITIVE LEARNING")
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