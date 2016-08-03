/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionA_HHRoster_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	April 8, 2016

LAST EDITED:	April 8, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section A of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean 
				X - Save and Exit
				
INPUTS: 		// Q101 ~ Q110
					${followup_data}/AP Raw/SectionAHouseholdRoster_1.dta
					${followup_data}/TN Raw/SectionAHouseholdRoster_1.dta
					${followup_data}/UP Raw/SectionAHouseholdRoster_1.dta
				// Q111 ~ Q115
					${followup_data}/AP Raw/SectionAHouseholdRoster2_1.dta
					${followup_data}/TN Raw/SectionAHouseholdRoster2_1.dta
					${followup_data}/UP Raw/SectionAHouseholdRoster2_1.dta
				
OUTPUTS: 		${builddta}/followup_2014/SectionA_HHRoster_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionAHouseholdRoster_1.do"
				- "${follow_data}/Do Files/SectionAHouseholdRoster2_1.do" 
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionA_HHRoster_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// A1: q101 ~ q110 //

use "${followup_data}/AP Raw/SectionAHouseholdRoster_1.dta" 
append using "${followup_data}/TN Raw/SectionAHouseholdRoster_1.dta" 
append using "${followup_data}/UP Raw/SectionAHouseholdRoster_1.dta" 

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
/// However, since "P4537" is dropped from initial cleaning, it can be dropped.
drop if (Id=="P4537")

isid Id subid
drop dup

// Relation to HH Head
// We can observe that there are 7 obs with "N/A" value, and all of them are invalid responses after manually checking. We can drop them.
loc var q102_relHH
drop if (`var'=="-666")

// Gender
/// Both had missing values, I've assumed genders based on the names of the individuals
replace q103_gender = "2" if Id == "P1773" & subid == "4"
replace q103_gender = "2" if Id == "P2613" & subid == "2"

// Age & Year of birth
replace q105_1_ageYYYY="" if (q105_1_ageYYYY=="-")

/// Kharif Health Expenditure
replace q110_hlthexpkha="0" if (q110_hlthexpkha=="-0")
replace q110_hlthexpkha="" if (q110_hlthexpkha=="-")

// Destring & recode variables
destring subid q102_relHH q103_gender q105_ageYY q105_1_ageYYYY q106_engdlywageemp q107_prioccup q108_indinvwork q109_curresHH q110_hlthexpkha, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*



// Caste & subcaste (q104) 

// Many observations have same castes with slightly different spellings. Need to fix them.
** I included all "YADAV", "JATAV" in its original group. For example, I renamed "AHIR YADAV" caste as "AHIR" caste
gen q104_caste_dex = soundex(q104_caste)
clonevar q104_caste_cleaned=q104_caste

loc var q104_caste
replace `var'_cleaned="AHIR" if inlist(`var'_dex,"A600", "A360", "A631")
replace `var'_cleaned="AHIR YADAV" if (`var'_dex=="A631")
replace `var'_cleaned="AGAMUDAYAR" if inlist(`var'_dex,"A253","A256")
replace `var'_cleaned="AMBALAKARAR" if inlist(`var'_dex,"A514","A512","M146")
replace `var'_cleaned="ANDRA ADHI MADIGA" if inlist(`var'_dex,"A536","A353")
*replace `var'_cleaned="ARIJAN" if inlist(`var'_dex,"A625")
replace `var'_cleaned="ARYA VYASYA" if inlist(`var'_dex,"A612")
replace `var'_cleaned="ASARI" if inlist(`var'_dex,"A260")
replace `var'_cleaned="ATHITHIRAVIDAR" if inlist(`var'_dex,"A336")

** I do not want to focus too much on exact spelling, as long as people with same caste are properly grouped.
	** ex. NADAR or NATAR? BRAHMAN or BRAHAMAN?
