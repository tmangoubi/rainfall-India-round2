/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionI2_Gifts_Loans_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section I2 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionI2_Gifts_Loans_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionI2_Gifts_Loans_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

/// Keep ID and Section I2
keep Id q1102_recgiftKha11_1-q1109_1_totvalcol_14
order *, alphabetic
loc vars 	q1102_recgiftKha11 q1103_totvalallgiftrs q1104_totvalmarrgift q1105_recloankha11 q1106_amtloanrec ///
			q1107_totmonownloan q1108_1_totMMloanper q1108_numpayloanper q1109_1_totvalcol q1109_totpaidwitint
foreach var of loc vars {
	order `var'_10-`var'_14, after(`var'_9)
}
*

/// Correct errors
replace q1108_1_totMMloanper_6="" if q1108_1_totMMloanper_6=="-"


/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Logic check
forval i=1/14{
	di "i is `i'"
	replace q1103_totvalallgiftrs_`i'=.m if (inlist(q1102_recgiftKha11_`i',2,.r,.n) & !mi(q1103_totvalallgiftrs_`i'))
	replace q1104_totvalmarrgift_`i'=.m if (inlist(q1102_recgiftKha11_`i',2,.r,.n) & !mi(q1104_totvalmarrgift_`i'))
	
	replace q1106_amtloanrec_`i'=.m if (inlist(q1105_recloankha11_`i',2,.r) & !mi(q1106_amtloanrec_`i'))
	replace q1107_totmonownloan_`i'=.m if (inlist(q1105_recloankha11_`i',2,.r) & !mi(q1107_totmonownloan_`i'))
	replace q1108_1_totMMloanper_`i'=.m if (inlist(q1105_recloankha11_`i',2,.r) & !mi(q1108_1_totMMloanper_`i'))
	replace q1108_numpayloanper_`i'=.m if (inlist(q1105_recloankha11_`i',2,.r) & !mi(q1108_numpayloanper_`i'))
	replace q1109_1_totvalcol_`i'=.m if (inlist(q1105_recloankha11_`i',2,.r) & !mi(q1109_1_totvalcol_`i'))
	replace q1109_totpaidwitint_`i'=.m if (inlist(q1105_recloankha11_`i',2,.r) & !mi(q1109_totpaidwitint_`i'))
}
*

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionI2_Gifts_Loans_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
