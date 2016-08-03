/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionP_SocialNetwork_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 22, 2016

LAST EDITED:	May 22, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section L of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Masterdata
					${builddta}/followup_2014/MasterData_cleaned.dta
					
					// Section P
					${followup_data}/AP Raw/SectionPRoster_1.dta
					${followup_data}/TN Raw/SectionPRoster_1.dta
					${followup_data}/UP Raw/SectionPRoster_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionP_SocialNetwork_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionPRoster_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionP_SocialNetwork_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q1501_relresinvill q1501_relresinvill_count
tempfile q1501
save `q1501'

// Section P
use "${followup_data}/AP Raw/SectionPRoster_1.dta", clear
append using "${followup_data}/TN Raw/SectionPRoster_1.dta" 
append using "${followup_data}/UP Raw/SectionPRoster_1.dta" 
isid Id subid

// Destring and recode variables
destring subid q*, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Label variables
label var Id "Household ID"
label var subid "SubId"
label var q1502_namerelHHinvil "Name of relative"
label var q1503_fathnamepriHH "Relative's Father's Name"
label var q1504_relwitresp "Relationship with respondent"
label var q1504_relwitresp_oth "Relationship with respondent - Other"
label var q1505_streetadd "Relative - Street Address"
label var q1506_landmark "Relative - Landmark"
label var q1507_percult "Is relative a cultivator?"
label var q1505_phnumber "Relative - Phone Number"

label value q1507_percult yesno

label define relationship 1 "Head of Household" 2 "Spouse" 3 "Son/Daughter" 4 "Daughter-in-law/son-in-law" 5 "Grand son/daughter"  ///
	6 "Parents" 7 "Father/mother-in-law" 8 "Brother/sister" 9 "Brother/sister-in-law" 10 "Uncle/aunt" 11 "Nephew/niece" ///
	12 "Foster child/step child" 13 "Other" 14 "Grandmother/father"
label value q1504_relwitresp relationship

tempfile SecP
save `SecP'


// Merge q1501 and section P
use `q1501', clear
merge 1:m Id using `SecP', nogen keep(3)
order Id subid, alphabetic

/// Logic check
ds subid-q1505_phnumber, has(type numeric)
loc numvars `r(varlist)'
ds subid-q1505_phnumber, has(type string)
loc strvars `r(varlist)'

foreach var of loc numvars {
	replace `var'=.b if ((q1501_relresinvill==2) & !mi(`var'))
}
foreach var of loc strvars {
	replace `var'="Mistake" if ((q1501_relresinvill==2) & !mi(`var'))
}
*

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionP_SocialNetwork_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
