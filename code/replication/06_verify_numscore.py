# ============================================================
# 06_verify_numscore.py - Bayesian Numscore Verification
# Dell & Querubin (2018)
# ============================================================
# Reimplements numscore.m in Python using scipy.io to read
# .mat files. Verifies Python output matches author-generated
# CSV files exactly.
#
# This eliminates the need for Matlab to reproduce the
# Bayesian scoring pipeline from scratch.
# ============================================================

import numpy as np
import pandas as pd
import scipy.io
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA_DIR = os.path.join(BASE_DIR, "data", "raw")

def load_rawdata(mat_file, n_raw):
    mat  = scipy.io.loadmat(mat_file, squeeze_me=True)
    key  = [k for k in mat.keys() if not k.startswith('_')][0]
    mod1 = mat[key]
    cols = [mod1[i].flatten().astype(float) for i in range(n_raw)]
    return np.column_stack(cols)

def load_score(mat_file, n_raw):
    """Load original letter grade scores from .mat file.
    score is at index n_raw+2 (after year and mth)."""
    mat  = scipy.io.loadmat(mat_file, squeeze_me=True)
    key  = [k for k in mat.keys() if not k.startswith('_')][0]
    mod1 = mat[key]
    # score is mod1{n_raw+3} in Matlab (1-based), so index n_raw+2 in Python
    score = mod1[n_raw + 2].flatten().astype(float)
    return score

def round_score(num_score):
    result = np.zeros(len(num_score))
    result[num_score >= 4.5] = 5
    result[(num_score >= 3.5) & (num_score < 4.5)] = 4
    result[(num_score >= 2.5) & (num_score < 3.5)] = 3
    result[(num_score >= 1.5) & (num_score < 2.5)] = 2
    result[num_score < 1.5] = 1
    return result

def load_condprob(csv_files):
    parts = [pd.read_csv(f, header=None).values for f in csv_files]
    return np.vstack(parts)

def bayes_update(rawdata, condprob):
    n  = rawdata.shape[0]
    pp = np.full((n, 5), 0.2)

    cp_ctr = 0
    for j in range(rawdata.shape[1]):
        q    = rawdata[:, j]
        mask = q != 999
        if not mask.any():
            continue

        qt   = q[mask]
        ppt  = pp[mask].copy()

        resp_ctr = int(qt.max())
        cp = condprob[cp_ctr: cp_ctr + resp_ctr, :]

        for i in range(1, resp_ctr + 1):
            rm = qt == i
            if not rm.any():
                continue
            denom = (ppt[rm] * cp[i-1]).sum(axis=1, keepdims=True)
            denom = np.where(denom == 0, 1e-300, denom)
            ppt[rm] = ppt[rm] * cp[i-1] / denom

        pp[mask] = ppt
        cp_ctr += resp_ctr

    return pp @ np.array([5, 4, 3, 2, 1], dtype=float)

