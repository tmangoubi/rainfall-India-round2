/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionH1_IrrCrop_cropdetail_2014_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	June 18, 2016

LAST EDITED:	June 18, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section H1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Raw data 
					${builddta}/followup_2014/MasterData_cleaned.dta

					${followup_data}/AP Raw/SectionH1Roster_1.dta
					${followup_data}/TN Raw/SectionH1Roster_1.dta
					${followup_data}/UP Raw/SectionH1Roster_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionH1_IrrCrop_cropdetail_2014_cleaned.dta
				
NOTE:			This do-file is based on "${followup_data}/Final Data/20.04.2016/AIC Missing Cleaned Files/SectionH1Roster_1.do"
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionH1_IrrCrop_cropdetail_2014_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Q304
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q304_culirrcropyear q304_count
lab var q304_culirrcropyear "Cultivated irregular crop in 2014 (or plan to cultivate in 2015)"

tempfile q304
save `q304'


// H1 Roster data

use "${followup_data}/AP Raw/SectionH1Roster_1.dta", clear
append using "${followup_data}/TN Raw/SectionH1Roster_1.dta" 
append using "${followup_data}/UP Raw/SectionH1Roster_1.dta" 
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
label var q305_namcrop "Name of crop grown"
label var q306_cropvarseed "Crop variety, seed variety"
label var q306_1_SeedVariety "Seed variety generation"
label var q307_cropcode "Crop code"
label var q308_plancropmay11 "Planted this crop since June 2014?"
rename q308_plancropmay11 q308_plancropjune14
label var q309_mstrecplanMM "Month of planting"
label var q309_1_mstrecplantYY "Year of planting"
label var q310_areaplaqua "Area of crop"
label var q310_1_areaplaunit "Unit for area of crop"
label var q310_1_areaplaunit_oth "Other unit for area of crop"
label var q313_harcropmay11 "Harvested crop since January 2014"
rename q313_harcropmay11 q313_harcropjan14
label var q314_harmm "Month of harvest"
label var q314_1haryy "Year of harvest"
label var q312_areaplanquant "Area PLAN to plant crop"
label var q312_1_areaplanunit "Unit for area PLAN to plant crop"
label var q312_1_areaplanunit_oth "Other unit for area PLAN to plant crop"
label var q310_2_planplantmm "Plan to plant crop again before May 2015"
label var q311_planplantcropmm "Expected month of planting"
label var q311_1_planplantcropyy "Expected year of planting"
label var q315_numharvcroplasthr "Number of harvests of this crop in last three years"

// Clean q305_namcrop
replace q305_namcrop="NA" if q305_namcrop=="-666"
replace q305_namcrop="POTATO" if q305_namcrop=="ALOO" | q305_namcrop=="ALOOU" | q305_namcrop=="ALUO" | q305_namcrop=="P0TAT0" | q305_namcrop=="P0TATO" | q305_namcrop=="PATATO" | q305_namcrop=="PATOTO" | q305_namcrop=="POPTATO" | q305_namcrop=="POTATOO" | q305_namcrop=="POTETO"
replace q305_namcrop="ARALI" if q305_namcrop=="ARALLI"
replace q305_namcrop="BLACK GRAM" if q305_namcrop=="BLACKGRAM" | q305_namcrop=="BALACK GRAM" | q305_namcrop=="BALCK GRAM"
replace q305_namcrop="CAULIFLOWER" if q305_namcrop=="BHOL GOBHI"
replace q305_namcrop="COCONUT" if q305_namcrop=="C0C0NUT" | q305_namcrop=="C0C0UNT" | q305_namcrop=="CO-CONUT" | q305_namcrop=="COCONET" | q305_namcrop=="COCONUTS" | q305_namcrop=="COCOUNET" | q305_namcrop=="COCOUNT" | q305_namcrop=="COCUNUT"
replace q305_namcrop="COTTON" if q305_namcrop=="PARUTHI" | q305_namcrop=="COOTON" | q305_namcrop=="COTON" | q305_namcrop=="COTTAN" | q305_namcrop=="CTTON"
replace q305_namcrop="SUGARCANE" if q305_namcrop=="GANNA"
replace q305_namcrop="GROUNDNUT" if q305_namcrop=="GROUNDENUT"
replace q305_namcrop="SORGHUM" if q305_namcrop=="GUVAR KI FALI" | q305_namcrop=="JWAR"
replace q305_namcrop="BITTER GOURD" if q305_namcrop=="KARELA"
replace q305_namcrop="GARLIC" if q305_namcrop=="LAHSOON"
replace q305_namcrop="BOTTLE GUARD" if q305_namcrop=="LOUKI"
replace q305_namcrop="MAIZE" if q305_namcrop=="MAIZA" | q305_namcrop=="MAZIA" | q305_namcrop=="MAZINE"
replace q305_namcrop="PEAS" if q305_namcrop=="MATAR"
replace q305_namcrop="CHILLI" if q305_namcrop=="MERICHI" | q305_namcrop=="MIRCHI"
replace q305_namcrop="RED GRAM" if q305_namcrop=="KANDI" | q305_namcrop=="ARAHAR" | q305_namcrop=="ARHAR"
replace q305_namcrop="TAPIOCA" if q305_namcrop=="KAPPAKKILANGU"
replace q305_namcrop="PADDY" if q305_namcrop=="PA" | q305_namcrop=="PATTI" | q305_namcrop=="PEEDY"
replace q305_namcrop="GREEN POTATO" if q305_namcrop=="PARWAL"
replace q305_namcrop="PIGEON PEA" if q305_namcrop=="PEGION PEA" | q305_namcrop=="PIGEON" | q305_namcrop=="PIGEONPEA"
replace q305_namcrop="PEPPERMINT" if q305_namcrop=="PIPERMINT"
replace q305_namcrop="PUMPKIN" if q305_namcrop=="PUMKIN"
replace q305_namcrop="MARIGOLD" if q305_namcrop=="SAMANTHI"
replace q305_namcrop="MUSTARD LEAVES" if q305_namcrop=="SARS0" | q305_namcrop=="SASRSO" | q305_namcrop=="SARSOAN"
replace q305_namcrop="SESAME" if q305_namcrop=="SESAMAM"
replace q305_namcrop="SUGAR CANE" if q305_namcrop=="SHUGAR CANE" | q305_namcrop=="SHUGARCANE" | q305_namcrop=="SUGAR CANCE" | q305_namcrop=="SUGARCAIN" | q305_namcrop=="SUGARCAN" | q305_namcrop=="SUGARCANA" | q305_namcrop=="SUGARCANE" | q305_namcrop=="SUGARHAND" | q305_namcrop=="SUGARCARN" | q305_namcrop=="SUGARGAN" | q305_namcrop=="SUGER CANE" | q305_namcrop=="SUGERCANE" | q305_namcrop=="SUGGARCANE" | q305_namcrop=="SUGGER CANE" | q305_namcrop=="SUGSRCANR" | q305_namcrop=="SUGAR" | q305_namcrop=="\SUGARCANE"
replace q305_namcrop="TOBACCO" if q305_namcrop=="TAMBAKU" | q305_namcrop=="TOBACCCO" | q305_namcrop=="TOBACCCO.TAMBAKU" | q305_namcrop=="TOBACCO" | q305_namcrop=="TOBACCOO" | q305_namcrop=="TOBBACCCO" | q305_namcrop=="TOBBACCO"
replace q305_namcrop="TOMATO" if q305_namcrop=="TOMOTO"

label value q308_plancropjune14 yesno
label value q309_mstrecplanMM months
label value q310_1_areaplaunit units

replace q310_1_areaplaunit_oth="-555" if q310_1_areaplaunit_oth=="0"
replace q310_areaplaqua=-666 if q310_1_areaplaunit_oth=="NO CROP"
replace q310_1_areaplaunit=-555 if missing( q310_1_areaplaunit)
replace q310_1_areaplaunit_oth="-666" if q310_1_areaplaunit_oth=="NO CROP"
destring q310_1_areaplaunit_oth, replace
label value q310_1_areaplaunit_oth general

replace q312_1_areaplanunit_oth="-666" if q312_1_areaplanunit_oth=="N0" | q312_1_areaplanunit_oth=="ALLRADY CONTINUE COCUNUT." | q312_1_areaplanunit_oth=="ALLRADY CULTIVATION" | q312_1_areaplanunit_oth=="0" | q312_1_areaplanunit_oth=="NO LAND" | q312_1_areaplanunit_oth=="AB NHI BUWAI KRENGE" | q312_1_areaplanunit_oth=="NO YEILDING"
destring q312_1_areaplanunit_oth, replace
replace q312_1_areaplanunit=-555 if missing( q312_1_areaplanunit)
label value q312_1_areaplanunit_oth general

label value q313_harcropjan14 yesno
label value q314_harmm months
label value q310_2_planplantmm yesno
label value q311_planplantcropmm months

// Merge
merge m:1 Id using `q304', nogen keep(2 3)
order q304_culirrcropyear q304_count, after(Id)



// Apply logic check
ds q304_count-q315_numharvcroplasthr, has(type numeric)
loc H1vars_num `r(varlist)'
ds q304_count-q315_numharvcroplasthr, has(type string)
loc H1vars_str `r(varlist)'

foreach var of local E2vars_num {
	replace `var'=.m if ((q304_culirrcropyear==2) & (!mi(`var')))
}
foreach var of local E2vars_str {
	replace `var'="Valid Skip" if (q304_culirrcropyear==2)
}
*


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionH1_IrrCrop_cropdetail_2014_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit

