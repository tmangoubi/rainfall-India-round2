/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionD2_CropDetails_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 11, 2016

LAST EDITED:	April 12, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section D2 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// D2
						${builddta}/followup_2014/MasterData_cleaned.dta - Master Data
						
OUTPUTS: 		${builddta}/followup_2014/SectionD2_CropDetails_cleaned.dta
				
NOTE:			Q328 (Area cultivated) is missing in the raw data.
				This do-file does not clean all questions, since there are too many skip patterns in this section considering its importance.
				Please do not hesitate to complete finishing this section if you have enough time (I believe you do not).
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionD2_CropDetails_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import & Clean Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q324_2_CulCrops-q332_outunitmeas_oth_5 q333_1_curown_1-q338_planpurkha_23


// Clean variables

/// Q324
/// Some households answered they did not cultivate any crops listed, but they answered they did in later questions.
replace q324_2_CulCrops=1 if inlist(Id,"P3124","P3579","P4715") // Change their answer from "No" to "Yes"
replace q327_plancrop_1=2 if inlist(Id,"P2068","P2199","P4924")
replace q327_plancrop_1=1 if inlist(Id,"F2166","P1092")

/// One household (Id=="P3425") answered "Yes" to q324 but skipped most questions. Need to correct them.
foreach var in q327_plancrop_1 q327_plancrop_2 q327_plancrop_3 q327_plancrop_5 {
	qui replace `var' =2 if (Id=="P3425")
}
*
/// Applying skip patterns
forval cropnum=1/5{
	replace q329_lowposoutperacre_`cropnum'=. if (q327_plancrop_`cropnum'==2)
	replace q330_highposoutperacre_`cropnum'=. if (q327_plancrop_`cropnum'==2)
	replace q331_mostfreoutperacre_`cropnum'=. if (q327_plancrop_`cropnum'==2)
	replace q332_outunitmeas_`cropnum'=. if (q327_plancrop_`cropnum'==2)
	if (`cropnum'==2) {
		replace q332_outunitmeas_oth_`cropnum'=. if (q327_plancrop_`cropnum'==2)
	}
	else {
		replace q332_outunitmeas_oth_`cropnum'="" if (q327_plancrop_`cropnum'==2)
	}
}
*

/// Destring & recode variables
qui destring *, replace
qui ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid skip)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*
label define yesno 1 "Yes" 2 "No", replace
label value q327_plancrop_1 q327_plancrop_2 q327_plancrop_3 q327_plancrop_4 q327_plancrop_5 yesno




/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionD2_CropDetails_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