** JAT/JAAT/JATAV/YADAV - are they the same caste?
** Many people gave same response for both caste and subcaste. How should I know whether they are caste or subcaste?
** Are "BALLAR" and "PALLAR" the same caste?
** What's the different b/w "KUSHWAHA" and "KACHI"? They appear both in caste and subcaste at the same time.
** "SC MALA" : Is "Mala" a caste or subcaste?
*** ID==P3001 : One person is MALA, while other ppl are "S.C"
** SC MADIGA : Are "Madiga" and "Mala" same caste
*** ID==P3026 : One person is MADIGA, while other ppl are S.C.
** SC CHOUDRY
** OC KAPU
** THELAGA KAPU
** KOPPU VELUMA
** ANDRA ADHI MADIGA vs MADIGA
** Are "HAJAM" and "HARIJAN" same caste?
** "THURPU KAPU": Is "KAPU" a caste or subcaste?
** Are "KOHAR", "KUMHAR", "KHUMARAR" and "KUBHAR" the same caste?
** Are "LONIA" and "NONIYA" the same caste?
** Are "PASI", "PASWAN" and "PASIWAN" the same caste?
** Are castes with "dex==M600" the same caste or different castes?
** RAJ BHAR vs BHAR
** AHIR YADAV vs YADAV
** JURGAR vs GUJAR
** PAYAL vs PALLAR, PAYAL vs PAYAL JAAT
** CHAMAR JATAV vs CHAMAR, AHIR YADAV vs AHIR
** MUSLIM vs MUSLIM RAJPOOT
** DHEEMAR vs DHEEMAR KAHAR
** BARAIYAN vs PARAIYAN.
** Are "BRAHAMAN" and "BARAIYAN" the same caste?

** KACHI vs KUSHAWA : Some ppl answered KACHI as caste and KUSHAWA as subcaste, while other ppl answered the opposite.

** HH-level caste: How should I assign HH-level caste?
	** HH head's caste
	** Cate of most ppl in HH
	
** P3496, P4228: One person have "CHAMAR" caste and "HARIJAN" subcaste, while other pp have the opposite.
** P4201, P4221: One person have "HARIJAN" caste and "CHAMAR" subcaste, while other pp have the opposite.
** P4267, P4221: One person have "HARIJAN" caste and "PASWAN" subcaste, while other pp have "CHAMAR" caste and "PASWAN" subcaste.
** P4338: One person have "BIND" caste and "BIND" subcaste, while other pp have "CHAMAR" caste and "BIND" subcaste.
*** Are "BIND" and "CHAMAR" caste or subcaste?

** subcaste=="VANNIYAR" if Id=="P514"
** subcaste=="MEENAVAR" if Id=="P775"
** subcaste=="AGAMUDAIYAR" if Id=="P794"
** P974


replace `var'_cleaned="BADHAI" if inlist(`var'_dex,"B300")
replace `var'_cleaned="BALIJA" if inlist(`var'_dex,"B420")
replace `var'_cleaned="BALLAR" if inlist(`var'_dex,"B460")
replace `var'_cleaned="BANIYA" if inlist(`var'_dex,"B500")
replace `var'_cleaned="BARBAR" if inlist(`var'_dex,"B616")
replace `var'_cleaned="BC" if inlist(`var'_dex,"B200","B210")
replace `var'_cleaned="BHAR" if inlist(`var'_dex,"B600","B260")
*replace `var'_cleaned="BAHMIN" if inlist(`var'_dex,"B550")
*replace `var'_cleaned="BARHMIN" if inlist(`var'_dex,"B655","B550")
replace `var'_cleaned="BRAHAMAN" if inlist(`var'_dex,"B655","B650","B625","B653","H531","B550")
replace `var'_cleaned="BILLAMAR" if inlist(`var'_dex,"B456")
replace `var'_cleaned="BIND" if inlist(`var'_dex,"B530")
replace `var'_cleaned="BOYA" if inlist(`var'_dex,"B000")
replace `var'_cleaned="BUDA BUKKALA" if inlist(`var'_dex,"B312")

