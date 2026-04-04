/*******************************************************************************
Program Name: adam_adsl.sas
Description:  Creates the ADaM ADSL (Subject Level Analysis) dataset.
Specification: Derives Age, Age Groups, Population Flags, and simulated Treatment.
*******************************************************************************/

/* 1. Setup Library Paths */
/* NOTE: Point 'sdtm' to your existing folder, and 'adam' to your new folder */
libname sdtm "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets";
libname adam "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets";

/* 2. Derive ADSL Variables from SDTM DM */
data work.adsl_mapped;
    set sdtm.dm;
    
    /* Variables kept directly from DM: STUDYID, USUBJID, SUBJID, SEX, RACE */
    
    /* 3. Age Derivation using INTCK */
    /* Convert ISO 8601 character date to SAS numeric date */
    format num_brthdtc date9.;
    num_brthdtc = input(substr(BRTHDTC, 1, 10), yymmdd10.);
    
    /* Calculate age relative to study reference date: Jan 1, 2026 */
    AGE = intck('YEAR', num_brthdtc, '01JAN2026'd);
    
    /* Adjust age if birthday hasn't happened yet in the reference year */
    if month(num_brthdtc) > 1 or (month(num_brthdtc) = 1 and day(num_brthdtc) > 1) then AGE = AGE - 1;
    
    /* 4. Age Group Derivation */
    length AGEGR1 $5;
    if . < AGE < 18 then AGEGR1 = '<18';
    else if 18 <= AGE <= 65 then AGEGR1 = '18-65';
    else if AGE > 65 then AGEGR1 = '>65';
    
    /* 5. Simulated Treatment Assignment (TRT01P, TRT01PN) */
    length TRT01P $20;
    /* We use the first character of the SUBJID to deterministically "randomize" */
    if substr(SUBJID, 1, 1) in ('0','1','2','3','4','5','6','7') then do;
        TRT01P = 'Placebo';
        TRT01PN = 1;
    end;
    else do;
        TRT01P = 'Study Drug';
        TRT01PN = 2;
    end;
    
    /* 6. Population Flags */
    length SAFFL $1 ITTFL $1;
    SAFFL = 'Y';
    ITTFL = 'Y';
    
    keep STUDYID USUBJID SUBJID AGE AGEGR1 SEX RACE TRT01P TRT01PN SAFFL ITTFL;
run;

/* 7. Format, Label, and Output Final Dataset */
data adam.adsl(label="Subject Level Analysis Dataset");
    retain STUDYID USUBJID SUBJID TRT01P TRT01PN AGE AGEGR1 SEX RACE SAFFL ITTFL;
    set work.adsl_mapped;
    
    /* Apply standard ADaM labels */
    label AGE     = "Age"
          AGEGR1  = "Pooled Age Group 1"
          TRT01P  = "Planned Treatment for Period 01"
          TRT01PN = "Planned Treatment for Period 01 (N)"
          SAFFL   = "Safety Population Flag"
          ITTFL   = "Intent-To-Treat Population Flag";
run;

/* 8. Create the XPT file for the FDA Submission folder */
libname xptout xport "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets/adsl.xpt";
proc copy in=adam out=xptout;
    select adsl;
run;
