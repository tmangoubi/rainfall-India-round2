/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_round2_compile.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 27, 2016

LAST EDITED:	June 25, 2016 by Seungmin Lee

DESCRIPTION: 	Compiles round 2 dataset from 3 states (AP, UP, TN) and prepare analysis
	
ORGANIZATION:	0 - Preamble
				1 - Import cleaned round 2 datasets from each state
					1.1 - Andhra Pradesh
					1.2 - Uttar Pradesh
					1.3 - Tamil Nadu
				2 - Compile and Analysis Preparation
				X - Save and Exit
				
INPUTS: 		${builddta}/round2/IN_rainfall_r2_cleaned_AP.dta
				${builddta}/round2/IN_rainfall_r2_cleaned_UP.dta
				${builddta}/round2/IN_rainfall_r2_cleaned_TN.dta
				${builddo}/round2/IN_rainfall_round2_label.do - label do-file.

OUTPUTS: 		${builddta}/round2/IN_rainfall_r2_compiled.dta

NOTE:			This file is based on "${outdated}/Compile Round 2.do" file with modifications.
******************************************************************/


/****************************************************************
	SECTION 0: Preamble	
****************************************************************/

version 13.1

set more off
clear all
cap log close 
set mem 500m

loc name_do IN_rainfall_round2_compile
log using "${buildlog}/`name_do'", replace

global mk "${r2_data}"
cap mkdir "$mk\Intervention Analysis"

/****************************************************************
	SECTION 1: Import cleaned round 2 datasets from each state
****************************************************************/

// 1.1 AP

use "${builddta}/round2/IN_rainfall_r2_cleaned_AP.dta"
gen states = "Andhra Pradesh"
tostring g_a_6chooseincent1 d_1_c_other d_1_c_other e_4_other /*g_a_4whymigcity*/ g_a_4otherwhycity d_4_nomigrate4, replace

/* // Disabled my SLee, 2016-1-25
foreach var in d_4_nomigrate4  {
	tostring `var', gen(`var's)
	drop `var'
	// gen `var' = `var's
	// drop `var's
	rename `var's `var'
	label values `var' nomigrate
	}
*/
save "$mk\Intervention Analysis\APData.dta", replace
clear


// 1.2 UP

use "${builddta}/round2/IN_rainfall_r2_cleaned_UP.dta"
// destring d_4_nomigrate4 , replace
/*
foreach var in g_a_6chooseincent1 /*d_1_k_findjob g_a_4whymigcity d_4_nomigrate4 */ {
	tostring `var', gen(`var's)
	drop `var'
	// gen `var' = `var's
	// drop `var's
	rename `var's `var'
	}
*/
// gen state = "Uttar Pradesh" // Added by SLee - 2016-1-22
gen states = "Uttar Pradesh"
save "$mk\Intervention Analysis\UPdata.dta", replace
append using "$mk\Intervention Analysis\APData.dta"
save "$mk\Intervention Analysis\Round2.dta", replace
clear

// 1.3 TN

use "${builddta}/round2/IN_rainfall_r2_cleaned_TN.dta"
destring backch_accompsupervisor_other1, replace
tostring f_7_othernobuy g_a_4otherwhycity  , replace

gen states = "Tamil Nadu"
save "$mk\Intervention Analysis\TNData.dta", replace
clear

/****************************************************************
	SECTION 2: Compile & Analysis Preparation
****************************************************************/

