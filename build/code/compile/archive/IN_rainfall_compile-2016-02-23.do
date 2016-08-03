/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_compile.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu)

DATE CREATED:	January 28, 2016

LAST EDITED:	January 28, 2016 by Seungmin Lee

DESCRIPTION: 	Compile a dataset from round2, round3 and intervention.
	
ORGANIZATION:	0 - Preamble
				1 - Import datasets
				2 - Merge datasets
					2.1 - round2
					2.2 - round3
					2.3 - intervention
				3 - Clean merged dataset
				4 - Save and Exit
				
INPUTS: 		${builddta}/round2/IN_rainfall_r2_compiled.dta
				${builddta}/round3/IN_rainfall_r3_cleaned.dta
				${builddta}/intervention/IN_rainfall_intervention.dta

OUTPUTS: 		${builddta}/compiled/IN_rainfall_compiled.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble	
****************************************************************/

version 13.1

set more off
clear all
cap log close 
set mem 500m
tempfile round2dta round3dta interventiondta

loc name_do IN_rainfall_compile
log using "${buildlog}/`name_do'", replace

/****************************************************************
	SECTION 1: Import datasets
****************************************************************/

// Round 2
use "${builddta}/round2/IN_rainfall_r2_compiled.dta"
isid a_1hhid
save `round2dta'

// Round 3
use "${builddta}/round3/IN_rainfall_r3_cleaned.dta", clear
isid a_1hhid
save `round3dta'

// Intervention
use "${builddta}/intervention/IN_rainfall_intervention.dta", clear
isid a_1hhid
save `interventiondta'

/****************************************************************
	SECTION 2: Merge datasets
****************************************************************/

// Merge round2, round3 and intervention dataset
use `round2dta', clear
merge 1:1 a_1hhid using `round3dta', nogen assert(1 3) // To confirm that round3 sample is a subset of round2 sample
merge 1:1 a_1hhid using `interventiondta', /*nogen*/ assert(2 3) // To confirm that round2 sample is a subset of intervention sample.

/****************************************************************
	SECTION 3: Clean merged dataset
****************************************************************/


// We will drop id variables from round 2 to use id variables from intervention dataset
// Before we drop round 2 id variables, we can observe how much they are different
list a_1hhid districtid r2_distid _merge if (districtid!=r2_distid & !mi(r2_distid)) // 6 households
list a_1hhid villageid r2_villid _merge if (villageid!=r2_villid & !mi(r2_villid)) // 6 households, save as bove
list a_1hhid tehsilid r2_tehsid _merge if (tehsilid!=r2_tehsid & !mi(r2_tehsid)) // 80 households
// Since there are not too many conflicts, we can drop round 2 id variables safely.
drop r2_distid-r2_stname _merge

// Declar macros of variables to sort & order later
// loc surveyinfovar submissiondate starttime endtime today deviceid subscriberid simid
loc id_var state stateid district districtid tehsil tehsilid block blockid village villageid dressid reds_vill a_1hhid
loc intervention_var r1_treatment r2_treatment r2_insurance r2_migration r3_treatment r3_insurance

order `id_var' `intervention_var'

/****************************************************************
	SECTION 4: Save and Exit
****************************************************************/

compress
save "${builddta}/compiled/IN_rainfall_compiled.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
