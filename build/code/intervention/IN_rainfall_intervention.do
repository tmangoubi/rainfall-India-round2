/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_intervention.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com

DATE CREATED:	January 28, 2016

LAST EDITED:	January 28, 2016 by Seungmin Lee

DESCRIPTION: 	Generates intervention dataset across 3 rounds.
	
ORGANIZATION:	0 - Preamble
				1 - Import datasets
				2 - Generate intervention variables.
				3 - Clean dataset
				4 - Save and Exit
				
INPUTS: 		${IN_rainfall_r2r3}/Sample/Randomization/pii_data/round 3/insur_final.dta
				${IN_rainfall_r2r3}/Sample/Randomization/pii_data/Final/all_mig_ins_final.dta

OUTPUTS: 		$mk/dta\AICWI2-FULL.dta
				$mk/dta\AICWI2-FULL BACKUP.dta
				$mk/dta\labelled_dataset.dta
				${builddta}/round3/IN_rainfall_r3_cleaned.dta
				
NOTE:			This do-file is based on "${IN_rainfall_r2r3}/Sample/Numbers across Rounds do file.do" with additional modifications.
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/
version 13.1

set more off
clear all
cap log close 
set mem 500m

loc name_do IN_rainfall_intervention
log using "${buildlog}/`name_do'", replace

/****************************************************************
	SECTION 1: Import datasets
****************************************************************/

// Round 3 data

use "${IN_rainfall_r2r3}/Sample/Randomization/pii_data/round 3/insur_final.dta", clear
gen hhid =  a_1hhid
label var hhid "Household ID"
sort hhid
tempfile temp1
save `temp1'

// Opening Data from Round1

use "${IN_rainfall_r2r3}/Sample/Randomization/pii_data/Final/all_mig_ins_final.dta", clear
sort hhid

//Merging
merge 1:1 hhid using `temp1', assert(1 3) nogen

/****************************************************************
	SECTION 2: Generate intervention variables
****************************************************************/


//Creating variable for Round 1 
gen r1_treatment = baseline_hhd
label var r1_treatment "Intervention in Round 1"
drop baseline_hhd

//Creating & renaming variable for Round 2
gen r2_treatment = 0
label var r2_treatment "Intervention in Round 2"
replace r2_treatment = 1 if migration == 1
replace r2_treatment = 2 if migration == 2
replace r2_treatment = 3 if insur_offer == 1
tab r2_treatment

rename insur_offer r2_insurance
label var r2_insurance "Offered insurance in round 2"
rename migration r2_migration
label var r2_migration "Offered migration in round 2"

//Creating & renaming variable for Round 3
rename insurance_r3 r3_insurance

// Apply Round 3 intervention modification
replace r3_insurance=1 if (r3_insurance==2 & state=="TN") // TN did NOT receive IMD forecast.
note r3_insurance: Tamil Nadu did NOT receive IMD forecast

gen r3_treatment =.
label var r3_treatment "Intervention in Round 3"
*replace r3_treatment = 1 if r3_insurance == 0
*tab r3_insurance, nolabel
replace r3_treatment = 1 if r3_insurance == 1
replace r3_treatment = 2 if r3_insurance == 2
note r3_treatment: Tamil Nadu did NOT receive IMD forecast

// Label variables
label define round11 0 "Control" 1 "Insurance"
label define round22 0 "Control" 1 "Mig-Ticket" 2 "Mig-Cash" 3 "Insurance"
label define round33 1 "Insurance" 2 "Insurance+IMD"
label value r1_treatment round11
label value r2_treatment round22
label value r3_treatment round33

tab r1_treatment r2_treatment
tab r1_treatment r3_treatment
tab r2_treatment r3_treatment

// This gives us "Pure Control"tab round1 round2 if state == "AP"

count if r1_treatment == 0 & r2_treatment == 0 & r3_treatment ==0

tab r1_treatment r2_treatment if state == "AP"
tab r1_treatment r2_treatment if state == "TN"
tab r1_treatment r2_treatment if state == "UP"

tab r1_treatment r3_treatment if state == "AP"
tab r1_treatment r3_treatment if state == "AP"
tab r1_treatment r3_treatment if state == "UP"

tab r2_treatment r3_treatment if state == "AP"
tab r2_treatment r3_treatment if state == "TN"
tab r2_treatment r3_treatment if state == "UP"

tab r2_insurance r2_migration

/****************************************************************
	SECTION 3: Clean dataset
****************************************************************/

// Change variable type
destring blockid districtid tehsilid blockid stateid villageid, replace

// Merging ID variables
// There are two differet id variables which need to be merged
// "${IN_rainfall_r2r3}/Sample/Randomization/pii_data/Final/all_mig_ins_final.dta" has more complete information, so we will use id variable from this data
drop bkchk-blockname
drop b_1findecmaker-b_8_contactno

// Label values to State ID
label define statevalue 10 "Uttar Pradesh" 16 "Andhra Pradesh" 17 "Tamil Nadu"
label value stateid statevalue

// Rename state variable
replace state = "Andhra Pradesh" if state == "AP"
replace state = "Uttar Pradesh" if state == "UP"
replace state = "Tamil Nadu" if state == "TN"

// Rename household Id variable name to be merged with round 2/3 datasets
rename hhid a_1hhid
replace a_1hhid=upper(a_1hhid)

// Drop unnecessary variables
drop respondentname-streetname

/****************************************************************
	SECTION 4: Save and Exit
****************************************************************/

compress
save "${builddta}/intervention/IN_rainfall_intervention.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
