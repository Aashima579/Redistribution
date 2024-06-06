cd "j:\Shared drives\levy_distribution\Time Poverty\US\LIMTIP\limtip\"
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
  scatter   bb2   bb4 bb5 bb1 , connect(l l l l)  ///
    legend(order(1 "I. Time Poverty" 2 "LIMTIP" 3 "Base-Income Poverty") pos(6) col(3)) ///
    xtitle("") ytitle("Povery Rate") ylabel(,format(%3.0f) ) ///
    mlabel(bb2    bb4 bb5) mlabformat(%3.1f %3.1f %3.1f %3.1f) mlabpos(12 12 6 6)  ///
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
replace itpoor = 5 if tpoor == 0 & htpoor!=0
mean i.itpoor  [pw=asecwt] if inrange(age,18,64)   
matrix bb = nullmat(bb)\[`i',e(b)]
}
capture frame create toplot
frame toplot:clear
frame toplot:lbsvmat bb

frame toplot:  {
      foreach i in bb7 bb6 bb5 bb4 bb3 { 
        gen v`i' = `i'*100
        replace `i' = `i'*100
    }
 
 gen bb76   =bb7+bb6
 gen bb765  =bb7+bb6+bb5
 gen bb7654 =bb7+bb6+bb5+bb4
 gen bb76543=bb7+bb6+bb5+bb4+bb3
 
 
 gen bb0  =0
 drop2 sct*
 gen sct7     = bb7/2
 gen sct76    = bb7 +(bb6/2)
 gen sct765   = bb76+(bb5/2)
 gen sct7654  = bb765+(bb4/2)
 gen sct76543 = bb7654+(bb3/2)
set scheme white2
color_style bay
two (rbar bb76543 bb0 bb1, barw(0.9)) (rbar bb7654 bb0 bb1, barw(0.9)) (rbar bb765 bb0 bb1, barw(0.9)) (rbar bb76 bb0 bb1, barw(0.9)) (rbar bb7 bb0 bb1, barw(0.9)) ///
  (scatter sct7   sct76  sct765 sct7654 sct76543 bb1, mcolor(%0 %0 %0 %0 %0) mlabsize(9pt  9pt 9pt  9pt 9pt) mlabel(vbb7 vbb6 vbb5 vbb4 vbb3) ///
  mlabformat(%3.1f %3.1f %3.1f %3.1f %3.1f) mlabpos(0 0 0 0 0)  ), xlabel(2005/2023 , alt noticks   ) ///
  scale(1.3) xscale( axis(none)) ysize(5) xsize(13) xtitle("") ytitle("Poverty Rate") ///
  graphregion(margin(small)) plotregion(margin(small))  ///
  legend(order(1 "Single Person" 2 "Time Poor in H.Type I" 3 "Time Poor in H.Type II" 4 "Time poor in H.Type III" 5 "Not Time Poor in T.P.H.") pos(3) col(1) ring(1) ) 
 
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
    replace spm_nobs = min(4,spm_nobs)
    drop if spm_nobs ==1
    drop if htpoor   ==0
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
** 
drop if htpoor == 0

label var    itpoor "Individual T. Poverty type"
label define itpoor 0 "Not Time Poor", modify
label define itpoor 1 "Single Person", modify
label define itpoor 2 "Lives in T-I   household", modify
label define itpoor 3 "Lives in T-II  household", modify
label define itpoor 4 "Lives in T-III household", modify
label define itpoor 5 "Not Time poor", modify
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
drop if spm_nobs ==1
recode rel_income (-99/1 = 1 "SPM Poor")  (-99/1 = 1 "SPM Poor") (1/2=2 "Non Poor <2 Pl") (2/4 =3 "2-4 Times PL") (4/100 =4 "4+ Times PL"), gen(rel_q)

capture progra drop  tabmean
program tabmean, rclass
    syntax varlist [if] [aw], mvar(varlist) [scale(int 100)]
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

gen htx_sc1 = htpoor_sc1
gen htx_sc2 = htpoor_sc2 
gen htx_sc3 = htpoor_sc3
replace htx_sc1 = 1-htpoor_sc1 if htpoor!=0
replace htx_sc2 = 1-htpoor_sc2 if htpoor!=0
replace htx_sc3 = 1-htpoor_sc3 if htpoor!=0

