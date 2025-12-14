* Manning extension: spline MW specification
version 18.0
clear all
set more off

* Data
use "ManningElusiveEmployment.dta", clear
rename statefips stfips

* Fixed effects
tab stfips, gen(ss)
tab quart,  gen(tt)

* State-specific polynomial time trends (order 4)
* Build trends off the state dummies that actually exist (avoid hard-coding 1/50)
ds ss*, has(type numeric)
local ssdum `r(varlist)'

forvalues p = 1/4 {
    foreach v of local ssdum {
        gen t`p'_`v' = `v' * ((quart-70)/50)^`p'
    }
}

* Division-by-time FE (kept for the extension, even if not used below)
rename region div
gen long time_div = quart*100 + div
tab time_div, gen(dtt)

* Minimum wage spline (knots at 33rd/66th percentiles)
describe lmin
_pctile lmin, p(33 66)
local k1 = r(r1)
local k2 = r(r2)

mkspline lmin1 `k1' lmin2 `k2' lmin3 = lmin
label var lmin1 "ln(MW) spline: low"
label var lmin2 "ln(MW) spline: mid"
label var lmin3 "ln(MW) spline: high"

* Teens: employment (ln) and wages (lw)
reg ln ss* tt* t1_* t2_* t3_* t4_* ///
    popshare ur lmin1 lmin2 lmin3 ///
    [aw=ne] if agecat==1, vce(cluster stfips)

reg lw ss* tt* t1_* t2_* t3_* t4_* ///
    popshare ur lmin1 lmin2 lmin3 ///
    [aw=ne] if agecat==1, vce(cluster stfips)

* Baseline linear MW
reg ln ss* tt* t1_* t2_* t3_* t4_* ///
    popshare ur lmin ///
    [aw=ne] if agecat==1, vce(cluster stfips)

reg lw ss* tt* t1_* t2_* t3_* t4_* ///
    popshare ur lmin ///
    [aw=ne] if agecat==1, vce(cluster stfips)
