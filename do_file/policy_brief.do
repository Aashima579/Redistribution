/******
Goal, Get New Statistics for Policy Brief
******/

** Coonsiidder only 5 years of dataa

global server "g:/Shared drives/"
global levy     "$server/levy_distribution/" 
global US     "$levy/Time Poverty/US/" 
global USLIMTIP     "$US/LIMTIP/" 
global LIMTIPdata "$USLIMTIP/limtip/"
global hhid spmfamunit
use "$USLIMTIP/redistribution_simulation/appended1519.dta", clear   

keep if h_tpoor==1 // Only time poor

bysort year spmu_id month:egen select = max(couple_in_sample==1)
keep if select== 1


// Consider cases with Couples  

bysort year spmu_id month:egen other_mm = max(couple_in_sample!=1 & inrange(age,18,64)  & disable == 0 )

// aprox 89.6% 

// With 0-14 Children

bysort year spmu_id month:egen nchild_014 = sum(inrange(age,0,14))
replace nchild_014=3 if nchild_014>3

// Goal First baseline
gen is_couple = couple_in_sample ==1
tab limtip if inrange(age,18,64), 
tab limtip is_couple if inrange(age,18,64)

tab tpoor sex       if inrange(age,18,64) & is_couple, col nofreq   
tab tpoor sex       if inrange(age,18,64) & is_couple & htype==1, col nofreq   
tab tpoor sex       if inrange(age,18,64) & is_couple & htype==2, col nofreq   
tab tpoor sex       if inrange(age,18,64) & is_couple & htype==3, col nofreq   
tab tpoor sex       if inrange(age,18,64) & is_couple & other_mm ==0, col nofreq
tab tpoor sex       if inrange(age,18,64) & is_couple & other_mm ==1, col nofreq
tab tpoor sex       if inrange(age,18,64) & is_couple & nchild_014 ==0, col nofreq
tab tpoor sex       if inrange(age,18,64) & is_couple & nchild_014>=0, col nofreq

tab tpoor_sc1 sex       if inrange(age,18,64) & is_couple, col nofreq   
tab tpoor_sc1 sex       if inrange(age,18,64) & is_couple & other_mm ==0, col nofreq
tab tpoor_sc1 sex       if inrange(age,18,64) & is_couple & other_mm ==1, col nofreq
tab tpoor_sc1 sex       if inrange(age,18,64) & is_couple & nchild_014 ==0, col nofreq
tab tpoor_sc1 sex       if inrange(age,18,64) & is_couple & nchild_014>=0, col nofreq

tab tpoor_sc2 sex       if inrange(age,18,64) & is_couple, col nofreq   
tab tpoor_sc2 sex       if inrange(age,18,64) & is_couple & other_mm ==0, col nofreq
tab tpoor_sc2 sex       if inrange(age,18,64) & is_couple & other_mm ==1, col nofreq
tab tpoor_sc2 sex       if inrange(age,18,64) & is_couple & nchild_014 ==0, col nofreq
tab tpoor_sc2 sex       if inrange(age,18,64) & is_couple & nchild_014>=0, col nofreq

tab tpoor_sc3 sex       if inrange(age,18,64) & is_couple, col nofreq   
tab tpoor_sc3 sex       if inrange(age,18,64) & is_couple & other_mm ==0, col nofreq
tab tpoor_sc3 sex       if inrange(age,18,64) & is_couple & other_mm ==1, col nofreq
tab tpoor_sc3 sex       if inrange(age,18,64) & is_couple & nchild_014 ==0, col nofreq
tab tpoor_sc3 sex       if inrange(age,18,64) & is_couple & nchild_014>=0, col nofreq