replace `var'_cleaned="CHAKALI" if inlist(`var'_dex,"C240","C245","C246")
replace `var'_cleaned="CHAMAR" if inlist(`var'_dex,"C560","C556","C562")
replace `var'_cleaned="CHOWDHURY" if inlist(`var'_dex,"C360","C362")
replace `var'_cleaned="CHETI BALIJA" if inlist(`var'_dex,"C314")
replace `var'_cleaned="CHRISTIAN NADAR" if inlist(`var'_dex,"C623")

replace `var'_cleaned="DEVAR" if inlist(`var'_dex,"D000","D160","D126")
replace `var'_cleaned="DHEEMAR" if inlist(`var'_dex,"D500","D560","D562","D600")
replace `var'_cleaned="DHOBI" if inlist(`var'_dex,"D100")
replace `var'_cleaned="DHULVA VELLALER" if inlist(`var'_dex,"D411","I533")
replace `var'_cleaned="DUSADH" if inlist(`var'_dex,"D230","D250")

replace `var'_cleaned="EKARI" if inlist(`var'_dex,"E260")
replace `var'_cleaned="ELAMA" if inlist(`var'_dex,"E450","E452")
replace `var'_cleaned="ERAKALA" if inlist(`var'_dex,"E624")
replace `var'_cleaned="ESAI VELLAR" if inlist(`var'_dex,"E214")
replace `var'_cleaned="ESHLAM" if inlist(`var'_dex,"E245")

replace `var'_cleaned="GADARIYA" if inlist(`var'_dex,"G360","G366")
replace `var'_cleaned="GAJULA BALIJA" if inlist(`var'_dex,"G241","G441")
replace `var'_cleaned="GOUDS" if inlist(`var'_dex,"G300","G320","G530","G323")
replace `var'_cleaned="GADARIYA" if (Id=="P4895")
replace `var'_cleaned="GUJAR" if (inlist(`var'_dex,"G260","U260","G200","G626") | (`var'_dex=="J260" & `var'=="JUJAR"))
replace `var'_cleaned="GUJAR" if (Id=="P3697")
replace `var'_cleaned="GOUNTER" if inlist(`var'_dex,"G536","G153")
replace `var'_cleaned="GOLLA" if inlist(`var'_dex,"G400","G440")
replace `var'_cleaned="GUPTA" if inlist(`var'_dex,"G130")
replace `var'_cleaned="GURUMMBA" if inlist(`var'_dex,"G651")

replace `var'_cleaned="HAJAM" if inlist(`var'_dex,"H250")
replace `var'_cleaned="HARIJAN" if (inlist(`var'_dex,"H625","H650","H620","H655","H652","A625") | inlist(`var',"H","HAIJAN"))


// Q. Need to clarify whether they are actually the same caste
replace `var'_cleaned="JAT/JATAV/YADAV" if inlist(`var'_dex,"J300","J310","A310","Y310","Y312","Y316")

replace `var'_cleaned="JUGGAR" if (inlist(`var'_dex,"J626") | (`var'=="J260" & `var'!="JUJAR"))
replace `var'_cleaned="JAISH" if inlist(`var'_dex,"J200")
replace `var'_cleaned="JALARI" if inlist(`var'_dex,"J460")
replace `var'_cleaned="JULAHA" if inlist(`var'_dex,"J400")

replace `var'_cleaned="KAPU" if inlist(`var'_dex,"K240","K524")
replace `var'_cleaned="KAPU" if inlist(`var'_dex,"K000","K100","K410","K121","K113")
replace `var'_cleaned="KACHI" if inlist(`var',"KACHI","KASHI")
replace `var'_cleaned="KOHAR" if inlist(`var'_dex,"K600")
replace `var'_cleaned="KANJAUIA" if inlist(`var'_dex,"K520")

