*Redistribution Brief2 Appended 15-19 LIMTIP 
*Miscel stats on the brief

use "$levy/Time Poverty/US/LIMTIP/redistribution_simulation/appended1519.dta", clear
bys year spmfamunit: gen flagh= _n
bys year spmfamunit: egen hcouple_in_sample= max(couple_in_sample==1)
bys year spmfamunit: egen flag1864=max(inrange(age, 18, 64))
bys year spmfamunit: egen flag2=max(intimecalc_redist==1)
gen iscouple=0
replace iscouple=1 if couple_in_sample==1

drop if flag1864==0


gen byte insample = 0
replace  insample = 1 if inrange(age,18,64) & disable == 0
	
	
* add Note: stats correspond  to hh with atleast one eligible person in 18-64 and not disabled. 
fre h_tpoor [aw=asecwth] if flagh==1 & flag2==1
fre h_tpoor [aw=asecwth] if hcouple_in_sample==1 & flagh==1 & flag2==1


tab iscouple tpoor [aw=asecwth] if hcouple_in_sample==1 & flag2==1 & h_tpoor==1, nofreq row

tab sex tpoor [aw=asecwth] if hcouple_in_sample==1 & flag2==1 & h_tpoor==1 & iscouple , nofreq row

bys	sex: tabstat	srhp	[w=asecwth]	if	couple_in_sample==1,	by(limtip_year)	stats(mean	sd	n)
bys	sex: tabstat	tdefw	[w=asecwth]	if	couple_in_sample==1 ,	by(limtip_year)	stats(mean	sd	n)


