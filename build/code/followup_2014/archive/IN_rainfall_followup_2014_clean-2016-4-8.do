/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			IN_rainfall_followup_2014_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	February 26, 2016

LAST EDITED:	April 7, 2016 by Seungmin Lee

DESCRIPTION: 	Import 2014 follow-up survey data and clean it
	
ORGANIZATION:	0 - Preamble
				1 - Recode Missing values
				2 - Cover Page
				X - Save and Exit
				
INPUTS: 		${followup_data}/Final Data/AICWIUP.dta

OUTPUTS: 		${builddta}/followup_2014/IN_rainfall_followup_2014_cleaned.dta
				
NOTE:			This do-file is based on "${r2_data}/AP/ap_marketing.do" with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do IN_rainfall_followup_2014_clean
log using "${buildlog}/`name_do'", replace


// Currently missing values are recoded as negative values which can distort future analyses
// We will recode those nagative numbers as various missing codes.
program var_recode
	quietly ds _all
	loc allvar `r(varlist)'
	foreach var of loc allvar {
		cap confirm numeric variable `var'
		if !_rc { // If a variable is a numeric variable
			qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
			qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
		}
		/* Let's not recode string variables for now.
		else { // If a variable is a non-numeric variable (string)
			replace `var'="blank" if (mi(`var') | `var'=="" | `var'=="-333") // Blank response (but not a valid response)
			replace `var'="don't know" if (`var'=="-999")
			replace `var'="refusal" if (`var'=="-777")
			replace `var'="" if (`var'=="-555")
		}
		*/
	}
end

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


// Variable cleaning

// ID
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
destring StartTimeHr, replace

/*
/// dups
drop dups // "0" across all observations except 88 obs - why do these 88 obs have missing dups? It seems all 88 obs with missing survey start time have missing dups.
*/


// Save
tempfile base cover_cleaned
save `base'
keep Id-dups
var_recode // Recode missing numeric variables
save `cover_cleaned'

/****************************************************************
	SECTION A: Household Roster
****************************************************************/

// A1: q101 ~ q110
use "${followup_data}/Final Data/SectionAHouseholdRoster_1.dta", clear

// Variable labeling
label var Id	"Household ID"
label var subid	"Household Member ID"

// Variable cleaning

/// subid
destring subid, replace

/// Year of birth
label var q105_1_ageYYYY "Year of Birth"
replace q105_1_ageYYYY="" if (q105_1_ageYYYY=="-")
destring q105_1_ageYYYY, replace

/// Daily Wage Employment
label define yesno 1 "Yes" 2 "No"
label value q106_engdlywageemp yesno

/// Kharif Health Expenditure
label var q110_hlthexpkha "Health Expenditure since the start of Kharif Season"
replace q110_hlthexpkha="0" if (q110_hlthexpkha=="-0")
replace q110_hlthexpkha="" if (q110_hlthexpkha=="-")
destring q110_hlthexpkha, replace

// Drop duplicates subid within a household

/// There are couple of observations with duplicate subid within a household.
/// We can distinguish proper member from improper member by observing ages, name, etc.
duplicates tag Id subid, gen(dup)
browse if dup==1

drop if (Id=="F1285" & q101_Hhmemnam=="GJHGHG") // Improper name
drop if (Id=="F1285" & q101_Hhmemnam=="HGJGJH") // Improper name
drop if (Id=="P244" & q101_Hhmemnam=="EYTWGW") // Improper name
drop if (Id=="P244" & q101_Hhmemnam=="YFG") // Improper name

/// Household "P4537" has duplicates obs which cannot be distinguished easily.
/// However, since "P4537" does not exist in the base dataset, it can be dropped.
drop if (Id=="P4537")

isid Id subid
drop dup

// Save (Long)
tempfile SectionA1 SectionA2
save `SectionA1'

// Collapse data to be merged with the main dataset later
collapse (sum) q110_hlthexpkha (count) subid, by(Id)
rename (subid q110_hlthexpkha) (NumberOfHHmembers Health_Expenditure_Kharif)
label var NumberOfHHmembers "Number of HH members"
label var Health_Expenditure_Kharif "Total household health expenditure since the beginning of Kharif season"

tempfile SectionA1_collapsed
save `SectionA1_collapsed' // This dataset will be later merged with base dataset

// A2: q111 ~ q115
use "${followup_data}/Final Data/SectionAHouseholdRoster2_1.dta", clear
destring subid, replace

// Like SectionA1, there are duplicates subid within a household.
// Duplicates in this dataset are more difficult (and sometimes impossible) to be distinguished, unfortunately.
duplicates drop // This drops one of the duplicates
drop if (Id=="F1285" & subid==2 & q112_2esttotschfeeyear==454) // Improper school fee (last year's fee is lower than Kharif school fee)
drop if (Id=="P244" & q111_highedulev==1) // For duplicates impossible to be distingushed, drop "Not eeducated" observation (This is a random criteria, so can be modified later)
drop if (Id=="P4537")
isid Id subid

// Merge A1, A2
save `SectionA2'
use `SectionA1', clear
merge 1:1 Id subid using `SectionA2', gen(SecA1_A2)
labe var SecA1_A2 "Household member data exist in Section A and A2"
label define SecA1_A2 1 "q101 ~ q110 only" 2 "q111 ~ q115 only" 3 "All section A questions (q101 ~ q115)"
label value SecA1_A2 SecA1_A2

// Save
var_recode // Recode variables
compress
save "${builddta}/followup_2014/SectionA1_HHroster_cleaned.dta", replace

/****************************************************************
	SECTION B : Wage Income & Employment
****************************************************************/

use "${followup_data}/Final Data/SectionBWageIncomeP2_1_clean.dta", clear
isid Id subid

// Variable cleaning

/// subid
destring subid, replace

/// Total agricultural earning in Kharif season - monetary + non-monetary
egen Total_agri_earning_kharif = rowtotal (q208_totearnlolagrikha11 q211_totvalnonmonkha11)
gen Daily_agri_earning_kharif = (Total_agri_earning_kharif / q206_totdaylocagrikhar11) // Total earning (money + non_money) divided by # of days worked
notes Total_agri_earning_kharif: Daily_agri_earning_kharif = (Total_agri_earning_kharif / q206_totdaylocagrikhar11)
notes Daily_agri_earning_kharif: Daily_agri_earning_kharif = (Total_agri_earning_kharif / q206_totdaylocagrikhar11)
label var Total_agri_earning_kharif "Total earning (monetary + non-monetary compensation) from agricultural wage employment - Kharif"
label var Daily_agri_earning_kharif "Average daily earning from agricultrual employment - Kharif"

// Save
var_recode // Recode variables
compress
save "${builddta}/followup_2014/SectionB1_WageEmployment_cleaned.dta", replace

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/


compress
save "${builddta}/followup_2014/followup_2014_compiled.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
