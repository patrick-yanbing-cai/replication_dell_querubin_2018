* ============================================================
* pipeline.do — Full Replication Pipeline
* Dell & Querubin (2018), "Nation Building Through Foreign
* Intervention: Evidence from Discontinuities in Military
* Strategies," QJE 133(2): 701–764
* ============================================================
*
* HOW TO RUN
*   File → Do in Stata GUI (do NOT run from command line;
*   c(pwd) must resolve to this file's directory)
*
* PRE-GENERATED FILES (require Matlab or R, not re-run here)
*   data/raw/hes_all_models.dta      ← code/original/numscore.m (Matlab)
*                                       + code/original/merge_numscore.do
*   data/raw/hes71_dist.dta          ← code/original/dist_hes71.do
*   data/raw/hes70_dist.dta          ← code/original/project_hes70.do
*   data/raw/lca_q_all.dta           ← code/original/hes_lca_all.R (R)
*                                       + code/original/import_lca_all.do
*   data/raw/lca_marines_all6971.dta ← same as above
*
* PYTHON SCRIPTS (run separately after Stata pipeline)
*   code/replication/05_figures_r.py      — replicate R figures in Python
*   code/replication/06_verify_numscore.py — verify Bayesian scoring
*
* OUTPUT
*   output/results/tables/   — LaTeX table fragments
*   output/results/figures/  — PDF figures
* ============================================================

clear all
global root = subinstr("`c(pwd)'", "\code\replication", "", .)
do "${root}/code/replication/00_header.do"

* ============================================================
* Step 1: Build RDD dataset
* Constructs min_dist.dta — distance from each hamlet to the
* nearest HES scoring threshold, with RDD polynomial terms
* ============================================================
do "${root}/code/replication/01_build_rd.do"

* ============================================================
* Step 2: All tables (Tables 1–11)
* Main RDD first stage, reduced form, IV results, and
* Marines vs Army geographic discontinuity
* ============================================================
do "${root}/code/replication/03_tables.do"

* ============================================================
* Step 3: All figures
* RD plots, McCrary density test, VNDBA pre-treatment plots,
* dynamic first stage (outputs CSV for Python figure script)
* ============================================================
do "${root}/code/replication/04_figures.do"

* ============================================================
* Stata pipeline complete.
* ============================================================
di ""
di "============================================================"
di "Stata pipeline complete."
di ""
di "To generate Python figures (replicates R scripts):"
di "  python code/replication/05_figures_r.py"
di ""
di "To verify Bayesian numscore reconstruction (23 modules):"
di "  python code/replication/06_verify_numscore.py"
di "============================================================"