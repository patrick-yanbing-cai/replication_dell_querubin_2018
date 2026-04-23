* ============================================================
* 14_marines_hamlet.do
* Builds hamlet-level dataset for Marines vs Army comparison
* Args: bw (bandwidth in km)
* ============================================================
args bw

cd "${data}"

* ---- Distance to Marine/Army boundary ----
* Identifies which boundary segment is closest to each hamlet
insheet using dist_by_seg.csv, comma clear
foreach N of num 1/3 {
    recode dis_seg`N' (-1=.)
}
egen dbnd = rowmin(dis_seg1 dis_seg2 dis_seg3)
drop if dbnd==.
g seg2 = 0
replace seg2 = 1 if (dbnd==dis_seg2 | dbnd==dis_seg3)
keep id dbnd seg2 lat lon
tempfile data
save `data', replace

* ---- Treatment indicator ----
* First digit of usid: 1=Marines, 2=Army
use coords, clear
keep id usid
merge 1:1 id using `data'
drop if _merge==1
drop _merge

tostring usid, g(temp)
g treat = substr(temp, 1, 1)
destring treat, replace
recode treat (2=0)
drop temp

* Distance and RD polynomial terms
replace dbnd  = dbnd/1000
replace dbnd  = -dbnd if treat==0
g dbnd2       = dbnd^2
rename latwgs lat
rename lonwgs lon
g lat2        = lat^2
g lon2        = lon^2
g treat_dbnd  = treat*dbnd
g treat2_dbnd = treat*dbnd2

tostring usid, g(temp)
g villageid = substr(temp, 1, 7)
destring villageid, replace
drop temp

save marines_data, replace

* ---- Elevation ----
insheet using marines_elev.csv, comma clear
keep id raster
recode raster (-9999=.)
rename raster elev
tempfile data
save `data', replace

use coords, clear
keep id usid
merge 1:1 id using `data'
drop if _merge==1
drop _merge id
merge 1:1 usid using marines_data
drop if _merge==1
drop _merge
save marines_data, replace

* ---- Slope ----
insheet using marines_slope.csv, comma clear
keep id raster
recode raster (-9999=.)
rename raster slope
tempfile data
save `data', replace

use coords, clear
keep id usid
merge 1:1 id using `data'
drop if _merge==1
drop _merge id
merge 1:1 usid using marines_data
drop if _merge==1
drop _merge

keep if abs(dbnd) < `bw'
save marines_data, replace

* ---- LCA outcomes ----
use lca_marines_all6971, clear
tostring usid, g(temp)
g villageid = substr(temp, 1, 7)
destring villageid, replace
merge 1:1 usid villageid using marines_data
keep if _merge==3
drop _merge
save marines_data, replace

* ---- SITRA data ----
use sitra_all2k, clear
merge 1:1 usid villageid using marines_data
drop if _merge==1
drop _merge
save marines_data, replace

* ---- French colonial maps: point features ----
foreach feature in factory market milpost telegraph traintram {
    if "`feature'" == "factory"   local file "fr_factory_dist.csv"
    if "`feature'" == "market"    local file "fr_market_dist.csv"
    if "`feature'" == "milpost"   local file "fr_milpost_dist.csv"
    if "`feature'" == "telegraph" local file "fr_telegraph_dist.csv"
    if "`feature'" == "traintram" local file "fr_traintram_dist.csv"

    insheet using `file', comma clear
    tempfile data
    save `data', replace

    use coords, clear
    keep id usid
    merge 1:1 id using `data'
    drop if _merge==1
    drop _merge id
    merge 1:1 usid using marines_data
    drop if _merge==1
    recode `feature' (.=0)
    drop _merge
    save marines_data, replace
}

* ---- French colonial maps: road networks ----
foreach feature in all_roads colonial_roads {
    if "`feature'" == "all_roads"      local file "fr_road_inter2k.csv"
    if "`feature'" == "colonial_roads" local file "fr_colroad_inter2k.csv"

    insheet using `file', comma clear
    tempfile data
    save `data', replace

    use coords, clear
    keep id usid
    merge 1:1 id using `data'
    drop if _merge==1
    drop _merge id
    merge 1:1 usid using marines_data
    drop if _merge==1
    recode `feature' (.=0)
    drop _merge
    save marines_data, replace
}

keep if abs(dbnd) < `bw'
save marines_data, replace

* ---- HES outcome data ----
use hes_ham_vilg69_71, clear
merge 1:1 usid villageid using marines_data
keep if _merge==3
drop _merge

g latlon = lat*lon
drop if elev==.

* Triangular kernel weights
gen oweight  = .
gen MaxDist  = `bw'
replace oweight = (1-(abs(dbnd)/MaxDist))
replace oweight = 0 if oweight<0
drop MaxDist

label var treat "Marines"
save marines_hamlet, replace

cd "${root}"