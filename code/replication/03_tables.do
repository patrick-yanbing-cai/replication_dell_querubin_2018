* ============================================================
* 03_tables.do - All Tables
* Dell & Querubin (2018) - Nation Building Through Foreign
* Intervention, QJE 133(2): 701-764
* ============================================================
* Generates Tables 1-11 from the paper.
* Calls 13_firstclose.do, 10_rd_reg.do, 17_plac_fs.do, 18_plac_fs0.do,
* 16_plac69.do, 14_marines_hamlet.do, 15_marines_paas.do as subroutines.
*
* Output: table1.out through table10.out (LaTeX fragments)
* ============================================================
set more off
set matsize 2000

* ============================================================
* TABLE 1 - Balance test
* Tests whether pre-determined characteristics are smooth
* through the RDD threshold (placebo outcomes)
* ============================================================

* [table1.do content]
capture program drop makestars
program define makestars, rclass
    syntax , Pointest(real) PVal(real) [bdec(integer 3)]
    local fullfloat = `bdec' + 1
    local outstr = string(`pointest',"%`fullfloat'.`bdec'f")
    if `pval' <= 0.01 {
        local outstr = "`outstr'" + "***"
    }
    else if `pval' <= 0.05 {
        local outstr = "`outstr'" + "**"
    }
    else if `pval' <= 0.1 {
        local outstr = "`outstr'" + "*"
    }
    return local coeff = "`outstr'"
end

capture program drop rowtitles
program define rowtitles
    g rowtitle = ""
    for num 1/2: g outcolX = ""
    g indexnum = _n
    replace rowtitle = "Bombing" if indexnum == 1
    replace rowtitle = "Security LCA" if indexnum == 2
    replace rowtitle = "Enemy Forces Present" if indexnum == 3
    replace rowtitle = "Village Guerrilla Squad" if indexnum == 4
    replace rowtitle = "VC Main Force Squad" if indexnum == 5
    replace rowtitle = "VC Base Nearby" if indexnum == 6
    replace rowtitle = "VC Attack" if indexnum == 7
    replace rowtitle = "Active VC Infrastructure" if indexnum == 8
    replace rowtitle = "\% Households Participate VC" if indexnum == 9
    replace rowtitle = "VC Propoganda" if indexnum == 10
    replace rowtitle = "VC Taxation" if indexnum == 11
    replace rowtitle = "Friendly Forces Nearby" if indexnum == 12
    replace rowtitle = "US Operations" if indexnum == 13
    replace rowtitle = "US Initiated Attacks" if indexnum == 14
    replace rowtitle = "US Deaths" if indexnum == 15
    replace rowtitle = "SVN Deaths" if indexnum == 16
    replace rowtitle = "VC Deaths" if indexnum == 17
    replace rowtitle = "Administration LCA" if indexnum == 18
    replace rowtitle = "Local Government Taxes" if indexnum == 19
    replace rowtitle = "Village Committee Filled" if indexnum == 20
    replace rowtitle = "Local Chief Visits Hamlet" if indexnum == 21
    replace rowtitle = "Education LCA" if indexnum == 22
    replace rowtitle = "Primary School Access" if indexnum == 23
    replace rowtitle = "Secondary School Access" if indexnum == 24
    replace rowtitle = "Health LCA" if indexnum == 25
    replace rowtitle = "Public Works Under Construction" if indexnum == 26
    replace rowtitle = "Civic Society LCA" if indexnum == 27
    replace rowtitle = "HH Participation in Civic Orgs" if indexnum == 28
    replace rowtitle = "HH Participation in PSDF" if indexnum == 29
    replace rowtitle = "HH Participation in Econ Training" if indexnum == 30
    replace rowtitle = "HH Participation in Devo Projects" if indexnum == 31
    replace rowtitle = "Self Devo Projects Underway" if indexnum == 32
    replace rowtitle = "Youth Organization Exists" if indexnum == 33
    replace rowtitle = "Council Meets Regularly with Citizens" if indexnum == 34
    replace rowtitle = "Economic LCA" if indexnum == 35
    replace rowtitle = "Non-Rice Food Available" if indexnum == 36
    replace rowtitle = "Manufactures Available" if indexnum == 37
    replace rowtitle = "Surplus Goods Produced" if indexnum == 38
    replace rowtitle = "Fields Fallow Due to Insecurity" if indexnum == 39
    replace rowtitle = "HH With Motorized Vehicle" if indexnum == 40
    replace rowtitle = "HH Require Assistance to Subsist" if indexnum == 41
    replace rowtitle = "Hamlet Population Growth" if indexnum == 42
    replace rowtitle = "Urban" if indexnum == 43
    replace rowtitle = "\textbf{Observations}" if indexnum == 46
