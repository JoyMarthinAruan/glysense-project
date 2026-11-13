"""
cek_duplikat.py  --  PEMERIKSAAN SAJA (read-only).
Tidak mengubah / menimpa file apa pun. Hanya membaca CSV dan mencetak laporan.

Cara pakai (dari folder glysense_backend, venv aktif):
    python cek_duplikat.py                      -> otomatis cari satu CSV di folder data\
    python cek_duplikat.py data\nama_file.csv   -> tentukan file sendiri
    python cek_duplikat.py data\nama_file.csv --split
        (opsional) hitung berapa baris yang sama persis antara train_final dan
        test_final_locked. HANYA menghitung baris kembar, tanpa model/metrik.
Bisa juga ditempel utuh ke satu sel notebook.
"""
import sys, os, glob
import pandas as pd

if os.path.basename(os.getcwd()) == "notebooks":
    os.chdir("..")

args = sys.argv[1:]
path = next((a for a in args if a.lower().endswith(".csv")), None)
cek_split = "--split" in args

if path is None:
    cand = sorted(glob.glob(os.path.join("data", "*.csv")))
    if len(cand) == 1:
        path = cand[0]
    else:
        print("Tidak bisa memilih otomatis. CSV di folder data:", cand)
        print("Jalankan lagi dengan menyebut file-nya, contoh: python cek_duplikat.py data\\nama.csv")
        sys.exit(1)

df = pd.read_csv(path)
target = "Diabetes_012" if "Diabetes_012" in df.columns else df.columns[0]
feats = [c for c in df.columns if c != target]
print("=" * 70)
print("FILE      :", path)
print("BENTUK    :", df.shape, "| kolom target:", target, "| jumlah fitur:", len(feats))
print("NILAI HILANG (total):", int(df.isna().sum().sum()))
print("Sebaran kelas:\n", df[target].value_counts().sort_index().to_string())

# ---------------------------------------------------------------- 1. duplikat persis
print("\n" + "=" * 70)
print("1) DUPLIKAT PERSIS (semua kolom sama, termasuk label)")
dup_extra = df.duplicated()                     # baris kelebihan (salinan ke-2 dst)
dup_all = df.duplicated(keep=False)             # semua baris yang punya kembaran
print("   Baris kelebihan (salinan) :", int(dup_extra.sum()), f"({dup_extra.mean()*100:.2f}% dari data)")
print("   Baris yang punya kembaran :", int(dup_all.sum()))
gsize = df[dup_all].groupby(list(df.columns)).size()
if len(gsize):
    print("   Jumlah pola berulang      :", len(gsize), "| ukuran kelompok terbesar:", int(gsize.max()))
print("   Salinan per kelas:\n", df[dup_extra][target].value_counts().sort_index().to_string())

# ---------------------------------------------------------------- 2. fitur sama, label beda
print("\n" + "=" * 70)
print("2) FITUR SAMA PERSIS, TAPI LABEL BERBEDA (konflik label)")
g = df.groupby(feats)[target].agg(["size", "nunique"]).reset_index()
rep = g[g["size"] > 1]
conf = rep[rep["nunique"] > 1]
print("   Pola fitur yang muncul >1 kali      :", len(rep))
print("   - labelnya semua sama (duplikat)    :", int((rep["nunique"] == 1).sum()))
print("   - labelnya berbeda (KONFLIK)        :", len(conf))
print("   Baris yang terlibat konflik         :", int(conf["size"].sum()))
if len(conf):
    m = df.merge(conf[feats], on=feats, how="inner")
    print("   Baris konflik per kelas:\n", m[target].value_counts().sort_index().to_string())

# ---------------------------------------------------------------- 3. beda di kolom mana?
print("\n" + "=" * 70)
print("3) 'MIRIP TAPI BEDA': jika SATU kolom diabaikan, berapa baris jadi kembar?")
print("   (dibanding duplikat persis di atas; kenaikan besar = kolom itu pembeda utamanya)")
base = int(dup_extra.sum())
rows = []
for c in df.columns:
    others = [x for x in df.columns if x != c]
    rows.append((c, int(df.duplicated(subset=others).sum())))
res = pd.DataFrame(rows, columns=["kolom_diabaikan", "baris_kembar"]).sort_values("baris_kembar", ascending=False)
res["tambahan_vs_persis"] = res["baris_kembar"] - base
print(res.head(10).to_string(index=False))

# ---------------------------------------------------------------- 4. contoh kelompok terbesar
print("\n" + "=" * 70)
print("4) CONTOH 3 KELOMPOK DUPLIKAT TERBESAR")
if len(gsize):
    top = gsize.sort_values(ascending=False).head(3)
    for k, (idx, n) in enumerate(top.items(), 1):
        vals = dict(zip(df.columns, idx))
        print(f"   #{k}: muncul {n}x ->", vals)

# ---------------------------------------------------------------- 5. (opsional) bocor antar split
if cek_split:
    print("\n" + "=" * 70)
    print("5) BARIS KEMBAR ANTARA train_final DAN test_final_locked (hanya menghitung)")
    tr = pd.read_csv(os.path.join("data", "final_split", "train_final.csv"))
    te = pd.read_csv(os.path.join("data", "final_split", "test_final_locked.csv"))
    ov = te.merge(tr.drop_duplicates(), on=list(te.columns), how="inner")
    print("   Baris test yang punya kembaran persis di train:", len(ov),
          f"({len(ov)/len(te)*100:.2f}% dari test)")
    ovf = te.merge(tr[feats].drop_duplicates(), on=feats, how="inner")
    print("   Baris test yang fiturnya sama dgn salah satu baris train:", len(ovf),
          f"({len(ovf)/len(te)*100:.2f}% dari test)")
print("\nSelesai. Tidak ada file yang diubah.")