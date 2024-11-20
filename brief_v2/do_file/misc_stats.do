*Redistribution Brief2 Appended 15-19 LIMTIP 
*Miscel stats on the brief

use "$levy/Time Poverty/US/LIMTIP/redistribution_simulation/appended1519.dta", clear

fre h_tpoor [aw=asecwth] 
fre h_tpoor [aw=asecwth] if couple_in_sample==1
bys tpoor: tab couple_in_sample [aw=asecwth] if h_tpoor ==1
bys sex: tab tpoor [aw=asecwth] if couple_in_sample==1 & h_tpoor ==1
bys sex: tab emp if couple_in_sample==1 & h_tpoor ==1
bys	sex: tabstat	srhp	[w=asecwth]	if	couple_in_sample==1,	by(limtip_year)	stats(mean	sd	n)
bys	sex: tabstat	tdefw	[w=asecwth]	if	couple_in_sample==1,	by(limtip_year)	stats(mean	sd	n)