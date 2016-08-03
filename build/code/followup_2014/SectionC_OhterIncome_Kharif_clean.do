/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionC_OtherIncome_Kharif_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 10, 2016

LAST EDITED:	April 11, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section C of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta - Master Data (including section C)
					
OUTPUTS: 		${builddta}/followup_2014/SectionC_OtherIncome_Kharif_cleaned.dta
				
NOTE:			
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionC_OtherIncome_Kharif_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import & Clean Data				 									
****************************************************************/

use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

keep Id q226_totincearnrecei_1-q228_hhmemrel_oth_12 // Keep Section C Only


// Destring & recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid skip)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Re-label variables

loc source1 "Domestic Remittance"
loc source2 "International Remittance"
loc source3 "Asset Sales(non-livestock)"
loc source4 "Entrepreneurial activity/start-up (since June 2014)"
loc source5 "Craft/Artisan"
loc source6 "Household-run business(small shop)/Transport/Trade"
loc source7 "Professional/Service"
loc source8 "Factory/Industry"
loc source9 "Tending Animals/Sale of animal goods/Fishing"
loc source10 "Scholarship/Lottery"
loc source11 "Government Pension"
loc source12 "Other (Specify)"


forval sourcenum=1/12 {
	label var q226_totincearnrecei_`sourcenum' "`source`sourcenum'' - Total earning"
	if (`sourcenum'==12) {
		label var q226_totincearnrecei_oth_`sourcenum' "`source`sourcenum'' - Earning source"
	}
	label var q227_totearncomplastkar_`sourcenum' "`source`sourcenum'' - Total earning compared to last Kharif"
	label var q228_hhmemrel_`sourcenum' "`source`sourcenum'' - HH Member 1 contributing"
	label var q228_hhmemrel_x2_`sourcenum' "`source`sourcenum'' - HH Member 2 contributing"
	label var q228_hhmemrel_x3_`sourcenum' "`source`sourcenum'' - HH Member 3 contributing"
	label var q228_hhmemrel_oth_`sourcenum' "`source`sourcenum'' - Other HH Member contributing"
}
*


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionC_OtherIncome_Kharif_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit


    
