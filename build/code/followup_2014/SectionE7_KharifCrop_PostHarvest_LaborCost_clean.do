/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionE7_KharifCrop_PostHarvest_LaborCost_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 18, 2016

LAST EDITED:	May 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section E7 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${followup_data}/AP Raw/SectionELabor5_1.dta
					${followup_data}/TN Raw/SectionELabor5_1.dta
					a${followup_data}/UP Raw/SectionELabor5_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionE7_KharifCrop_PostHarvest_LaborCost_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionELabor5_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionE7_KharifCrop_PostHarvest_LaborCost_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

keep Id q400_cultivate q401_decculkhar q401_decculkhar_cou
order Id q400_cultivate q401_decculkhar q401_decculkhar_cou
* keep if (q218_2_mwl==1) // Only those who answered "Yes" answered the rest of M2 section.

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
	if ("`var'" == "q218_4_migratetemptaer") {
		qui recode `var' (-222=.n)
	}
}
*
/// Label variable
label var q400_cultivate "Did your household cultivate crops during 2014 Kharif season?"
label var q401_decculkhar "Did you make decision on cultivating during 2014 Kharif season?"

label define yesno 1 "Yes" 2 "No", replace
label value q400_cultivate q401_decculkhar yesno

/// Save
tempfile q400
save `q400'


// Section E7
use "${followup_data}/AP Raw/SectionELabor5_1.dta", clear
append using "${followup_data}/TN Raw/SectionELabor5_1.dta" 
append using "${followup_data}/UP Raw/SectionELabor5_1.dta" 
isid Id subid

/// Destring and recode variables
qui destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

/// Label variables
label var Id "Household ID"
label var subid "SubId"

label 	var 	q525_outproquan	"Output - Quantity"
label 	var 	q526_outprounit	"Output - Units"
label 	var 	q526_outprounitoth	"Output - Units (Other)"
label 	var 	q527_outprokgsunit	"Output - KG/Unit"
label 	var 	q528_outavmarpri	"Output - Average Market Price"
label 	var 	q529_valtotout11	"Output - Total Value"
label 	var 	q530_expoutquankha11	"Expected Output - Quantity"
label 	var 	q531_expoutunitkha11	"Expected Output - Units"
label 	var 	q531_expoutunitkha11oth	"Expected Output - Units (Others)"
label 	var 	q531_1_exppriperunit	"Expected - Price/Unit"
label 	var 	q564_1_pasproquankha10	"Past Output - Quantity"
label 	var 	q564_2_pasprounitkha10	"Past Output - Units"
label 	var 	q564_2_pasprounitkha10oth	"Past Output - Units (Others)"
label 	var 	q564_3_paspriceperunit	"Past Output - Actual Price/Unit"

/// Merge with q400
merge m:1 Id using `q400', nogen keep(2 3)
order q400_cultivate q401_decculkhar q401_decculkhar_cou, after(Id)

// Apply logic check
ds subid-q564_3_paspriceperunit, has(type numeric)
loc E7vars_num `r(varlist)'
ds subid-q564_3_paspriceperunit, has(type string)
loc E7vars_str `r(varlist)'

foreach var of local E7vars_num {
	replace `var'=.m if ((q400_cultivate==2) & (!mi(`var')))
	
	* Some observations have negative subid with strange values. I (SL) will replace them as missing.
	replace `var'=.m if ((subid==.m) | (subid<0))
}
foreach var of local E7vars_str {
	replace `var'="Valid Skip" if (q400_cultivate==2)
	
	* Some observations have negative subid with strange values. I (SL) will replace them as missing.
	replace `var'="" if ((subid==.m) | (subid<0))
}
*


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionE7_KharifCrop_PostHarvest_LaborCost_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
