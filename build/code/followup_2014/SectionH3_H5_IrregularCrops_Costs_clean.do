/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionH3_H5_IrregularCrops_Costs_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 20, 2016

LAST EDITED:	May 20, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section H3, H4 and H5 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master data
					${builddta}/followup_2014/MasterData_cleaned.dta
											
OUTPUTS: 		${builddta}/followup_2014/SectionH3_H5_IrregularCrops_Costs_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionH3_H5_IrregularCrops_Costs_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q600_culirrcrop-q709_supfamlabdayC
label var q600_culirrcrop "DID your household cultivate irregular crops in 2014 OR PLAN to cultivate by May 2015?"

/// Destring and recode variables
qui destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Logic check
ds q600_culirrcrop_count-q709_supfamlabdayC, has(type numeric)
loc H3vars_num `r(varlist)'
ds q600_culirrcrop_count-q709_supfamlabdayC, has(type string)
loc H3vars_str `r(varlist)'

foreach var of local H3vars_num {
	qui replace `var'=.m if ((q600_culirrcrop==2) & (!mi(`var')))
}
foreach var of local H3vars_str {
	qui replace `var'="Valid Skip" if (q600_culirrcrop==2)
}
*


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionH3_H5_IrregularCrops_Costs_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
