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
					2.4 - 2014 Follow-up (Analysis variables only)
					2.5 - Admin (Insurance Payout Information)
				3 - Clean merged dataset
					3.1 - Cleaning labels and dropping observations with conflicts
					3.2 - Insurance payout update
					3.3 - Sort & Order
				4 - Save and Exit
				
INPUTS: 		${builddta}/round2/IN_rainfall_r2_compiled.dta
				${builddta}/round3/IN_rainfall_r3_cleaned.dta
				${builddta}/intervention/IN_rainfall_intervention.dta
				${builddta}/followup_2014/Analysis_variables.dta

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
tempfile round2dta round3dta interventiondta fu_2014_analysis ins_payout

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

// 2014 Follow-up (Analysis variables only)
use "${builddta}/followup_2014/Analysis_variables.dta", clear
isid a_1hhid
save `fu_2014_analysis'

// Admin data (Insurance Payout Information)
use "${builddta}/admin/Insur_payout_Kharif2014_cleaned.dta", clear
** This dataset is a long format - HH ID does NOT uniquely identify observations
save `ins_payout'

/****************************************************************
	SECTION 2: Merge datasets
****************************************************************/

// Merge round2, round3, intervention and 2014 follow-up (analysis vars only) dataset
use `round2dta', clear
merge 1:1 a_1hhid using `round3dta', gen(r2r3_panel) assert(1 3) // To confirm that round3 sample is a subset of round2 sample
label define r2r3_panel 1 "Surveyed in round 2 only" 3 "Surveyed both in round 2 and round 3"
label value r2r3_panel r2r3_panel
label var r2r3_panel "Household survey status in round 2 & 3"
merge 1:1 a_1hhid using `interventiondta', /*nogen*/ assert(3) // To confirm that round2 sample equal to the intervention sample.
merge 1:1 a_1hhid using `fu_2014_analysis', nogen assert (1 3) // To confirm that 2014 follow-up survey sample is a subset of r2 sample
merge 1:m a_1hhid using `ins_payout', gen(_adminmerge)

/****************************************************************
	SECTION 3: Clean merged dataset
****************************************************************/

// 3.1	Cleaning labels and dropping observations with conflicts


// R2/R3 and Follow-up 2014 have different "yesno" value label. R2/R3 has 0 as "No", while FU2014 has 2 as "NO"
label define yesno 0 "No" 1 "Yes" 2 "No", replace

// We will drop id variables from round 2 to use id variables from intervention dataset
// Before we drop round 2 id variables, we can observe how much they are different
list a_1hhid districtid r2_distid _merge if (districtid!=r2_distid & !mi(r2_distid)) // 6 households
list a_1hhid villageid r2_villid _merge if (villageid!=r2_villid & !mi(r2_villid)) // 6 households, same as bove
list a_1hhid tehsilid r2_tehsid _merge if (tehsilid!=r2_tehsid & !mi(r2_tehsid)) // 80 households
// Since there are not too many conflicts, we can drop round 2 id variables safely.
drop r2_distid-r2_stname _merge


// 3.2	Insurance Payout Update

// Our insurance payout admin data does NOT exactly match self-reported HH survey data
// We assume our admin data is more accurate, so we will update insurance payout information using admin data


/*
// If HH obs is missing in insurance payout data, it implies HH did not any purchase insurance in either round => NO. It might mean HH purchased but did NOT receive payout
replace r2_insurance_agreed=. if (_adminmerge==1 & r2_insurance_offered==0)
replace r2_insurance_agreed=0 if (_adminmerge==1 & r2_insurance_offered==1)
replace r2_insurance_unit_purchased=. if (_adminmerge==1)
replace r3_insurance_agreed=0 if (_adminmerge==1 & r3_insurance_agreed==1)
replace r3_insurance_purchased_visit=. if (r3_insurance_agreed==0)
replace r3_insurance_unit_purchased=. if (r3_insurance_agreed==0)
*/

// Generate payout and claim amount variable from admin data
foreach round in r2 r3 {
	gen `round'_insurance_payout=.
	replace `round'_insurance_payout=0 if (`round'_insurance_agreed==1 & _adminmerge==1) // purchased but did NOT get payout
	replace `round'_insurance_payout=1 if (`round'_insurance_agreed==1 & _adminmerge==3) // purchased and did get payout
	replace `round'_insurance_unit_purchased=total_insurance_unit if (`round'_insurance_payout==1) // update unit purchased using admin data
	gen `round'_insurance_claim_amt = claims if (`round'_insurance_payout==1) // Amount of insurance claim received in round 2/3
	order `round'_insurance_payout `round'_insurance_claim_amt, after(`round'_insurance_unit_purchased)
	
	lab var `round'_insurance_payout "Whether HH received insurance payout in `round'"
	lab var `round'_insurance_claim_amt "Amount of insurance claim received in `round'"
}
*

