*** Redistribution Graphs
cd "g:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation"
*** First Agg all years
capture frame drop agg
capture frame create agg
forvalues i = 2005/2023 {
    use red_scenarios_`i', clear
    drop if htype == 0 | htype == 1
    keep if inrange(age,18,64)
    compress
    tempfile r`i'
    save `r`i'', replace
    frame agg:append using `r`i''
}
frame change agg
frame drop default
frame put *, into(default)
frame change default

replace couple_in_sample = couple_in_sample==1

tabstat2 spmpov tpoor adjpoor [aw= asecwth ], by(h_tpoor) save

matrix res =  r(tmatrix2)'*100
tab h_tpoor [iw= asecwth ], matcell(s0)
mata:st_matrix("shr",(st_matrix("s0"):/sum(st_matrix("s0"))*100)')
matrix res = shr\res
matrix colname res = "Time not-poor Household" "Time poor Household"
matrix rowname res = "Share" "SPM-Poverty" "Ind Time Poverty" "Adj Poverty/LIMTIP"

esttab matrix(res, fmt(%3.1f)), tex

drop2 ptype2 
gen byte ptype2 = 0 if disable==1
replace  ptype2 = 1 if disable==0 & couple_in_sample ==1 & sex == 1 
replace  ptype2 = 2 if disable==0 & couple_in_sample ==1 & sex == 2 
replace  ptype2 = 3 if disable==0 & couple_in_sample ==0

tab htype ptype2 [aw=asecwth], sum(tpoor) nofreq nost noobs
egen gg = group(htype ptype2)
sort gg
mata:
dta= st_data(.,"gg htype ptype2 asecwth tpoor_sc1")
info = panelsetup(dta[,1],1)
ww = panelsum(dta[,5],dta[,4],info):/panelsum(dta[,4],info)
ww = ww,uniqrows(dta[,(2,3)])
mns = J(5,4,0)

for(i=1;i<=5;i++){
    for(j=1;j<=4;j++){
        if (sum((ww[,2]:==(i-1)):*(ww[,3]:==(j-1)))>0)     mns[i,j] = select(ww[,1],(ww[,2]:==(i-1)):*(ww[,3]:==(j-1)))
    }
}
end
mata:st_matrix("res2",mns)
** Small Table
**
** Classification
gen byte new_class = 1 if sex == 1 & couple_in_sample == 1
replace  new_class = 2 if sex == 2 & couple_in_sample == 1
replace  new_class = 3 if couple_in_sample != 1
label define new_class 1 "Married: Men", modify
label define new_class 2 "Married: Women", modify
label define new_class 3 "Other Member", modify
label values new_class new_class 

capture frame drop coll
frame put tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3  tdef tdef_sc1 tdef_sc2 tdef_sc3 tbal* new_class asecwth ptype, into(coll)
frame coll: {
    foreach i of varlist tbal* {
                replace `i'=max(`i',0)
    }    
}
frame coll: collapse tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3  tdef tdef_sc1 tdef_sc2 tdef_sc3 tbal* [w=asecwth], by(ptype new_class)
frame coll: {
    foreach i of varlist tpoor*   {
                replace `i'=`i'*100
    }    
    foreach i of varlist tpoor* {
                replace `i'=100-`i' if ptype !=0
    }
}

** Figures
set scheme white2
color_style  bay
cd "C:\Users\Fernando\Documents\GitHub\Redistribution\resources_brief"
frame coll: {
    graph bar (asis) tpoor_sc1 tpoor_sc2 tpoor_sc3 if new_class==1, over(ptype) ///
        legend(order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3") pos(6) row(1)) ///
        ytitle("Transition Rate") graphregion(margin(zero)) blabel(bar, format(%3.1f)) ///
        xsize(10) ysize(5) scale(1.5)
    graph export "poverty_men.pdf", replace
    graph export "poverty_men.png", replace width(1500)           
    
    graph bar (asis) tpoor_sc1 tpoor_sc2 tpoor_sc3 if new_class==2, over(ptype) ///
        legend(order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3") pos(6) row(1)) ///
        ytitle("Transition Rate") graphregion(margin(zero)) blabel(bar, format(%3.1f)) ///
        xsize(10) ysize(5) scale(1.5)
    graph export "poverty_wmen.pdf", replace
    graph export "poverty_wmen.png", replace width(1500)                   
    
    graph bar (asis) tpoor_sc1 tpoor_sc2 tpoor_sc3 if new_class==3, over(ptype) ///
        legend(order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3") pos(6) row(1)) ///
        ytitle("Transition Rate") graphregion(margin(zero)) blabel(bar, format(%3.1f)) ///
        xsize(10) ysize(5) scale(1.5)
    graph export "poverty_other.pdf", replace
    graph export "poverty_other.png", replace width(1500)           
    
    graph bar (asis) tdef tdef_sc1 tdef_sc2 tdef_sc3 if new_class==1, over(ptype) ///
        legend(order(1 "Baseline" 2 "Scenario 1" 3 "Scenario 2" 4 "Scenario 3") pos(6) row(1)) ///
        ytitle("Time Deficit") graphregion(margin(zero)) ///
        blabel(bar, format(%3.1f)) ///
        bar(1, color(gs4))  bar(2, bstyle(p1)) bar(3, bstyle(p2)) bar(4, bstyle(p3)) ///
        xsize(10) ysize(5) scale(1.5) 
    graph export "tdef_men.pdf", replace
    graph export "tdef_men.png", replace width(1500)                   
    
    graph bar (asis) tdef tdef_sc1 tdef_sc2 tdef_sc3 if new_class==2, over(ptype) ///
        legend(order(1 "Baseline" 2 "Scenario 1" 3 "Scenario 2" 4 "Scenario 3") pos(6) row(1)) ///
        ytitle("Time Deficit") graphregion(margin(zero)) ///
        blabel(bar, format(%3.1f)) ///
        bar(1, color(gs4))  bar(2, bstyle(p1)) bar(3, bstyle(p2)) bar(4, bstyle(p3)) ///
        xsize(10) ysize(5) scale(1.5)
    graph export "tdef_wmen.pdf", replace
    graph export "tdef_wmen.png", replace width(1500)                   
    
    graph bar (asis) tdef tdef_sc1 tdef_sc2 tdef_sc3 if new_class==3, over(ptype) ///
        legend(order(1 "Baseline" 2 "Scenario 1" 3 "Scenario 2" 4 "Scenario 3") pos(6) row(1)) ///
        ytitle("Time Deficit") graphregion(margin(zero)) ///
        blabel(bar, format(%3.1f)) ///
        bar(1, color(gs4))  bar(2, bstyle(p1)) bar(3, bstyle(p2)) bar(4, bstyle(p3)) ///
        xsize(10) ysize(5) scale(1.5)   
    graph export "tdef_other.pdf", replace
    graph export "tdef_other.png", replace width(1500)                           
}

** Out of Poverty household

capture frame drop coll
frame put h_tpoor* new_class htype asecwth , into(coll)
 frame coll: collapse h_tpoor*, by(htype new_class)
frame coll:{
    foreach i of varlist h_tpoor* {
        replace `i' = 100-`i'*100
    }
}
frame coll:{
    
    graph bar (asis) h_tpoor_* if htype==4, over(new_class) ///
       legend(order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3") pos(6) row(1)) ///
        ytitle("H.H. Transition Rate") graphregion(margin(zero)) blabel(bar, format(%3.1f)) ///
        xsize(10) ysize(5) scale(1.5)
    graph export "hhtrate.pdf", replace
    graph export "hhtrate.png", replace width(1500)     
    
}


capture frame drop coll
frame put spmpov adjpoor adjpoor_sc1 adjpoor_sc2 adjpoor_sc3 new_class htype asecwth , into(coll)
frame coll: collapse spmpov adjpoor adjpoor_sc1 adjpoor_sc2 adjpoor_sc3 [w=asecwth], by(htype new_class)
frame coll: {
    foreach i of varlist spmpov adjpoor adjpoor_sc1 adjpoor_sc2 adjpoor_sc3 {
        replace `i'=`i'*100
    }
}

frame coll:{
    
    graph bar (asis) spmpov adjpoor adjpoor_sc1 adjpoor_sc2 adjpoor_sc3 if new_class==1, over(htype) ///
    legend(order(1 "Baseline" 2 "LIMTIP" 3 "Scenario 1" 4 "Scenario 2" 5 "Scenario 3") pos(6) row(1)) ///
    ytitle("Poverty rate") graphregion(margin(zero)) ///
    blabel(bar, format(%3.1f)) ///
    bar(1, color(gs4)) bar(2, color(gs7)) ///
    bar(3, bstyle(p1)) bar(4, bstyle(p2)) bar(5, bstyle(p3)) ///
    xsize(10) ysize(5) scale(1.5) ylabel(0(5)20) yscale(range(0 20.1)) name(s, replace)
    graph export "hh_pov_hw.pdf", replace
    graph export "hh_pov_hw.png", replace width(1500)       
        graph bar (asis) spmpov adjpoor adjpoor_sc1 adjpoor_sc2 adjpoor_sc3 if new_class==3, over(htype) ///
    legend(order(1 "Baseline" 2 "LIMTIP" 3 "Scenario 1" 4 "Scenario 2" 5 "Scenario 3") pos(6) row(1)) ///
    ytitle("Poverty rate") graphregion(margin(zero)) ///
    blabel(bar, format(%3.1f)) ///
    bar(1, color(gs4)) bar(2, color(gs7)) ///
    bar(3, bstyle(p1)) bar(4, bstyle(p2)) bar(5, bstyle(p3)) ///
    xsize(10) ysize(5) scale(1.5) 
    graph export "hh_pov_oth.pdf", replace
    graph export "hh_pov_oth.png", replace width(1500)       
}

tabstat2 spmpov adj* [w=asecwth] , by(htype) save
matrix res = r(tmatrix2)\r(StatTotal)
matrix res = res*100   

frame toplot: {
    clear
    svmat res
    gen n=_n
    replace n=0 if n==4
    ren n group
label define group 0 "All Households" 1 "H.H. Type I" 2 "H.H. Type II" 3 "H.H. Type III", modify
label values group group
set scheme white2
color_style bay
graph bar res1 res2 res3 res4 res5, by(group, note("") row(1) scale(1.5)) ///
    blabel(bar, format(%3.1f))  ///
    bar(1, color(gs4)) bar(2, color(gs7)) ///
    bar(3, bstyle(p1)) bar(4, bstyle(p2)) bar(5, bstyle(p3)) ///
    legend(order(1 "Baseline" 2 "LIMTIP" 3 "Scenario 1" 4 "Scenario 2" 5 "Scenario 3") pos(6) row(1)) ///
    ytitle("Poverty rate") graphregion(margin(zero))   scale(1.5) yscale(range(0 12)) ///    
    ysize(4) xsize(10) 
    graph export "hh_pov.pdf", replace
    graph export "hh_pov.png", replace width(1500) 
}

tabstat2 spmpov adj* [w=asecwth] if couple_in_sample, by(htype) save
matrix res = r(tmatrix2)\r(StatTotal)
matrix res = res*100   

frame toplot: {
    clear
    svmat res
    gen n=_n
    replace n=0 if n==4
    ren n group
label define group 0 "All Households" 1 "H.H. Type I" 2 "H.H. Type II" 3 "H.H. Type III", modify
label values group group
set scheme white2
color_style bay
graph bar res1 res2 res3 res4 res5, by(group, note("") row(1) scale(1.5)) ///
    blabel(bar, format(%3.1f))  ///
    bar(1, color(gs4)) bar(2, color(gs7)) ///
    bar(3, bstyle(p1)) bar(4, bstyle(p2)) bar(5, bstyle(p3)) ///
    legend(order(1 "Baseline" 2 "LIMTIP" 3 "Scenario 1" 4 "Scenario 2" 5 "Scenario 3") pos(6) row(1)) ///
    ytitle("Poverty rate") graphregion(margin(zero))   scale(1.5) yscale(range(0 12)) ///    
    ysize(4) xsize(10) 
    graph export "hh_pov_couple.pdf", replace
    graph export "hh_pov_couple.png", replace width(1500) 
}
 
tabstat2 spmpov adj* [w=asecwth] if !couple_in_sample, by(htype) save
matrix res = r(tmatrix2)\r(StatTotal)
matrix res = res*100   
 
 frame toplot: {
    clear
    svmat res
    gen n=_n
    replace n=0 if n==4
    ren n group
label define group 0 "All Households" 1 "H.H. Type I" 2 "H.H. Type II" 3 "H.H. Type III", modify
label values group group
set scheme white2
color_style bay
graph bar res1 res2 res3 res4 res5, by(group, note("") row(1) scale(1.5)) ///
    blabel(bar, format(%3.1f))  ///
    bar(1, color(gs4)) bar(2, color(gs7)) ///
    bar(3, bstyle(p1)) bar(4, bstyle(p2)) bar(5, bstyle(p3)) ///
    legend(order(1 "Baseline" 2 "LIMTIP" 3 "Scenario 1" 4 "Scenario 2" 5 "Scenario 3") pos(6) row(1)) ///
    ytitle("Poverty rate") graphregion(margin(zero))   scale(1.5) yscale(range(0 12)) ///    
    ysize(4) xsize(10) 
    graph export "hh_pov_Other.pdf", replace
    graph export "hh_pov_Other.png", replace width(1500) 
}