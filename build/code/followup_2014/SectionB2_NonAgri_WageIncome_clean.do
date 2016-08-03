/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionB2_NonAgri_WageIncome_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 8, 2016

LAST EDITED:	April 9, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section B2 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta - Masterdata (q213)
					${followup_data}/AP Raw/SectionBWageIncomeP4_1.dta
					${followup_data}/TN Raw/SectionBWageIncomeP4_1.dta
					${followup_data}/UP Raw/SectionBWageIncomeP4_1.dta
				
OUTPUTS: 		${builddta}/followup_2014/SectionB2_NonAgri_WageIncome_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionBWageIncomeP4_1.do"
				with additional modifications.
******************************************************************/


/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionB_WageIncome_clean
log using "${buildlog}/`name_do'", replace

/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q213_nonagrwageempkha11
tempfile Id_q213
save `Id_q213'

// Section B2
use "${followup_data}/AP Raw/SectionBWageIncomeP4_1.dta", clear
append using "${followup_data}/TN Raw/SectionBWageIncomeP4_1.dta" 
append using "${followup_data}/UP Raw/SectionBWageIncomeP4_1.dta" 
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


// Clean variables

/// q213_2_Hhrosid
/// In the dataset it is NOT ID, but actually name of wage earners. Rename variable as "wage earner"
rename q213_2_Hhrosid q213_2_wagearname

// Daily Wage & # of days worked & Total earning
// There are observations where total earning and daily wage are mistakenly swapped. Need to detect them and correct them.
gen swapped = 1 if (q214_totdaynonagriwork * q218_totearnlocnonagr == q217_avdaiwag)
gen temp = q218_totearnlocnonagr
replace q218_totearnlocnonagr = q217_avdaiwag if (swapped==1)
replace q217_avdaiwag = temp if (swapped==1)
drop swapped temp

// Generate outlier-indicator
// Here we define x as an outlier if "Q(25)-3IQR < x < Q(75)+3IQR"
foreach var in q218_totearnlocnonagr q217_avdaiwag {
	gen byte `var'_outlier=0
	order `var'_outlier, after(`var')
	qui sum `var', detail
	scalar `var'_IQR = r(p75)-r(p25)
	replace `var'_outlier=1 if !inrange(`var',r(p25)-(3*`var'_IQR),r(p75)+(3*`var'_IQR))
	scalar drop `var'_IQR
}
*

// Label variables
label var Id "Household ID"
label var subid "Roster ID"

label var  q213_1_baseHHrosid "Baseline HH Roster ID"
label var  q213_2_wagearname "HH Roster ID"
label var  q214_totdaynonagriwork "Total Days - Non-Agriculture Work"
label var  q218_totearnlocnonagr "Total Earnings - Non-Agricultural Work"
label var  q218_totearnlocnonagr_outlier "Is 'Total Earnings - Non-Agricultural Work' an outlier?"