// There are multiple households who purchased insurance in both rounds (2 & 3). Most of them purchase same units of insurances in each round
// There are 3 households ("P1551","A530","A455") which purchased different units in each round. We need to update those information correctly.

// "A455" purchased 2 units in round 2 and 1 unit in round 3
replace r2_insurance_agreed=1 if (a_1hhid=="A455")
replace r2_insurance_unit_purchased=2 if (a_1hhid=="A455")
replace r2_insurance_payout=1 if (a_1hhid=="A455")
replace r2_insurance_claim_amt=1500 if (a_1hhid=="A455")
replace r3_insurance_agreed=1 if (a_1hhid=="A455")
replace r3_insurance_unit_purchased=1 if (a_1hhid=="A455")
replace r3_insurance_payout=1 if (a_1hhid=="A455")
replace r3_insurance_claim_amt=750 if (a_1hhid=="A455")

// "A530" purchased 2 units in round 2, and 1 unit in round 3
replace r2_insurance_agreed=1 if (a_1hhid=="A530")
replace r2_insurance_unit_purchased=2 if (a_1hhid=="A530")
replace r2_insurance_payout=1 if (a_1hhid=="A530")
replace r2_insurance_claim_amt=2400 if (a_1hhid=="A530")
replace r3_insurance_agreed=1 if (a_1hhid=="A530")
replace r3_insurance_unit_purchased=1 if (a_1hhid=="A530")
replace r3_insurance_payout=1 if (a_1hhid=="A530")
replace r3_insurance_claim_amt=1200 if (a_1hhid=="A530")

// "P1551" purchased 2 units in round 2, and 1 unit in round 3
replace r2_insurance_agreed=1 if (a_1hhid=="P1551")
replace r2_insurance_unit_purchased=2 if (a_1hhid=="P1551")
replace r2_insurance_payout=1 if (a_1hhid=="P1551")
replace r2_insurance_claim_amt=2400 if (a_1hhid=="P1551")
replace r3_insurance_agreed=1 if (a_1hhid=="P1551")
replace r3_insurance_unit_purchased=1 if (a_1hhid=="P1551")
replace r3_insurance_payout=1 if (a_1hhid=="P1551")
replace r3_insurance_claim_amt=1200 if (a_1hhid=="P1551")


// Drop duplicates and admin data (no longer needed)
quietly bysort a_1hhid:  gen dup = cond(_N==1,0,_n) // Tag duplicates
drop if (dup==2) // Drop duplicates
drop Proposalname-PhoneNumber _adminmerge dup // Drop admin data no longer needed
isid a_1hhid

// 3.3	Sort & Order

// Declar macros of variables to sort & order later
// loc surveyinfovar submissiondate starttime endtime today deviceid subscriberid simid
loc id_var state stateid district districtid tehsil tehsilid block blockid village villageid redsid reds_vill a_1hhid
loc intervention_var r1_treatment r2_treatment r2_insurance r2_migration r3_treatment r3_insurance
loc sample_var r2r3_panel r2_attrition r3_attrition

order `id_var' `intervention_var' `sample_var'

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