// Need to check whether these three castes are all the same.
replace `var'_cleaned="KAMMALAR" if inlist(`var'_dex,"K546")
replace `var'_cleaned="KAMMA" if inlist(`var'_dex,"K500")
replace `var'_cleaned="KUMHAR" if inlist(`var'_dex,"K550","K560","K540","K566")
replace `var'_cleaned="KUMHAR" if (Id=="F1514")

replace `var'_cleaned="KAPULU" if inlist(`var'_dex,"K140","W000")
replace `var'_cleaned="KASHYAP" if inlist(`var'_dex,"K210")
replace `var'_cleaned="KAVUNDAR" if inlist(`var'_dex,"K153")
replace `var'_cleaned="KAYASTH" if inlist(`var'_dex,"K230")
replace `var'_cleaned="KEWAT" if (inlist(`var'_dex,"K300","K130") | `var'=="KEWAR")
replace `var'_cleaned="KERALA MUTHALI" if inlist(`var'_dex,"K645")
replace `var'_cleaned="KHARHAR" if inlist(`var'_dex,"K660")
replace `var'_cleaned="KHATIK" if inlist(`var'_dex,"K320")
replace `var'_cleaned="KURMI" if inlist(`var'_dex,"K650","K635")
replace `var'_cleaned="KUSHWAHA" if (inlist(`var'_dex,"K200","K220")&(`var'_cleaned!="KACHI"))
replace `var'_cleaned="KOMATI" if inlist(`var'_dex,"K530")
replace `var'_cleaned="KOMATLU" if inlist(`var'_dex,"K534")
replace `var'_cleaned="KOPPALA VELAMA" if inlist(`var'_dex,"K114","K115","K140","K141","K144")
replace `var'_cleaned="KORI" if (`var'=="KORI")
replace `var'_cleaned="KOPPALA VELAMA" if inlist(`var'_dex,"K114","K115","K140","K141")
replace `var'_cleaned="KOUSALI" if inlist(`var'_dex,"K240")
replace `var'_cleaned="KRISHNA VAGAI" if inlist(`var'_dex,"K625","K251")
replace `var'_cleaned="KRISTEN" if inlist(`var'_dex,"K623")
replace `var'_cleaned="KRISTHAVAR" if regexm( q104_caste,"KRISTHAVAR")
replace `var'_cleaned="KUBHAR" if inlist(`var'_dex,"K160")
replace `var'_cleaned="KUDUMBAMAR" if inlist(`var'_dex,"K351")
replace `var'_cleaned="KUBHAR" if inlist(`var'_dex,"K160","K516")
replace `var'_cleaned="KURUMPOOR" if inlist(`var'_dex,"K651")

replace `var'_cleaned="LAMBADI" if inlist(`var'_dex,"L513","L153")
replace `var'_cleaned="LOHAR" if inlist(`var'_dex,"L000","L600")
replace `var'_cleaned="LONIYA" if inlist(`var'_dex,"L500")

replace `var'_cleaned="MEENAVAR" if inlist(`var'_dex,"M516")
replace `var'_cleaned="MEENAVAR" if (Id=="P775")
replace `var'_cleaned="MALA" if inlist(`var'_dex,"M400","M432")
replace `var'_cleaned="MADIGA" if inlist(`var'_dex,"M320","M322","M200")
replace `var'_cleaned="MAHAMMADS" if inlist(`var'_dex,"M532")

//** Check "M600" castes carefully
replace `var'_cleaned="MARUYA" if inlist(`var'_dex,"M600","M000","M300")

replace `var'_cleaned="MANDHULA" if inlist(`var'_dex,"M534")
replace `var'_cleaned="MANGALI" if inlist(`var'_dex,"M524")
replace `var'_cleaned="MANSOORI" if inlist(`var'_dex,"526")
replace `var'_cleaned="MUDIRAJ" if inlist(`var'_dex,"M362")
replace `var'_cleaned="MBC" if inlist(`var'_dex,"M120")
replace `var'_cleaned="MUSLIM" if inlist(`var'_dex,"M235","M245")
replace `var'_cleaned="MUTHALIYAR" if inlist(`var'_dex,"M346","M366")
replace `var'_cleaned="MOOPANAR" if inlist(`var'_dex,"M156")

