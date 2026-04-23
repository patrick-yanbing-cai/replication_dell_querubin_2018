# Replication Notes
## Dell & Querubin (2018) — Nation Building Through Foreign Intervention

---

## Replication Status

All main results replicate exactly. Coefficients in Tables 1–11 match
the original paper to at least three decimal places with no exceptions.
Figures reproduce the same point estimates and confidence intervals.
The only numerical differences in the entire replication arise in the
Python Bayesian numscore verification, where floating-point precision
differences of at most 5×10⁻⁵ are attributable to 4-decimal truncation
in the conditional probability CSV files — not to any algorithmic
discrepancy.

---

## Why This Paper

This paper is technically demanding relative to most replication
packages: it combines a regression discontinuity design with a
historical administrative dataset of unusual complexity (the Vietnam-era
Hamlet Evaluation System), requires Matlab for the core data
construction step, uses R for figures, and relies on heavily
parameterized subroutines rather than a linear script. Replicating it
required engaging seriously with each of these components rather than
simply re-running existing code.

---

## The Flat Structure Problem

The original package drops everything — do-files, data, output — into
a single directory. This works fine when you run the author's scripts
exactly as written from exactly that directory, but it creates a
fundamental tension with modularization: any do-file that calls another
via a relative path (`do firstclose .2 1 1`) will fail the moment the
working directory changes.

The naive fix — just `cd` to `data/raw/` at the top of `pipeline.do`
and leave it there — breaks the moment you want to call a subroutine
stored elsewhere. The opposite approach — putting everything in
`code/replication/` and using absolute paths for data — requires
rewriting every `use`, `save`, and `insheet` across dozens of files.

The solution that actually worked: each subroutine opens with
`cd "${data}"` and closes with `cd "${root}"`. The subroutine manages
its own working directory, does its work, and restores the state before
returning. The calling scripts (`03_tables.do`, `04_figures.do`) never
touch `cd` at all, and call subroutines via
`do "${root}/code/replication/XX_name.do" args`. This is a clean
encapsulation pattern that took a while to arrive at — earlier attempts
included putting do-files in `data/raw/` (wrong), calling `cd` from the
pipeline itself (breaks subroutine calls), and trying to use absolute
paths for all data operations (too much rewriting).

---

## Intermediate Files Written to the Wrong Place

Even after the `cd` pattern was established, several intermediate files
continued to appear in the wrong location. The `rd_plot` program in
`04_figures.do` saves a temporary file called `RD.dta` and later appends
from it:

```stata
save RD, replace
...
append using RD
```

With `cd "${root}"` restoring the working directory between subroutine
calls, these relative paths resolve to the repo root rather than
`data/raw/`. The fix was straightforward once the cause was identified —
replace with `"${data}/RD"` — but finding it required tracing through
the program definition line by line. The same issue affected
`tempplac.dta`, `firstclose_post.dta`, `marines_hamlet.dta`,
`vndba_merged.dta`, and the `F$counter` temporary files in the VNDBA
section. Each had to be patched individually.

The lesson here is that Stata's `cd` state is global and mutable, and
any program or do-file that saves files using relative paths will be
affected by whatever the current working directory happens to be at
call time. Modularizing code that was not designed with modularity in
mind means accepting this kind of incremental debugging.

---

## Parameterized Subroutines

Most replication packages use a linear structure: run script A, then
script B, then script C. This package is different. `13_firstclose.do`,
`17_plac_fs.do`, `16_plac69.do`, and `19_plac_out.do` are subroutines
that take arguments — bandwidth, start period, end period — and are
called repeatedly with different parameters across different tables and
figures. For example, Table 2 calls `firstclose` seven times with
different combinations of bandwidth and time window to produce seven
columns.

This design is actually elegant: it avoids duplicating hundreds of lines
of data construction code. But it means these files cannot simply be
merged into a monolithic `03_tables.do` — they must remain as separate
callable scripts. Understanding this structure required reading the
original table do-files carefully rather than assuming a standard
linear layout.