use "$mk\Intervention Analysis\Round2.dta"
foreach var in backch_accompsupervisor_other1 backch_accompsupervisor_other2 backch_accompsupervisor_other3 backch_accompmonitor_other2 {
	tostring `var', gen(`var's)
	drop `var'
	gen `var' = `var's
	drop `var's
	}

append using "$mk\Intervention Analysis\TNData.dta"
label var states "State of Survey"
rename states state
drop backch*

do "${builddo}/round2/IN_rainfall_round2_label.do" // Apply variable labels.

drop hhnotfound
order a1_* b_* c_* d_* e_* f_* g_*, after(prevresp)
order a_1hhid state, first
order metainstancename-attrition, after(simid)

tempfile vars_original
save `vars_original'


// Generate variables for analysis

* Primary income source
loc var primary_incsource_kh13
clonevar `var'=c_1_incomesource

* Primary income source (other)
loc var primary_othincsource_kh13
clonevar `var'=c_1_other

* Weeks worked
loc var weeksworked_kh13
clonevar `var'=c_2_weeksworked

* Days worked
loc var hrsworked_kh13
clonevar `var'=c_3_daysworked

* Daily income
loc var dailyincome_kh13
clonevar `var'=c_5_dailywage

* Land cultivated (in acre)
loc var landcultivated_acre_kh13
rename c_6_landcultivated_acre `var'
order `var', last

* Total earning during the last Kharif season (July-Nov 2013)
loc var totearn_kh13
clonevar `var'=c_7_kharifearnings

* Total HH income last year (2013)
loc var totHHincome_2013
clonevar `var'=c_8_annualincome

* Has a bank account
loc var bankaccount
clonevar `var'=c_9_bankaccount

* Rainfall last Kharif (2013)
loc var rainfall_kh13
clonevar `var'=c_10_lastkharif

* Shock since 2011
loc var hasshock
clonevar `var'= c_11_shocktype
forval i=1/5 {
	clonevar `var'_type`i'=c_11_shocktype`i'
}
*


***** Migration *****

* Migrated during the last lean season (March-June 2013)
loc var migrated_lean13
clonevar `var'=d_1_migrant

* Migrated days during the last lean season (March-June 2013)
loc var migdays_lean13
clonevar `var'=d_1_a_daysaway

* Migration income during the last lean season (March-June 2013)
loc var migincome_lean13
clonevar `var'=d_1_b_migincome

* Migrated member during the last lean season (March-June 2013)
loc var1 migmember1_lean13
loc var2 migmember2_lean13
loc var3 migmember3_lean13
clonevar `var1'=d_1_c_migmember1
clonevar `var2'=d_1_c_migmember2
clonevar `var3'=d_1_c_migmember3

* Migrated abroad
loc var migabroad_lean13
clonevar `var'=d_1_d_indiaabroad

* Reason for migration destinty
loc var1 whymigdest1_lean13
loc var2 whymigdest2_lean13
loc var3 whymigdest3_lean13
loc var4 whymigdest4_lean13
clonevar `var1'=d_1_e_whymigdest1
clonevar `var2'=d_1_e_whymigdest2
clonevar `var3'=d_1_e_whymigdest3
clonevar `var4'=d_1_e_whymigdest4

* Migration transportation (mean, cost, etc.)
loc var1 migtransport_lean13
loc var2 migtransportoth_lean13
loc var3 migtranscost_lean13
loc var4 migalone_lean13
loc var5 miggroupmem_lean13
clonevar `var1'=d_1_f_transport
clonevar `var2'=d_1_f_other
clonevar `var3'=d_1_g_transcost
clonevar `var4'=d_1_h_alonegroup
clonevar `var5'=d_1_i_miggroup

* Job at migration destination & earning
loc var1 foundjob_lean13
loc var2 waytojob1_lean13
loc var3 waytojob2_lean13
loc var4 waytojob3_lean13
loc var5 waytojob4_lean13
loc var6 waytojoboth_lean13
loc var7 migjob_lean13
loc var8 migjoboth_lean13
loc var9 migearning_lean13
loc var10 migearnlevel_lean13
loc var11 migsuccess_lean13
loc var12 migearnmore_lean13
loc var13 migremitway1_lean13
loc var14 migremitway2_lean13
loc var15 migremitway3_lean13
clonevar `var1'=d_1_j_success
clonevar `var2'=d_1_k_findjob1
clonevar `var3'=d_1_k_findjob2
clonevar `var4'=d_1_k_findjob3
clonevar `var5'=d_1_k_findjob4
clonevar `var6'=d_1_k_other
clonevar `var7'=d_1_l_occupation
clonevar `var8'=d_1_l_other
clonevar `var9'=d_1_m_earnings
clonevar `var10'=d_1_m1_earninglevel
clonevar `var11'=d_1_m2_success
clonevar `var12'=d_1_n_earnmore
clonevar `var13'=d_1_o_sendmoney1
clonevar `var14'=d_1_o_sendmoney2
clonevar `var15'=d_1_o_sendmoney3

* Migration during Rabi/Kharif season (Nov-March 2013)/(June-Nov 2013)
loc var1 migrated_rabi13
loc var2 migdays_rabi13
loc var3 migincome_rabi13
loc var4 migrated_kh13
loc var5 migdays_kh13
loc var6 migincome_kh13
clonevar `var1'=d_2_migrabi
clonevar `var2'=d_2_a_daysaway
clonevar `var3'=d_2_b_rabiincome
clonevar `var4'=d_3_migkharif
clonevar `var5'=d_3_a_daysaway
clonevar `var6'=d_3_b_kharifincome


* Aggregate Past migration variables (migration variables across 3 different migration experience - lean, rabi, kharif)
	
loc var migrated_any
egen `var'=rowmax(migrated_lean13 migrated_rabi13 migrated_kh13)
lab var `var' "Migrated at least once during the last 3 seasons - lean, Rabi, Kharif"
label value `var' yesno

loc var migfrequency
egen `var'=rowtotal(migrated_lean13 migrated_rabi13 migrated_kh13), missing
label var `var' "How many seasons did you or your household member migrate during the last 3 seasons?"

loc var migdays_tot
egen `var' = rowtotal(migdays_lean13 migdays_rabi13 migdays_kh13), missing
label var `var' "How many days did you or your household member migrate during the last 3 seasons?"

loc var migincome_tot
egen `var' = rowtotal (migincome_lean13 migincome_rabi13 migincome_kh13), missing
label var `var' "How much did your household make from migration during the last 3 seasons?"
	

* Reason for NOT migrating
forval i=1/7 {
	loc var`i' whynotmig`i'
	clonevar `var`i''=d_4_nomigrate`i'
}
*
loc var7 whynotmig_oth
clonevar `var7'=d_4_other


***** Past insurance *****

* Distance b/w AWS to vilalge
loc var1 distanceAWS
loc var2 distancdAWS_opinion
clonevar `var1'=e_1_kilometers
clonevar `var2'=e_2_distanceopinion

* Past insurance history
loc var pastinsur_any
gen byte `var'=.
replace `var'=1 if inlist(e_3_insurance1,1,2,3,4,5)
replace `var'=0 if (e_3_insurance1==6)
replace `var'=.d if inlist(e_3_insurance1,-999,.d)
label var `var' "Have you or any member of you household purchased any insurance last year?"
label value `var' yesno

loc var pastinsur_DMOS
gen byte `var'=.
replace `var'=1 if inlist(e_3_insurance1,5)
replace `var'=1 if inlist(e_3_insurance2,5)
replace `var'=0 if (e_3_insurance1==6)
replace `var'=.d if inlist(e_3_insurance1,-999,.d)
label var `var' "Have you or any member of you household purchased DMOS last year?"
label value `var' yesno

loc var1 pastinsur_scheme1
loc var2 pastinsur_scheme2
clonevar `var1'=e_3_insurance1
clonevar `var2'=e_3_insurance2

* Reason for insurance investment
loc var1 pastinsur_whybuy1
loc var2 pastinsur_whybuy2
loc var3 pastinsur_whybuy3
loc var4 pastinsur_whybuyoth
clonevar `var1'=e_4_whybuyins1
clonevar `var2'=e_4_whybuyins2
clonevar `var3'=e_4_whybuyins3
clonevar `var4'=e_4_other

* Payout history
loc var1 pastinsur_payout
loc var2 pastinsur_payoutdeserve
clonevar `var1'=e_5_payout
clonevar `var2'=e_6_deservepayout



***** Insurance Offer *****

* Insurance purchased
loc var insur_offered
clonevar `var'=f_1insexplain

loc var1 insur_purch1st
loc var2 insur_unitpurch1st
loc var3 insur_purch2nd
loc var4 insur_unitpurch2nd
clonevar `var1'=f_2purchasins
clonevar `var2'=f_3unitsins
clonevar `var3'=f_5purchasins
clonevar `var4'=f_6unitsins

* Reason for NOT buying insurance
loc var1 insur_whynotbuy1
loc var2 insur_whynotbuy2
loc var3 insur_whynotbuy3
loc var4 insur_whynotbuyoth
clonevar `var1'=f_7nobuyins1
clonevar `var2'=f_7nobuyins2
clonevar `var3'=f_7nobuyins3
clonevar `var4'=f_7_othernobuy


* Aggregate insurance offer variables

** Insurance purchased
loc var1 insur_agreed
gen `var1' = (f_2purchasins==1 |f_5purchasins==1)
replace `var1'=. if (f_1insexplain!=1) // Correctedly skipped
label var `var1' "Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance? " // Added by SLee-2016-1-22
label value `var1' yesno
		
** Total insurance units sold
loc var2 insur_unitpurchased
egen `var2'=rowtotal(f_3unitsins f_6unitsins) if (attrition==0), missing
replace `var2'=. if (`var1'!=1) // Correctedly skipped
label var `var2' "total insurance unit purchased from 2 visits"

replace `var1'=0 if (`var2'==0) // If no units were purchased, then it means it did not purchase
replace `var2'=. if (`var1'!=1)
	


***** Migration Offer *****

* Migration offer & acceptance
loc var mig_offered
clonevar `var'= f_1mig

loc var1 mig_acpt1st
loc var2 mig_mem1st
loc var3 mig_othmem1st
loc var4 mig_dest1st
loc var5 mig_accepted
loc var6 mig_member
loc var7 mig_othmemer
clonevar `var1'=f_2migaccep
clonevar `var2'=f_3migmember
clonevar `var3'=f_3migother
clonevar `var4'=f_4choosedest
clonevar `var5'=g_1migaccep
clonevar `var6'=g_a_2migmember
clonevar `var7'=g_a_2migother

* Migration detail
loc var1 mig_cellphone
loc var2 mig_mthleave
loc var3 mig_dayleave
loc var4 mig_mthreturn
loc var5 mig_dayreturn
clonevar `var1'=g_a_2cellphone
clonevar `var2'=g_a_b_1migmonthleave
clonevar `var3'=g_a_b_1migdateleave
clonevar `var4'=g_a_b_2migmonthreturn
clonevar `var5'=g_a_b_2migdayreturn

loc var mig_daysexpected
gen `var'=((mig_mthreturn-mig_mthleave)*30)+(g_a_b_2migdayreturn-g_a_b_1migdateleave)
replace `var'=.m if (`var'<0)
lab var `var' "Expected duration of migration (days)"

* Reason for Migration/No-migration & etc.
loc var1 whyacceptmig1
loc var2 whyacceptmig2
loc var3 whyacceptmig3
clonevar `var1'=g_a_6chooseincent1
clonevar `var2'=g_a_6chooseincent2
clonevar `var3'=g_a_6chooseincent3

