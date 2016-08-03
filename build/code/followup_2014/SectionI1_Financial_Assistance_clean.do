/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionI1_Financial_Assistance_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 18, 2016

LAST EDITED:	May 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section I1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionI1_Financial_Assistance_cleaned.dta
				
NOTE:			
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionI1_Financial_Assistance_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

/// Keep ID and Section I1
keep Id q1111_givgiftkha10_1-q1116_totvalcolforloan_14
order *, alphabetic
order q1111_givgiftkha10_10-q1111_givgiftkha10_14, after(q1111_givgiftkha10_9)
order q1112_totvalallgift_10-q1112_totvalallgift_14, after(q1112_totvalallgift_9)
order q1113_totvalallmarrgift_10-q1113_totvalallmarrgift_14, after(q1113_totvalallmarrgift_9)
order q1114_giveloankha11_10-q1114_giveloankha11_14, after(q1114_giveloankha11_9)
order q1115_1_intcharloan_10-q1115_1_intcharloan_14, after(q1115_1_intcharloan_9)
order q1115_totamtloangiv_10-q1115_totamtloangiv_14, after(q1115_totamtloangiv_9)
order q1116_totvalcolforloan_10-q1116_totvalcolforloan_14, after(q1116_totvalcolforloan_9)

// Correct errors
ds q1113_*, has(type string)
local q1113var_str `r(varlist)'
foreach var of local q1113var_str {
	replace `var'="" if (`var'=="-")
}
*
replace q1113_totvalallmarrgift_12="" if (q1113_totvalallmarrgift_12=="-")

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
	replace q1112_totvalallgift_`i'=.m if (inlist(q1111_givgiftkha10_`i',2,.r,.n) & !mi(q1112_totvalallgift_`i'))
	replace q1113_totvalallmarrgift_`i'=.m if (inlist(q1111_givgiftkha10_`i',2,.r,.n) & !mi(q1113_totvalallmarrgift_`i'))
	
	replace q1115_totamtloangiv_`i'=.m if (inlist(q1114_giveloankha11_`i',2,.r,.n) & !mi(q1115_totamtloangiv_`i'))
	replace q1115_1_intcharloan_`i'=.m if (inlist(q1114_giveloankha11_`i',2,.r,.n) & !mi(q1115_1_intcharloan_`i'))
	replace q1116_totvalcolforloan_`i'=.m if (inlist(q1114_giveloankha11_`i',2,.r,.n) & !mi(q1116_totvalcolforloan_`i'))
}
*
/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionI1_Financial_Assistance_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