replace `var'_cleaned="NATAR" if inlist(`var'_dex,"N300","N360","N362")
replace `var'_cleaned="NAGIYAR" if inlist(`var'_dex,"N260")
replace `var'_cleaned="NAI" if inlist(`var'_dex,"N000")
replace `var'_cleaned="NAYANI BRAHMANA" if inlist(`var'_dex,"N165","N516") 
replace `var'_cleaned="NAIDU" if inlist(`var'_dex,"G530","N300")
replace `var'_cleaned="NONIYA" if inlist(`var'_dex,"N500")

replace `var'_cleaned="OC" if inlist(`var'_dex,"O200","O236","O210")

replace `var'_cleaned="PADAIYACHI" if inlist(`var'_dex,"P000","P320","P332")
replace `var'_cleaned="P.C" if ((inlist(`var'_dex,"P200")) & (Id!="P541"))
replace `var'_cleaned="PADMASHALI" if inlist(`var'_dex,"P352","P524")
replace `var'_cleaned="PADAIYACHI" if (Id=="P541")
replace `var'_cleaned="PARAYAR" if inlist(`var'_dex,"P650","P660")
replace `var'_cleaned="PALLAR" if inlist(`var'_dex,"P360","P460","P456","P600","P400","P456","P465")
replace `var'_cleaned="PALLAN" if inlist(`var'_dex,"P450")
replace `var'_cleaned="PANDARAM" if inlist(`var'_dex,"P536")
replace `var'_cleaned="PANDEY" if inlist(`var'_dex,"P530")
replace `var'_cleaned="PANDIT" if inlist(`var'_dex,"P533")
replace `var'_cleaned="PARJA PATI" if inlist(`var'_dex,"P621")
replace `var'_cleaned="PASI" if inlist(`var',"PASI","PASHI")
replace `var'_cleaned="PASWAN" if inlist(`var'_dex,"P250")
replace `var'_cleaned="PATHAN" if inlist(`var'_dex,"P350")
replace `var'_cleaned="PAYAL" if inlist(`var'_dex,"P423")
*replace `var'_cleaned="PILLAI" if inlist(`var'_dex,"P400")
*replace `var'_cleaned="PILLAIMAR" if inlist(`var'_dex,"P456")

replace `var'_cleaned="RAJ BHAR" if inlist(`var'_dex,"R216")
replace `var'_cleaned="RAJ POOT" if inlist(`var'_dex,"R213")
replace `var'_cleaned="RAJAKA" if inlist(`var'_dex,"R220","R224")
replace `var'_cleaned="RAJAMUTHIRAYER" if inlist(`var'_dex,"R253")
replace `var'_cleaned="RANGADH" if inlist(`var'_dex,"R523")
replace `var'_cleaned="REDDY" if ((inlist(`var'_dex,"R300","R320")) & (`var'!="RAWAT")) 