# ============================================================
# Model configurations
# ============================================================
models = [
    {"name":"mod1a","mat":"mod1a.mat","n_raw":6,
     "conds":["12_VMB02_cond.csv","12_VQB02_cond.csv","12_VQB03_cond.csv",
              "12_VQB04_cond.csv","12_HMB01_cond.csv","12_HQC04_cond.csv"],
     "ref_csv":"mod1a_numscore.csv"},
    {"name":"mod1b","mat":"mod1b.mat","n_raw":8,
     "conds":["13_HMB01_cond.csv","13_HMB02_cond.csv","13_HMB03_cond.csv",
              "13_HMB04_cond.csv","13_HMD01_cond.csv","13_HMD02_cond.csv",
              "13_HMD05_cond.csv","13_VMB01_cond.csv"],
     "ref_csv":"mod1b_numscore.csv"},
    {"name":"mod1c","mat":"mod1c.mat","n_raw":13,
     "conds":["14_HMC01_cond.csv","14_HMC02_cond.csv","14_HMD01_cond.csv",
              "14_HMD02_cond.csv","14_HMD03_cond.csv","14_HMD04_cond.csv",
              "14_HMD06_cond.csv","14_HMD07_cond.csv","14_HQD05_cond.csv",
              "14_HQR05_cond.csv","14_VMB02_cond.csv","14_VMC02_cond.csv",
              "14_VQT06_cond.csv"],
     "ref_csv":"mod1c_numscore.csv"},
    {"name":"mod1d","mat":"mod1d.mat","n_raw":13,
     "conds":["15_HMD07_cond.csv","15_HQC01_cond.csv","15_HQC02_cond.csv",
              "15_HQC03_cond.csv","15_HQC04_cond.csv","15_HQC05_cond.csv",
              "15_HQE02_cond.csv","15_VQC01_cond.csv","15_VQC02_cond.csv",
              "15_VQC03_cond.csv","15_VQC04_cond.csv","15_VQC05_cond.csv",
              "15_VQC06_cond.csv"],
     "ref_csv":"mod1d_numscore.csv"},
    {"name":"mod1e","mat":"mod1e.mat","n_raw":8,
     "conds":["16_HMC03_cond.csv","16_HMD03_cond.csv","16_HMD04_cond.csv",
              "16_HMD05_cond.csv","16_HQC02_cond.csv","16_HQC03_cond.csv",
              "16_VMC01_cond.csv","16_VMC02_cond.csv"],
     "ref_csv":"mod1e_numscore.csv"},
    {"name":"mod1f71","mat":"mod1f71.mat","n_raw":9,
     "conds":["17_HQD01_cond.csv","17_HQD02_cond.csv","17_HQD03_cond.csv",
              "17_HQD04_cond.csv","17_VQD01_cond.csv","17_VQD02_cond.csv",
              "17_VQD04_cond.csv","17_VQD05_cond.csv","17_VQD06_cond.csv"],
     "ref_csv":"mod1f71_numscore.csv"},
    {"name":"mod1f70","mat":"mod1f70.mat","n_raw":10,
     "conds":["17_HQD01_cond.csv","17_HQD02_cond.csv","17_HQD03_cond.csv",
              "17_HQD04_cond.csv","17_HQE03_cond.csv","17_VQD01_cond.csv",
              "17_VQD02_cond.csv","17_VQD04_cond.csv","17_VQD05_cond.csv",
              "17_VQD06_cond.csv"],
     "ref_csv":"mod1f70_numscore.csv"},
    {"name":"mod1g","mat":"mod1g.mat","n_raw":3,
     "conds":["18_HMC04_cond.csv","18_HQC06_cond.csv","18_HQC07_cond.csv"],
     "ref_csv":"mod1g_numscore.csv"},
    {"name":"mod1h71","mat":"mod1h71.mat","n_raw":7,
     "conds":["19_HQB01_cond.csv","19_HQB02_cond.csv","19_HQB03_cond.csv",
              "19_HQF01_cond.csv","19_HQF02_cond.csv","19_VQB01_cond.csv",
              "19_VQB05_cond.csv"],
     "ref_csv":"mod1h71_numscore.csv"},
    {"name":"mod1h70","mat":"mod1h70.mat","n_raw":8,
     "conds":["19_HQB01_cond.csv","19_HQB02_cond.csv","19_HQB03_cond.csv",
              "19_HQE03_cond.csv","19_HQF01_cond.csv","19_HQF02_cond.csv",
              "19_VQB01_cond.csv","19_VQB05_cond.csv"],
     "ref_csv":"mod1h70_numscore.csv"},
    {"name":"mod1i","mat":"mod1i.mat","n_raw":6,
     "conds":["20_HMB05_cond.csv","20_HMB06_cond.csv","20_HMB07_cond.csv",
              "20_HMB08_cond.csv","20_HQB01_cond.csv","20_VQB01_cond.csv"],
     "ref_csv":"mod1i_numscore.csv"},
    {"name":"mod1j71","mat":"mod1j71.mat","n_raw":15,
     "conds":["21_HQE01_cond.csv","21_HQE02_cond.csv","21_HQE04_cond.csv",
              "21_HQF05_cond.csv","21_VQC05_cond.csv","21_VQC06_cond.csv",
              "21_VQD02_cond.csv","21_VQE01_cond.csv","21_VQE02_cond.csv",
              "21_VQE03_cond.csv","21_VQE04_cond.csv","21_VQE05_cond.csv",
              "21_VQE07_cond.csv","21_VQF05_cond.csv","21_VQF06_cond.csv"],
     "ref_csv":"mod1j_numscore71.csv"},
    {"name":"mod1j70","mat":"mod1j70.mat","n_raw":17,
     "conds":["21_HQE01_cond.csv","21_HQE02_cond.csv","21_HQE03_cond.csv",
              "21_HQE04_cond.csv","21_HQF05_cond.csv","21_VQC05_cond.csv",
              "21_VQC06_cond.csv","21_VQD02_cond.csv","21_VQE01_cond.csv",
              "21_VQE02_cond.csv","21_VQE03_cond.csv","21_VQE04_cond.csv",
              "21_VQE05_cond.csv","21_VQE07_cond.csv","21_VQF05_cond.csv",
              "21_VQF06_cond.csv","21_HQE05_cond.csv"],
     "ref_csv":"mod1j_numscore70.csv"},
    {"name":"mod1k","mat":"mod1k.mat","n_raw":8,
     "conds":["22_HQC06_cond.csv","22_HQF04_cond.csv","22_HQF05_cond.csv",
              "22_HQF06_cond.csv","22_HQN02_cond.csv","22_VQF05_cond.csv",
              "22_VQF06_cond.csv","22_VQF07_cond.csv"],
     "ref_csv":"mod1k_numscore.csv"},
    {"name":"mod1l","mat":"mod1l.mat","n_raw":7,
     "conds":["23_HQG01_cond.csv","23_HQG02_cond.csv","23_HQG03_cond.csv",
              "23_HQG04_cond.csv","23_VQG01_cond.csv","23_VQG02_cond.csv",
              "23_VQG03_cond.csv"],
     "ref_csv":"mod1l_numscore.csv"},
    {"name":"mod1m","mat":"mod1m.mat","n_raw":14,
     "conds":["24_HQB01_cond.csv","24_HQB03_cond.csv","24_HQC06_cond.csv",
              "24_HQF01_cond.csv","24_HQF02_cond.csv","24_HQF03_cond.csv",
              "24_HQF06_cond.csv","24_HQG04_cond.csv","24_HQN02_cond.csv",
              "24_VQB01_cond.csv","24_VQF01_cond.csv","24_VQF02_cond.csv",
              "24_VQF03_cond.csv","24_VQF04_cond.csv"],
     "ref_csv":"mod1m_numscore.csv"},
    {"name":"mod1n","mat":"mod1n.mat","n_raw":6,
     "conds":["25_HQP01_cond.csv","25_HQP02_cond.csv","25_VQP01_cond.csv",
              "25_VQP02_cond.csv","25_VQP03_cond.csv","25_VQP04_cond.csv"],
     "ref_csv":"mod1n_numscore.csv"},
    {"name":"mod1o","mat":"mod1o.mat","n_raw":8,
     "conds":["26_HQR01_cond.csv","26_HQR02_cond.csv","26_HQR03_cond.csv",
              "26_HQR04_cond.csv","26_HQR05_cond.csv","26_VQR01_cond.csv",
              "26_VQR02_cond.csv","26_VQR03_cond.csv"],
     "ref_csv":"mod1o_numscore.csv"},
    {"name":"mod1p","mat":"mod1p.mat","n_raw":5,
     "conds":["27_HQS01_cond.csv","27_HQS02_cond.csv","27_HQS03_cond.csv",
              "27_HQS04_cond.csv","27_HQS05_cond.csv"],
     "ref_csv":"mod1p_numscore.csv"},
    {"name":"mod1q71","mat":"mod1q71.mat","n_raw":7,
     "conds":["28_HQN01_cond.csv","28_HQN02_cond.csv","28_VQN01_cond.csv",
              "28_VQN02_cond.csv","28_VQN03_cond.csv","28_VQN04_cond.csv",
              "28_VQN05_cond.csv"],
     "ref_csv":"mod1q_numscore71.csv"},
    {"name":"mod1q70","mat":"mod1q70.mat","n_raw":8,
     "conds":["28_HQN01_cond.csv","28_HQN02_cond.csv","28_VQE06_cond.csv",
              "28_VQN01_cond.csv","28_VQN02_cond.csv","28_VQN03_cond.csv",
              "28_VQN04_cond.csv","28_VQN05_cond.csv"],
     "ref_csv":"mod1q_numscore70.csv"},
    {"name":"mod1r","mat":"mod1r.mat","n_raw":12,
     "conds":["29_HQB02_cond.csv","29_HQG03_cond.csv","29_HQL01_cond.csv",
              "29_HQL02_cond.csv","29_HQL03_cond.csv","29_HQS01_cond.csv",
              "29_VQB05_cond.csv","29_VQE07_cond.csv","29_VQL01_cond.csv",
              "29_VQL02_cond.csv","29_VQL03_cond.csv","29_VQT06_cond.csv"],
     "ref_csv":"mod1r_numscore.csv"},
    {"name":"mod1s","mat":"mod1s.mat","n_raw":6,
     "conds":["30_VQT01_cond.csv","30_VQT02_cond.csv","30_VQT03_cond.csv",
              "30_VQT04_cond.csv","30_VQT05_cond.csv","30_VQT06_cond.csv"],
     "ref_csv":"mod1s_numscore.csv"},
]