end

do  "${root}/code/replication/17_plac_fs.do" .2 1 1
rowtitles
local i = 1

reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons cluster(villageid)
local colnum = 2
local tval = (_b[below]/_se[below])
local pval = 2*ttail(e(df_r),abs(`tval'))
replace outcol`colnum' = "'(" + string(_se[below],"%4.3f") + ")" ///
    if indexnum == `i'
local pe = _b[below]
makestars, pointest(`pe') pval(`pval') bdec(3)
local colnum = 1
replace outcol`colnum' = r(coeff) if indexnum == `i'
keep outcol* indexnum rowtitle
keep if indexnum == `i'
tempfile f`i'
save `f`i'', replace

do  "${root}/code/replication/17_plac_fs.do" .2 1 16
for num 3/4: g outcolX = ""
g indexnum = _n

reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons cluster(villageid)
local colnum = 4
local tval = (_b[below]/_se[below])
local pval = 2*ttail(e(df_r),abs(`tval'))
replace outcol`colnum' = "'(" + string(_se[below],"%4.3f") + ")" ///
    if indexnum == `i'
local pe = _b[below]
local pval = `pval'
makestars, pointest(`pe') pval(`pval') bdec(3)
local colnum = 3
replace outcol`colnum' = r(coeff) if indexnum == `i'
keep outcol* indexnum
keep if indexnum == `i'
tempfile temp
save `temp', replace

use `f`i'', clear
merge 1:1 indexnum using `temp'
drop _merge
save `f`i'', replace

do "${root}/code/replication/19_plac_out.do" .2 1 1 12
do "${root}/code/replication/19_plac_out.do" .2 1 16 12

foreach V in sec_p1 en_pres guer_squad mainforce_squad en_base ///
    all_atk vc_infr_vilg part_vc_cont en_prop entax_vilg ///
    fr_forces_mean fw_opday_dummy fw_init fw_d fr_d en_d ///
    admin_p1 gvn_taxes village_comm chief_visit educ_p1 ///
    prim_access sec_school_vilg health_p1 pworks_under_constr ///
    soccap_p1 civic_org_part phh_psdf econ_train self_dev_part ///
    selfdev_vilg youth_act vilg_council_meet econ_p1 nonrice_food ///
    manuf_avail surplus_goods nofarm_sec p_own_vehic p_require_assist ///
    pop_g urban {

    use "${data}/placout1", clear
    rowtitles
    local i = `i' + 1

    reg `V' below md_* ab bc cd de i.qdate vmb22-vt54 ///
        [aw=oweight20], nocons cluster(villageid)
    local colnum = 2
    local tval = (_b[below]/_se[below])
    local pval = 2*ttail(e(df_r),abs(`tval'))
    replace outcol`colnum' = "'(" + string(_se[below],"%4.3f") + ")" ///
        if indexnum == `i'
    local pe = _b[below]
    local pval = `pval'
    makestars, pointest(`pe') pval(`pval') bdec(3)
    local colnum = 1
    replace outcol`colnum' = r(coeff) if indexnum == `i'
    keep outcol* indexnum rowtitle
    keep if indexnum == `i'
    tempfile f`i'
    save `f`i'', replace

    use "${data}/placout16", clear
    for num 3/4: g outcolX = ""
    g indexnum = _n

    reg `V' below md_* ab bc cd de i.qdate vmb22-vt54 ///
        [aw=oweight20], nocons cluster(villageid)
    local colnum = 4
    local tval = (_b[below]/_se[below])
    local pval = 2*ttail(e(df_r),abs(`tval'))
    replace outcol`colnum' = "'(" + string(_se[below],"%4.3f") + ")" ///
        if indexnum == `i'
    local pe = _b[below]
    local pval = `pval'
    makestars, pointest(`pe') pval(`pval') bdec(3)
    local colnum = 3
    replace outcol`colnum' = r(coeff) if indexnum == `i'
    keep outcol* indexnum
    keep if indexnum == `i'
    tempfile temp
    save `temp', replace

    use `f`i'', clear
    merge 1:1 indexnum using `temp'
    drop _merge
    save `f`i'', replace
}

use `f1', clear
foreach N of num 2/`i' {
    append using `f`N''
}
outsheet rowtitle outcol1 outcol2 outcol3 outcol4 ///
    using "${results}/tables/table_balance.out", replace noquote

* ============================================================
* TABLE 2 - First stage: Bombing
* RDD first stage showing that being below the threshold
* causes more US bombing in subsequent periods
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons replace se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

do  "${root}/code/replication/18_plac_fs0.do" .2
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

do  "${root}/code/replication/17_plac_fs.do" .2 1 1
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

do  "${root}/code/replication/16_plac69.do" .2 1
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

do  "${root}/code/replication/13_firstclose.do" .2 1 12
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

do  "${root}/code/replication/17_plac_fs.do" .2 1 16
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

do  "${root}/code/replication/16_plac69.do" .2 14
reg fr_strikes_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_strikes_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

outreg using "${results}/tables/table2", replay replace tex ///
    ctitles("", "Dependent Variable is Share Months Bomb/Artillery:" ///
    \ "", "$ t+1$", "$ t$", "$ t-1$", "$ t+1$", "Post", "Pre", "Post" ///
    \ "", "70-72", "70-72", "70-72", "69", "70-72", "70-72", "69" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)") ///
    multicol(1, 2, 7) hlines(11001{0}1) plain fragment nocenter

* ============================================================
* TABLE 3 - Friendly forces deployment
* RDD reduced form: being below threshold → more friendly forces
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1

reg fr_forces_mean below md_* ab bc cd de i.qdate vmb22-vt54 ///
    [aw=oweight20], nocons robust cluster(villageid)
summ fr_forces_mean if e(sample)==1
local mean : display %4.2f `r(mean)'
outreg, varlabel nocons replace se bdec(3) nostars summstat(N) ///
    summtitles("Obs") keep(below) ///
    addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend

foreach V in fw_opday_dummy fw_init fr_opday_dummy fr_init ///
    naval_attack sh_pf_presence sh_rf_presence psdf_dummy ///
    phh_psdf rdc_active {
    reg `V' below md_* ab bc cd de i.qdate vmb22-vt54 ///
        [aw=oweight20], nocons robust cluster(villageid)
    summ `V' if e(sample)==1
    local mean : display %4.2f `r(mean)'
    outreg, varlabel nocons merge se bdec(3) nostars summstat(N) ///
        summtitles("Obs") keep(below) ///
        addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend
}

outreg using "${results}/tables/table2b", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "", "Immediate ($ t+1$)", "", "", "", "" ///
    \ "","Friendly","US", "US", "SVN", "SVN", "Naval", ///
    "Regional", "Popular", "PSDF", "\% HH", "RD Cadre" ///
    \ "", "Forces", "Ops", "Attacks", "Ops", "Attacks", ///
    "Attacks", "Forces", "Forces", "Present", "PSDF", "Present" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)") ///
    multicol(1, 2, 11; 2, 2, 11) hlines(110001{0}1) plain fragment nocenter

* ============================================================
* TABLE 4 - Security outcomes (IV)
* 2SLS using below-threshold as instrument for bombing
* Key result: bombing worsens security outcomes
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do  "${root}/code/replication/10_rd_reg.do" sec_p1 replace

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" sec_p1 merge

foreach V in en_pres guer_squad mainforce_squad en_base all_atk ///
    vc_infr_vilg part_vc_cont en_prop entax_vilg {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

outreg using "${results}/tables/table3", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "","Security", "","Armed", "Vilg", "VC", "VC", "VC" ///
    ,"Reg VC", "\% HH", "VC", "VC" ///
    \ "", "Posterior Prob", "", "VC", "Guer", "Main", "Base", ///
    "Attack", "Infra", "Part", "Prop", "Extorts" ///
    \ "", "$ t+1$", "Cum", "Present", "Squad", "Squad", "Nearby", ///
    "Hamlet", "Activity", "VC Infr", "Drive", "Pop" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)") ///
    multicol(1, 2, 11; 2, 2, 2; 3, 2, 2) ///
    hlines(110001{0}1) plain fragment nocenter

* ============================================================
* TABLE 5 - Military outcomes (IV)
* 2SLS: bombing effect on military activity and casualties
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do "${root}/code/replication/10_rd_reg.do" fr_forces_mean replace
foreach V in fw_opday_dummy fw_init fw_d fr_d en_d {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" fr_forces_mean merge
foreach V in fw_opday_dummy fw_init fw_d fr_d en_d {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

outreg using "${results}/tables/table4", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "", "Immediate", "", "", "", "", "", "Cumulative", "", "", "" ///
    \ "","Friendly","US", "US", "US", "SVN", "VC", ///
    "Friendly", "US", "US", "US", "SVN", "VC" ///
    \ "", "Forces", "Ops", "Attacks", "Troop Deaths", "", "", ///
    "Forces", "Ops", "Attacks", "Troop Deaths", "", "" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)", "(12)") ///
    multicol(1, 2, 12; 2, 2, 6; 2, 8, 6; 4,5,3; 4, 11, 3) ///
    hlines(110001{0}1) plain fragment nocenter

* ============================================================
* TABLE 6 - Economic outcomes (IV)
* 2SLS: bombing effect on economic activity
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do "${root}/code/replication/10_rd_reg.do" econ_p1 replace

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" econ_p1 merge

foreach V in nonrice_food manuf_avail surplus_goods nofarm_sec ///
    p_own_vehic p_require_assist pop_g {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

outreg using "${results}/tables/table7", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "","Economic", "", "Non-Rice", "Manuf.", "Surplus", ///
    "No Farm", "\% HH", "\% HH", "Ham" ///
    \ "", "Posterior Prob", "", "Food", "Goods", "Goods", ///
    "Security", "Own", "Require", "Pop" ///
    \ "", "$ t+1$", "Cum", "Avail", "Avail", "Prod", "Bad", ///
    "Vehic", "Assist", "Growth" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)") ///
    multicol(1, 2, 9; 2,2,2; 3, 2, 2) ///
    hlines(110001{0}1) plain fragment nocenter

* ============================================================
* TABLE 7 - Governance outcomes (IV)
* 2SLS: bombing effect on administration, education, health
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do "${root}/code/replication/10_rd_reg.do" admin_p1 replace

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" admin_p1 merge
foreach V in village_comm gvn_taxes chief_visit {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do "${root}/code/replication/10_rd_reg.do" educ_p1 merge

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" educ_p1 merge
foreach V in prim_access sec_school_vilg {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do "${root}/code/replication/10_rd_reg.do" health_p1 merge

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" health_p1 merge
do "${root}/code/replication/10_rd_reg.do" pworks_under_constr merge

outreg using "${results}/tables/table5", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "","Administration", "","Vilg", "Vilg", "Chief" ///
    ,"Education", "","Primary", "Sec", "Health", "","Pub" ///
    \ "", "Posterior Prob", "", "Comm", "Gov", "Visits" ///
    , "Posterior Prob", "", "School", "School", ///
    "Posterior Prob", "", "Works" ///
    \ "", "$ t+1$", "Cum", "Filled", "Taxes", "Hamlet" ///
    , "$ t+1$", "Cum", "Access", "Access", "$ t+1$", "Cum", "Cons." ///
    \ "",   "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)", "(12)") ///
    multicol(1, 2, 12; 2,2,2; 2, 7, 2; 2, 11, 2; ///
    3, 2, 2; 3, 7, 2; 3, 11, 2) ///
    hlines(110001{0}1) plain fragment nocenter

* ============================================================
* TABLE 8 - Civic society outcomes (IV)
* 2SLS: bombing effect on civic participation
* ============================================================

do  "${root}/code/replication/13_firstclose.do" .2 1 1
label var fr_strikes_mean "Bombing ($ t+1$)"
do "${root}/code/replication/10_rd_reg.do" soccap_p1 replace

do  "${root}/code/replication/13_firstclose.do" .2 1 12
label var fr_strikes_mean "Bombing (Cum)"
do "${root}/code/replication/10_rd_reg.do" soccap_p1 merge

foreach V in civic_org_part phh_psdf econ_train self_dev_part ///
    selfdev_vilg youth_act vilg_council_meet {
    do "${root}/code/replication/10_rd_reg.do" `V' merge
}

outreg using "${results}/tables/table6", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "", "Civic Society", "", "\% HH with a Member Active in", ///
    "", "", "", "Self Dev", "Youth", "Council" ///
    \ "","Posterior Prob.", "", "Civic", "PSDF", "Econ", ///
    "Dev", "Proj", "Org", "Meets" ///
    \ "", "$ t+1$", "Cum", "Org", "Units", "Train", "Proj", ///
    "Underway", "Exists", "Regularly" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)") ///
    multicol(1, 2, 9; 2, 2, 2; 2, 4, 4; 3,2,2) ///
    hlines(110001{0}1) plain fragment nocenter

* ============================================================
* TABLES 9-11 - Marines/USMC vs Army comparison
* Geographic RDD using boundary between Marine and Army zones
* Tests pre-treatment balance and long-run outcomes
* ============================================================

capture program drop regs_geo
program regs_geo
    args outcome add
    regress `outcome' treat lat lon seg2 ///
        if (abs(dbnd)<=25) [aw=oweight], robust cluster(villageid)
    summ `outcome' if e(sample)==1
    local mean : display %4.2f `r(mean)'
    outreg, varlabel nocons `add' se bdec(3) nostars summstat(N) ///
        summtitles("Obs") keep(treat) ///
        addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend
end

capture program drop regs_discon
program regs_discon
    args outcome add
    regress `outcome' treat lat lon elev slope seg2 ///
        if (abs(dbnd)<=25) [aw=oweight], robust cluster(villageid)
    summ `outcome' if e(sample)==1
    local mean : display %4.2f `r(mean)'
    outreg, varlabel nocons `add' se bdec(3) nostars summstat(N) ///
        summtitles("Obs") keep(treat) ///
        addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend
end

capture program drop regs_paas
program regs_paas
    args outcome add
    regress `outcome' treat elev slope ///
        if abs(dbnd)<=100 [aw=n_`outcome'], robust cluster(villageid)
    summ `outcome' [aw=n_`outcome'] if e(sample)==1
    local mean : display %4.2f `r(mean)'
    outreg, varlabel nocons `add' se bdec(3) nostars summstat(N) ///
        summtitles("Obs") keep(treat) ///
        addrows(Clusters, `e(N_clust)' \ Mean, `mean') nolegend
end

capture program drop regs_vndba
program regs_vndba
    use "${data}/marines_hamlet", clear
    keep usid
    foreach Y in 1964 1965 {
        g v`Y' = 1
    }
    reshape long v, i(usid) j(yr)
    drop v
    forvalues Y = 1/12 {
        g v`Y' = 1
    }
    reshape long v, i(usid yr) j(mth)
    drop v
    g date = ym(yr, mth)
    format date %tm
    merge 1:n usid date using "${data}/vndba_all_2k.dta"
    drop if _merge == 2
    drop _merge
    recode en_init (.=0)
    label var en_init "dummy for enemy initiated attack"
    keep if date < ym(1965, 5)
    collapse (mean) en_init, by(usid)
    rename en_init en_init_vndba
    merge 1:1 usid using "${data}/marines_hamlet.dta"
    drop _merge
    regs_discon en_init_vndba replace
end

do  "${root}/code/replication/14_marines_hamlet.do" 25

* Table 9: Pre-treatment balance
quietly regs_vndba

use "${data}/marines_hamlet", clear
quietly regs_geo urban merge
quietly regs_geo elev merge
quietly regs_geo slope merge
quietly regs_discon factory merge
quietly regs_discon market merge
quietly regs_discon milpost merge
quietly regs_discon telegraph merge
quietly regs_discon traintram merge
quietly regs_discon all_roads merge
quietly regs_discon colonial_roads merge

outreg using "${results}/tables/table8", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "", "VC", "", "", "", "", "", "Military", "", "Tram or", ///
    "Total", "Colonial" ///
    \ "","Attack", "Urban", "Elev.", "Slope", "Factory", "Market", ///
    "Post", "Telegraph", "Train", "Road (Km)", "" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)") ///
    multicol(1, 2, 11; 3, 11, 2) hlines(11001{0}1) plain fragment nocenter

* Table 10: Public goods and security
use "${data}/marines_hamlet", clear
quietly regs_discon educ_p1 replace
quietly regs_discon health_p1 merge
quietly regs_discon sec_p1 merge
quietly regs_discon en_pres merge
quietly regs_discon all_atk merge
quietly regs_discon vc_infr merge
quietly regs_discon en_init_sitra merge
quietly replace fr_d = fr_d + fw_d
quietly regs_discon fr_d merge
quietly regs_discon en_d merge
quietly regs_discon admin_p1 merge
quietly regs_discon soccap_p1 merge
quietly regs_discon econ_p1 merge

outreg using "${results}/tables/table9", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "","Educ", "Health", "Secur", "Armed", "VC", "Active", ///
    "VC", "Friendly", "VC", "Admin", "Civic Soc", "Econ" ///
    \ "", "Posterior", "", "", "VC", "Init", "VC", "Attacks", ///
    "Troop", "", "Posterior", "", "" ///
    \ "", "Probability", "", "", "Present", "Attack", "Infr.", ///
    "Troops", "Deaths", "", "Probability", "", "" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)", "(12)") ///
    hlines(110001{0}1) plain fragment nocenter ///
    multicol(1, 2, 11; 3, 2, 3; 4, 2, 3; 3, 11, 3; 4, 11, 3; ///
    3, 9, 2; 4, 9, 2)

* Table 11: Attitudes (PAAS survey data)
use "${data}/marines_paas", clear
quietly regs_paas likesamer replace
foreach V in hatesamer vnamhost_vlow vnamer_harm amepres {
    quietly regs_paas `V' merge
}
quietly regs_paas vconf merge
foreach V in arvn pf rf npvc npord lofsuc {
    quietly regs_paas `V' merge
}

outreg using "${results}/tables/table10", replay replace tex ///
    ctitles("", "Dependent variable is:" ///
    \ "","Respondent", "", "No", "America", "", "Fully", "", ///
    "", "", "Police", "", "Local" ///
    \ "", "Likes", "Hates", "Hostility", "Promotes", "Presence", ///
    "Conf", "ARVN", "PF", "RF", "Effective", "", "Officials" ///
    \ "", "Americans", "", "Am.", "Harmony", "Beneficial", ///
    "in GVN", "Effective", "", "", "VC", "Order", "Effective" ///
    \ "",  "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", ///
    "(8)", "(9)", "(10)", "(11)", "(12)") ///
    multicol(1, 2, 12; 2, 2, 2; 2, 5, 2; 2, 11, 2; ///
    3, 11, 2; 4, 2, 2; 4, 8, 3) ///
    hlines(110001{0}1) plain fragment nocenter

di "03_tables.do complete"