replace q215_indnonagriworkprim_oth="VALID SKIP" if q215_indnonagriworkprim_oth=="-555"
replace q215_indnonagriworkprim_oth="MISSING" if q215_indnonagriworkprim_oth=="0"
replace q215_indnonagriworkprim_oth="100 DAY JOB" if q215_indnonagriworkprim_oth=="100 DAY S WORK"
replace q215_indnonagriworkprim_oth="ACCOUNTANT" if  q215_indnonagriworkprim_oth=="ACCOTENT"
replace q215_indnonagriworkprim_oth="CATERING" if q215_indnonagriworkprim_oth=="CATRING" 
replace q215_indnonagriworkprim_oth="CLOTHES SELLING" if q215_indnonagriworkprim_oth=="CLATHS SALING"
replace q215_indnonagriworkprim_oth="CLOTHES WASHING" if q215_indnonagriworkprim_oth=="CLOTHS WASHING" | q215_indnonagriworkprim_oth=="COLTH VASH" | q215_indnonagriworkprim_oth=="WACHMEN" | q215_indnonagriworkprim_oth=="WASHER MAN" | q215_indnonagriworkprim_oth=="WASHERMAN"
replace q215_indnonagriworkprim_oth="MASON" if q215_indnonagriworkprim_oth=="CUNSTRUCTION" | q215_indnonagriworkprim_oth=="HOUSING CONSTRUCTION"
replace q215_indnonagriworkprim_oth="CARPENTER" if q215_indnonagriworkprim_oth=="CORPENDOR" | q215_indnonagriworkprim_oth=="PARADALU"
replace q215_indnonagriworkprim_oth="ELECTRICIAN" if q215_indnonagriworkprim_oth=="POWAR" | q215_indnonagriworkprim_oth=="ELECRICTION" | q215_indnonagriworkprim_oth=="ELECTRICAL"
replace q215_indnonagriworkprim_oth="FACTORY" if q215_indnonagriworkprim_oth=="FACTORY WORK" | q215_indnonagriworkprim_oth=="PICE FACTRI" | q215_indnonagriworkprim_oth=="FOOD FACTORY"
replace q215_indnonagriworkprim_oth="CONFECTIONARY" if q215_indnonagriworkprim_oth=="HALWAI"
replace q215_indnonagriworkprim_oth="HELPER" if q215_indnonagriworkprim_oth=="HELPAR TELI PHONE" | q215_indnonagriworkprim_oth=="MYAREGI HELPAR" | q215_indnonagriworkprim_oth=="SCHOOL COOK"
replace q215_indnonagriworkprim_oth="LABOUR" if q215_indnonagriworkprim_oth=="LABOAR" | q215_indnonagriworkprim_oth=="LABOUR TRACTOR"
replace q215_indnonagriworkprim_oth="INHERITED PROFESSION" if q215_indnonagriworkprim_oth=="KULA VRUTTHI" | q215_indnonagriworkprim_oth=="KULAVRUTTHI"
replace q215_indnonagriworkprim_oth="MECHANIC" if q215_indnonagriworkprim_oth=="MEKANIC" | q215_indnonagriworkprim_oth=="MOBILE MEHANIC"
replace q215_indnonagriworkprim_oth="MASON" if q215_indnonagriworkprim_oth=="VELDING" | q215_indnonagriworkprim_oth=="MESHAN" | q215_indnonagriworkprim_oth=="MESHAN WORK" | q215_indnonagriworkprim_oth=="MESHTIRI" | q215_indnonagriworkprim_oth=="MESTRI" | q215_indnonagriworkprim_oth=="ROAD WORK" | q215_indnonagriworkprim_oth=="WELDEAR" | q215_indnonagriworkprim_oth=="WELDER" | q215_indnonagriworkprim_oth=="WELDING" | q215_indnonagriworkprim_oth=="WILDER"
replace q215_indnonagriworkprim_oth="MICRO FINANCE" if q215_indnonagriworkprim_oth=="MIGRO FIANCE"
replace q215_indnonagriworkprim_oth="NURSE" if q215_indnonagriworkprim_oth=="NURCUC"
replace q215_indnonagriworkprim_oth="PAINTER" if q215_indnonagriworkprim_oth=="PAINTINGS"
replace q215_indnonagriworkprim_oth="MILL" if q215_indnonagriworkprim_oth=="MILLU" | q215_indnonagriworkprim_oth=="RICE MEILE" | q215_indnonagriworkprim_oth=="RICE MILL" | q215_indnonagriworkprim_oth=="RICEMILL"
replace q215_indnonagriworkprim_oth="PETROL PUMP" if q215_indnonagriworkprim_oth=="PETROL BUNK PIPE MAN" | q215_indnonagriworkprim_oth=="RB OIL"
replace q215_indnonagriworkprim_oth="TRANSPORT" if q215_indnonagriworkprim_oth=="SCHOOL DRIVER" | q215_indnonagriworkprim_oth=="SCHOOL.VANTA" | q215_indnonagriworkprim_oth=="TRACTOR"
replace q215_indnonagriworkprim_oth="STUDIO" if q215_indnonagriworkprim_oth=="STOTIYOO"
replace q215_indnonagriworkprim_oth="TAILORING" if q215_indnonagriworkprim_oth=="TYIORING" | q215_indnonagriworkprim_oth=="TYLORING"

