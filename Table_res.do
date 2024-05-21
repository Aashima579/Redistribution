cd "J:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\limtip\"
matrix drop bb
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

cd "J:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation\"
matrix drop _all
forvalues i = 2005 / 2023 {
use red_scenarios_`i'.dta, clear
 
replace tpoor = .  if !inrange(age,18,64)
bysort spmfamunit:egen htpoor=max(tpoor)

drop2 any_tpoor any_npoor net_bal 
bysort spmfamunit: egen any_tpoor = max(tpoor      *inrange(age,18,64)) 
bysort spmfamunit: egen any_npoor = max((1 - tpoor)*inrange(age,18,64)) 
bysort spmfamunit: egen net_bal   = sum(tbalance   *inrange(age,18,64))

** Reclass of Time Poor
drop2   tpoor_type   
gen     tpoor_type = .
replace tpoor_type = 1 if net_bal   <  0                // Everyone is Time Poor
replace tpoor_type = 2 if any_npoor ! =0 & htpoor == 1  // Not enough to Lift them out of Poverty
replace tpoor_type = 3 if net_bal   >  0 & htpoor == 1  // Can be lift out of poverty
replace tpoor_type = 0 if htpoor    == 0                // is not Time poor
gen itpoor = tpoor_type * tpoor
mean i.itpoor  [pw=asecwt] if inrange(age,18,64)   
matrix bb = nullmat(bb)\[`i',e(b)]
}

frame toplot:clear
frame toplot:lbsvmat bb

frame toplot:  {
      foreach i in bb5 bb4 bb3 { 
        gen v`i' = `i'*100
        replace `i' = `i'*100
    }
       
 gen bb54 =bb5+bb4
 gen bb543=bb5+bb4+bb3
 gen bb0  =0
 drop2 sct*
 gen sct5  = bb5/2
 gen sct54 = bb5 +(bb4/2)
 gen sct543 = bb54+(bb3/2)
 

two (rbar bb543 bb0 bb1, barw(0.9)) (rbar bb54 bb0 bb1, barw(0.9)) (rbar bb5 bb0 bb1, barw(0.9)) ///
  (scatter sct5   sct54  sct543 bb1, mcolor(%0 %0 %0) mlabsize(11pt 11pt 11pt) mlabel(vbb5 vbb4 vbb3) ///
  mlabformat(%3.1f %3.1f %3.1f) mlabpos(0 0 0) mlabangle(90 90 90)), xlabel(2005/2023 , alt noticks   ) ///
  scale(1.3) xscale( axis(none)) ysize(5) xsize(10) xtitle("") ytitle("Poverty Rate") ///
  graphregion(margin(small)) plotregion(margin(small))  ///
  legend(order(1 "Irreducible T.Poverty" 2 "Reducible Ind. T.Poverty" 3 "Reducible Hld. T.Povery") pos(6) col(3)) 
 
   graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\tpov_type.pdf", replace
  graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\tpov_type.png", replace width(1500)
} 

 
 
*** Profile of Time Povery and Redistribution
replace tpoor = .  if !inrange(age,18,64)
bysort spmfamunit:egen htpoor=max(tpoor)

drop2 any_tpoor any_npoor net_bal 
bysort spmfamunit: egen any_tpoor = max(tpoor      *inrange(age,18,64)) 
bysort spmfamunit: egen any_npoor = max((1 - tpoor)*inrange(age,18,64)) 
bysort spmfamunit: egen net_bal   = sum(tbalance   *inrange(age,18,64))
drop2   tpoor_type   
gen     tpoor_type = .
replace tpoor_type = 1 if net_bal   <  0                // Everyone is Time Poor
replace tpoor_type = 2 if any_npoor ! =0 & htpoor == 1  // Not enough to Lift them out of Poverty
replace tpoor_type = 3 if net_bal   >  0 & htpoor == 1  // Can be lift out of poverty
replace tpoor_type = 0 if htpoor    == 0                // is not Time poor
gen itpoor = tpoor_type * tpoor
mean i.itpoor  [pw=asecwt] if inrange(age,18,64)   

tab itpoor tpoor_sc1  if itpoor>=2 [iw=asecwt], row nofreq
tab itpoor tpoor_sc2   if itpoor>=2 [iw=asecwt], row nofreq
tab itpoor tpoor_sc3   if itpoor>=2 [iw=asecwt], row nofreq

** HH 
bysort spmfamunit:egen htpoor_sc1=max(tpoor_sc1)
bysort spmfamunit:egen htpoor_sc2=max(tpoor_sc2)
bysort spmfamunit:egen htpoor_sc3=max(tpoor_sc3)

tab tpoor_type htpoor_sc1 if tpoor_type>=2 [iw=asecwt], row nofreq
tab tpoor_type htpoor_sc2 if tpoor_type>=2 [iw=asecwt], row nofreq
tab tpoor_type htpoor_sc3 if tpoor_type>=2 [iw=asecwt], row nofreq