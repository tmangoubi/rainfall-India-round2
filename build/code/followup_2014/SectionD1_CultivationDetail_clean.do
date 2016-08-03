/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionD1_CultivationDetail_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 10, 2016

LAST EDITED:	April 11, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section D1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master
						${builddta}/followup_2014/MasterData_cleaned.dta - Master Data (q300, q301)
					
					// Section D1
						${followup_data}/AP Raw/SectionDP2_1.dta
						${followup_data}/TN Raw/SectionDP2_1.dta
						${followup_data}/UP Raw/SectionDP2_1.dta
						
						
OUTPUTS: 		${builddta}/followup_2014/SectionD1_CultivationDetail_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionDP2_1.do" (written by Alreena Pinto)
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
keep Id q300_AgrCoop q301_lastyeahhcropownrent-q302_2_AreaUnit_oth_4

/// Destring & recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid skip)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*
label define yesno 1 "Yes" 2 "No", replace

tempfile q30X
save `q30X'

// Section D1 (Part 1)
use "${followup_data}/AP Raw/SectionDP2_1.dta", clear
append using "${followup_data}/TN Raw/SectionDP2_1.dta" 
append using "${followup_data}/UP Raw/SectionDP2_1.dta" 
isid Id subid

/// Variable cleaning
//// q300_4_MemFee
replace q300_4_MemFee="200" if (q300_4_MemFee=="200-")

/// Destring & recode variables
destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid skip)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Reshape 
/// Since q300.X is a long dataset and the rest of dataset is wide, we can reshape q300.X from wide into long (there are only 3 different subids, which makes easier to reshape)
reshape wide q300*, i(Id) j(subid)

// Label variables
label var Id "Household ID"

forval subid=1/3 {
	label var  q300_1_listname`subid' "Name of Cooperative, HH member `subid'"
	label var  q300_2_MM`subid' "Month of Joining, HH member `subid'"
	label var  q300_3_YYYY`subid' "Year of Joining, HH member `subid'"
	label var  q300_4_MemFee`subid' "Membership Fee of 2014, HH member `subid'"
	label var  q300_5_EstBen`subid' "Estimated Benefit in Kharif 2015 (July - Dec 2014), HH member `subid'"
}
*

