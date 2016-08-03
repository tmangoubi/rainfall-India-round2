/*****************************************************************
PROJECT: 		IN_Rainfall, India Rainfall Insurance
				
TITLE:			SectionF1_KharifCrop_NotThisYear_clean.do
			
AUTHOR: 		Seungmin Lee (seungmin.lee@yale.edu, eatorange@gmail.com)

DATE CREATED:	May 20, 2016

LAST EDITED:	May 20, 2016 by Seungmin Lee

DESCRIPTION: 	Import & clean Section F1 of 2014 follow-up survey data
	
ORGANIZATION:	0 - Preamble
				1 - Import & clean
					1.1 - F1
					1.2 - F2
					1.3 - Merge
				X - Save and Exit
				
INPUTS: 		// Raw data 
					// Master data (for q801)
					${builddta}/followup_2014/MasterData_cleaned.dta

					// Section F1
					${followup_data}/AP Raw/SectionF1Roster_1.dta
					${followup_data}/TN Raw/SectionF1Roster_1.dta
					${followup_data}/UP Raw/SectionF1Roster_1.dta
						
OUTPUTS: 		${builddta}/followup_2014/SectionF1_KharifCrop_NotThisYear_cleaned.dta
				
NOTE:			This do-file is based on
				- "${follow_data}/Do Files/SectionF1Roster_1.do"
				with additional modifications.
******************************************************************/

/****************************************************************
	SECTION 0: Preamble					 									
****************************************************************/

version 13.1

set more off
clear all
cap log close 

loc name_do SectionF1_KharifCrop_NotThisYear_clean
log using "${buildlog}/`name_do'", replace


/****************************************************************
	SECTION 1: Import Raw Data				 									
****************************************************************/

// Master Data
use "${builddta}/followup_2014/MasterData_cleaned.dta", clear
keep Id q801*
label var q801_cropnokha11bef "Were there any crops during the Kharif 2014 season that you did NOT grow?"
note q801_cropnokha11bef: Among the crops households had grown during any of the previous 3 Kharif seasons

