/*******************************************************************************
Program Name: sdtm_lb.sas
Description:  Creates the SDTM LB (Laboratory Test Results) domain.
*******************************************************************************/

/* 1. Setup Library Paths */
libname raw "/home/u63934368/CDISC_Portfolio/01_RAW_DATA";
libname sdtm "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets";

/* 2. Import the Raw CSV Data */
proc import datafile="/home/u63934368/CDISC_Portfolio/01_RAW_DATA/observations.csv"
    out=work.raw_obs
    dbms=csv
    replace;
    getnames=yes;
run;

/* 3. Filter for Lab Data and Derive Core SDTM LB Variables */
data work.lb_mapped;
    set work.raw_obs;
    
    /* FIX: The Category data shifted into the CODE column */
    where upcase(CODE) = "LABORATORY";
    
    /* Identifier Variables */
    length STUDYID $12 DOMAIN $2 USUBJID $50;
    STUDYID = "SYNTHEA-001";
    DOMAIN  = "LB";
    
    /* FIX: Patient ID shifted into the ENCOUNTER column. 
       Added max() to prevent invalid mathematical parameter errors. */
    USUBJID = catx("-", STUDYID, substr(ENCOUNTER, max(1, length(ENCOUNTER)-7), 8));
    
    /* Laboratory Variables */
    length LBTESTCD $8 LBTEST $100 LBCAT $40 LBORRES $50 LBORRESU $50 LBDTC $16;
    
    /* FIX: LOINC code shifted into DESCRIPTION. 
       CDISC Rule: LBTESTCD cannot start with a number and is max 8 chars */
    LBTESTCD = substr(cats('L', compress(DESCRIPTION, '-')), 1, 8);
    
    /* FIX: Test name shifted into VALUE */
    LBTEST = VALUE;
    
    /* FIX: Category shifted into CODE */
    LBCAT  = upcase(CODE); 
    
    /* FIX: Numeric Result shifted into UNITS */
    LBORRES = UNITS;
    
    /* FIX: Unit Type shifted into TYPE */
    LBORRESU = TYPE;
    
    /* FIX: Date shifted into PATIENT */
    LBDTC = substr(PATIENT, 1, 16);
    
    keep STUDYID DOMAIN USUBJID LBTESTCD LBTEST LBCAT LBORRES LBORRESU LBDTC;
run;

/* 4. Sort data to prepare for Sequence Number (LBSEQ) derivation */
proc sort data=work.lb_mapped;
    by USUBJID LBDTC LBTESTCD;
run;

/* 5. Derive LBSEQ (Sequence Number) */
data work.lb_seq;
    set work.lb_mapped;
    by USUBJID;
    
    if first.USUBJID then LBSEQ = 1;
    else LBSEQ + 1;
run;

/* 6. Format, Label, and Output Final Dataset */
data sdtm.lb(label="Laboratory Test Results");
    retain STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU LBDTC;
    set work.lb_seq;
    
    /* Apply standard CDISC labels */
    label STUDYID  = "Study Identifier"
          DOMAIN   = "Domain Abbreviation"
          USUBJID  = "Unique Subject Identifier"
          LBSEQ    = "Sequence Number"
          LBTESTCD = "Lab Test or Examination Short Name"
          LBTEST   = "Lab Test or Examination Name"
          LBCAT    = "Category for Lab Test"
          LBORRES  = "Result or Finding in Original Units"
          LBORRESU = "Original Units"
          LBDTC    = "Date/Time of Specimen Collection";
run;

/* 7. Create the XPT file for the FDA Submission folder */
libname xptout xport "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets/lb.xpt";
proc copy in=sdtm out=xptout;
    select lb;
run;
