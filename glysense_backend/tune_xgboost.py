import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import (
    recall_score,
    f1_score,
    accuracy_score,
    confusion_matrix,
    make_scorer
)
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
# 4. MEMBUAT SAMPLE WEIGHT UNTUK CSL
# ============================================================

sample_weights = compute_sample_weight(
    class_weight="balanced",
    y=y_train
)


# ============================================================
# 5. MEMBUAT SCORER MACRO F1
# ============================================================

macro_f1_scorer = make_scorer(
    f1_score,
    average="macro",
    zero_division=0
)


# ============================================================
# 6. MODEL DASAR XGBOOST
# ============================================================

xgb_model = XGBClassifier(
    objective="multi:softprob",
    num_class=3,
    eval_metric="mlogloss",
    random_state=42,
    n_jobs=-1
)


# ============================================================
# 7. PARAMETER YANG AKAN DICOBA
# ============================================================

param_dist = {
    "n_estimators": [100, 200, 300, 400],
    "max_depth": [3, 4, 5, 6, 8],
    "learning_rate": [0.01, 0.03, 0.05, 0.1, 0.2],
    "subsample": [0.7, 0.8, 0.9, 1.0],
    "colsample_bytree": [0.7, 0.8, 0.9, 1.0],
    "min_child_weight": [1, 3, 5, 7]
}


# ============================================================
# 8. RANDOM SEARCH
# ============================================================

random_search = RandomizedSearchCV(
    estimator=xgb_model,
    param_distributions=param_dist,
    n_iter=20,
    scoring=macro_f1_scorer,
    cv=5,
    verbose=2,
    random_state=42,
    n_jobs=-1
)


# ============================================================
# 9. MENJALANKAN TUNING
# ============================================================

print("=" * 75)
print("MEMULAI RANDOM SEARCH XGBOOST + COST-SENSITIVE LEARNING")
print("=" * 75)

random_search.fit(
    X_train,
    y_train,
    sample_weight=sample_weights
)


# ============================================================
# 10. HASIL PARAMETER TERBAIK
# ============================================================

print("\n" + "=" * 75)
print("HASIL HYPERPARAMETER TERBAIK")
print("=" * 75)

print("\nBest Parameters:")
print(random_search.best_params_)

print("\nBest Macro F1 Cross-Validation:")
print(round(random_search.best_score_, 4))


# ============================================================
# 11. MODEL TERBAIK
# ============================================================

best_model = random_search.best_estimator_


# ============================================================
# 12. PREDIKSI DATA TEST
# ============================================================

y_pred = best_model.predict(X_test)


# ============================================================
# 13. EVALUASI
# ============================================================

recalls = recall_score(
    y_test,
    y_pred,
    labels=[0, 1, 2],
    average=None,
    zero_division=0
)

macro_f1 = f1_score(
    y_test,
    y_pred,
    average="macro",
    zero_division=0
)

accuracy = accuracy_score(
    y_test,
    y_pred
)

gmean = np.prod(recalls) ** (1 / len(recalls))


print("\n" + "=" * 75)
print("HASIL EVALUASI MODEL XGBOOST TUNED + CSL")
print("=" * 75)

print(f"\nRecall Kelas 0 - Tidak Diabetes : {recalls[0]:.4f}")
print(f"Recall Kelas 1 - Prediabetes    : {recalls[1]:.4f}")
print(f"Recall Kelas 2 - Diabetes       : {recalls[2]:.4f}")

print(f"\nMacro F1 : {macro_f1:.4f}")
print(f"G-Mean   : {gmean:.4f}")
print(f"Accuracy : {accuracy:.4f}")

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))