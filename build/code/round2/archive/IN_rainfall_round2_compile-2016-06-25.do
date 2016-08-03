/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_round2_compile.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 27, 2016

LAST EDITED:	January 28, 2016 by Seungmin Lee

DESCRIPTION: 	Compiles round 2 dataset from 3 states (AP, UP, TN)
	
ORGANIZATION:	0 - Preamble
				1 - Import cleaned round 2 datasets from each state
					1.1 - Andhra Pradesh
					1.2 - Uttar Pradesh
					1.3 - Tamil Nadu
				2 - Compile, Save and Exit
				
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
/*
foreach var in g_a_6chooseincent /* d_1_o_sendmoney3 d_4_nomigrate4 */ {
	tostring `var', gen(`var's)
	drop `var'
	// gen `var' = `var's
	// drop `var's
	rename `var's `var'
	}
*/
// gen state="Tamil Nadu" // Added by SLee - 2016-1-22
gen states = "Tamil Nadu"
save "$mk\Intervention Analysis\TNData.dta", replace
clear

/****************************************************************
	SECTION 2: Compile, Save and Exit
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


foreach x of varlist _all {
	rename `x' r2_`x'
}

rename (r2_a_1hhid r2_state) (a_1hhid state)

compress
save "$mk\Intervention Analysis\Round2.dta", replace
save "${builddta}/round2/IN_rainfall_r2_compiled.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit


