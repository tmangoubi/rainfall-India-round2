/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_round3_analysis_prep.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	June 26, 2016

LAST EDITED:	June 26, 2016 by Seungmin Lee

DESCRIPTION: 	Import round3 survey data and clean it
	
ORGANIZATION:	0 - Preamble
				1 - Analysis Preparation
				X - Save and Exit
				
INPUTS: 		${builddta}/round3/IN_rainfall_r3_cleaned.dta
				
OUTPUTS: 		${builddta}/round3/IN_rainfall_r3_prep.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do IN_rainfall_round3_clean
log using "${buildlog}/`name_do'", replace

		
/****************************************************************
	SECTION 1: Analysis Preparation					 									
****************************************************************/
use "${builddta}/round3/IN_rainfall_r3_cleaned.dta", clear


***** Section C: Seasonal migration during 2014 lean season *****

* Migrated during lean 2014
loc var migrated_lean14
clonevar `var'=c_1_seasonal_mig

* Members migrated
forval i=1/3{
	loc var`i' migmember`i'_lean14
	clonevar `var`i''=c_1_a_member_mig`i'
}
*

* Migrated days
loc var migdays_lean14
clonevar `var'=c_1_b_daysaway

* Migration destination
loc var1 migstate_lean14
loc var2 migdistrict_lean14
loc var3 migcity_lean14
clonevar `var1'=statemig
clonevar `var2'=districtmig
clonevar `var3'=c_1_c_1_c_towncity
lab var `var3' "To which city did they migrate?"
forval i=1/3{
	loc var`i' whymigdest`i'_lean14
	clonevar `var`i''=c_1_d_whymigdest`i'
}
loc var4 migabroad_lean14
clonevar `var4'=statecategory

* Migration result
loc var1 foundjob_lean14
loc var2 waytojob1_lean14
loc var3 waytojob2_lean14
loc var4 waytojoboth_lean14
loc var5 migjob_lean14
loc var6 migjoboth_lean14
loc var7 mighrsworked_lean14
loc var8 migwksworked_lean14
loc var9 migsalary_lean14
loc var10 miginkind_lean14
loc var11 migearning_lean14
loc var12 migearnmore_lean14
clonevar `var1'=c_1_e_success
clonevar `var2'=c_1_f_findjob1
clonevar `var3'=c_1_f_findjob2
clonevar `var4'=c_1_f_other
clonevar `var5'=c_1_g_occupation
clonevar `var6'=c_1_g_other
clonevar `var7'=c_1_h_hours
clonevar `var8'=c_1_i_months
clonevar `var9'=c_1_j_1_j_salary
clonevar `var10'=c_1_j_1_j_kind
egen `var11'=rowtotal(`var9' `var10'), missing
lab var `var11' "Total migration earning (salary+in-kind) during Lean 2014 season"
clonevar `var12'=c_1_k_earninglevel

* Reason for Migration/no-migration
forval i=1/5{
	loc var`i' whynotmig`i'_lean14
	clonevar `var`i''=c_1_l_nomigrate`i'
}
*

***** Section D: Insurance Offer *****

* Insurance investment decision
loc var1 insur_purch1st
loc var2 insur_unitpurch1st
loc var3 insur_purch2nd
loc var4 insur_unitpurch2nd
clonevar `var1'=d_1purchasins
clonevar `var2'=d_2unitsins
clonevar `var3'=d_6purchasins
clonevar `var4'=d_7unitsins

** Insurance investment across 2 visits
loc var1 insur_agreed
gen `var1' = (d_1purchasins==1 |d_6purchasins==1)
replace `var1'=. if (d_1purchasins!=1) // Correctedly skipped
label var `var1' "Do you want to purchase Delayed Monsoon Onset Kharif 2014 Insurance? " 
label value `var1' yesno
		
** Total insurance units sold
loc var2 insur_unitpurchased
egen `var2'=rowtotal(d_2unitsins d_7unitsins) if (attrition==0), missing
replace `var2'=. if (`var1'!=1) // Correctedly skipped
label var `var2' "total insurance unit purchased from 2 visits"

replace `var1'=0 if (`var2'==0) // If no units were purchased, then it means it did not purchase
replace `var2'=. if (`var1'!=1)

** Reason for investment/non-investment
forval i=1/4{

	loc var`i' whyinsur1st_`i'
	clonevar `var`i''=d_2_a_whybuy`i'
		
	if inrange(`i',1,3) {
		loc var`i' whyinsur2nd_`i'
		clonevar `var`i''=d_7_a_whybuy`i'
	}
	
	loc var`i' whynoinsur_`i'
	clonevar `var`i''=d_8nobuyins`i'

}
*

* Automatic Weather Station (AWS)
loc var1 knowAWSlocation
loc var2 AWSlocation
loc var3 AWSdistanceKm
clonevar `var1'=d_3awstation
clonevar `var2'=d_4awslocation
clonevar `var3'=d_4awskms

// Keep only variables for analysis
drop submissiondate-d_7_a_whybuy3

/****************************************************************
	SECTION 3: Save and Exit		 									
****************************************************************/

foreach x of varlist _all {
	rename `x' r3_`x'
}

rename (r3_a_1hhid r3_states) (a_1hhid state)

compress
save "${builddta}/round3/IN_rainfall_r3_prep.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
	
