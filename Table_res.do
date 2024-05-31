/*cd "g:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\limtip\"
capture matrix drop  bb
forvalues i = 2005/2023 {
    use limtip_us_`i', clear
    bysort spmfamunit:egen htpoor=max(tpoor)
    mean tpoor htpoor adjpoor spmpov   [pw=asecwt] if inrange(age,18,64)
    matrix bb=nullmat(bb)\[`i',e(b)]
}
set scheme white2
color_style bay
capture frame create toplot
frame toplot:clear
frame toplot:lbsvmat bb

frame toplot: {
    foreach i in bb2 bb3 bb4 bb5 { 
        replace `i' = `i'*100
    }
  gen pbb2 = 12  
  scatter   bb2 bb4 bb5 bb1 , connect(l l l l) ///
    legend(order(1 "I. Time Poverty" 2 "LIMTIP" 3 "Base-Income Poverty") pos(6) col(3)) ///
    xtitle("") ytitle("Povery Rate") ylabel(,format(%3.0f) ) ///
    mlabel(bb2 bb3 bb4) mlabformat(%3.1f %3.1f %3.1f) mlabpos(12 6 6)  ///
    yscale(range(5/30)) xscale(range(2003/2025)) ysize(5)  xsize(10) scale(1.5) ///
    graphregion(margin(small)) plotregion(margin(small)) xlabel(2005(5)2020 2023)
  graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\trend.pdf", replace
  graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\trend.png", replace width(1500)
} 

**

cd "g:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation\"
capture matrix drop  _all
forvalues i = 2005 / 2023 {
use red_scenarios_`i'.dta, clear
 
replace tpoor = .  if !inrange(age,18,64)
bysort spmfamunit:egen htpoor=max(tpoor)

drop2 any_tpoor any_npoor net_bal 
bysort spmfamunit: egen any_tpoor = max(tpoor      *inrange(age,18,64)) 
bysort spmfamunit: egen any_npoor = max((1 - tpoor)*inrange(age,18,64)) 
bysort spmfamunit: egen net_bal   = sum(tbalance   *inrange(age,18,64))
bysort spmfamunit: egen spm_nobs   = sum(inrange(age,18,64))

** Reclass of Time Poor
drop2   tpoor_type   
gen     tpoor_type = .
replace tpoor_type = 2 if net_bal   <  0                // Everyone is Time Poor
replace tpoor_type = 3 if any_npoor ! =0 & htpoor == 1  // Not enough to Lift them out of Poverty
replace tpoor_type = 4 if net_bal   >  0 & htpoor == 1  // Can be lift out of poverty
replace tpoor_type = 1 if spm_nobs  == 1                // Single person Household
replace tpoor_type = 0 if htpoor    == 0                // is not Time poor
gen itpoor = tpoor_type * tpoor
mean i.itpoor  [pw=asecwt] if inrange(age,18,64)   
matrix bb = nullmat(bb)\[`i',e(b)]
}
capture frame create toplot
frame toplot:clear
frame toplot:lbsvmat bb

frame toplot:  {
      foreach i in bb6 bb5 bb4 bb3 { 
        gen v`i' = `i'*100
        replace `i' = `i'*100
    }
       
 gen bb65  =bb6+bb5
 gen bb654 =bb6+bb5+bb4
 gen bb6543=bb6+bb5+bb4+bb3
 gen bb0  =0
 drop2 sct*
 gen sct6  = bb6/2
 gen sct65 = bb6 +(bb5/2)
 gen sct654 = bb65+(bb4/2)
 gen sct6543 = bb654+(bb3/2)
 
set scheme white2
color_style bay
two (rbar bb6543 bb0 bb1, barw(0.9)) (rbar bb654 bb0 bb1, barw(0.9)) (rbar bb65 bb0 bb1, barw(0.9)) (rbar bb6 bb0 bb1, barw(0.9)) ///
  (scatter sct6   sct65  sct654 sct6543 bb1, mcolor(%0 %0 %0 %0) mlabsize(10pt  10pt 10pt 10pt) mlabel(vbb6 vbb5 vbb4 vbb3) ///
  mlabformat(%3.1f %3.1f %3.1f %3.1f) mlabpos(0 0 0 0 )  ), xlabel(2005/2023 , alt noticks   ) ///
  scale(1.3) xscale( axis(none)) ysize(5) xsize(10) xtitle("") ytitle("Poverty Rate") ///
  graphregion(margin(small)) plotregion(margin(small))  ///
  legend(order(1 "Single Person" 2 "Irreducible H.T.Poverty" 3 "Reducible I.T.Poverty" 4 "Reducible Hld. T.Povery") pos(6) col(4)) 
 
   graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\tpov_type.pdf", replace
  graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\tpov_type.png", replace width(1500)
} 
*/
****************************************************************************************************

capture matrix drop  _all
forvalues i = 2005 / 2023 {
    tempfile `i'
    use red_scenarios_`i'.dta, clear
    keep if inrange(age,18,64)
    compress 
    bysort spmfamunit:egen htpoor=max(tpoor)

    drop2 any_tpoor any_npoor net_bal 
    bysort spmfamunit: egen any_tpoor = max(tpoor      *inrange(age,18,64)) 
    bysort spmfamunit: egen any_npoor = max((1 - tpoor)*inrange(age,18,64)) 
    bysort spmfamunit: egen net_bal   = sum(tbalance   *inrange(age,18,64))
    bysort year spmfamunit:gen spm_nobs = _N

    ** Reclass of Time Poor
    drop2   tpoor_type   
    gen     tpoor_type = .
    replace tpoor_type = 2 if net_bal   <  0                // Everyone is Time Poor
    replace tpoor_type = 3 if any_npoor ! =0 & htpoor == 1  // Not enough to Lift them out of Poverty
    replace tpoor_type = 4 if net_bal   >  0 & htpoor == 1  // Can be lift out of poverty
    replace tpoor_type = 1 if spm_nobs ==1                  // Single Person HH

    replace tpoor_type = 0 if htpoor    == 0                // is not Time poor
    gen itpoor = tpoor_type * tpoor
    save ``i''
}

