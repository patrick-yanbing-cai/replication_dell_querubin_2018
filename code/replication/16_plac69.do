* ============================================================
* 16_plac69.do
* 1969 placebo test: checks if threshold predicts pre-period
* bombing in 1969, before HES scoring began
* Args: bw diffvar
* ============================================================
args bw diffvar

cd "${data}"

* ---- Bombing data ----
use vmc_prepped, clear
drop if fr_strikes_mean==.
rename qdate outcomedate
tempfile airstrike
save `airstrike', replace

* ---- RDD dataset ----
use min_dist, clear
merge 1:n corps-vilg ham date using controls
keep if _merge==3
drop _merge

* Keep only 1969 survey months (placebo period)
keep if yr==1969
keep if (mth==7 | mth==9)
replace qdate = yq(1969, 2) if mth==7

* Drop first category of each control variable
foreach V in vmb2 vb2 vb3 vb4 hmb2 hmb3 hmb4 hmd1 hmd2 hmd5 vmb1 ///
    hmc1 hmc2 hmd3 hmd4 hmd6 hd5 hr5 vt6 hmd7 hc1 hc2 hc3 hc4 hc5 ///
    he2 vc1 vc2 vc3 vc4 vc5 vc6 hmc3 vmc1 hd1 hd2 hd3 hd4 he3 vd1 ///
    vd2 vd4 vd5 vd6 hmc4 hc6 hc7 hb2 hf1 hf2 hmb5 hmb6 hmb7 hmb8 ///
    hb1 vb1 he1 he4 hf5 ve1 ve2 ve3 ve4 ve5 ve7 vf5 vf6 he5 hf4 hf6 ///
    hn2 vf7 hg1 hg2 hg3 hg4 vg1 vg2 vg3 hf3 vf1 vf2 vf3 vf4 hp1 hp2 ///
    vp1 vp2 vp3 vp4 hr1 hr2 hr3 hr4 vr1 vr2 vr3 hs1 hs2 hs3 hs4 hs5 ///
    hn1 vn1 vn2 vn3 vn4 vn5 ve6 hl1 hl2 hl3 vb5 vl1 vl2 vl3 vt1 vt2 ///
    vt3 vt4 vt5 {
    capture drop `V'1
}

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

* ---- Merge with bombing data ----
merge 1:n usid using `airstrike'
keep if _merge==3
drop _merge

* Keep post-period bombing only
keep if outcomedate > closedate
g diff = outcomedate - closedate
keep if diff <= `diffvar'

* Collapse to hamlet level
collapse (mean) fr_strikes_mean fr_forces_mean, by(usid)

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

save plac69_`diffvar', replace

cd "${root}"