replace q215_indnonagriworkprim=15 if q215_indnonagriworkprim_oth=="TRANSPORT"
replace q215_indnonagriworkprim=22 if q215_indnonagriworkprim_oth=="MICRO FINANCE" | q215_indnonagriworkprim_oth=="ACCOUNTANT"
replace q215_indnonagriworkprim=14 if q215_indnonagriworkprim_oth=="ELECTRICIAN"
replace q215_indnonagriworkprim=25 if q215_indnonagriworkprim_oth=="MASON" | q215_indnonagriworkprim_oth=="MILL" | q215_indnonagriworkprim_oth=="MECHANIC"| q215_indnonagriworkprim_oth=="FACTORY"


label var  q215_indnonagriworkprim "Industry - Non-Agriculture Work"
label define industry 1 "Food Processing" 2 "Manufacturing of Textile Products" 3 "Manufacturing of Wooden Products, Furniture" 4 "Manufacturing of Paper Products, Printing, Publishing" 5 "Other Manufacturing of Industry" 6 "Agriculture" 7 "Livestock" 8 "Fisheries" 9 "Forestry" 10 "Wholesale Trade" 11 "Retail Trade" 12 "Other Business" 13 "Hotel/ Restaurants" 14 "Electricity/gas/water" 15 "Transportation" 16 "Communication" 17 "Army/Police" 18 "Science/ Education" 19 "Arts and Culture" 20 "Health care" 21 "Sport/ tourism/ retirement" 22 "Banking, finance and credit" 23 "Management and administration" 24 "Religious activities" 25 "Non-agricultural workers" 26 "Others" -222 "Not in HH Roster" -888 "Others"
label value q215_indnonagriworkprim industry
label var  q215_indnonagriworkprim_oth "Industry - Non-Agriculture Work - Other"

replace q216_occprim_oth="MISSING" if q216_occprim_oth=="-" | q216_occprim_oth=="0" | q216_occprim_oth=="C"
replace q216_occprim_oth="VALID SKIP" if q216_occprim_oth=="-555"
replace q216_occprim_oth="100 DAY JOB" if q216_occprim_oth=="1OODAYS WORK"
replace q216_occprim_oth="TRANSPORT" if q216_occprim_oth=="AUTO DRIVER" | q216_occprim_oth=="DRIVER" | q216_occprim_oth=="SCHOOLVANTA"
replace q216_occprim_oth="CATERING" if q216_occprim_oth=="CENTRING"
replace q216_occprim_oth="HELPER" if q216_occprim_oth=="COOKER" | q216_occprim_oth=="MAYAREGI HELPAR" | q216_occprim_oth=="SERVANT" | q216_occprim_oth=="WATAERBOY"
replace q216_occprim_oth="CARPENTER" if q216_occprim_oth=="CORPENDOR" | q216_occprim_oth=="KARPENTER" | q216_occprim_oth=="HOUSING CUP" | q216_occprim_oth=="PARADALU"
replace q216_occprim_oth="ELECTRICIAN" if q216_occprim_oth=="ELECTRICAL" | q216_occprim_oth=="ELECTRICIAN"
replace q216_occprim_oth="LABOUR" if q216_occprim_oth=="KULI" | q216_occprim_oth=="LABAR" | q216_occprim_oth=="LABOUR" | q216_occprim_oth=="LABOUR IN FACTORY" | q216_occprim_oth=="LEBAR"
replace q216_occprim_oth="MASON" if q216_occprim_oth=="MASTHRI" | q216_occprim_oth=="MESHRI" | q216_occprim_oth=="ROAD WORK" | q216_occprim_oth=="WELDER" | q216_occprim_oth=="WELDING"
replace q216_occprim_oth="PAINTING" if q216_occprim_oth=="PAINTINGS"
replace q216_occprim_oth="PETROL PUMP" if q216_occprim_oth=="PETROL BUNK PIPE MAN"
replace q216_occprim_oth="STUDIO" if q216_occprim_oth=="STODIYO"
replace q216_occprim_oth="TAILORING" if q216_occprim_oth=="TAYLORING"
replace q216_occprim=29 if q216_occprim_oth=="CARPENTER"
replace q216_occprim=61 if q216_occprim_oth=="MASON"
replace q216_occprim=62 if q216_occprim_oth=="HELPER"
replace q216_occprim=63 if q216_occprim_oth=="CONSTRUCTION"
replace q216_occprim=55 if q216_occprim_oth=="TRANSPORT"
replace q216_occprim=30 if q216_occprim_oth=="LABOUR"