replace `var'_cleaned="S.C" if ((inlist(`var'_dex,"S000")) & (`var'!="SAAH"))
replace `var'_cleaned="SAKILIYAR" if inlist(`var'_dex,"S245","S240","S246")
replace `var'_cleaned="SAILA" if inlist(`var'_dex,"S400")
replace `var'_cleaned="SANAN" if inlist(`var'_dex,"S550")
replace `var'_cleaned="SHETTI BALIJA" if inlist(`var'_dex,"S314","S312","S342")
replace `var'_cleaned="SHETTI BALIJA" if (Id=="F2106")
replace `var'_cleaned="S.C" if inlist(`var'_dex,"S532","S540")
replace `var'_cleaned="SEKH" if inlist(`var'_dex,"S200")
replace `var'_cleaned="SENA THALAIVAR" if inlist(`var'_dex,"S534")
replace `var'_cleaned="SENGKUNDHAR" if inlist(`var'_dex,"S525")
replace `var'_cleaned="SETIYAR" if inlist(`var'_dex,"S360")
replace `var'_cleaned="SHARMA" if inlist(`var'_dex,"S650")
replace `var'_cleaned="SIROHI" if inlist(`var'_dex,"S600")
replace `var'_cleaned="SISAUDIYA" if inlist(`var'_dex,"S230")
replace `var'_cleaned="SONKAR" if inlist(`var'_dex,"S526")
replace `var'_cleaned="SURYA BALIJA" if inlist(`var'_dex,"S614")
replace `var'_cleaned="TELAGA" if inlist(`var'_dex,"T420","T421","T422","T424")
replace `var'_cleaned="TELI" if inlist(`var'_dex,"T400")
replace `var'_cleaned="THAKUR" if inlist(`var'_dex,"T260","T236","T226")
replace `var'_cleaned="THEVAR" if inlist(`var'_dex,"T160")
replace `var'_cleaned="THURPU KAPU" if inlist(`var'_dex,"T612")
replace `var'_cleaned="THURPU THENUKULA" if inlist(`var'_dex,"T613")
replace `var'_cleaned="TIWARI" if inlist(`var'_dex,"T600")

replace `var'_cleaned="VACHISU" if inlist(`var'_dex,"V220")
replace `var'_cleaned="VAISHYA" if inlist(`var'_dex,"V200")
replace `var'_cleaned="VALAI" if inlist(`var'_dex,"V400")
replace `var'_cleaned="VALAIYAR" if inlist(`var'_dex,"V460")
replace `var'_cleaned="VALAMA" if inlist(`var'_dex,"V450")

replace `var'_cleaned="VANIYAR" if inlist(`var'_dex,"V556","V560","V561","V563","V526","V530")
replace `var'_cleaned="VANIYAR" if ((Id=="P1041") | (`var'=="VANNIYAY"))
replace `var'_cleaned="VARMA" if inlist(`var'_dex,"V650")
replace `var'_cleaned="VARMA" if (Id=="P4877")
replace `var'_cleaned="VELALAR" if inlist(`var'_dex,"V446","V440")
replace `var'_cleaned="VELAMA" if inlist(`var'_dex,"V450","V452","Y450")
replace `var'_cleaned="VISHWA BRAHAMANA" if inlist(`var'_dex,"V216","V210","V200","V220")


// Age & year of birth
// Fill-out missing age &  by calculating "2014(survey year) - year of birth"
loc var1 q105_ageYY
loc var2 q105_1_ageYYYY
replace `var1' = (2014 - `var2') if mi(`var1')
replace `var2' = (2014 - `var1') if mi(`var2')




//Label Variables
label define yesno 1 "Yes" 2 "No"

label var Id	"Household ID"
label var subid	"Household Roster ID"
label var  q101_Hhmemnam "Name of HH Member"
label var  q102_relHH "Relationship to HH Head"
label define relationship 1 "HH Head" 2 "Spouse" 3 "Son/Daughter" 4 "Daughter-in-law / Son-in-law" 5 "Grandson/daughter" 6 "Parents" 7 "Father/Mother-in-law" 8 "Brother/Sister" 9 "Brother/Sister-in-law" 10 "Uncle/Aunt" 11 "Nephew/Neice" 12 "Foster/step child" 13 "Other" 14 "Grandparent" -666 "NA" -777 "Refuse" -888 "Others" -999 "Don't Know"
label value q102_relHH relationship
label var  q102_relHH_oth "Other Relationship to HH Head"
label var  q103_gender "Gender"
label define gender 1 "Male" 2 "Female"
label value q103_gender gender
label var  q104_caste "Caste"
label var  q104_1_subcaste "Sub-Caste"
label var q105_ageYY "Age"
label var q105_1_ageYYYY "Year of Birth"

