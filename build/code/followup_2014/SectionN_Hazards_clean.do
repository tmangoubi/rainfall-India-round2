/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionN_Hazards_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section L of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionN_Hazards_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionN_Hazards_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

/// Keep ID and Section L1
keep Id q1301_HHunusnotfood-q1305_oth_copethirstrat_3
order *, alphabetic
/*
loc vars 	q1102_recgiftKha11 q1103_totvalallgiftrs q1104_totvalmarrgift q1105_recloankha11 q1106_amtloanrec ///
			q1107_totmonownloan q1108_1_totMMloanper q1108_numpayloanper q1109_1_totvalcol q1109_totpaidwitint
foreach var of loc vars {
	order `var'_10-`var'_14, after(`var'_9)
}
*			
*/
/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionN_Hazards_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