tempfile q300_X
save `q300_X'

use `q30X', clear
merge 1:1 Id using `q300_X', keep(1 3) gen(q300_X_answered) // Drop households exist in D1 but NOT in master data
recode q300_X_answered (1=2) (3=1)
label value q300_X_answered yesno
label var q300_X_answered "Did this household answer questions q300_X? (Editor generated)"

// Check & correct data entry error
tab q300_AgrCoop q300_X_answered, m

list q300* if (q300_AgrCoop==2 & q300_X_answered==1) // List households who answered "NO" in q300 but answered the rest of D1 questions.
list q300* if (q300_AgrCoop==.b & q300_X_answered==1) // List households who did not answer q300 but answered the rest of D1 questions.
// It seems they are all valid observation, indicating they answered q300 "No" by mistake. Need to correct them.
replace q300_AgrCoop=1 if (q300_AgrCoop==2 & q300_X_answered==1)
replace q300_AgrCoop=1 if (q300_AgrCoop==.b & q300_X_answered==1)


// Land unit (q301)
replace q301_lastyeahhcropownrent=1 if ( q301_lastyeahhcropownrent==2 & q301_1_1_AreaCult_1>=0 & !mi( q301_1_1_AreaCult_1))
replace q301_2_AreaUnit_oth_1="" if regexm(q301_2_AreaUnit_oth_1,"555") // Valid skip
replace q301_2_AreaUnit_oth_1="" if (inrange(q301_2_AreaUnit_1,1,8) & inlist(q301_2_AreaUnit_oth_1,"-666","0"))
replace q301_2_AreaUnit_oth_1="" if (mi(q301_2_AreaUnit_1) & inlist(q301_2_AreaUnit_oth_1,"-666","0"))
replace q301_2_AreaUnit_oth_1="blank" if (q301_2_AreaUnit_1==-888 & q301_2_AreaUnit_oth_1=="")

replace q301_lastyeahhcropownrent=1 if ( q301_lastyeahhcropownrent==2 & q301_1_1_AreaCult_2>=0 & !mi( q301_1_1_AreaCult_2))
replace q301_2_AreaUnit_oth_2="" if regexm(q301_2_AreaUnit_oth_2,"555") // Valid skip
replace q301_2_AreaUnit_oth_2="" if regexm(q301_2_AreaUnit_oth_2,"-")
replace q301_2_AreaUnit_oth_2="" if regexm(q301_2_AreaUnit_oth_2,"XXD")
replace q301_2_AreaUnit_2=.n if (q301_2_AreaUnit_2==-888)
replace q301_2_AreaUnit_oth_2="" if inlist(q301_2_AreaUnit_oth_2,"0","1")

replace q301_lastyeahhcropownrent=1 if ( q301_lastyeahhcropownrent==2 & q301_1_1_AreaCult_3>=0 & !mi( q301_1_1_AreaCult_3))
replace q301_2_AreaUnit_3=.n if q301_2_AreaUnit_3==-888
replace q301_2_AreaUnit_oth_3=. if q301_2_AreaUnit_oth_3==0
*replace q301_2_AreaUnit_oth_3=. if q301_2_AreaUnit_oth_3==.b

replace q301_lastyeahhcropownrent=1 if ( q301_lastyeahhcropownrent==2 & q301_1_1_AreaCult_4>=0 & !mi( q301_1_1_AreaCult_4))
replace q301_2_AreaUnit_4=.n if (q301_2_AreaUnit_4==-888)
replace q301_2_AreaUnit_oth_4=. if (q301_2_AreaUnit_oth_4==0)
*replace q301_2_AreaUnit_oth_4=. if (q301_2_AreaUnit_oth_4==.b)

// Land unit (q302)
replace q301_lastyeahhIrrcropownrent=1 if ( q301_lastyeahhIrrcropownrent==2 & q302_1_AreaCult_1>=0 & !mi( q302_1_AreaCult_1))
replace q302_2_AreaUnit_oth_1=. if (q302_2_AreaUnit_oth_1==0)
*replace q302_2_AreaUnit_oth_1=. if (q302_2_AreaUnit_oth_1==.b)

replace q301_lastyeahhIrrcropownrent=1 if ( q301_lastyeahhIrrcropownrent==2 & q302_1_AreaCult_2>=0 & !mi( q302_1_AreaCult_2))
replace q302_2_AreaUnit_oth_2=. if (q302_2_AreaUnit_oth_2==0)
*replace q302_2_AreaUnit_oth_2=. if (q302_2_AreaUnit_oth_2==.b)

replace q301_lastyeahhIrrcropownrent=1 if ( q301_lastyeahhIrrcropownrent==2 & q302_1_AreaCult_3>=0 & !mi( q302_1_AreaCult_3))
replace q301_lastyeahhIrrcropownrent=1 if ( q301_lastyeahhIrrcropownrent==2 & q302_1_AreaCult_4>=0 & !mi( q302_1_AreaCult_4))


// Rename & relabel some variables for clarification
label var q301_lastyeahhcropownrent "Cultivate crop on own land/rented land - Kharif 2014"
rename q301_lastyeahhIrrcropownrent q302_lastyeahhIrrcropownrent
labe var q302_lastyeahhIrrcropownrent "Cultivate irregular crops on either owned or rented land - Last year (Jan - Dec 2014)"

// Order variables
order q300_1_listname1-q300_5_EstBen3, after(q300_AgrCoop)
order q300_X_answered, after(q300_AgrCoop)



/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionD1_CultivationDetail_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

