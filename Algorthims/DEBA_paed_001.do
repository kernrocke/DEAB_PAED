cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          DEBA_paed_001.do
    //  project:                DEBA in Jamaica
    //  analysts:               Kern ROCKE
    //  date first created      17-MAY-2025
    // 	date last modified      17-MAY-2025
    //  algorithm task          Data analysis for research report
    //  status                  Pending

    
    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    *local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p117"
	local datapath "/Users/kernrocke/Library/Mobile Documents/com~apple~CloudDocs/Github/DEAB_PAED" // Kern encrypted local machine
	



***************
** DATA IMPORT  
***************
** LOAD the national registry deaths 2008-2023 excel dataset
import spss using "`datapath'/Dataset/data_set_09_5_25.sav", clear

*******************
** DATA PREPARATION 
*******************
*Create age category
gen age_cat = . 
replace age_cat = 1 if age >=10 & age<16
replace age_cat = 2 if age >=16 & age!=.
label var age_cat "Age categories"
label define age_cat 1"Early adolescents" 2"Late adolescents"
label value age_cat age_cat

*Create bmi classifcation
gen bmi_class_2 = . 
replace bmi_class_2 = 1 if bmi_category == 1 & bmi_class == .
replace bmi_class_2 = 2 if BMI_class == 1
replace bmi_class_2 = 3 if BMI_class == 2
replace bmi_class_2 = 4 if BMI_class == 3
label var bmi_class_2 "BMI classification"
label define bmi_class_2 1"Overweight" 2"Class 1 Obesity" 3"Class 2 Obesity" 4"Class 3 Obesity"
label value bmi_class_2 bmi_class_2

*Create ACE categories
gen ace_risk = .
replace ace_risk = 1 if ACE_total == 0
replace ace_risk = 2 if ACE_total >= 1 & ACE_total<=3
replace ace_risk = 3 if ACE_total >3 & ACE_total!=.
label var ace_risk "ACE Risk Categories"
label define ace_risk 1"Low risk" 2"Intermediate risk" 3"High risk"
label values ace_risk ace_risk
tabulate ace_risk, generate(ace_risk_cat)

*Create coping categories
gen coping_cat = .
replace coping_cat = 1 if coping_scale_total<22
replace coping_cat = 2 if coping_scale_total>=22 & coping_scale_total<=32
replace coping_cat = 3 if coping_scale_total>32 & coping_scale_total!=.
label var coping_cat "Coping categories"
label define coping_cat 1"Low" 2"Medium" 3"High"
label value coping_cat coping_cat
tab coping_cat, gen(coping_cat_)

*Create self-esteem categories
gen self_esteem_cat = . 
replace self_esteem_cat = 1 if self_esteem_scale_total<15 // Low
replace self_esteem_cat = 2 if self_esteem_scale_total>=15 & self_esteem_scale_total<=25 // Normal
replace self_esteem_cat = 3 if self_esteem_scale_total>25 & self_esteem_scale_total!=. // High
label var self_esteem_cat "Self-esteem categories"
label define self_esteem_cat 1"Low" 2"Normal" 3"High"
label value self_esteem_cat self_esteem_cat

*------------------------------------------------------
*------------------------------------------------------
*------------------------------------------------------

****************
** DATA ANALYSIS  
****************

*Description of analysis population - Table 1
tab age_cat sex, col exact
tab bmi_class_2 sex, col exact
tab DM sex, col exact
tab hypertensive sex, col exact

ttest posession_score , by(sex)
ttest sanitation_index, by(sex)
*------------------------------------------------------

*Mean estimates of DEBAs - Table 2a
foreach x of varlist YEDE_Q_total_score restraint eating_concern shape_concern weight_concern {
	
	ttest `x', by(sex)
	ttest `x', by(age_cat)
	oneway `x' bmi_class_2, tab
}

*------------------------------------------------------

*Mean estimates of emotional-eating - Table 2b
	ttest emotional_eating, by(sex)
	ttest emotional_eating, by(age_cat)
	oneway emotional_eating bmi_class_2, tab

*------------------------------------------------------
*Mean estimates of ACE - Table 3a
	ttest ACE_total, by(sex)
	ttest ACE_total, by(age_cat)
	oneway ACE_total bmi_class_2, tab

*Low risk ACE - Table 3a
	tab ace_risk_cat1 sex, col exact
	tab ace_risk_cat1 age_cat, col exact
	tab ace_risk_cat1 bmi_class_2, col exact
	
*Intermediate risk ACE - Table 3a
	tab ace_risk_cat2 sex, col exact
	tab ace_risk_cat2 age_cat, col exact
	tab ace_risk_cat2 bmi_class_2, col exact
	
*High risk ACE - Table 3a
	tab ace_risk_cat3 sex, col exact
	tab ace_risk_cat3 age_cat, col exact
	tab ace_risk_cat3 bmi_class_2, col exact
	
*------------------------------------------------------
	
*Participant Coping Skills 
*Mean estimates of Coping skills - Table 3b
	ttest coping_scale_total, by(sex)
	ttest coping_scale_total, by(age_cat)
	oneway coping_scale_total bmi_class_2, tab
	
	
*Analysis note: There was no low risk coping (coping score<22)
*Medium coping - Table 3b
	tab coping_cat_1 sex, col exact
	tab coping_cat_1 age_cat, col exact
	tab coping_cat_1 bmi_class_2, col exact
	
*High coping - Table 3b
	tab coping_cat_2 sex, col exact
	tab coping_cat_2 age_cat, col exact
	tab coping_cat_2 bmi_class_2, col exact
*------------------------------------------------------
	
*Participant self-esteem - Table 3c
	tab self_esteem_cat sex, col exact
	tab self_esteem_cat age_cat, col exact
	tab self_esteem_cat bmi_class_2, col exact