label var q106_engdlywageemp "Daily Wage Employment?"
label value q106_engdlywageemp yesno
*label define dailywage 1 "Yes" 2 "No" -999 "Do not Know" -666 "Not Applicable"
*label value q106_engdlywageemp dailywag

label var  q107_prioccup "Primary Occupation"
#delimit ;
label define occupation 1 "Agricultural work on own farm" 2 "Supervisory work on agricultural activity on own farm" 3 "Share cropper / cultivate plot owned by others" 4 "Agricultural wage labor" 11 "Fisherman (Fishing)" 12 "Fish culture"
13 "Look after live stocks" 14 "Look after Poultry (Duck, Chicken,Pigeons)" 15 "Cultivation and other works on fruits" 16 "Agricultural wage labor (Off Farm)" 17 "Nursery/forestry" 18 "Other agricultural activities (excluding 11-17)"
21 "Processing of crops" 22 "Family labor in Enterprise" 23 "Family labor in Tailoring" 24 "Family labor in Sewing" 25 "Family labor in Pottery" 26 "Family labor in Blacksmith" 27 "Family labor in Goldsmith" 28 "Repairing of manufactured products/mechanics" 29 "Carpenter" 30 "Non-agri. wage labor" 
41 "Petty Trade (Small retail shop)" 42 "Medium Trader (Retail and insignificant wholesale)" 43 "Wholesale Trader" 44 "Contractor" 45 "Labor supplier" 51 "Rickshaw/ Van Pulling"
52 "Boat man" 53 "Wage labor in transport" 54 "Other transport workers" 55 "Driver (motorized vehicle)" 56 "Helper" 61 "Mason" 62 "Helper" 63 "Other construction worker"
64 "Earthen work" 65 "House Repairing (fixing)" 71 "Doctor" 73 "Advocate" 74 "Barber" 75 "Washerman" 76 "Full time house tutor" 77 "Imam/ Purohit" 79 "Kutir Shilpi (Handicrafts)"
81 "Others self employment" 82 "Service ( govt/employee)" 83 "Pension" 84 "Service worker in NGO" 85 "Servant in house (Maid/ Male)" 89 "Beggar";
#delimit cr
*****************ADD REMAINING OCCUPATION CODES
label value q107_prioccup occupation
label var  q107_prioccup_oth "Other Primary Occupation"

label var  q108_indinvwork "Industry"
label define industry 1 "Food Processing" 2 "Manufacturing of Textile Products" 3 "Manufacturing of Wooden Products, Furniture" 4 "Manufacturing of Paper Products, Printing, Publishing" 5 "Other Manufacturing of Industry" 6 "Agriculture" 7 "Livestock" 8 "Fisheries" 9 "Forestry" 10 "Wholesale Trade" 11 "Retail Trade" 12 "Other Business" 13 "Hotel/ Restaurants" 14 "Electricity/gas/water" 15 "Transportation" 16 "Communication" 17 "Army/Police" 18 "Science/ Education" 19 "Arts and Culture" 20 "Health care" 21 "Sport/ tourism/ retirement" 22 "Banking, finance and credit" 23 "Management and administration" 24 "Religious activities" 25 "Non-agricultural workers" 26 "Others" -888 "Others"
label value q108_indinvwork industry
label var  q108_indinvwork_oth "Other Industry"

label var  q109_curresHH "Currently Residing in HH?"
label define residing 1 "Yes" 2 "No, temporary migrant worker" 3 "No, permanent migrant worker" 4 "No, attending school" 5 "No, away for marriage, ceremony,festival" 6 "No, away because of illness" 7 "No, away for family reasons" 8 "Passed Away" -888 "Other(SPECIFY)"
label value q109_curresHH residing 

