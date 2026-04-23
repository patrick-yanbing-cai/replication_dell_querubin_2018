* ============================================================
* 13_firstclose.do
* Builds main analysis dataset by merging bombing, outcome,
* and RDD threshold data
* Args: bw startvar endvar
* ============================================================
args bw startvar endvar

cd "${data}"

* ---- Bombing data ----
use vmc_prepped, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
drop if fr_strikes_mean==.
tempfile airstrike
save `airstrike', replace

* ---- LCA data ----
use lca_q_all, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
merge 1:1 usid qdate using `airstrike'
drop if _merge==1
drop _merge
save firstclose_post, replace

* ---- HES outcome data ----
use hes_outcomes, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
merge 1:1 usid qdate using firstclose_post
drop if _merge==1
drop _merge
save firstclose_post, replace

* ---- SITRA data ----
use sitra_all, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
merge 1:1 usid qdate using firstclose_post
drop if _merge==1
drop _merge
save firstclose_post, replace

* ---- TFES/TFARS data ----
use TFES_HAMLET_PANEL_QUARTERLY, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
merge 1:1 usid qdate using firstclose_post
drop if _merge==1
drop _merge
save firstclose_post, replace

* ---- NASVA data ----
use nasva_yq, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
merge 1:1 usid qdate using firstclose_post
drop if _merge==1
drop _merge
save firstclose_post, replace

* ---- Population growth data ----
use pop_g, clear
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 4))
merge 1:1 usid qdate using firstclose_post
drop if _merge==1
drop _merge
rename qdate outcomedate
save firstclose_post, replace

* ---- RDD dataset ----
* Merge distance-to-threshold with HES question response controls
use min_dist, clear
keep corps-vilg ham date yr mth min_dist-oweight

merge 1:n corps-vilg ham date using controls
keep if _merge==3
drop _merge

* Keep only quarter-end months when HES scores are updated
g keepmth=0
replace keepmth=1 if inlist(mth, 3, 6, 9, 12)
keep if keepmth==1
drop keepmth

* Drop first category of each control variable (omitted category)
foreach V in vmb2 vb2 vb3 vb4 hmb2 hmb3 hmb4 hmd1 hmd2 hmd5 vmb1 ///
    hmc1 hmc2 hmd3 hmd4 hmd6 hd5 hr5 firstclose_post vt6 hmd7 hc1 ///
    hc2 hc3 hc4 hc5 he2 vc1 vc2 vc3 vc4 vc5 vc6 hmc3 vmc1 hd1 hd2 ///
    hd3 hd4 he3 vd1 vd2 vd4 vd5 vd6 hmc4 hc6 hc7 hb2 hf1 hf2 hmb5 ///
    hmb6 hmb7 hmb8 hb1 vb1 he1 he4 hf5 ve1 ve2 ve3 ve4 ve5 ve7 vf5 ///
    vf6 he5 hf4 hf6 hn2 vf7 hg1 hg2 hg3 hg4 vg1 vg2 vg3 hf3 vf1 ///
    vf2 vf3 vf4 hp1 hp2 vp1 vp2 vp3 vp4 hr1 hr2 hr3 hr4 vr1 vr2 vr3 ///
    hs1 hs2 hs3 hs4 hs5 hn1 vn1 vn2 vn3 vn4 vn5 ve6 hl1 hl2 hl3 vb5 ///
    vl1 vl2 vl3 vt1 vt2 vt3 vt4 vt5 {
    capture drop `V'1
}

* Keep period when score in use, prior to U.S. withdrawal
keep if (qdate>=yq(1970, 1) & qdate<=yq(1972, 3))

* RDD polynomial interaction terms
foreach d in ab bc cd de {
    g md_`d'     = min_dist*`d'
    g md_abv_`d' = min_dist*above*`d'
}

* Restrict to bandwidth and first observation per hamlet
keep if abs(min_dist) < `bw'
sort usid date
by usid: g ctr = _n
keep if ctr==1
rename qdate closedate

tempfile data
save `data', replace

* ---- Merge with outcome data ----
merge 1:n usid using firstclose_post
keep if _merge==3
drop _merge

* Keep post-period air strikes only
keep if outcomedate > closedate
g diff = outcomedate - closedate

keep if diff<=`endvar'
keep if diff>=`startvar'

* Collapse to hamlet level
collapse (mean) fr_strikes_mean fr_forces_mean pop_g naval_attack ///
    sh_*_presence fr_init-fw_op vc_infr_vilg-en_prop *_p1, by(usid)

merge 1:1 usid using `data'
keep if _merge==3
drop _merge

tostring villageid, g(districtid)
replace districtid = substr(districtid, 1, 5)
destring districtid, replace

label var fr_strikes_mean "Bombing"
rename closedate qdate
g below = 1-above
label var below "Below"

save firstclose_post, replace

cd "${root}"