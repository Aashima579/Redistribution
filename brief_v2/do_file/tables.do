*** Tables forReplication

 ** Load data 
use "J:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation\appended1519_small.dta", clear
bysort year spmu_id: gen hasychildren = sum(inrange(age,0,6))

** Table 1
keep if is_couple
gen work_1 =.
gen work_2 =.
bysort year spmu_id (sex):replace work_1 = wkswork1[1]!=0
bysort year spmu_id (sex):replace work_2 = wkswork2[2]!=0
tab htype , gen(ht_)
tabstat ht_1 ht_2 ht_3 hasychildren other_mm work_1 work_2 if inrange(age,18,64) & is_couple==1 [w=asecwt] 

tabstat ht_1 ht_2 ht_3 hasychildren other_mm work_1 work_2 if inrange(age,18,64) & is_couple==1 & !other_mm  [w=asecwt] 
tabstat ht_1 ht_2 ht_3 hasychildren other_mm work_1 work_2 if inrange(age,18,64) & is_couple==1 & other_mm  [w=asecwt] 

tabstat ht_1 ht_2 ht_3 hasychildren other_mm work_1 work_2 if inrange(age,18,64) & is_couple==1 & work_2  [w=asecwt] 