* ============================================================
* 04_figures.do - All Figures
* Dell & Querubin (2018) - Nation Building Through Foreign
* Intervention, QJE 133(2): 701-764
* ============================================================
* Generates all RDD plots, McCrary density test, and
* pre-treatment VNDBA attack plots.
* ============================================================
set more off

* ============================================================
* RD PLOTS (rd_plots.do)
* Visualizes the discontinuity at the HES threshold
* Left of zero = below threshold (more bombing)
* Right of zero = above threshold (less bombing)
* ============================================================

cap program drop rd_plot
program rd_plot
    args out titlex titley bw inputfile period invars

    use "${data}/`inputfile'", clear
    local wt = `bw'*100

    reg `out' `invars' [aw=oweight`wt'], nocons
    predict resid, resid

    lpoly resid min_dist if (min_dist>0 & min_dist<`bw') ///
        [aw=oweight`wt'], kernel(rectangle) bwidth(`bw') degree(1) ///
        generate(x s) se(se) nograph
    keep x s se
    drop if x==.
    save "${data}/RD", replace

    use "${data}/`inputfile'", clear
    local wt = `bw'*100

    reg `out' `invars' [aw=oweight`wt'], nocons
    predict resid, resid

    lpoly resid min_dist if (min_dist<0 & min_dist>-`bw') ///
        [aw=oweight`wt'], kernel(rectangle) bwidth(`bw') degree(1) ///
        generate(x s) se(se) nograph
    keep x s se
    drop if x==.
    append using "${data}/RD"

    g ciplus  = s + 1.96*se
    g ciminus = s - 1.96*se
    keep if abs(x) < `bw'
    save "${data}/RD", replace

    use "${data}/`inputfile'", replace
    local increment = `bw'/10

    gen bin10 = .
    foreach X of num 0(`increment')`bw' {
        replace bin = (-`X'+(`increment'/2)) ///
            if (min_dist>=-`X' & min_dist<(-`X'+`increment') & min_dist<0)
        replace bin = (`X'+(`increment'/2)) ///
            if (min_dist>`X' & min_dist<=(`X'+`increment'))
    }
    drop if bin10==.

    reg `out' `invars' [aw=oweight`wt'], nocons
    predict resid, resid
    collapse (mean) resid min_dist, by(bin10)
    append using "${data}/RD"

    local biginc = `increment'*2

    twoway ///
        (connected s x if x>0, sort msymbol(none) clcolor(black) ///
            clpat(solid) clwidth(medthick)) ///
        (connected ciplus x if x>0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (connected ciminus x if x>0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (connected s x if x<0, sort msymbol(none) clcolor(black) ///
            clpat(solid) clwidth(medthick)) ///
        (connected ciplus x if x<0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (connected ciminus x if x<0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (scatter resid min_dist, sort msize(med) xline(0) mcolor(black)), ///
        legend(off) graphregion(color(white)) ///
        xtitle(`titlex') ytitle(`titley') ///
        xlabel(-`bw'(`biginc')`bw') xsc(r(-`bw' `bw')) ///
        xline(0, lpattern(shortdash) lc(black)) ylab(,nogrid) ///
        name(`out', replace)
end

* First stage: immediate bombing
do "${root}/code/replication/13_firstclose.do" .2 1 1
rd_plot fr_strikes_mean ///
    "distance to threshold in period t" ///
    "bombing in period t+1" .2 firstclose_post 1 "ab bc cd de"
graph export "${results}/figures/bomb_immed_noc.pdf", replace

* First stage: cumulative bombing
do "${root}/code/replication/13_firstclose.do" .2 1 12
rd_plot fr_strikes_mean ///
    "distance to threshold in period t" ///
    "bombing until U.S. withdrawal" .2 firstclose_post 12 "ab bc cd de"
graph export "${results}/figures/bomb_cum_noc.pdf", replace

* First stage placebos
do "${root}/code/replication/18_plac_fs0.do" .2
rd_plot fr_strikes_mean ///
    "distance to threshold in period t" ///
    "bombing in period t" .2 fs_plac0 1 "ab bc cd de"
graph export "${results}/figures/fs_plac0.pdf", replace

do "${root}/code/replication/17_plac_fs.do" .2 1 1
rd_plot fr_strikes_mean ///
    "distance to threshold in period t" ///
    "bombing in period t-1" .2 fs_plac 1 "ab bc cd de"
graph export "${results}/figures/fs_immedplac.pdf", replace

do "${root}/code/replication/17_plac_fs.do" .2 1 16
rd_plot fr_strikes_mean ///
    "distance to threshold in period t" ///
    "pre-period bombing" .2 fs_plac 12 "ab bc cd de"
graph export "${results}/figures/fs_cumplac.pdf", replace

* Outcome plots
do "${root}/code/replication/13_firstclose.do" .2 1 12
foreach V in en_pres vc_infr_vilg village_comm prim_access ///
    civic_org_part fw_init {
    rd_plot `V' "distance to threshold in period t" "" ///
        .2 firstclose_post 12 "ab bc cd de"
    graph export "${results}/figures/`V'_cum_noc.pdf", replace
}

* Predicted bombing placebo
do "${root}/code/replication/13_firstclose.do" .2 1 1
reg fr_strikes_mean vmb22-vt54
predict bomb_pred, xb
save "${data}/tempplac", replace
rd_plot bomb_pred "distance to threshold in period t" ///
    "predicted bombing" .2 tempplac 1 "ab bc cd de"
graph export "${results}/figures/predict_bomb_immed.pdf", replace

do "${root}/code/replication/13_firstclose.do" .2 1 12
reg fr_strikes_mean vmb22-vt54
predict bomb_pred, xb
save "${data}/tempplac", replace
rd_plot bomb_pred "distance to threshold in period t" ///
    "predicted bombing" .2 tempplac 12 "ab bc cd de"
graph export "${results}/figures/predict_bomb_cum.pdf", replace

* 1969 placebos
do "${root}/code/replication/16_plac69.do" .2 1
rd_plot fr_strikes_mean "distance to threshold in period t" ///
    "bombing in period t-1" .2 plac69_1 1 "ab bc cd de"
graph export "${results}/figures/immedplac69.pdf", replace

do "${root}/code/replication/16_plac69.do" .2 14
rd_plot fr_strikes_mean "distance to threshold in period t" ///
    "pre-period bombing" .2 plac69_14 14 "ab bc cd de"
graph export "${results}/figures/cumplac69.pdf", replace

* By-period dynamics
global counter 0

cap program drop dynam
program dynam
    args datafile V yr dropvar
    use "${data}/`datafile'", clear
    if `yr'==0 {
        capture drop `dropvar'
    }
    reg `V' below md_* ab bc cd de i.qdate vmb22-vt54 ///
        [aw=oweight20], nocons cluster(villageid)
    g indexnum = _n
    keep if indexnum==1
    keep indexnum
    g depvar  = "`V'"
    g period  = `yr'
    g coeff   = _b[below]
    g se      = _se[below]
    g dfile   = "`datafile'"
    drop indexnum
    global counter = $counter+1
    save temp/f$counter, replace
end

cap mkdir temp
foreach Y of num -2/8 {
    do "${root}/code/replication/12_balance_panel.do" .2 `Y' `Y'
    dynam firstclose_post fr_strikes_mean `Y'
}

use temp/f1, clear
forvalues i = 2/$counter {
    append using temp/f`i'
}

g cp5  = coeff + 1.96*se
g cn5  = coeff - 1.96*se
g cp10 = coeff + 1.65*se
g cn10 = coeff - 1.65*se

replace period = -period if dfile=="placout"
replace period = -period if dfile=="fs_plac"

outsheet using "${results}/figures/bombing_balanced_dynamics.csv", ///
    comma replace

* ============================================================
* McCRARY DENSITY TEST (mccrary.do)
* Tests for manipulation of running variable at threshold
* Flat density = no manipulation (supports RDD validity)
* ============================================================

cap program drop rd_plot
program rd_plot
    args out titlex titley bw inputfile

    use "${data}/`inputfile'", clear
    local increment = `bw'/100

    gen bin10 = .
    foreach X of num 0(`increment')`bw' {
        replace bin = (-`X'+(`increment'/2)) ///
            if (min_dist>=-`X' & min_dist<(-`X'+`increment') & min_dist<0)
        replace bin = (`X'+(`increment'/2)) ///
            if (min_dist>`X' & min_dist<=(`X'+`increment'))
    }
    drop if bin10==.
    collapse (sum) Nobs, by(bin10)

    lpoly N bin10 if bin10>0, kernel(rectangle) bwidth(`bw') degree(1) ///
        generate(x s) se(se) nograph
    keep x s se
    drop if x==.
    save "${data}/RD", replace

    use "${data}/`inputfile'", clear
    local increment = `bw'/100

    gen bin10 = .
    foreach X of num 0(`increment')`bw' {
        replace bin = (-`X'+(`increment'/2)) ///
            if (min_dist>=-`X' & min_dist<(-`X'+`increment') & min_dist<0)
        replace bin = (`X'+(`increment'/2)) ///
            if (min_dist>`X' & min_dist<=(`X'+`increment'))
    }
    drop if bin10==.
    collapse (sum) Nobs, by(bin10)

    lpoly N bin10 if bin10<0, kernel(rectangle) bwidth(`bw') degree(1) ///
        generate(x s) se(se) nograph
    keep x s se
    drop if x==.
    append using "${data}/RD"

    g ciplus  = s + 1.96*se
    g ciminus = s - 1.96*se
    keep if abs(x) < `bw'
    save "${data}/RD", replace

    use "${data}/`inputfile'", replace
    local increment = `bw'/100

    gen bin10 = .
    foreach X of num 0(`increment')`bw' {
        replace bin = (-`X'+(`increment'/2)) ///
            if (min_dist>=-`X' & min_dist<(-`X'+`increment') & min_dist<0)
        replace bin = (`X'+(`increment'/2)) ///
            if (min_dist>`X' & min_dist<=(`X'+`increment'))
    }
    drop if bin10==.
    collapse (sum) Nobs (mean) min_dist, by(bin10)
    append using "${data}/RD"

    local biginc = `increment'*10

    twoway ///
        (connected s x if x>0, sort msymbol(none) clcolor(black) ///
            clpat(solid) clwidth(medthick)) ///
        (connected ciplus x if x>0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (connected ciminus x if x>0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (connected s x if x<0, sort msymbol(none) clcolor(black) ///
            clpat(solid) clwidth(medthick)) ///
        (connected ciplus x if x<0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (connected ciminus x if x<0, sort msymbol(none) clcolor(black) ///
            clpat(shortdash) clwidth(thin)) ///
        (scatter Nobs min_dist, sort msize(med) xline(0) mcolor(black)), ///
        legend(off) graphregion(color(white)) ///
        xtitle(`titlex') ytitle(`titley') ///
        xlabel(-`bw'(`biginc')`bw') xsc(r(-`bw' `bw')) ///
        xline(0, lpattern(shortdash) lc(black)) ylab(,nogrid) ///
        saving("${results}/figures/Fig3.gph", replace)

    graph export "${results}/figures/mccrary.pdf", replace
end

do "${root}/code/replication/13_firstclose.do" 1 1 1
g Nobs = 1
save "${data}/firstclose_post", replace
rd_plot Nobs "distance to threshold in period t" "Observations" ///
    1 "firstclose_post"

* ============================================================
* VNDBA PRE-TREATMENT PLOT (vndba_rf.do)
* Shows pre-treatment VC attack rates by threshold side
* Validates parallel trends before HES scoring began
* ============================================================

cap program drop regs
program regs
    args outcome yr quart

    use "${data}/vndba_merged", clear
    regress `outcome' below md_* ab bc cd de i.date_score vmb22-vt54 ///
        if qdate==yq(`yr', `quart') [aw=oweight20], ///
        nocons robust cluster(villageid)

    g indexnum = _n
    keep if indexnum==1
    keep indexnum
    g depvar   = "`outcome'"
    g year     = `yr'
    g quarter  = `quart'
    g coeff    = _b[below]
    g se       = _se[below]
    drop indexnum
    global counter = $counter+1
    save "${data}/F$counter", replace
end

do "${root}/code/replication/13_firstclose.do" .2 1 1
keep below md_* ab bc cd de oweight usid villageid qdate vmb22-vt54
rename qdate date_score
merge 1:n usid using "${data}/vndba_ym"
keep if _merge==3
drop _merge
save "${data}/vndba_merged", replace

global counter = 0

foreach Y of num 1964 {
    foreach Q of num 2/4 {
        regs en_init `Y' `Q'
    }
}
foreach Y of num 1965/1969 {
    foreach Q of num 1/4 {
        regs en_init `Y' `Q'
    }
}

use "${data}/F1", clear
foreach c of num 2/$counter {
    append using "${data}/F`c'"
}

g period = .
local counter = 1
foreach Y of num 1964 {
    foreach Q of num 2/4 {
        replace period = `counter' if (year==`Y' & quarter==`Q')
        local counter = `counter'+1
    }
}
foreach Y of num 1965/1969 {
    foreach Q of num 1/4 {
        replace period = `counter' if (year==`Y' & quarter==`Q')
        local counter = `counter'+1
    }
}

g cp5  = coeff + 1.96*se
g cn5  = coeff - 1.96*se
g cp10 = coeff + 1.65*se
g cn10 = coeff - 1.65*se

outsheet using "${results}/figures/vndba_rf.csv", comma replace

di "04_figures.do complete"