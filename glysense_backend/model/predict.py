from pathlib import Path

import joblib
import numpy as np
import pandas as pd


# ============================================================
# 1. MENENTUKAN LOKASI FOLDER BACKEND DAN ARTIFACTS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

ARTIFACTS_DIR = BASE_DIR / "artifacts"


# ============================================================
# 2. MEMUAT MODEL YANG SUDAH DILATIH
# ============================================================

rf_model = joblib.load(
    ARTIFACTS_DIR / "random_forest_final.joblib"
)

xgb_model = joblib.load(
    ARTIFACTS_DIR / "xgboost_final.joblib"
)

meta_model = joblib.load(
    ARTIFACTS_DIR / "meta_logistic_regression.joblib"
)

feature_names = joblib.load(
    ARTIFACTS_DIR / "feature_names.joblib"
)


# ============================================================
# 3. MEMUAT THRESHOLD PREDIABETES
# ============================================================

with open(
    ARTIFACTS_DIR / "prediabetes_threshold.txt",
    "r"
) as file:

    prediabetes_threshold = float(
        file.read().strip()
    )


# ============================================================
# 4. NAMA KELAS
# ============================================================

CLASS_NAMES = {
    0: "Tidak Diabetes",
    1: "Prediabetes",
    2: "Diabetes"
}


# ============================================================
# 5. FUNGSI PREDIKSI
# ============================================================

def predict_diabetes(data):

    # --------------------------------------------------------
    # Menyusun input sesuai urutan fitur saat training
    # --------------------------------------------------------

    input_df = pd.DataFrame(
        [[data[feature] for feature in feature_names]],
        columns=feature_names
    )


    # --------------------------------------------------------
    # Prediksi probabilitas dari Random Forest
    # --------------------------------------------------------

    rf_proba = rf_model.predict_proba(
        input_df
    )


    # --------------------------------------------------------
    # Prediksi probabilitas dari XGBoost
    # --------------------------------------------------------

    xgb_proba = xgb_model.predict_proba(
        input_df
    )


    # --------------------------------------------------------
    # Menggabungkan probabilitas RF dan XGBoost
    #
    # RF  : 3 probabilitas
    # XGB : 3 probabilitas
    #
    # Total = 6 nilai untuk Logistic Regression
    # --------------------------------------------------------

    stacking_features = np.hstack(
        (
            rf_proba,
            xgb_proba
        )
    )


    # --------------------------------------------------------
    # Probabilitas dari meta-learner Logistic Regression
    # --------------------------------------------------------

    stacking_proba = meta_model.predict_proba(
        stacking_features
    )[0]


    # --------------------------------------------------------
    # Mengambil probabilitas berdasarkan kelas model
    # --------------------------------------------------------

    probability_by_class = {}

    for class_value, probability in zip(
        meta_model.classes_,
        stacking_proba
    ):

        probability_by_class[int(class_value)] = float(
            probability
        )


    prob_0 = probability_by_class.get(
        0,
        0.0
    )

    prob_1 = probability_by_class.get(
        1,
        0.0
    )

    prob_2 = probability_by_class.get(
        2,
        0.0
    )


    # --------------------------------------------------------
    # THRESHOLD KHUSUS PREDIABETES
    # --------------------------------------------------------

    if prob_1 >= prediabetes_threshold:

        predicted_class = 1

    else:

        if prob_0 >= prob_2:

            predicted_class = 0

        else:

            predicted_class = 2


    # --------------------------------------------------------
    # HASIL YANG DIKIRIM KE FASTAPI / FLUTTER
    # --------------------------------------------------------

    result = {

        "predicted_class": predicted_class,

        "prediction": CLASS_NAMES[
            predicted_class
        ],

        "probability": {

            "tidak_diabetes": round(
                prob_0,
                4
            ),

            "prediabetes": round(
                prob_1,
                4
            ),

            "diabetes": round(
                prob_2,
                4
            )
        },

        "prediabetes_threshold": prediabetes_threshold,

        "message": (
            "Hasil ini merupakan skrining risiko awal "
            "dan bukan diagnosis medis."
        )
    }


    return result