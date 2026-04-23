* ============================================================
* 00_header.do - Header
* Dell & Querubin (2018) - Nation Building Through Foreign
* Intervention: Evidence from Discontinuities in Military
* Strategies, QJE 133(2): 701-764
* ============================================================
* How to run: File -> Do in Stata, or right-click -> Execute
* ============================================================

* Set repo root dynamically
global root = subinstr("`c(pwd)'", "\code\replication", "", .)

* ============================================================
* Dependencies
* ============================================================
cap ssc install outreg
cap ssc install outreg2
cap ssc install rdrobust
cap ssc install rddensity
cap ssc install coefplot

* ============================================================
* Paths
* ============================================================
* Data: all raw files are flat in data/raw (mirrors original package)
gl data    "${root}/data/raw"
gl results "${root}/output/results"

* Create output directories
cap mkdir "${results}"
cap mkdir "${results}/tables"
cap mkdir "${results}/figures"

* ============================================================
* Stata settings
* ============================================================
set more off
set matsize 10000