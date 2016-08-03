/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionM4_MNREGA_Kharif_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 10, 2016

LAST EDITED:	April 11, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section M4 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master
						${builddta}/followup_2014/MasterData_cleaned.dta - Master Data (q218.22)
					
					// Section M4
						${followup_data}/AP Raw/SectionM4MNREGARoster_1.dta
						${followup_data}/TN Raw/SectionM4MNREGARoster_1.dta
						${followup_data}/UP Raw/SectionM4MNREGARoster_1.dta
						
						
OUTPUTS: 		${builddta}/followup_2014/SectionM4_MRNREGA_Kharif_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionM4MNREGARoster_1.do" (written by Alreena Pinto)
				with additional modifications.
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionM4_MNREGA_Kharif_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import & Clean Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

keep Id q218_22_mnrega
destring q218_22_mnrega, replace
qui replace q218_22_mnrega=.b if mi(q218_22_mnrega) // Blank response (but not a valid response)
qui recode q218_22_mnrega (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"

label define yesno 1 "Yes" 2 "No", replace
label value q218_22_mnrega yesno

tempfile q218_22
save `q218_22'


// M4 - MNREGA data

use "${followup_data}/AP Raw/SectionM4MNREGARoster_1.dta", clear
append using "${followup_data}/TN Raw/SectionM4MNREGARoster_1.dta" 
append using "${followup_data}/UP Raw/SectionM4MNREGARoster_1.dta" 
isid Id subid

/// Destring & recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid skip)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

label var Id "Household ID"
label var subid "SubId"
label var qM4_NREGA_BHID "Baseline HH Roster ID"
label var qM4_NREGA_CHID "Current HH Roster ID"
label var q218_23_daysempl "Days employed under MNREGA"
label var q218_24_totearning "Total Earnings - MNREGA"

tempfile SecM4
save `SecM4'

// Merge
use `q218_22', clear
merge 1:m Id using `SecM4', nogen keep(3)


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionM4_MRNREGA_Kharif_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit


    
