# Replication: Dell & Querubin (2018)

**"Nation Building Through Foreign Intervention: Evidence from Discontinuities in Military Strategies"**  
Melissa Dell and Pablo Querubin  
*Quarterly Journal of Economics*, 133(2): 701–764

---

## Overview

This repository replicates the main results of Dell & Querubin (2018), which uses regression discontinuity designs to study the causal effects of US military strategy in Vietnam. The paper exploits two sources of quasi-random variation:

1. **HES scoring thresholds** — The Hamlet Evaluation System (HES) used a mechanical algorithm to assign security grades (E through A) to Vietnamese hamlets. Hamlets just below a scoring threshold received more US bombing; those just above received more nation-building (governance and development programs). The paper uses this discontinuity to estimate the causal effects of bombing vs. nation-building on long-run outcomes.

2. **Marine/Army boundary** — The geographic boundary between US Marine Corps and Army operational zones in I Corps is used as a second discontinuity to compare the two services' nation-building strategies.

---

## Data

Original data are from the Harvard Dataverse:  
[https://doi.org/10.7910/DVN/ZCQIMI](https://doi.org/10.7910/DVN/ZCQIMI)

Download the Dataverse files and place them in `data/raw/`. Several files are pre-generated and require Matlab or R to reproduce from scratch — see `replication_notes.md` for details. These pre-generated files are treated as raw inputs by the Stata pipeline.

---

## Requirements

**Stata 17** with the following packages:
```stata
ssc install outreg
ssc install outreg2
ssc install rdrobust
ssc install rddensity
ssc install coefplot
```

**Python 3.11** with:
```
pip install numpy pandas scipy matplotlib
```

**R** is not required. The two R figure scripts from the original package (`dynamics_balanced.R`, `vndba.R`) have been replaced by `code/replication/05_figures_r.py`.

**Matlab** is not required. The Bayesian numscore algorithm (`numscore.m`) has been reimplemented and verified in Python (`code/replication/06_verify_numscore.py`).

---

## How to Run

### Step 1 — Stata pipeline

Open Stata, then:

```
File → Do → code/replication/pipeline.do
```

Do **not** run from the command line. `pipeline.do` uses `c(pwd)` to resolve paths dynamically, which requires the Stata GUI to set the working directory correctly.

Runtime: approximately 2–3 hours.

### Step 2 — Python figures

```bash
python code/replication/05_figures_r.py
```

Generates `dynamics_balance_fs.pdf` and `vndba_rf.pdf` in `output/results/figures/`.

### Step 3 — Numscore verification (optional)

```bash
python code/replication/06_verify_numscore.py
```

Verifies that the Python reimplementation of the Bayesian scoring algorithm matches the author's Matlab output across all 23 HES modules. Expected output: 23/23 PASS.

---

## Repository Structure

```
.
├── pipeline.do                  ← not here; see code/replication/
├── README.md
├── replication_notes.md
├── code/
│   ├── original/                ← all original do-files, unmodified
│   └── replication/
│       ├── pipeline.do          ← entry point (run this)
│       ├── 00_header.do         ← global path definitions
│       ├── 01_build_rd.do       ← RDD dataset construction
│       ├── 03_tables.do         ← Tables 1–11
│       ├── 04_figures.do        ← all Stata figures
│       ├── 05_figures_r.py      ← Python replacement for R figures
│       ├── 06_verify_numscore.py← Bayesian scoring verification
│       ├── 10_rd_reg.do         ← IV regression subroutine
│       ├── 12_balance_panel.do  ← balanced panel subroutine
│       ├── 13_firstclose.do     ← main dataset builder
│       ├── 14_marines_hamlet.do ← Marines hamlet dataset
│       ├── 15_marines_paas.do   ← PAAS survey dataset
│       ├── 16_plac69.do         ← 1969 placebo
│       ├── 17_plac_fs.do        ← first stage placebo
│       ├── 18_plac_fs0.do       ← contemporaneous placebo
│       └── 19_plac_out.do       ← outcome placebo
├── data/
│   ├── raw/                     ← Dataverse data files (not tracked by git)
│   └── processed/               ← empty
└── output/
    └── results/
        ├── tables/              ← LaTeX table fragments
        └── figures/             ← PDF figures
```

---

## Replication Results

All tables and figures replicate the original paper's results.

| Output | Status |
|--------|--------|
| Table 1 (balance) | ✓ |
| Table 2 (first stage: bombing) | ✓ |
| Table 3 (friendly forces) | ✓ |
| Table 4 (security outcomes, IV) | ✓ |
| Table 5 (military outcomes, IV) | ✓ |
| Table 6 (economic outcomes, IV) | ✓ |
| Table 7 (governance outcomes, IV) | ✓ |
| Table 8 (civic society outcomes, IV) | ✓ |
| Table 9 (Marines balance) | ✓ |
| Table 10 (Marines outcomes) | ✓ |
| Table 11 (PAAS attitudes) | ✓ |
| RD plots | ✓ |
| McCrary density test | ✓ |
| VNDBA pre-treatment plot | ✓ |
| Dynamic first stage | ✓ |

---

## Python Contributions

### Bayesian numscore verification

The original paper uses a Matlab script (`numscore.m`) to convert
HES survey responses into continuous security scores via a Bayesian
classifier. The algorithm applies sequential Bayesian updates across
survey questions, using conditional probability matrices estimated
from historical HES data.

`06_verify_numscore.py` reimplements this algorithm in Python and
verifies it against the author's pre-generated output across all
23 HES modules (mod1a through mod1s). Both verification criteria pass:

- **Lookup table match:** max absolute difference < 5×10⁻⁵ (floating-point precision only)
- **Letter grade match rate:** 100% for 22 modules; 99.9999% for mod1n (3 boundary cases at rounding thresholds)

### R figure replication

`05_figures_r.py` replaces two R scripts that used hardcoded
absolute paths to the authors' Dropbox folder, making them
non-portable. The Python implementation reads from relative paths
and reproduces the same figures using matplotlib.

---

## Citation

Dell, Melissa and Pablo Querubin. 2018. "Nation Building Through
Foreign Intervention: Evidence from Discontinuities in Military
Strategies." *Quarterly Journal of Economics* 133(2): 701–764.

---

## Acknowledgments

Original replication package by Melissa Dell and Pablo Querubin,
available at the Harvard Dataverse. This replication was conducted
as part of a PhD application portfolio project. Code organization,
debugging, and documentation were assisted by Claude (Anthropic).
