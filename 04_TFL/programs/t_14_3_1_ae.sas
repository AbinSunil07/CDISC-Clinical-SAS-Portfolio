/*******************************************************************************
Program Name: t_14_3_1_ae.sas
Description:  Generates Table 14.3.1: Incidence of Adverse Events by Treatment
Output:       t_14_3_1_ae.rtf
*******************************************************************************/

/* 1. Setup Library Paths */
libname adam "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets";
%let outpath = /home/u63934368/CDISC_Portfolio/04_TFL;

/* 2. CRITICAL STEP: Deduplicate the data */
/* We want to count the number of SUBJECTS who had an AE, not the number of events.
   If a patient has 3 'Acute bronchitis' events, they only count once. */
proc sort data=adam.adae out=work.adae_subj nodupkey;
    by TRTA AETERM USUBJID;
run;

/* 3. Generate the RTF Document */
options nodate nonumber orientation=portrait;
ods escapechar='^';

ods rtf file="&outpath/t_14_3_1_ae.rtf" style=journal bodytitle;

title1 j=c "Table 14.3.1";
title2 j=c "Incidence of Adverse Events by Treatment Group";
title3 j=c "Safety Population";

proc tabulate data=work.adae_subj missing;
    class TRTA AETERM;
    
    /* Clean column header for the counts */
    keylabel n = 'Number of Subjects (n)';
             
    table 
        /* ROW DIMENSION: AE Terms down the left side */
        AETERM="Reported Adverse Event Term",
        
        /* COLUMN DIMENSION: Treatments across the top */
        TRTA="Actual Treatment" * n
        
        /* Formatting options */
        / misstext='0' row=float box="Adverse Event";
run;

ods rtf close;
title;