tabmean tpoor_type   if tpoor_type >=2 [w=asecwt], mvar(htx_sc1)
matrix mres2 = r(ret)
tabmean tpoor_type   if tpoor_type >=2 [w=asecwt], mvar(htx_sc2)
matrix mres2 = mres2,r(ret)
tabmean tpoor_type   if tpoor_type >=2 [w=asecwt], mvar(htx_sc3)
matrix mres2 = mres2,r(ret)


tabstat tdef* if tpoor_type >=2 & [w=asecwt], by(itpoor)
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

frame new:waffle_plot 69.2, color0(gs10) msymbol(S) xsize(5) ysize(6) xtitle(Scenario 1, size(huge)) name(m1, replace)
frame new:waffle_plot 87.2, color0(gs10) msymbol(S) xsize(5) ysize(6) xtitle(Scenario 2, size(huge)) name(m2, replace)
frame new:waffle_plot 65.0, color0(gs10) msymbol(S) xsize(5) ysize(6) xtitle(Scenario 3, size(huge)) name(m3, replace)

graph combine m1 m2 m3, nocopies altshrink col(3) ysize(6) xsize(15)
   graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\hhtrans.pdf", replace
  graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\hhtrans.png", replace width(1500)
  

 pie_i 4.57 7.11 33.72, plotopt(xlabel(, nogrid) ylabel(, nogrid)  ///
    legend(order( 1 "T.P. in H.T-I (4.6%)"  ///
                  2 "T.P. in H.T-II (7.1%)"  ///  
                  3 "T.P. in H.T-III (33.7%)"   ///
                  4 "Not Time Poor (54.6%)" ) pos(6) row(2) size(16pt)) xsize(5.5) ysize(5)) 
   graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\ind_dist.pdf", replace
  graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\ind_dist.png", replace width(1500)
                    
pie_i 4.57 14.2 81.23, plotopt(xlabel(, nogrid) ylabel(, nogrid)  ///
    legend(order( 1 "H.T-I (4.6%)"  ///
                  2 "H.T-II (14.2%)"  ///  
                  3 "H.T-III (81.2%)"   ) pos(6) row(2)  size(16pt)) xsize(5.5) ysize(5)) 
graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\hh_dist.pdf", replace
graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\hh_dist.png", replace width(1500)

