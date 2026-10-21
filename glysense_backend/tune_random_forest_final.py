import pandas as pd

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import RandomizedSearchCV
from sklearn.metrics import f1_score, make_scorer


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
# 3. MEMBUAT SCORER MACRO F1
# ============================================================

macro_f1_scorer = make_scorer(
    f1_score,
    average="macro",
    zero_division=0
)


# ============================================================
# 4. MODEL DASAR RANDOM FOREST + CSL
# ============================================================

rf_model = RandomForestClassifier(
    class_weight="balanced",
    random_state=42,
    n_jobs=-1
)


# ============================================================
# 5. RUANG PENCARIAN HYPERPARAMETER
# ============================================================

param_dist = {
    "n_estimators": [100, 200, 300, 400, 500],
    "max_depth": [None, 5, 10, 15, 20, 30],
    "min_samples_split": [2, 5, 10, 15],
    "min_samples_leaf": [1, 2, 4, 8],
    "max_features": ["sqrt", "log2", None],
    "bootstrap": [True, False]
}


# ============================================================
# 6. RANDOM SEARCH
# ============================================================

random_search = RandomizedSearchCV(
    estimator=rf_model,
    param_distributions=param_dist,
    n_iter=20,
    scoring=macro_f1_scorer,
    cv=5,
    verbose=2,
    random_state=42,
    n_jobs=-1
)


# ============================================================
# 7. MENJALANKAN TUNING
# ============================================================

print("=" * 75)
print("RANDOM SEARCH FINAL RANDOM FOREST + CSL")
print("=" * 75)

random_search.fit(
    X_train,
    y_train
)


# ============================================================
# 8. MENAMPILKAN HASIL TERBAIK
# ============================================================

print("\n" + "=" * 75)
print("HASIL HYPERPARAMETER TERBAIK")
print("=" * 75)

print("\nBest Parameters:")
print(random_search.best_params_)

print("\nBest Macro F1 Cross-Validation:")
print(round(random_search.best_score_, 4))


# ============================================================
# 9. MENYIMPAN HASIL PARAMETER
# ============================================================

result_path = "artifacts/random_forest_best_params.txt"

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