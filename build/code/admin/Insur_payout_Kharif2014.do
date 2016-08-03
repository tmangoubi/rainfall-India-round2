/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			Insur_payout_Kharif2014.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 10, 2016

LAST EDITED:	April 11, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean insurance payout information from Kharif 2014
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${followup_data}/Payout_Information/AP Payout Beneficiaries tracker (incl address).xlsx - Payout Info
					
OUTPUTS: 		${builddta}/admin/Insur_payout_Kharif2014.dta
				
NOTE:			
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do Insur_payout_Kharif2014
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import & Clean Data (Long format)				 									
****************************************************************/

// Raw data
import excel using "${followup_data}/Payout_Information/AP Payout Beneficiaries tracker (incl address).xlsx", sheet("ONLY CLAIM") cellrange(A2) firstrow clear

// Clean variables
drop Sno
rename (ID Amt_Recieved Located) (a_1hhid Amt_Received Ins_payout_located)

// Label variables
label var a_1hhid "Household ID"
label var villname "Village"
label var farmers "Number of farmers" // Need to confirm
label var total_insurance_unit "Total unit of insurance farmers purchased"
label var Unitcost "Unit cost of insurance"
label var Amt_Received "Total amount farmers actually paid (50% of full-price)"
label var Total_Amount "Total price of insurance purchased"
label var payouts "Payout of unit insurance"
label var claims "Total amount of payout farmers received"
label var Ins_payout_located "Whether household was located at the time of insurance payout"

label define yesno 0 "No" 1 "Yes"
label value Ins_payout_located yesno
/*
compress
save "${builddta}/admin/Insur_payout_Kharif2014_cleaned.dta", replace


/****************************************************************
	SECTION 2: Clean Data (Wide format)				 									
****************************************************************/
// Now we will convert data into wide format, in order to be merged with round 2/3/follow-up data (leaving unique obs for each HH)

// Tag duplicate observations (some households purchased insurnace both in round 2 and round 3)
quietly bysort a_1hhid:  gen num_purchased = cond(_N==1,0,_n)
replace num_purchased=1 if (num_purchased==0) // 0 indicates household purchased insurance only once, while 1 & 2 indicates purchaed in both rounds.
** 


// Tag households with duplicats observations (i.e. purchased insurance in both rounds)
duplicates tag a_1hhid, gen(both_rounds)

quietly bysort a_1hhid:  gen purchased_round = cond(_N==1,0,_n)
recode purchased_round (0=2) (1=2) (2=3)

// Tag round 




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
merge 1:1 Id using `q300_X', keep(1 3) gen(q300_X_answered) // Drop households exist in B1 but NOT in master data
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


// Rename & relabel some variables for clarification
label var q301_lastyeahhcropownrent "Cultivate crop on own land/rented land - Kharif 2014"
rename q301_lastyeahhIrrcropownrent q302_lastyeahhIrrcropownrent
labe var q302_lastyeahhIrrcropownrent "Cultivate irregular crops on either owned or rented land - Last year (Jan - Dec 2014)"

// Order variables
order q300_1_listname1-q300_5_EstBen3, after(q300_AgrCoop)
order q300_X_answered, after(q300_AgrCoop)

*/
/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/admin/Insur_payout_Kharif2014_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

*/
