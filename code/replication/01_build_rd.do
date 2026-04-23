* ============================================================
* 01_build_rd.do - Build RDD Dataset
* Dell & Querubin (2018)
* ============================================================
* Merges HES hamlet security scores with distance-to-threshold
* measures to construct the main RDD dataset (min_dist.dta).
*
* Inputs (pre-generated):
*   hes70_dist.dta  - distance to HES70 threshold (from project_hes70.do)
*   hes71_dist.dta  - distance to HES71 threshold (from dist_hes71.do)
*   hes_all_models.dta - full HES dataset with all model scores
*
* Output: min_dist.dta (main RDD dataset)
*
* Note: dist_hes71.do and project_hes70.do compute the threshold
* distance measures using a Bayesian scoring algorithm. These files
* are preserved in code/original/ for reference. Because their
* outputs are included in the replication package, this pipeline
* starts from the pre-generated distance files.
* ============================================================

* ---- HES70 (1970 data) ----
use "${data}/hes70_dist.dta", clear
rename mod4pert near_thresh
tempfile data
save `data', replace

use "${data}/hes_all_models.dta", clear
keep corps-date ham mod4 mth yr mod1a_num-mod1s_num
keep if yr <= 1970
drop if mod4 == "V"
drop if mod4 == "N"
merge 1:1 corps-date ham using `data'
keep if _merge == 3
drop _merge

* Convert letter grades to numerical scores
foreach V in mod4 near_thresh {
    g `V'_num = .
    replace `V'_num = 1 if `V' == "E"
    replace `V'_num = 2 if `V' == "D"
    replace `V'_num = 3 if `V' == "C"
    replace `V'_num = 4 if `V' == "B"
    replace `V'_num = 5 if `V' == "A"
}

* Sign convention: negative distance = below threshold
replace min_dist = -min_dist
keep corps-date ham near_thresh min_dist mod4 mod1a_num-mod1s_num mth yr
save `data', replace

* ---- HES71 (1971-72 data) ----
use "${data}/hes71_dist.dta", clear
tempfile hes71
save `hes71', replace

use "${data}/hes_all_models.dta", clear
keep if yr >= 1971
drop if mod8 == "N"
drop if mod8 == "V"
drop if mod8 == ""
keep corps-date ham mth yr mod1a_num-mod1s_num
merge 1:1 corps-date ham using `hes71'
keep if _merge == 3
drop _merge

* Convert letter grades to numerical scores
g mod8_num = .
g near_thresh_num = .
foreach V in mod8 near_thresh {
    replace `V'_num = 1 if `V' == "E"
    replace `V'_num = 2 if `V' == "D"
    replace `V'_num = 3 if `V' == "C"
    replace `V'_num = 4 if `V' == "B"
    replace `V'_num = 5 if `V' == "A"
}

* Sign convention: negative if moving down to threshold
replace min_dist = -min_dist if near_thresh_num > mod8_num
keep corps-date ham near_thresh min_dist mod8 mod1a_num-mod1s_num mth yr
rename mod8 mod4
append using `data'

* ---- Identifiers ----
g long usid      = ham + 100*vilg + 10000*dist + 1000000*prov + 100000000*corp
g long villageid = 100*vilg + 10000*dist + 1000000*prov + 100000000*corp
save `data', replace

* ---- Time variables ----
g q = .
replace q = 1 if inlist(mth, 1, 2, 3)
replace q = 2 if inlist(mth, 4, 5, 6)
replace q = 3 if inlist(mth, 7, 8, 9)
replace q = 4 if inlist(mth, 10, 11, 12)
g qdate = yq(yr, q)
format qdate %tq

* ---- RDD variables ----
* Dummy for being above the threshold
g above = 0

* Threshold pair dummies (above/below each grade boundary)
g ab = 0
replace ab    = 1 if (near_thresh == "B" & mod4 == "A")
replace ab    = 1 if (near_thresh == "A" & mod4 == "B")
replace above = 1 if (near_thresh == "B" & mod4 == "A")

g bc = 0
replace bc    = 1 if (near_thresh == "C" & mod4 == "B")
replace bc    = 1 if (near_thresh == "B" & mod4 == "C")
replace above = 1 if (near_thresh == "C" & mod4 == "B")

g cd = 0
replace cd    = 1 if (near_thresh == "D" & mod4 == "C")
replace cd    = 1 if (near_thresh == "C" & mod4 == "D")
replace above = 1 if (near_thresh == "D" & mod4 == "C")
replace above = 1 if (near_thresh == "D" & mod4 == "B")

g de = 0
replace de    = 1 if (near_thresh == "E" & mod4 == "D")
replace de    = 1 if (near_thresh == "D" & mod4 == "E")
replace above = 1 if (near_thresh == "E" & mod4 == "D")

* Running variable interactions
g above_dist = above * min_dist
g abs_dist   = abs(min_dist)

* ---- Triangular kernel weights (bandwidth = 0.20) ----
* Weights decline linearly from 1 at threshold to 0 at bandwidth edge
gen oweight20 = .
egen MaxDist  = max(abs_dist) if abs_dist <= .20
replace oweight20 = (1 - (abs(min_dist) / MaxDist))
replace oweight20 = 0 if oweight20 < 0
drop MaxDist

* ---- Drop non-hamlet population ----
* ham==0 are scattered population without hamlet assignment
drop if ham == 0

save "${data}/min_dist.dta", replace
di "01_build_rd.do complete: min_dist.dta saved"