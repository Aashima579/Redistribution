/*** 
BRIEF v2 
This dofile should replicate the results I had earlier for the Brief
Unfortunately, original Dofile got lost.

***/
/*
* Not to run Every time

use "J:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation\appended1519.dta", clear
keep if h_tpoor==1
** Note NOBS 266127

bysort year spmfamunit:egen mcp = max(couple_in_sample==1)
drop if mcp==0
save "J:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation\appended1519_small.dta", replace
*/

** Data: "SMall"
** Already has only Time poor households
** Age Constrained
use "J:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\redistribution_simulation\appended1519_small.dta", clear

gen is_couple = couple_order!=99
compress
** Note NOBS 266127
** Family spmfamunit
bysort year spmfamunit:egen ychild= sum(inrange(age,0,14))
keep if inrange(age,18,64)
replace ychild = ychild>0
bysort year spmfamunit:egen max_iscouple = sum(is_couple)
keep if max_iscouple==2

bysort year spmfamunit:gen flagx=_n
keep if inrange(age,18,64)
drop2 other_mm
bysort year spmfamunit:egen other_mm= sum(!is_couple) 
replace other_mm=other_mm>0
** ID 
 ** there are few cases with More than one couple


tab ychild [aw=asecwth] if flagx==1 & max_iscouple==2
tab other_mm [aw=asecwth] if flagx==1

keep if inrange(age,18,64)
keep if is_couple==1  

bysort year spmfamunit (sex):gen work_1 = wkswork1[1]>0
bysort year spmfamunit (sex):gen work_2 = wkswork1[2]>0

** REl income
recode rel_income (-999/1 =1  "<Pline") (1/2 = 2 "1-2 x Pline") ///
                  (2/4 =3 "2-4 x Pline")  (4/999 =4 ">4 Pline"), gen(rel_pinc)
** OBS 138,668 


** Table 1
tab htype, gen(ht_)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] , save
matrix tb1 = r(StatTotal)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] if ychild, save
matrix tb1 = tb1\r(StatTotal)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] if !ychild , save
matrix tb1 = tb1\r(StatTotal)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] if other_mm, save
matrix tb1 = tb1\r(StatTotal)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] if !other_mm, save
matrix tb1 = tb1\r(StatTotal)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] if work_2, save
matrix tb1 = tb1\r(StatTotal)
tabstat ht_1 ht_2 ht_3 ychild other_mm work_1 work_2 [aw=asecwth] if !work_2, save
matrix tb1 = tb1\r(StatTotal)

matrix tb1=tb1*100
matrix rowname tb1 = b1 b2 b3 b4 b5 b6 b7

    
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1, save
matrix tb2a = r(StatTotal)

tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & tpoor==0, save
matrix tb2a = tb2a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & tpoor==1, save
matrix tb2a = tb2a\r(StatTotal)\J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & htype==2, save
matrix tb2a = tb2a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & htype==3, save
matrix tb2a = tb2a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & htype==4, save
matrix tb2a = tb2a\r(StatTotal)

tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2, save
matrix tb2b = r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & tpoor==0, save
matrix tb2b = tb2b\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & tpoor==1, save
matrix tb2b = tb2b\r(StatTotal)\J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & htype==2, save
matrix tb2b = tb2b\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & htype==3, save
matrix tb2b = tb2b\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & htype==4, save
matrix tb2b = tb2b\r(StatTotal)    

matrix tb2a=tb2a*100
matrix tb2b=tb2b*100

matrix rowname tb2a = b1 b2 b3 b4 b5 b6 b7
matrix rowname tb2b = b1 b2 b3 b4 b5 b6 b7

matrix tb2 = tb2a,tb2b


** TB3 
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1, save
matrix tb3a = J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & ychild==0, save
matrix tb3a = tb3a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & ychild==1, save
matrix tb3a = tb3a\r(StatTotal)\J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & other_mm==0, save
matrix tb3a = tb3a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & other_mm==1, save
matrix tb3a = tb3a\r(StatTotal) 

tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2, save
matrix tb3b = J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & ychild==0, save
matrix tb3b = tb3b\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & ychild==1, save
matrix tb3b = tb3b\r(StatTotal)\J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & other_mm==0, save
matrix tb3b = tb3b\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & other_mm==1, save
matrix tb3b = tb3b\r(StatTotal) 

matrix tb3 = 100*(tb3a,tb3b)
matrix rowname tb3 = b1 b2 b3 b4 b5 b6  


* TB4
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & rel_pinc==1,  save
matrix tb4a = J(1,4,.)\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & rel_pinc==2, save
matrix tb4a = tb4a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & rel_pinc==3, save
matrix tb4a = tb4a\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & rel_pinc==4, save
matrix tb4a = tb4a\r(StatTotal)\J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & work_2==0, save
matrix tb4a = tb4a\r(StatTotal) 
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==1 & work_2==1, save
matrix tb4a = tb4a\r(StatTotal) 

tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & rel_pinc==1,  save
matrix tb4b = J(1,4,.)\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & rel_pinc==2, save
matrix tb4b = tb4b\r(StatTotal)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & rel_pinc==3, save
matrix tb4b = tb4b\r(StatTotal) 
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & rel_pinc==4, save
matrix tb4b = tb4b\r(StatTotal)\J(1,4,.)
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & work_2==0, save
matrix tb4b = tb4b\r(StatTotal) 
tabstat tpoor tpoor_sc1 tpoor_sc2 tpoor_sc3 [aw=asecwth] if sex==2 & work_2==1, save
matrix tb4b = tb4b\r(StatTotal) 

matrix tb4 = 100*(tb4a,tb4b)
matrix rowname tb4 = b1 b2 b3 b4 b5 b6 b7 b8 

tabstat spmpov adjp* [aw=asecwth] , save
matrix tb5 = r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if htype==2, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if htype==3, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if htype==4, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if ychild==0, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if ychild==1, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if other_mm==0, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if other_mm==1, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if rel_pinc==2, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if rel_pinc==3, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if work_2==0, save
matrix tb5 = tb5\r(StatTotal)
tabstat spmpov adjp* [aw=asecwth] if work_2==1, save
matrix tb5 = tb5\r(StatTotal)
matrix list tb5
matrix tb5=tb5*100
matrix tb5=tb5[....,2]-tb5[....,1], ///
           tb5[....,3]-tb5[....,1], ///
           tb5[....,4]-tb5[....,1], ///
           tb5[....,5]-tb5[....,1]
** Official Poverty
matrix roweq tb5 = a b b b c c d d e e f f 
matrix rowname tb5 = b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11
esttab matrix(tb1, fmt(%5.1f)) , nomtitle ///
    collabel("All Mem TP" "At Least 1m NTP" ///
    "HHld Can exit TP" "Has Y.Children" "Oth Mem Present" ///
    "H. Working " "W. Working") ///
    varlabel( ///
    b1 "All" ///
    b2 "Has Y.Children" ///
    b3 "No Y.Children" ///
    b4 "Other H Member" ///
    b5 "No Other Member" ///
    b6 "Wife Works" b7 "Wife Not working")   tex

esttab matrix(tb2, fmt(%5.1f)) , nomtitle ///
    collabel("BL" "S.1" "S.2" "S. 3" "BL" "S.1" "S.2" "S. 3") ///
    varlabel(b1 "All" b2 "BL: Time NP" b3 "BL: Time P" ///
    b4 "Household Type" b5 "\ All Mem. TP " ///
    b6 "\ At Least 1 Mem.time NP" b7 "\ Hhld can exit TP") 
    tex
    
esttab matrix(tb3, fmt(%5.1f)) , nomtitle ///
    collabel("BL" "S.1" "S.2" "S. 3" "BL" "S.1" "S.2" "S. 3") ///
    varlabel(b1 "Yng Children Presence" b2 "\ No Children" b3 "\ With Children" ///
    b4 "Other Members in HH" b5 "\ No " ///
    b6 "\ Yes") 
    
 esttab matrix(tb4, fmt(%5.1f)) , nomtitle ///
    collabel("BL" "S.1" "S.2" "S. 3" "BL" "S.1" "S.2" "S. 3") ///
    varlabel( ///
    b1 "Income/Pline" ///
    b2 "\ < Pline" ///
    b3 "\ 1-2 x Pline" ///
    b4 "\ 2-4 x Pline" ///
    b5 "\ > 4 x Pline" ///
    b6 "Wife Works Status" ///
    b7 "\ Not working" ///
    b8 "\ Working")  
    tex
    
esttab matrix(tb5, fmt(%5.1f)) , nomtitle ///
    collabel("BL" "S.1" "S.2" "S. 3" "BL" "S.1" "S.2" "S. 3") ///
    varlabel( ///
    b1 "All" ///
    b2 "\ All Mem. TP " ///
    b3 "\ At Least 1 Mem.time NP"  ///
    b4 "\ Hhld can exit TP" ///
    b5 "\ No Children"  ///
    b6 "\ With Children"  ///
    b7 "\ No" ///
    b8 "\ Yes" ///
    b9 "\ 1-2 x Pline" ///
    b10 "\ 2-4 x Pline" ///
    b11 "\ Not working" ///
    b12 "\ Working")   ///
    eqlabel("" "Household Type" "Yng Children Presence" ///
    "Other Members in HH" "Income/Pline" "Wife Work Status") 
    tex
    
        