clear
forvalues i = 2005 / 2023 {
    append using ``i''
    capture gen year = `i'
    capture replace year = `i' if year ==.
} 
 
*** Profile of Time Povery and Redistribution
 *bysort spmfamunit:egen htpoor=max(tpoor)
 
*************************************************************
label var tpoor_type "Household T. Poverty type"
label define tpoor_type 0 "Not Time Poor", modify
label define tpoor_type 1 "Single Person", modify
label define tpoor_type 2 "Everyone is Time Poor", modify
label define tpoor_type 3 "Time poor/Not poor: Household Remains T. poor", modify
label define tpoor_type 4 "Time poor/Not poor: Household can exit T. poverty", modify
label values tpoor_type tpoor_type

label var    itpoor "Individual T. Poverty type"
label define itpoor 0 "Not Time Poor", modify
label define itpoor 1 "Single Person", modify
label define itpoor 2 "Lives in T-I   household", modify
label define itpoor 3 "Lives in T-II  household", modify
label define itpoor 4 "Lives in T-III household", modify
label values itpoor itpoor

label var    age_g "Age Group"
label define age_g 1 "18/30" 2 "31/45" 3 "46/64", modify
label values age_g age_g 

gen tx_sc1 = tpoor_sc1
gen tx_sc2 = tpoor_sc2 
gen tx_sc3 = tpoor_sc3
replace tx_sc1 = 1-tpoor_sc1 if itpoor!=0
replace tx_sc2 = 1-tpoor_sc2 if itpoor!=0
replace tx_sc3 = 1-tpoor_sc3 if itpoor!=0

bysort year spmfamunit:egen htpoor_sc1=max(tpoor_sc1)

bysort year spmfamunit:egen htpoor_sc2=max(tpoor_sc2)

bysort year spmfamunit:egen htpoor_sc3=max(tpoor_sc3)

 
replace spm_nobs = min(4,spm_nobs)

recode rel_income (-99/1 = 1 "SPM Poor")  (-99/1 = 1 "SPM Poor") (1/2=2 "Non Poor <2 Pl") (2/4 =3 "2-4 Times PL") (4/100 =4 "4+ Times PL"), gen(rel_q)

capture progra drop  tabmean
program tabmean, rclass
    syntax varlist [if] [aw], mvar(varlist) scale(str)
    marksample touse
    gettoken v1 v2:varlist
    levelsof `v1' if `touse', local(lv1)
    tempname mt1 mt2 mtx
    if "`v2'"=="" {
        foreach i of local lv1 {
            sum `mvar' [`weight'`exp'] if `touse' & `v1' == `i', meanonly
            matrix `mt1' = nullmat(`mt1')\r(mean)*`scale'
            local rname `rname'  `i'.`v1'
        }
    }
    else {  
        local v2 = strtrim("`v2'")
        levelsof `v2' if `touse', local(lv2)
        foreach i of local lv1 {
            capture matrix drop `mtx'
            foreach j of local lv2 {
                sum `mvar' [`weight'`exp'] if `touse' & `v1' == `i' & `v2' == `j', meanonly
                matrix `mtx' = nullmat(`mtx'),r(mean)*`scale'
            }
            matrix `mt1' = nullmat(`mt1') \ `mtx'
            local rname `rname'  `i'.`v1'
        }
        
        foreach j of local lv2 {
            local cname `cname' `j'.`v2'
        }
    }
    capture matrix rowname `mt1'=`rname'
    capture matrix colname `mt1'=`cname'
    return matrix ret = `mt1'
end

** Three Scenarios: First Analyzing on Time Poverty
tab itpoor [iw=asecwt], 
tab tpoor_type [iw=asecwt], 
tab itpoor if tpoor_type >=2 [iw=asecwt], 

tabmean itpoor   if tpoor_type >=2 [w=asecwt], mvar(tx_sc1)
matrix mres1 = r(ret)
tabmean itpoor   if tpoor_type >=2 [w=asecwt], mvar(tx_sc2)
matrix mres1 = mres1,r(ret)
tabmean itpoor   if tpoor_type >=2 [w=asecwt], mvar(tx_sc3)
matrix mres1 = mres1,r(ret)

** By X

forvalues qq = 1/3 {
tabmean itpoor    if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = r(ret)

tabmean itpoor  sex if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = mres_sc`qq',r(ret)

tabmean itpoor  haschildren if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = mres_sc`qq',r(ret)

tabmean itpoor  emp if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = mres_sc`qq',r(ret)

tabmean itpoor  educ if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = mres_sc`qq',r(ret)

tabmean itpoor  age_g if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = mres_sc`qq',r(ret)

tabmean itpoor  rel_q if tpoor_type >=2 [w=asecwt], mvar(tx_sc`qq')
matrix mres_sc`qq' = mres_sc`qq',r(ret)
}
 
matrix tot =  mres_sc1',mres_sc2',mres_sc3'
matrix coleq tot = scen1 scen1 scen1 scen2 scen2 scen2 scen3 scen3 scen3 

