/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionG_Insurance_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 10, 2016

LAST EDITED:	April 11, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section G of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Section G
						${builddta}/followup_2014/MasterData_cleaned.dta - Master Data
					
OUTPUTS: 		${builddta}/followup_2014/SectionG_Insurance_cleaned.dta
				
NOTE:			
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionG_Insurance_clean
log using "${buildlog}/`name_do'", replace

/****************************************************************
	SECTION 1: Import & Clean Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear

/// Keep ID and Section G
keep Id q1401_indculcropkha11-q1406_amt_6

/// Destring and recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Clean variables

/// Varsha Bhima
/// Some households answered q1402 and onward which they should have skipped.
/// They did not seem to purcahse, so we can replace their answers to q1402, ... as "missing"

tab q1402_hrdschename_1 q1403_purcscheme_1, m
list Id q1403_purcscheme_1 q1404_totprempaidlastyear_1 q1405_purins_1 q1406_amt_1 if (q1402_hrdschename_1==2 & inlist(q1403_purcscheme_1,1,2))
foreach var in q1403_purcscheme_1 q1404_totprempaidlastyear_1 q1405_purins_1 q1406_amt_1 {
	replace `var'=. if q1402_hrdschename_1==2
}
*
replace q1403_purcscheme_1=1 if (Id=="P562")
replace q1406_amt_1=. if (q1405_purins_1==2)
replace q1406_amt_1=.m if (q1406_amt_1<10) 


/// NAIS
list Id q1403_purcscheme_2 q1404_totprempaidlastyear_2 q1405_purins_2 q1406_amt_2 if (q1402_hrdschename_2==2 & inlist(q1403_purcscheme_2,1,2))
foreach var in q1403_purcscheme_2 q1404_totprempaidlastyear_2 q1405_purins_2 q1406_amt_2 {
	replace `var'=. if inlist(q1402_hrdschename_2,.,2)
}
*
replace q1406_amt_2=. if (q1405_purins_2==2)


/// MNAIS
list Id q1403_purcscheme_3 q1404_totprempaidlastyear_3 q1405_purins_3 q1406_amt_3 if (q1402_hrdschename_3==2 & inlist(q1403_purcscheme_3,1,2))
foreach var in q1403_purcscheme_3 q1404_totprempaidlastyear_3 q1405_purins_3 q1406_amt_3 {
	replace `var'=. if inlist(q1402_hrdschename_3,.,2)
}
*

/// WBCIS
list Id q1403_purcscheme_4 q1404_totprempaidlastyear_4 q1405_purins_4 q1406_amt_4 if (q1402_hrdschename_4==2 & inlist(q1403_purcscheme_4,1,2))
replace q1402_hrdschename_4=1 if (Id=="P4972")
foreach var in q1403_purcscheme_4 q1404_totprempaidlastyear_4 q1405_purins_4 q1406_amt_4 {
	replace `var'=. if inlist(q1402_hrdschename_4,.,2)
}
*

/// Delayed Monsoon Onset Scheme
list Id q1403_purcscheme_5 q1404_totprempaidlastyear_5 q1405_purins_5 q1406_amt_5 if (q1402_hrdschename_5==2 & inlist(q1403_purcscheme_5,1,2))
foreach var in q1403_purcscheme_5 q1404_totprempaidlastyear_5 q1405_purins_5 q1406_amt_5 {
	replace `var'=. if inlist(q1402_hrdschename_5,.,2)
}
*
replace q1406_amt_5=. if (q1405_purins_5==2)

/// Others
/// Only one observation who purchased "HBM" is the valid observation. None of the observation (household) purchased other insurance scheme

list Id q1403_purcscheme_6 q1403_purcscheme_oth_6 q1404_totprempaidlastyear_6 q1405_purins_6 q1406_amt_6 if (q1402_hrdschename_6==2 & inlist(q1403_purcscheme_6,1,2))
foreach var in q1403_purcscheme_6 q1404_totprempaidlastyear_6 q1405_purins_6 q1406_amt_6 {
	replace `var'=. if inlist(q1402_hrdschename_6,.,2)
}
*
replace q1402_hrdschename_6=2 if (!mi(q1403_purcscheme_6) & q1402_hrdschename_oth_6!="HBM")
replace q1402_hrdschename_oth_6="-555" if (!mi(q1402_hrdschename_oth_6) & q1402_hrdschename_oth_6!="HBM")
replace q1403_purcscheme_oth_6="-555" if (!mi(q1403_purcscheme_oth_6) & q1403_purcscheme_oth_6!="HBM")
replace q1404_totprempaidlastyear_6=. if (q1403_purcscheme_6==2)

// Label variable
label define yesno 1 "Yes" 2 "No", replace

/*
// Generate variables for analyses
egen fl_insurance_any_heard = rowmin(q1402_hrdschename_1 q1402_hrdschename_2 q1402_hrdschename_3 q1402_hrdschename_4 q1402_hrdschename_5 q1402_hrdschename_6)
*/

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionG_Insurance_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

