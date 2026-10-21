import pandas as pd

file_path = "data/diabetes_012_health_indicators_BRFSS2015.csv"

df = pd.read_csv(file_path)

target_col = "Diabetes_012"

feature_cols = [
    col for col in df.columns
    if col != target_col
]

print("Jumlah data:")
print(df.shape)

print("\nJumlah fitur:")
print(len(feature_cols))

print("\nNama fitur:")
print(feature_cols)

print("\nMengecek apakah kombinasi 21 fitur yang sama memiliki target berbeda...")

target_variation = (
    df.groupby(feature_cols)[target_col]
    .nunique()
)

conflicting_patterns = target_variation[
    target_variation > 1
]

print("\nJumlah kombinasi fitur yang memiliki target berbeda:")
print(len(conflicting_patterns))

if len(conflicting_patterns) > 0:
    print("\nContoh kombinasi fitur yang memiliki target berbeda:")

    example_index = conflicting_patterns.index[0]

    if not isinstance(example_index, tuple):
        example_index = (example_index,)

    condition = pd.Series(True, index=df.index)

    for col, value in zip(feature_cols, example_index):
        condition &= df[col] == value

    example_rows = df[condition]

    print(example_rows)

    print("\nTarget yang muncul pada contoh tersebut:")
    print(example_rows[target_col].value_counts().sort_index())

else:
    print("\nTidak ditemukan kombinasi 21 fitur yang sama dengan target berbeda.")