# ============================================================
# Run verification
# ============================================================
print("=" * 60)
print("Numscore Verification: Python vs Author Matlab Output")
print("=" * 60)

for m in models:
    try:
        # 验证1：Python vs 作者CSV（lookup table对比）
        ref      = pd.read_csv(os.path.join(DATA_DIR, m["ref_csv"]),
                               header=None).values
        ref_raw  = ref[:, :-1].astype(float)
        ref_scr  = ref[:, -1]

        cond_paths = [os.path.join(DATA_DIR, f) for f in m["conds"]]
        condprob   = load_condprob(cond_paths)

        py_scr    = bayes_update(ref_raw, condprob)
        max_diff  = np.abs(py_scr - ref_scr).max()
        status    = "PASS" if max_diff < 1e-4 else "FAIL"

        # 验证2：四舍五入后和美军原始字母评级比较
        rawdata    = load_rawdata(os.path.join(DATA_DIR, m["mat"]), m["n_raw"])
        orig_score = load_score(os.path.join(DATA_DIR, m["mat"]), m["n_raw"])
        full_scr   = bayes_update(rawdata, condprob)
        rounded    = round_score(full_scr)
        match_rate = (rounded == orig_score).mean()

        print(f"{m['name']}:")
        print(f"  CSV verification: max_diff={max_diff:.6f} → {status}")
        print(f"  Grade match rate: {match_rate:.4f} "
              f"({int(match_rate*len(orig_score))}/{len(orig_score)})")

    except Exception as e:
        print(f"{m['name']}: ERROR - {e}")

print("=" * 60)
