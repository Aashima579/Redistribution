global server "/Users/aashimasinha/Library/CloudStorage/GoogleDrive-asinha@levy.org/"
cd "$server/Shared drives/levy_distribution/Time Poverty/US/LIMTIP/redistribution_simulation"

*** First Agg all years
capture frame drop agg
capture frame create agg
forvalues i = 2005/2023 {
    use red_scenarios_`i', clear
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
cd "/Users/aashimasinha/Documents/GitHub/Redistribution/resources_brief"
global resources_brief "/Users/aashimasinha/Documents/GitHub/Redistribution/resources_brief"
esttab matrix(res, fmt(%3.1f)) using "$resources_brief/table1.tex", replace

** Classification
gen byte new_class = 1 if sex == 1 & couple_in_sample == 1
replace  new_class = 2 if sex == 2 & couple_in_sample == 1
replace  new_class = 3 if couple_in_sample != 1
label define new_class 1 "Married: Men", modify
label define new_class 2 "Married: Women", modify
label define new_class 3 "Other Member", modify
label values new_class new_class 

tabstat2 new_class[aw= asecwth ], by(htype) save


