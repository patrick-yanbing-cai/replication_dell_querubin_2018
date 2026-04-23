* ============================================================
* 10_rd_reg.do
* 2SLS IV regression for RDD analysis
* Instruments bombing (fr_strikes_mean) with below-threshold
* indicator (below), controlling for RD polynomial terms and
* HES question response controls
* Args: outcome add
* ============================================================
args outcome add

cd "${data}"

* 2SLS: below threshold instruments for bombing intensity
* FE: RD polynomial (md_*), threshold pair dummies (ab bc cd de),
* quarter FE (i.qdate), HES controls (vmb22-vt54)
quietly ivregress 2sls `outcome' ///
    (fr_strikes_mean=below) md_* ab bc cd de ///
    i.qdate vmb22-vt54 [aw=oweight20], ///
    nocons robust cluster(villageid)

* First stage F-statistic (instrument strength)
quietly estat firststage
mat fstat   = r(singleresults)
local fs    = fstat[1,4]
local fstat : display %4.2f `fs'

* Sample mean of outcome
quietly summ `outcome' if e(sample)==1 [aw=oweight20]
local mean : display %4.2f `r(mean)'

* Output to outreg buffer
quietly outreg, tex varlabel nocons `add' se bdec(3) nostars ///
    summstat(N) summtitles("Obs") keep(fr_strikes_mean) ///
    addrows(Clusters, `e(N_clust)' \ "F stat", `fstat' \ Mean, `mean') ///
    nolegend

cd "${root}"