---

## The Bayesian Numscore: Algorithm and Verification

The most technically interesting component of the replication is the
Bayesian scoring algorithm in `numscore.m`. The HES questionnaire has
dozens of questions per module, and the algorithm converts the raw
categorical responses into a continuous score using a naive Bayes
classifier.

The setup: each hamlet has a true security state in {E, D, C, B, A}
(coded 1–5). Each question has a conditional probability distribution
over its possible responses given each security state — these are stored
in the `_cond.csv` files. Starting from a uniform prior (0.2 for each
state), the algorithm updates the posterior sequentially across
questions, skipping missing responses (coded 999). The final score is
the posterior expectation: `5p₁ + 4p₂ + 3p₃ + 2p₄ + p₅`.

Two things are worth noting about the implementation. First, the
conditional probability columns are ordered with the best state first —
so `pp1` (the first column of the posterior) corresponds to the highest
security level, and gets weight 5 in the expectation. Getting this
backwards (weighting `pp1` with 1) produces scores that are
approximately inverted around the midpoint, which is exactly the error
that appeared initially and took some time to diagnose.

Second, the verification strategy matters. The author's CSV files are
not per-hamlet scores — they are lookup tables of unique
`(rawdata pattern, num_score)` pairs, produced by Matlab's
`unique(data_all, 'rows')`. The full dataset has ~750,000 observations
per module, but many hamlets share the same response pattern, so the
lookup table has only ~4,000–10,000 rows. Comparing the full-sample
mean from Python against the lookup table mean in the CSV will always
show a large discrepancy, because the two distributions weight patterns
differently. The correct verification is to feed the lookup table's
input columns back through the Python algorithm and compare outputs
row by row — which gives max_diff < 5×10⁻⁵ across all 23 modules.

The 100% letter grade match rate (rounding the continuous score back to
E–A and comparing against the original HES grades stored in the `.mat`
files) confirms that the conditional probability parameters fully encode
the evaluation algorithm used by US field officers. This is expected —
the parameters were estimated from the same data — but it provides a
clean validation that the Python implementation is correct.

---

## R Scripts: Portability as a Real Problem

The two R figure scripts open with:

```r
data = read.csv("/Users/melissadell/Dropbox (Melissa Dell)/VietnamWar/reprod/...")
```

This is not unusual — most academic code is written to run on the
author's machine and not carefully generalized. But it means the scripts
fail immediately on any other system without modification. Rather than
patching the R scripts with relative paths (which would still require R
to be installed), these were replaced with a Python implementation
(`05_figures_r.py`) that reads from `output/results/figures/` via a
path computed relative to the script's own location. The figures
reproduce the same point estimates, confidence intervals, and
black/#0D4F8B color scheme.

---

## What Pre-Generated Means in Practice

Three `.dta` files require Matlab to reproduce from scratch
(`hes_all_models.dta`, `hes71_dist.dta`, `hes70_dist.dta`), and two
require R (`lca_q_all.dta`, `lca_marines_all6971.dta`). These are
included in the replication package pre-generated, which means the
Stata pipeline can run without either Matlab or R installed.

The practical consequence is that `01_build_rd.do` reads these files
as if they are raw data inputs, without being able to verify how they
were produced. The Python numscore verification partially addresses this
for `hes_all_models.dta` — by showing that the Bayesian algorithm can
be fully reconstructed from the `.mat` and `_cond.csv` files — but the
distance calculations in `hes71_dist.dta` and the LCA models in
`lca_q_all.dta` remain unverified at the generative level. This is a
limitation of the replication, not of the paper.

---

## Tools Used

- Stata 17: main replication pipeline
- Python 3.11 (scipy, numpy, pandas, matplotlib): figure replication
  and Bayesian scoring verification
- Claude (Anthropic): code organization, debugging assistance,
  and documentation drafting