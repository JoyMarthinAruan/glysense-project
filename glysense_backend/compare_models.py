import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    recall_score,
    f1_score,
    accuracy_score
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
# 4. FUNGSI G-MEAN MULTICLASS
# ============================================================

def multiclass_gmean(y_true, y_pred):
    recalls = recall_score(
        y_true,
        y_pred,
        labels=[0, 1, 2],
        average=None,
        zero_division=0
    )

    gmean = np.prod(recalls) ** (1 / len(recalls))

    return recalls, gmean


# ============================================================
# 5. FUNGSI EVALUASI MODEL
# ============================================================

def evaluate_model(model_name, y_true, y_pred):
    recalls, gmean = multiclass_gmean(
        y_true,
        y_pred
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

    print("\n" + "=" * 75)
    print(model_name)
    print("=" * 75)

    print("\nRecall per kelas:")
    print(f"Kelas 0 - Tidak Diabetes : {recalls[0]:.4f}")
    print(f"Kelas 1 - Prediabetes    : {recalls[1]:.4f}")
    print(f"Kelas 2 - Diabetes       : {recalls[2]:.4f}")

    print(f"\nMacro F1 : {macro_f1:.4f}")
    print(f"G-Mean   : {gmean:.4f}")
    print(f"Accuracy : {accuracy:.4f}")

    print("\nConfusion Matrix:")
    print(confusion_matrix(y_true, y_pred))

    return {
        "Model": model_name,
        "Recall_0": recalls[0],
        "Recall_1": recalls[1],
        "Recall_2": recalls[2],
        "Macro_F1": macro_f1,
        "G_Mean": gmean,
        "Accuracy": accuracy
    }


results = []


# ============================================================
# 6. RANDOM FOREST TANPA CSL
# ============================================================

rf_baseline = RandomForestClassifier(
    n_estimators=100,
    random_state=42,
    n_jobs=-1
)

rf_baseline.fit(
    X_train,
    y_train
)

rf_baseline_pred = rf_baseline.predict(
    X_test
)

results.append(
    evaluate_model(
        "Random Forest Tanpa CSL",
        y_test,
        rf_baseline_pred
    )
)


# ============================================================
# 7. RANDOM FOREST DENGAN CSL
# ============================================================

rf_csl = RandomForestClassifier(
    n_estimators=100,
    class_weight="balanced",
    random_state=42,
    n_jobs=-1
)

rf_csl.fit(
    X_train,
    y_train
)

rf_csl_pred = rf_csl.predict(
    X_test
)

results.append(
    evaluate_model(
        "Random Forest Dengan CSL",
        y_test,
        rf_csl_pred
    )
)


# ============================================================
# 8. XGBOOST TANPA CSL
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

xgb_baseline.fit(
    X_train,
    y_train
)

xgb_baseline_pred = xgb_baseline.predict(
    X_test
)

results.append(
    evaluate_model(
        "XGBoost Tanpa CSL",
        y_test,
        xgb_baseline_pred
    )
)


# ============================================================
# 9. XGBOOST DENGAN CSL
# ============================================================

sample_weights = compute_sample_weight(
    class_weight="balanced",
    y=y_train
)

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

xgb_csl_pred = xgb_csl.predict(
    X_test
)

results.append(
    evaluate_model(
        "XGBoost Dengan CSL",
        y_test,
        xgb_csl_pred
    )
)


# ============================================================
# 10. TABEL PERBANDINGAN
# ============================================================

results_df = pd.DataFrame(results)

print("\n")
print("=" * 100)
print("RINGKASAN PERBANDINGAN MODEL")
print("=" * 100)

print(
    results_df.round(4).to_string(
        index=False
    )
)