# ============================================================
# 05_figures_r.py - R Figure Replication in Python
# Dell & Querubin (2018)
# ============================================================
# Replicates dynamics_balanced.R and vndba.R using Python.
# Original R scripts used hardcoded Dropbox paths.
# Inputs:  output/results/figures/bombing_balanced_dynamics.csv
#          output/results/figures/vndba_rf.csv
# Outputs: output/results/figures/dynamics_balance_fs.pdf
#          output/results/figures/vndba_rf.pdf
# ============================================================

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import os

BASE    = os.path.dirname(os.path.dirname(os.path.dirname(
          os.path.abspath(__file__))))
FIG_DIR = os.path.join(BASE, "output", "results", "figures")

# ============================================================
# Figure 1: Dynamic first stage
# Shows bombing effect by quarter relative to threshold crossing
# Pre-period (t<0): placebo; Post-period (t>0): treatment effect
# ============================================================
df = pd.read_csv(os.path.join(FIG_DIR, "bombing_balanced_dynamics.csv"))
df = df[df["depvar"] == "fr_strikes_mean"]
df = df[(df["period"] >= -2) & (df["period"] <= 8)]
df["color"] = df["period"].apply(
    lambda x: "#000000" if x <= 0 else "#0D4F8B")
df["label"] = df["period"].apply(
    lambda x: "Pre-period" if x <= 0 else "Post-period")

fig, ax = plt.subplots(figsize=(7, 4))

for _, row in df.iterrows():
    ax.plot([row["period"], row["period"]],
            [row["cn5"], row["cp5"]],
            color=row["color"], linewidth=0.65)
    ax.scatter(row["period"], row["coeff"],
               color=row["color"], s=40, zorder=5)

ax.axhline(0, color="black", linewidth=0.8)
ax.set_xticks(range(-2, 9))
ax.set_xlabel("Quarter Relative to Threshold Crossing")
ax.set_ylabel("")
ax.set_title("")

pre_patch  = mpatches.Patch(color="#000000", label="Pre-period")
post_patch = mpatches.Patch(color="#0D4F8B", label="Post-period")
ax.legend(handles=[pre_patch, post_patch], frameon=True)

plt.style.use("seaborn-v0_8-whitegrid")
plt.tight_layout()
plt.savefig(os.path.join(FIG_DIR, "dynamics_balance_fs.pdf"),
            dpi=150, bbox_inches="tight")
plt.close()
print("Saved: dynamics_balance_fs.pdf")

# ============================================================
# Figure 2: VNDBA pre-treatment VC attacks
# Shows RDD coefficient on VC-initiated attacks by quarter
# 1964Q2 through 1969Q4 (before HES scoring began)
# Flat/insignificant = no pre-treatment differences across threshold
# ============================================================
df2 = pd.read_csv(os.path.join(FIG_DIR, "vndba_rf.csv"))
df2 = df2[df2["depvar"] == "en_init"]

fig, ax = plt.subplots(figsize=(7, 4))

for _, row in df2.iterrows():
    ax.plot([row["period"], row["period"]],
            [row["cn5"], row["cp5"]],
            color="black", linewidth=0.65)
    ax.plot([row["period"], row["period"]],
            [row["cn5"], row["cp5"]],
            color="black", linewidth=1.35)
    ax.scatter(row["period"], row["coeff"],
               color="black", s=40, zorder=5)

ax.axhline(0, color="black", linewidth=0.8)

# x-axis: label by year
tick_positions = [1, 4, 8, 12, 16, 20]
tick_labels    = ["1964", "1965", "1966", "1967", "1968", "1969"]
ax.set_xticks(tick_positions)
ax.set_xticklabels(tick_labels)
ax.set_ylabel("VC Initiated Attacks")
ax.set_title("")

plt.style.use("seaborn-v0_8-whitegrid")
plt.tight_layout()
plt.savefig(os.path.join(FIG_DIR, "vndba_rf.pdf"),
            dpi=150, bbox_inches="tight")
plt.close()
print("Saved: vndba_rf.pdf")