/*******************************************************************************
Program Name: t_14_1_1_demo.sas
Description:  Generates Table 14.1.1 Demographics and Baseline Characteristics
Output:       t_14_1_1_demo.rtf
*******************************************************************************/

/* 1. Setup Library Paths */
libname adam "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets";

/* NOTE: Update this path to point to your new TFL folder */
%let outpath = /home/u63934368/CDISC_Portfolio/04_TFL;

/* 2. Format Definitions for Clean Output */
proc format;
    value $sexfmt
        'M' = 'Male'
        'F' = 'Female';
run;

/* 3. Generate the RTF Document */
options nodate nonumber orientation=portrait;
ods escapechar='^';

/* The 'journal' style creates a clean, black-and-white, FDA-standard look */
ods rtf file="&outpath/t_14_1_1_demo.rtf" style=journal bodytitle;

title1 j=c "Table 14.1.1";
title2 j=c "Summary of Demographics and Baseline Characteristics";
title3 j=c "Safety Population";

proc tabulate data=adam.adsl missing;
    class TRT01P SEX RACE;
    var AGE;
    format SEX $sexfmt.;
    
    /* Define clean column headers instead of SAS variable names */
    keylabel n = 'n'
             mean = 'Mean'
             std = 'SD'
             median = 'Median'
             min = 'Min'
             max = 'Max'
             colpctn = '%';
             
    table 
        /* ROW DIMENSION: What goes down the left side */
        (
         AGE="Age (Years)" * (n*f=5.0 mean*f=5.1 std*f=5.2 median*f=5.1 min*f=5.0 max*f=5.0)
         SEX="Sex" * (n*f=5.0 colpctn*f=5.1)
         RACE="Race" * (n*f=5.0 colpctn*f=5.1)
        ),
        /* COLUMN DIMENSION: What goes across the top */
        TRT01P="Planned Treatment" * (all="Total")
        
        /* Formatting options for the table box */
        / misstext='0' row=float box="Demographic Parameter";
run;

ods rtf close;
title; /* Clear titles */