label var q109_curresHH_oth "Other Currently Residing"
label var q110_hlthexpkha "Health Expenditure since the start of Kharif Season"

// Save (Section A1)
tempfile SectionA1
save `SectionA1'




// A2: q111 ~ q115 //

use "${followup_data}/AP Raw/SectionAHouseholdRoster2_1.dta", clear
append using "${followup_data}/TN Raw/SectionAHouseholdRoster2_1.dta" 
append using "${followup_data}/UP Raw/SectionAHouseholdRoster2_1.dta" 

// Like SectionA1, there are duplicates subid within a household.
// Duplicates in this dataset are more difficult (and sometimes impossible) to be distinguished, unfortunately.
duplicates drop // This drops one of the duplicates
drop if (Id=="F1285" & subid=="2" & q112_2esttotschfeeyear=="454") // Improper school fee (last year's fee is lower than Kharif school fee)
drop if (Id=="P244" & q111_highedulev=="1") // For duplicates impossible to be distingushed, drop "Not eeducated" observation (This is a random criteria, so can be modified later)
drop if (Id=="P4537")
isid Id subid

// Destring & recode variables
destring subid q*, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*

// Apply skip pattern
foreach var in q112_2esttotschfeeyear q113_esttotschfeekhar q114_absschoillkhar q115_absschoworkkhar {
	qui replace `var'=.m if (q112_schlastyr!=1) & !mi(`var')
}


//Label Variables
label var  q111_highedulev "Highest Educ Level"
label define education 1 "Not Educated" 2 "Primary Education (Incomplete)" 3 "Primary Education (Complete)" 4 "Secondary Education (Incomplete)" 5 "Secondary Education (Complete)" 6 "Higher Secondary (Incomplete)" 7 "Higher Secondary (Complete)" 8 "Technical Diploma" 9 "Bachelors Degree (Incomplete)" 10 "Bachelors Degree (Complete)" 11 "Child under 7 years" -888 "Other" -999 "Don’t Know" 12 "Madarsa  education" 13 "Senior secondary (incomplete)" 14 "Senior secondary (complete)" 15 "Post graduate degree (complete)" 16 "Post graduate degree (incomplete)"
label value q111_highedulev education

label var  q111_highedulev_oth "Other Highest Educ Level"
label var  q112_schlastyr "In school last year?"
label var  q112_2esttotschfeeyear "School Fees Last Year"
label var  q113_esttotschfeekhar "School Fees Kharif"
label var  q114_absschoillkhar "School Days Missed - Illness"
label var  q115_absschoworkkhar "School Days Missed - Work"


// Merge A1 and A2 //
tempfile SectionA2
save `SectionA2'
use `SectionA1', clear
merge 1:1 Id subid using `SectionA2', keep(1 3) gen(SecA1_A2) // Drop observations with missing q101 ~ q110.

// Replace missing A2 values as "blank" for those who answerd q101~q110 only.
ds q111_highedulev-q115_absschoworkkhar
ds, has(type numeric)
local A2_var `r(varlist)'
foreach var of local A2_var {
	qui replace `var'=.b if (SecA1_A2==1)
}
*
drop SecA1_A2


/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

compress
save "${builddta}/followup_2014/SectionA1_HHroster_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit


/*
// Collapse data to be merged with the main dataset later
collapse (sum) q110_hlthexpkha (count) subid, by(Id)
rename (subid q110_hlthexpkha) (NumberOfHHmembers Health_Expenditure_Kharif)
gen Health_Expenditure_pc_Kharif = (Health_Expenditure_Kharif/NumberOfHHmembers)
label var NumberOfHHmembers "Number of HH members"
label var Health_Expenditure_Kharif "Total household health expenditure since the beginning of Kharif season"
label var Health_Expenditure_pc_Kharif "Per capita household health expenditure since the beginning of Kharif season"

tempfile SectionA1_collapsed
save `SectionA1_collapsed' // This dataset will be later merged with base dataset

*/