matrix tmres1 = mres1'
capture frame create toplot
frame toplot: lbsvmat tmres1
frame toplot: {

    scatter tmres12 tmres13 tmres14 tmres11 scenario, ///
            connect(l l l l) xlabel(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3", labsize(11pt)) ///
            xtitle("") lpatter( solid solid solid - )  xscale(range(0.75 3.25)) ylabel(,labsize(9pt)) ///
            legend(order(1 "T.P. in H.T-I" ///
            2 "T.P. in H.T-II" ///
            3 "T.P. in H.T-III" ///
            4 "Not Time Poor") pos(6) row(1) size(10pt)) ysize(3)
    graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\trans1.pdf", replace
    graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\trans1.png", replace width(1500)        
}

frame toplot:clear
matrix tx = r(tmatrix2)
frame toplot: {
    mata:tx = st_matrix("tx"); tx = (tx[,1],tx[,2],(1\2\3\4),(1\1\1\1))\(tx[,1],tx[,3],(1\2\3\4),(2\2\2\2))\(tx[,1],tx[,4],(1\2\3\4),(3\3\3\3));st_matrix("tx",tx)
    lbsvmat tx
    
 
    gen type1 = tx3+(tx4-2)/5
    
    gen ty0 = tx1
    two (pcarrow tx1 type1 tx2 type1 if tx4==1 , msize(medlarge))  ///
        (pcarrow tx1 type1 tx2 type1 if tx4==2 , msize(medlarge)) ///
        (pcarrow tx1 type1 tx2 type1 if tx4==3 , msize(medlarge)), ///
        legend(order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3") ring(0) pos(7)) ///
        ytitle("Time Deficit") xtitle("") xlabel( 1 "Non Time Poor" 2 "T.P. in H.T-I" 3 "T.P. in H.T-II" 4 "T.P. in H.T-I" ) ///
        scale(1.5) ysize(4) xsize(8) xscale(range(0.5 4.5))
    graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\def1.pdf", replace
    graph export "C:\Users\Fernando\Documents\GitHub\Redistribution\resources\def1.png", replace width(1500)       
        
}

frame toplot: {
    clear
    mata:tot=st_matrix("tot");tot=tot,(1::19);tot=tot[,(1..4,13)]\tot[,(5..8,13)]\tot[,(9..12,13)]
    mata:st_matrix("tot",tot)
    lbsvmat  tot, row
    gen cat = "Overall" if tot5==1
    replace cat = "Men" if tot5==2
    replace cat = "Women" if tot5==3
    replace cat = "No Children" if tot5==4
    replace cat = "Children" if tot5==5
    replace cat = "Not Employed" if tot5==6
    replace cat = "Employed" if tot5==7
    replace cat = "Less than HS" if tot5==8
    replace cat = "HighSchool" if tot5==9
    replace cat = "Some Coll" if tot5==10
    replace cat = "College" if tot5==11
    replace cat = "Grad" if tot5==12
    replace cat = "Age: 18/30" if tot5==13
    replace cat = "Age: 31/45" if tot5==14
    replace cat = "Age: 45/64" if tot5==15
 
    drop if inrange(tot5,8,12)
    drop if inrange(tot5,16,99)
    gen     tlist = 1 in 1/10
    replace tlist = 2 in 11/20
    replace tlist = 3 in 21/30
    sort tlist n
    by tlist:gen clist = 11-_n

    /*clonevar clist2 = clist
    replace clist = 17.9 if clist2 == 9
    replace clist = 17.1 if clist2 == 87
    
    replace clist = 15.9 if clist2 == 16
    replace clist = 15.1 if clist2 == 15
    
    replace clist = 13.9 if clist2 == 14
    replace clist = 13.1 if clist2 == 13
    
    replace clist = 11.8 if clist2 == 12
    replace clist = 10.9 if clist2 == 11
    replace clist = 10   if clist2 == 10
    replace clist = 9.1 if clist2 == 9
    replace clist = 8.2 if clist2 == 8
    
    replace clist = 6.8 if clist2 == 7
    replace clist = 5.9   if clist2 == 6
    replace clist = 5.1 if clist2 == 5
    replace clist = 4.2 if clist2 == 4*/
    
    forvalues i = 1/10 {
        local ylabs `ylabs' `=clist[`i']' "`=cat[`i']'" 
        local yt `yt' `=clist[`i']'  " "
        
    }
    global ylabs `ylabs'
    global yt `yt'
    two (scatter clist tot1 ) (scatter clist tot1) (scatter clist tot1) , ///
    ysize(10) xsize(6) ytitle("")  ylabel( $ylabs   ) yscale(range(0/10)) ///
    scale(1.5) subtitle("Non Time Poor")    ///
    name(m1, replace) legend(off) by(tlist, col(3)) 
    
    two (scatter clist tot2 ) (scatter clist tot6) (scatter clist tot10) , ///
    ysize(10) xsize(6) ytitle("")  ylabel( $yt ) yscale(range(0/10)) ///
    scale(1.5) subtitle("T.P. in H.T-I")    ///
    legend(ring(0) pos(7) col(3) order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3")) ///
    name(m2, replace) fxsize(20) legend(off)
    
        two (scatter clist tot3 ) (scatter clist tot7) (scatter clist tot11) , ///
    ysize(10) xsize(6) ytitle("")  ylabel( $yt   ) yscale(range(0/10)) ///
    scale(1.5) subtitle("T.P. in H.T-II")    ///
    name(m3, replace) fxsize(20) legend(off)
    
        two (scatter clist tot4 ) (scatter clist tot8) (scatter clist tot12) , ///
    ysize(10) xsize(6) ytitle("")  ylabel( $yt    ) yscale(range(0/10)) ///
    scale(1.5) subtitle("T.P. in H.T-III")    ///
    legend( order(1 "Scenario 1" 2 "Scenario 2" 3 "Scenario 3")) ///
    name(m4, replace) fxsize(30) 
    graph combine m1 m2 m3 m4,  row(1) imargin(0 0 0 0) nocopies
}