loc var1 whymigcity1
loc var2 whymigcity2
loc var3 whymigcity3
loc var4 whymigcity4
clonevar `var1'=g_a_4whymigcity1
clonevar `var2'=g_a_4whymigcity2
clonevar `var3'=g_a_4whymigcity3
clonevar `var4'=g_a_4whymigcity4

loc var1 whynotacceptmig1
loc var2 whynotacceptmig2
loc var3 whynotacceptmig3
loc var4 whynotacceptmig4
loc var5 whynotacceptmig5
loc var6 whynotacceptmig6
clonevar `var1'=g_9noaccept1
clonevar `var2'=g_9noaccept2
clonevar `var3'=g_9noaccept3
clonevar `var4'=g_9noaccept4
clonevar `var5'=g_9noaccept5
clonevar `var6'=g_9noaccept6

loc var mignoincentive
clonevar `var'=g_a_5migwithout

* Save newly created variables
tempfile vars_prep
save `vars_prep'	
/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

// Save original variables only
use `vars_original'

qui compress
save "$mk\Intervention Analysis\Round2.dta", replace
save "${builddta}/round2/IN_rainfall_r2_compiled.dta", replace

// Save variables prepared for analysis only
use `vars_prep'
keep a_1hhid state attrition-villname primary_incsource_kh13-mignoincentive

foreach x of varlist _all {
	rename `x' r2_`x'
}
*
rename (r2_a_1hhid r2_state) (a_1hhid state)

compress
save "${builddta}/round2/IN_rainfall_r2_compiled_prep.dta", replace
note: IN_rainfall_r2_compiled_prep / created by `name_do'.do file

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit


