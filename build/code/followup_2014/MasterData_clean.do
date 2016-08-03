/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			MasterData_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	February 26, 2016

LAST EDITED:	May 31, 2016 by Seungmin Lee

DESCRIPTION: 	Import Master Dataset of 2014 follow-up survey and clean it
	
ORGANIZATION:	0 - Preamble
				1 - Cover Page, ID
				X - Save and Exit
				
INPUTS: 		${followup_data}/Final Data/AICWIUP.dta

OUTPUTS: 		${builddta}/followup_2014/MasterData_cleaned.dta
				${builddta}/followup_2014/Front_page_cleaned.dta
				
NOTE:			Please run "IN_rainfall_globals.do" before running this file.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do MasterData_clean
log using "${buildlog}/`name_do'", replace

use "${followup_data}/Final Data/AICWIUP.dta", clear

/****************************************************************
	SECTION 2: Cover page			 									
****************************************************************/

// Variable labeling
label var Id			"Household ID"
label var RespName		"Respondent Name"
label var DressHofH		"DRES HofH"
label var PhoneNumber	"Phone Number"
label var DoorNumber	"Door Number"
label var StreetName	"Street Name"
label var DistrictID	"District ID"
label var TehsilID		"Tehsil ID"
label var BlockID		"Block ID"
label var VillageID		"VillageID"
label var VisitDay		"Day of Visit"
label var VisitMonth	"Month of Visit"
label var VisitYear		"Year of Visit"
label var RevisitMade	"Revisit Made?"
label var ReVisitDay	"Day of Revisit"
label var ReVisitMonth	"Month of Revisit"
label var ReVisitYear	"Year of Revisit"
label var Intvrname		"Interviewer Name"
label var IntvrID		"Interviewer ID"
label var SuprName		"Supervisor Name"
label var SuprID		"Supervisor ID"
label var StartTimeHr	"Hour of Survey Started"
label var StartTimeMin	"Minute of Survey Started"
label var enddate_day	"Day of survey ended"
label var enddate_month	"Month of survey ended"
label var enddate_year	"Year of survey ended"
label var endtime_hh	"Hour of survey ended"
label var endtime_min	"Minute of survey ended"
label var endComment	"Comment at the end of survey"


// ID cleaning
// Drop duplicate observations or improper observations
duplicates tag Id, gen(ID_dup)
sort Id
list Id if (ID_dup==1)
/// There are 5 households with duplicates (10 obs total)
/// 4 of them can be distinguished, since only one of the two has complete observation.
/// Unfortunately, Id=="P4537" can't be determined which observation has more complete information - this household will be dropped.
drop if (Id=="A1145" & DoorNumber=="-999")
drop if (Id=="A2040" & DoorNumber=="RR")
drop if (Id=="F1285" & DoorNumber=="6F6")
drop if (Id=="P244" & DoorNumber=="66")
drop if (Id=="P4537")
drop ID_dup

drop if (Id=="-555") // Invalid household ID
isid Id // Confirm there is no more duplicates.

/// StartTimeHr
replace StartTimeMin=15 if (StartTimeHr=="04:15")
replace StartTimeHr="04" if (StartTimeHr=="04:15")
// destring StartTimeHr, replace

// Destring & recode ID variables
destring Id-StartTimeMin, replace
ds Id-StartTimeMin, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

/*
/// dups
drop dups // "0" across all observations except 88 obs - why do these 88 obs have missing dups? It seems all 88 obs with missing survey start time have missing dups.
*/


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

// Save entire master dataset (Will be called in cleaning several survey sections)
qui compress
save "${builddta}/followup_2014/MasterData_cleaned.dta", replace

// Save front page only
keep Id-StartTimeMin machinename-endComment
save "${builddta}/followup_2014/Front_page_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