label var  q216_occprim "Primary Occupation"
label var  q216_occprim_oth "Primary Occupation - Other"
label var q217_avdaiwag "Average Daily Wage"
label var q217_avdaiwag_outlier "Is 'Average Daily Wage' an outlier?"
label var  q218_1_relempl "Relationship to Employer"
label define relationship 1 "Immediate family" 2 "Same sub-caste" 3 "Same caste" 4 "Friend" 5 "No Relation" -666 "NA" -777 "Refuse" -888 "Others" -999 "Don't Know" -333 "Missing" -555 "Valid Skip"
label value q218_1_relempl relationship
label var  q218_1_relempl_oth "Relationship to Employer - Other"

#delimit ;
label define occupation 1 "Agricultural work on own farm" 2 "Supervisory work on agricultural activity on own farm" 3 "Share cropper / cultivate plot owned by others" 4 "Agricultural wage labor" 11 "Fisherman (Fishing)" 12 "Fish culture"
13 "Look after live stocks" 14 "Look after Poultry (Duck, Chicken,Pigeons)" 15 "Cultivation and other works on fruits" 16 "Agricultural wage labor (Off Farm)" 17 "Nursery/forestry" 18 "Other agricultural activities (excluding 11-17)"
21 "Processing of crops" 22 "Family labor in Enterprise" 23 "Family labor in Tailoring" 24 "Family labor in Sewing" 25 "Family labor in Pottery" 26 "Family labor in Blacksmith" 27 "Family labor in Goldsmith" 28 "Repairing of manufactured products/mechanics" 29 "Carpenter" 30 "Non-agri. wage labor" 
41 "Petty Trade (Small retail shop)" 42 "Medium Trader (Retail and insignificant wholesale)" 43 "Wholesale Trader" 44 "Contractor" 45 "Labor supplier" 51 "Rickshaw/ Van Pulling"
52 "Boat man" 53 "Wage labor in transport" 54 "Other transport workers" 55 "Driver (motorized vehicle)" 56 "Helper" 61 "Mason" 62 "Helper" 63 "Other construction worker"
64 "Earthen work" 65 "House Repairing (fixing)" 71 "Doctor" 73 "Advocate" 74 "Barber" 75 "Washerman" 76 "Full time house tutor" 77 "Imam/ Purohit" 79 "Kutir Shilpi (Handicrafts)"
81 "Others self employment" 82 "Service ( govt/employee)" 83 "Pension" 84 "Service worker in NGO" 85 "Servant in house (Maid/ Male)" 89 "Beggar";
#delimit cr

label value q216_occprim occupation

tempfile SecB2
save `SecB2'

// Merge q201 with B1
use `Id_q213', clear
merge 1:m Id using `SecB2', keep(3) nogen

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionB2_NonAgri_WageIncome_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
