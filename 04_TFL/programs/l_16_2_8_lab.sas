/*******************************************************************************
Program Name: l_16_2_8_lab.sas
Description:  Generates Listing 16.2.8: Individual Patient Laboratory Results
Output:       l_16_2_8_lab.rtf
*******************************************************************************/

/* 1. Setup Library Paths */
libname adam "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets";
%let outpath = /home/u63934368/CDISC_Portfolio/04_TFL;

/* 2. Sort the Data */
/* Listings must be perfectly sorted by Treatment, Subject, and Date so 
   PROC REPORT groups the rows correctly. */
proc sort data=adam.adlb out=work.adlb_sorted;
    by TRTA USUBJID ADT PARAM;
run;

/* 3. Generate the RTF Document */
/* Notice we are using landscape orientation for wider columns */
options nodate nonumber orientation=landscape; 
ods escapechar='^';

ods rtf file="&outpath/l_16_2_8_lab.rtf" style=journal bodytitle;

title1 j=c "Listing 16.2.8";
title2 j=c "Individual Patient Laboratory Results";
title3 j=c "Safety Population";

proc report data=work.adlb_sorted split='*' missing headline headskip;
    /* Define the order of columns from left to right */
    columns TRTA USUBJID ADT PARAM AVAL ABLFL BASE CHG;
    
    /* Using 'order' suppresses repeating values so the listing looks clean */
    define TRTA    / order "Actual Treatment" width=15;
    define USUBJID / order "Subject ID" width=20;
    define ADT     / order "Analysis Date" format=date9. width=12;
    
    /* Using 'display' prints every individual record */
    define PARAM   / display "Laboratory Parameter" width=30;
    define AVAL    / display "Result" width=10;
    define ABLFL   / display "Baseline*Flag" width=10;
    define BASE    / display "Baseline*Value" width=10;
    define CHG     / display "Change from*Baseline" width=10;
    
    /* This adds a visual blank line every time the subject ID changes */
    compute after USUBJID;
        line ' ';
    endcomp;
run;

ods rtf close;
title;
