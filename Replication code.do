* Manning (2021) replication: teen wages and employment (7 specifications)
version 18.0
clear all
set more off

use "ManningElusiveEmployment.dta", clear
rename statefips stfips

* Quarter index (only generate if you need it)
capture confirm variable quart
if _rc {
    gen quart = yq(year, qtr)
    format quart %tq
}

* Fixed effects
tab stfips, gen(ss)
tab quart,  gen(tt)

* Common time index used for trends
gen double t = (quart - 70) / 50

* State-specific polynomial time trends (up to quartic)
ds ss*, has(type numeric)
local ssdum `r(varlist)'

forvalues p = 1/4 {
    foreach v of local ssdum {
        gen double t`p'_`v' = `v' * t^`p'
    }
}

* Division-by-time FE
rename region div
gen long time_div = quart*100 + div
tab time_div, gen(dtt)

estimates clear

* --- Wages (lw), teens (agecat==1) ---
reg lw ss* tt* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W1

reg lw ss* tt* t1_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W2

reg lw ss* tt* dtt* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W3

reg lw ss* tt* dtt* t1_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W4

reg lw ss* tt* t2_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W5

reg lw ss* tt* t3_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W6

reg lw ss* tt* t4_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store W7

* --- Employment (ln), teens (agecat==1) ---
reg ln ss* tt* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E1

reg ln ss* tt* t1_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E2

reg ln ss* tt* dtt* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E3

reg ln ss* tt* dtt* t1_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E4

reg ln ss* tt* t2_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E5

reg ln ss* tt* t3_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E6

reg ln ss* tt* t4_* popshare ur lmin [aw=ne] if agecat==1, vce(cluster stfips)
est store E7

* esttab (estout) for export
cap which esttab
if _rc ssc install estout, replace

esttab W1 W2 W3 W4 W5 W6 W7 using "wage_table.rtf", replace ///
    keep(lmin) se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Minimum Wage on Teen Wages")

esttab E1 E2 E3 E4 E5 E6 E7 using "emp_table.rtf", replace ///
    keep(lmin) se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Minimum Wage on Teen Employment")
