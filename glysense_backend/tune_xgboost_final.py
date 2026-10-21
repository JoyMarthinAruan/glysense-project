import pandas as pd

from sklearn.model_selection import RandomizedSearchCV
from sklearn.metrics import f1_score, make_scorer
from sklearn.utils.class_weight import compute_sample_weight

from xgboost import XGBClassifier


# ============================================================
# 1. MEMBACA DATA TRAIN FINAL
# ============================================================

train_path = "data/final_split/train_final.csv"

df_train = pd.read_csv(train_path)


# ============================================================
# 2. MEMISAHKAN FITUR DAN TARGET
# ============================================================

X_train = df_train.drop(columns=["Diabetes_012"])

y_train = df_train["Diabetes_012"].astype(int)


# ============================================================
# 3. MEMBUAT SAMPLE WEIGHT UNTUK COST-SENSITIVE LEARNING
# ============================================================

sample_weights = compute_sample_weight(
    class_weight="balanced",
    y=y_train
)


# ============================================================
# 4. MEMBUAT SCORER MACRO F1
# ============================================================

macro_f1_scorer = make_scorer(
    f1_score,
    average="macro",
    zero_division=0
)


# ============================================================
# 5. MODEL DASAR XGBOOST
# ============================================================

xgb_model = XGBClassifier(
    objective="multi:softprob",
    num_class=3,
    eval_metric="mlogloss",
    random_state=42,
    n_jobs=-1
)


# ============================================================
# 6. RUANG PENCARIAN HYPERPARAMETER
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
# 7. RANDOM SEARCH
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
# 8. MENJALANKAN TUNING
# ============================================================

print("=" * 75)
print("RANDOM SEARCH FINAL XGBOOST + CSL")
print("=" * 75)

random_search.fit(
    X_train,
    y_train,
    sample_weight=sample_weights
)


# ============================================================
# 9. MENAMPILKAN HASIL TERBAIK
# ============================================================

print("\n" + "=" * 75)
print("HASIL HYPERPARAMETER TERBAIK")
print("=" * 75)

print("\nBest Parameters:")
print(random_search.best_params_)

print("\nBest Macro F1 Cross-Validation:")
print(round(random_search.best_score_, 4))


# ============================================================
# 10. MENYIMPAN HASIL PARAMETER KE FILE TEKS
# ============================================================

result_path = "artifacts/xgboost_best_params.txt"

with open(result_path, "w") as file:
    file.write("Best Parameters:\n")
    file.write(str(random_search.best_params_))

    file.write("\n\nBest Macro F1 Cross-Validation:\n")
    file.write(str(round(random_search.best_score_, 4)))


print("\nHasil tuning disimpan di:")
print(result_path)

print("\nCATATAN:")
print(
    "test_final_locked.csv TIDAK digunakan "
    "pada proses tuning ini."
)