tempfile q801
save `q801'


// Section F1
use "${followup_data}/AP Raw/SectionF1Roster_1.dta", clear
append using "${followup_data}/TN Raw/SectionF1Roster_1.dta" 
append using "${followup_data}/UP Raw/SectionF1Roster_1.dta" 
isid Id subid

/// Destring and recode variables
qui destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*
// Label variables
label var Id "HHID"
label var subid "Roster ID"

label var q802_cropname "Crop Name"
label var q803_cropcode "Crop Code"
label define cropcode1 1 "Paddy "2 "Wheat"3 "Barley"4 "Maize"5 "Jawar"6 "Bajra"7 "Ragi"8 "Other Cereals and millets"9 "Black Gram (Urd)"10 "Green Gram (Moong)"11 "Pigeon Pea (Arhar,Tur)"12 "Horse Gram (Kulthi)"13 "Cowpea (Lobia)"14 "Kidney Bean (Moth)"15 "Lentil (Massor)"16 "Fiels Pea (Matar)]"17 "Bengal Gram (Chana)"18 "Other Pulses"19 "Sesamam ( Til )"20 "Groundnut"21 "Castor"22 "Sunflower"23 "Niger ( Ramtil)"24 "Soyabean"25 "Safflower ( Kusum, Kardi)"26 "Rapeseed/ Mustard ( Sarsoan)'"27 "Indian Mustard (Rai)"28 "Lineseed (Alsi)"29 "Other Oilseeds"30 "Cotton (Kapas)"31 "Brown Hemp ( Patsan ,Mesta)"32 "Jute"33 "Rozelle (Patua)"34 "Sannehemp : Bombay Hemp ( Sann) "35 "Sisal Hemp : Agava ( Seesal)"36 "Other fibre crops"37 "Sugarcane"38 "Tapioca"39 "Othere Sugar & Starch Crops"40 "Baramuda Grass ( Doob)"41 "Blue Panic ( Neelon Ghas)"42 "Carpet Legume ( Sem)"43 "Common Vetch ( Bakla)"44 "Elephant grass,Napier Grass"45 "Egyptian Clover ( Berseem )"46 "Guinea Grass"47 "Indian Clover (Senji)"48 "Lucerne ,Alfalfa ( Rajka)"49 "Para Grass"50 "Rhodes Grass"51 "Soyabean"52 "Star Grass"53 "Sudan Grass"54 "Canary Grass"55 "Other Grasses ( Other Fodder)"56 "Jawar Fodder"57 "Bajra Fodder"58 "Maize Fodder"59 "Ragi Fodder"60 "Oat/Jai Fooder"61 "Lobiya Fodder"62 "Other food Crops Grown as Fodder"63 "Ash Gourd (Kohla)"64 "Beet Root ( Chukandar)"65 "Bitter Gourd ( Kerela)"66 "Bottle Gourd (Louki)"67 "Brinjal ,Eggplant ( Baingan)"68 "Broad Bean ( Baakla )"69 "Cabbage (Pattagobby )"70 "Carrot ( Gajat)"71 "Cauliflower ( Phool Gobby )"72 "Cluster Bean ( Guvar Ki Fali)"73 "Cowpea (Lobia)"74 "Cress ,Garden Cress( Pani Dhleem)"75 "Cucumber ( Khera)"76 "Double Bean"77 "Drum Stick ( Sejana)"78 "Elephant Ear, Edible Arum (Akhi ,Arvi)"79 "Elephant Foot (Gimmy Kand )"80 "French Bean ( Jungli Sem , Frans Bean)"81 "Garden Pea, Pea,(Matar)"82 "Goose Foot ( Bathua )"83 "Indian Bean ( Sem)"84 "Knolknol ( Gaath Gobhi)"85 "Lady's Finger( Bhindi)"86 "Lettuce (Salad)"87 "Lime Bean"88 "Little Gourd (Kundroo, Tindora)"89 "Mountain Spinach ( Pahari Palak)"90 "Musk Melon (Kharbooja)"91 "Onion (Piaz)"92 "Pointed Gourd ( Parwal)"93 "Potato (Aaloo)"94 "Pumpkin ( Petha)"95 "Radish ( Mooli)"96 "Red Pumpkin ( Sitaphal ,Kaddu)"97 "Ridge Gourd ( Tori)"98 "Round Gourd ( Tinda)"99 "Smoth Gourd ( Kali Tori)"100 "Snake Guard ( Chachera, Chachinda)"101 "Spinach ( Palak)"102 "Sword Bean"103 "Sweet Potato ( Sakar Kandi)"104 "Tomato ( Tamattar)"105 "Turnip ( Saljam)"106 "Velet Bean ( Khamch ,Tohar Sem)"107 "Water Melon ( Tarbooj)"108 "Yam ( Tataaloo )"109 "Other Vegetables"110 " Almond ( Badam)"111 "Apple ( Seb)"112 "Apricot (Khumani)"113 "Banana (Kela)"114 "Bread Fruit ( Khadel)"115 "Bullock Heart (Ramphal )"116 "Cape Gooseberry ( Rasbhari)"117 "Cashew ( Kaju)"118 "Cherry (Cherry )"119 "Citron ( Gulgul )"120 "Custard Apple ( Sarifa)"121 "Date Palm (Khajoor)"122 "Fig (Anjeer)"123 "Grape Fruit(Grape Fruit)"124 "Grapevine (Angur)"125 "Guava ( Armood)"126 "Jack Fruit ( Kat-Hal )"127 "Jujube ( Ber)"128 "Lemon ( Bara- Nemboo)"129 "Lime, Acid lime,Sour lime (Kagzi Nemboo)"130 "Litchi ( Leechi )"131 "Laquat( Lokat)"132 "Mango (Aam)"133 "Mangosteen (Mangosteen )"134 "Malbuerry (Raitun)"135 "Papaya (Papita)"136 "Peach ( Aaroo)"137 "Pear (Naaspaati)"138 "Pineapple (Annanas)"139 "Pulm ( Aaloo Bhukhara)"140 "Pomegranate ( Anaar,Dadim)"141 "Raspberry, (Raspbherry, Rasbhary)"142 "Rough Lemon (Nemboo)"143 "Sapota ,Sapodilla Plum (Cheeku)"144 "Shaddock ,Pomelo ( Chakotra)"145 "Santra Orange,Mandarian Orange"146 "Strawberry (Strawberry )"147 "Sweet Lime ( Meetha Nemboo)"148 "Sweet Orange ,Malta ( Mausmee)"149 "Walnut (Akhroat )"150 "Other Fruits"151 "Other Dry Fruits"152 "Amise"153 "Aromatic Cardamon ( Chhoti Elaichi )"154 "Betelvine (Pan)"155 "Bishop's Weed ( Ajwan,Ajamo)"156 "Black Mustard ( Kali Sarson ,Kali Rai') "157 "Black Pepper ( Kali Mirch )"158 "Cardomam (Elaichi )"159 "Chilli' ( Lal Mirch)"160 "Coriander ( Dhaniya)"161 "Cumin ( Jeera)"162 "Dill Seed ( Soya, Suwa)"163 "Fennel ( Sonf ,Variali)"164 "Fanugreek ( Maythik, Methi)"165 "Garlic ( Lehsoon ,Lasan)"166 "Ginger ( Adrakh )"167 "Indian Mustard ( Raie)"168 "Large Cardamon ( Bari Elaichy)"169 "Long Pepper ( Mirchi)"170 "Mint ( Pudeena)"171 "Ntmeg ( Jaiphal )"172 "Turmeric ( Haldi )"173 "White Mustard ( Banarsi Raie)"174 "Other Condiments & Spices)"175 "Indian Hemp ( Bhang)"176 "Indigo (Kneel)"177 "Poppy -Opium Poppy( Aphim)"178 "Poppy (Posta)"179 "Saffron (Kesar)"180 "Tobaccco ( Tambaku)"181 "Blonde Psyllium (Isapgol )"182 "Indian Privet ( Mehandi)"183 "Cluster Bean(Gawar)"184 "Other Drugs ,Dyes & Narcotiecs"185 "Areca Palm( Kattha)"186 "Cocao (Koka ,Kahva)"187 "Chinchona ( Quinine)"188 "Coconut ( Narial)"189 "Coffee ( Coffee)"190 "Para Rubber ( Rubber)"191 "Tea ( Chaie)"192 "Banana"193 "Mango"194 "Arcanut"195 "Other Plantations"196 "Rose"197 "Tube Rose"198 "Jasmine"199 "Marigold"200 "Gladiolus"201 "Orchids"202 "Other Flowers"203 "Barseem Seed"
label value q803_cropcode cropcode1
label var q804_cropvarname "Crop Variety"
label var q805_khaYYfirgroyy "Year First Grown"
label var q806_khaYYlastgrow "Year Last Grown"
label var q807_notgrowwhy "Why did you stop growing?"
label var q807_oth_notgrowwhy "Why did you stop growing? - Other"
label define whystopgrow 1 "Too Expensive " 2 "Better variety available" 3 "Not available in village" 4 "Poor yield" 5 "Not very resistant (weather/pest)" 6 "Experimenting with new crop" 7 "More profitable crop available" 8 "New farming equipment available"
label value q807_notgrowwhy whystopgrow

tempfile F1
save `F1'
/*
// Section F2

use "${followup_data}/AP Raw/SectionF2Roster_1.dta", clear
append using "${followup_data}/TN Raw/SectionF2Roster_1.dta" 
append using "${followup_data}/UP Raw/SectionF2Roster_1.dta" 
isid Id subid

/// Destring and recode variables
qui destring *, replace
ds, has(type numeric)
local num_var `r(varlist)'
foreach var of local num_var {
	qui replace `var'=.b if mi(`var') // Blank response (but not a valid response)
	qui recode `var' (-999=.d) (-777=.r) (-666=.n) (-333=.b) (-555=.) // -999 "Don't Know" -888 "Others" -777 "Refuse" -666 "N/A" -333 "Missing" -555 "Valid Skip"
}
*
// Label variables
label var Id "HHID"
label var subid "Roster ID"

label var q809_cropname "Crop Name"
label var q810_cropcode "Crop Code"
label define cropcode1 1 "Paddy "2 "Wheat"3 "Barley"4 "Maize"5 "Jawar"6 "Bajra"7 "Ragi"8 "Other Cereals and millets"9 "Black Gram (Urd)"10 "Green Gram (Moong)"11 "Pigeon Pea (Arhar,Tur)"12 "Horse Gram (Kulthi)"13 "Cowpea (Lobia)"14 "Kidney Bean (Moth)"15 "Lentil (Massor)"16 "Fiels Pea (Matar)]"17 "Bengal Gram (Chana)"18 "Other Pulses"19 "Sesamam ( Til )"20 "Groundnut"21 "Castor"22 "Sunflower"23 "Niger ( Ramtil)"24 "Soyabean"25 "Safflower ( Kusum, Kardi)"26 "Rapeseed/ Mustard ( Sarsoan)'"27 "Indian Mustard (Rai)"28 "Lineseed (Alsi)"29 "Other Oilseeds"30 "Cotton (Kapas)"31 "Brown Hemp ( Patsan ,Mesta)"32 "Jute"33 "Rozelle (Patua)"34 "Sannehemp : Bombay Hemp ( Sann) "35 "Sisal Hemp : Agava ( Seesal)"36 "Other fibre crops"37 "Sugarcane"38 "Tapioca"39 "Othere Sugar & Starch Crops"40 "Baramuda Grass ( Doob)"41 "Blue Panic ( Neelon Ghas)"42 "Carpet Legume ( Sem)"43 "Common Vetch ( Bakla)"44 "Elephant grass,Napier Grass"45 "Egyptian Clover ( Berseem )"46 "Guinea Grass"47 "Indian Clover (Senji)"48 "Lucerne ,Alfalfa ( Rajka)"49 "Para Grass"50 "Rhodes Grass"51 "Soyabean"52 "Star Grass"53 "Sudan Grass"54 "Canary Grass"55 "Other Grasses ( Other Fodder)"56 "Jawar Fodder"57 "Bajra Fodder"58 "Maize Fodder"59 "Ragi Fodder"60 "Oat/Jai Fooder"61 "Lobiya Fodder"62 "Other food Crops Grown as Fodder"63 "Ash Gourd (Kohla)"64 "Beet Root ( Chukandar)"65 "Bitter Gourd ( Kerela)"66 "Bottle Gourd (Louki)"67 "Brinjal ,Eggplant ( Baingan)"68 "Broad Bean ( Baakla )"69 "Cabbage (Pattagobby )"70 "Carrot ( Gajat)"71 "Cauliflower ( Phool Gobby )"72 "Cluster Bean ( Guvar Ki Fali)"73 "Cowpea (Lobia)"74 "Cress ,Garden Cress( Pani Dhleem)"75 "Cucumber ( Khera)"76 "Double Bean"77 "Drum Stick ( Sejana)"78 "Elephant Ear, Edible Arum (Akhi ,Arvi)"79 "Elephant Foot (Gimmy Kand )"80 "French Bean ( Jungli Sem , Frans Bean)"81 "Garden Pea, Pea,(Matar)"82 "Goose Foot ( Bathua )"83 "Indian Bean ( Sem)"84 "Knolknol ( Gaath Gobhi)"85 "Lady's Finger( Bhindi)"86 "Lettuce (Salad)"87 "Lime Bean"88 "Little Gourd (Kundroo, Tindora)"89 "Mountain Spinach ( Pahari Palak)"90 "Musk Melon (Kharbooja)"91 "Onion (Piaz)"92 "Pointed Gourd ( Parwal)"93 "Potato (Aaloo)"94 "Pumpkin ( Petha)"95 "Radish ( Mooli)"96 "Red Pumpkin ( Sitaphal ,Kaddu)"97 "Ridge Gourd ( Tori)"98 "Round Gourd ( Tinda)"99 "Smoth Gourd ( Kali Tori)"100 "Snake Guard ( Chachera, Chachinda)"101 "Spinach ( Palak)"102 "Sword Bean"103 "Sweet Potato ( Sakar Kandi)"104 "Tomato ( Tamattar)"105 "Turnip ( Saljam)"106 "Velet Bean ( Khamch ,Tohar Sem)"107 "Water Melon ( Tarbooj)"108 "Yam ( Tataaloo )"109 "Other Vegetables"110 " Almond ( Badam)"111 "Apple ( Seb)"112 "Apricot (Khumani)"113 "Banana (Kela)"114 "Bread Fruit ( Khadel)"115 "Bullock Heart (Ramphal )"116 "Cape Gooseberry ( Rasbhari)"117 "Cashew ( Kaju)"118 "Cherry (Cherry )"119 "Citron ( Gulgul )"120 "Custard Apple ( Sarifa)"121 "Date Palm (Khajoor)"122 "Fig (Anjeer)"123 "Grape Fruit(Grape Fruit)"124 "Grapevine (Angur)"125 "Guava ( Armood)"126 "Jack Fruit ( Kat-Hal )"127 "Jujube ( Ber)"128 "Lemon ( Bara- Nemboo)"129 "Lime, Acid lime,Sour lime (Kagzi Nemboo)"130 "Litchi ( Leechi )"131 "Laquat( Lokat)"132 "Mango (Aam)"133 "Mangosteen (Mangosteen )"134 "Malbuerry (Raitun)"135 "Papaya (Papita)"136 "Peach ( Aaroo)"137 "Pear (Naaspaati)"138 "Pineapple (Annanas)"139 "Pulm ( Aaloo Bhukhara)"140 "Pomegranate ( Anaar,Dadim)"141 "Raspberry, (Raspbherry, Rasbhary)"142 "Rough Lemon (Nemboo)"143 "Sapota ,Sapodilla Plum (Cheeku)"144 "Shaddock ,Pomelo ( Chakotra)"145 "Santra Orange,Mandarian Orange"146 "Strawberry (Strawberry )"147 "Sweet Lime ( Meetha Nemboo)"148 "Sweet Orange ,Malta ( Mausmee)"149 "Walnut (Akhroat )"150 "Other Fruits"151 "Other Dry Fruits"152 "Amise"153 "Aromatic Cardamon ( Chhoti Elaichi )"154 "Betelvine (Pan)"155 "Bishop's Weed ( Ajwan,Ajamo)"156 "Black Mustard ( Kali Sarson ,Kali Rai') "157 "Black Pepper ( Kali Mirch )"158 "Cardomam (Elaichi )"159 "Chilli' ( Lal Mirch)"160 "Coriander ( Dhaniya)"161 "Cumin ( Jeera)"162 "Dill Seed ( Soya, Suwa)"163 "Fennel ( Sonf ,Variali)"164 "Fanugreek ( Maythik, Methi)"165 "Garlic ( Lehsoon ,Lasan)"166 "Ginger ( Adrakh )"167 "Indian Mustard ( Raie)"168 "Large Cardamon ( Bari Elaichy)"169 "Long Pepper ( Mirchi)"170 "Mint ( Pudeena)"171 "Ntmeg ( Jaiphal )"172 "Turmeric ( Haldi )"173 "White Mustard ( Banarsi Raie)"174 "Other Condiments & Spices)"175 "Indian Hemp ( Bhang)"176 "Indigo (Kneel)"177 "Poppy -Opium Poppy( Aphim)"178 "Poppy (Posta)"179 "Saffron (Kesar)"180 "Tobaccco ( Tambaku)"181 "Blonde Psyllium (Isapgol )"182 "Indian Privet ( Mehandi)"183 "Cluster Bean(Gawar)"184 "Other Drugs ,Dyes & Narcotiecs"185 "Areca Palm( Kattha)"186 "Cocao (Koka ,Kahva)"187 "Chinchona ( Quinine)"188 "Coconut ( Narial)"189 "Coffee ( Coffee)"190 "Para Rubber ( Rubber)"191 "Tea ( Chaie)"192 "Banana"193 "Mango"194 "Arcanut"195 "Other Plantations"196 "Rose"197 "Tube Rose"198 "Jasmine"199 "Marigold"200 "Gladiolus"201 "Orchids"202 "Other Flowers"203 "Barseem Seed"
label value q810_cropcode cropcode1
label var q811_varname "Variety Name"
label var q812_grainyld "Grain Yield"
label var q813_fodyielf "Fodder Yield"
label var q814_drghttol "Drought Tolerance"
label var q815_disres "Disease Resistance"
label var  q816_insdamfld "Insect Damage in Field"
label var q817_birdpro "Bird Prone"
label var q818_procqual "Processing Quality"
label var q819_instdamstor "Insect Damage in Storage"
label var q820_eatqual "Eating Quality"

tempfile F2
save `F2'
*/
// Merge q801 and F1
use `q801', clear
merge 1:m Id using `F1', nogen keep(3)
order Id subid

/****************************************************************
	SECTION X: Save and Exit
****************************************************************/

qui compress
save "${builddta}/followup_2014/SectionF1_KharifCrop_NotThisYear_cleaned.dta", replace

cap file close _all
cap log close
copy "${buildlog}/`name_do'.smcl" ///
	"${buildlog}/archive/`name_do' - `c(current_date)' - `c(username)'.smcl" ///
	, replace
exit
