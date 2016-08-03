/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionM1_LeanPeriod_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 8, 2016

LAST EDITED:	June 3, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section M1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${followup_data}/AP Raw/SectionM1Roster_1.dta
					${followup_data}/TN Raw/SectionM1Roster_1.dta
					${followup_data}/UP Raw/SectionM1Roster_1.dta
				
OUTPUTS: 		${builddta}/followup_2014/SectionM1_LeanPeriod_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionM1Roster_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionM1_LeanPeriod_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/


use "${followup_data}/AP Raw/SectionM1Roster_1.dta", clear
append using "${followup_data}/TN Raw/SectionM1Roster_1.dta" 
append using "${followup_data}/UP Raw/SectionM1Roster_1.dta" 
isid Id subid

// Variable cleaning

/// q224_1_homesaving
replace q224_1_homesaving = "0" if (q224_1_homesaving=="-0")
replace q224_1_homesaving = "" if (q224_1_homesaving=="-")


// Destring and recode variables
destring *, replace
qui ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) (-222=.n) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
	if ("`var'" == "q224_destearning") {
		qui recode `var' (-222=.n)
	}
}
*

/*
***** q224_destearning *****
* There are over 1K observation who responded "0" destination income. This does NOT make sense, so I assumed those who answered "0" migration income did not actually migrate.
* However, there are many observations which answered "NO" in the question "did anyone migrate during Kharif(Lean) season?" (q218), but have non-zero positive migration income (q224_destearning)
* I(SL) do NOT know the reason of this discrepancy. India field team is not answering my questions.
* Maybe this variable is not migration income, since we have q213.25 (Total income of migrant) <- but this section (M2B) data is missing!

(update(2016/6/3) - I will replace those 1K obs with "0" migration income as "missing")
*/
clonevar q224_destearning_c = q224_destearning
replace q224_destearning_c =. if (q224_destearning==0)
order q224_destearning_c, after(q224_destearning)

// Tag outliers
loc money_vars q223_avgdailywage q223_1_avgmonthwage q223_2_homeearning q224_destearning_c q224_1_homesaving
foreach var of loc money_vars {
	gen byte `var'_outlier=0
	order `var'_outlier, after(`var')
	qui sum `var', detail
	scalar `var'_IQR = r(p75)-r(p25)
	replace `var'_outlier=1 if !inrange(`var',r(p25)-(3*`var'_IQR),r(p75)+(3*`var'_IQR))
	label var `var'_outlier "=1: this obs is an outlier"
	note `var'_outlier: Defined as outlier if x < Q(25)-3IQR  or  x > Q(75)+3IQR
	scalar drop `var'_IQR
}
*

// Label variables
note: Lean period is from April to July in UP and AP, and from June to September in TN
label define yesno 1 "Yes" 2 "No"

label var Id "Household ID"
label var subid "SubId"
label var qM1_BHID "Baseline HH Roster ID"
label var qM1_HHRID "Current HH Roster ID"

label var q222_3_industry "Industry - Find work"
label define industry 1 "Food Processing" 2 "Manufacturing of Textile Products" 3 "Manufacturing of Wooden Products, Furniture" 4 "Manufacturing of Paper Products, Printing, Publishing" 5 "Other Manufacturing of Industry" 6 "Agriculture" 7 "Livestock" 8 "Fisheries" 9 "Forestry" 10 "Wholesale Trade" 11 "Retail Trade" 12 "Other Business" 13 "Hotel/ Restaurants" 14 "Electricity/gas/water" 15 "Transportation" 16 "Communication" 17 "Army/Police" 18 "Science/ Education" 19 "Arts and Culture" 20 "Health care" 21 "Sport/ tourism/ retirement" 22 "Banking, finance and credit" 23 "Management and administration" 24 "Religious activities" 25 "Non-agricultural workers" 26 "Others" -888 "Others"
label value q222_3_industry industry
label var q222_3_industry_oth "Industry - Find work - Other"

label var q221_primaryactivity "Activities for work"
#delimit ;
label define occupation 1 "Agricultural work on own farm" 2 "Supervisory work on agricultural activity on own farm" 3 "Share cropper / cultivate plot owned by others" 4 "Agricultural wage labor" 11 "Fisherman (Fishing)" 12 "Fish culture"
13 "Look after live stocks" 14 "Look after Poultry (Duck, Chicken,Pigeons)" 15 "Cultivation and other works on fruits" 16 "Agricultural wage labor (Off Farm)" 17 "Nursery/forestry" 18 "Other agricultural activities (excluding 11-17)"
21 "Processing of crops" 22 "Family labor in Enterprise" 23 "Family labor in Tailoring" 24 "Family labor in Sewing" 25 "Family labor in Pottery" 26 "Family labor in Blacksmith" 27 "Family labor in Goldsmith" 28 "Repairing of manufactured products/mechanics" 29 "Carpenter" 30 "Non-agri. wage labor" 
41 "Petty Trade (Small retail shop)" 42 "Medium Trader (Retail and insignificant wholesale)" 43 "Wholesale Trader" 44 "Contractor" 45 "Labor supplier" 51 "Rickshaw/ Van Pulling"
52 "Boat man" 53 "Wage labor in transport" 54 "Other transport workers" 55 "Driver (motorized vehicle)" 56 "Helper" 61 "Mason" 62 "Helper" 63 "Other construction worker"
64 "Earthen work" 65 "House Repairing (fixing)" 71 "Doctor" 73 "Advocate" 74 "Barber" 75 "Washerman" 76 "Full time house tutor" 77 "Imam/ Purohit" 79 "Kutir Shilpi (Handicrafts)"
81 "Others self employment" 82 "Service ( govt/employee)" 83 "Pension" 84 "Service worker in NGO" 85 "Servant in house (Maid/ Male)" 89 "Beggar";
#delimit cr
label value q221_primaryactivity occupation

label var q221_primaryactivity_oth "Activities for work - Other"
label var q223_avgdailywage "Average daily wage"
label var q223_1_avgmonthwage "Average monthly income"
label var q223_2_homeearning "Earnings at home during lean period"
label var q224_destearning "Earnings at destination during lean period"
label var q224_destearning_c "Earnings at destination during lean period (cleaned)"
label var q224_1_homesaving "Savings at home during lean period"
label var q225_relationship "Relationship to employer"
label var q225_relationship_oth "Relationship to employer - Other"
label var q225_1_knowanybody "Know anybody at migration destination?"
label var q225_2_newplace "Relationship with people at migration destination_1"
label var q225_3_newplace "Relationship with people at migration destination_2"
label var q225_4_newplace "Relationship with people at migration destination_3"
label var q225_5_mnrega "Employed under MNREGA"
label var q225_6_daysempl "Days employed under MNREGA"
label var q225_7_totmnrgaearning "Total earnings - MNREGA"

label define people 1 "Parents" 2 "Siblings" 3 "Children" 4 "Spouse / fiancée" 5 "Other relatives" 6 "Friends" 7 "Neighbours" 8 "Unknown" 9 "Living alone"
label value q225_2_newplace q225_3_newplace q225_4_newplace people
label value q225_5_mnrega yesno


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionM1_LeanPeriod_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
