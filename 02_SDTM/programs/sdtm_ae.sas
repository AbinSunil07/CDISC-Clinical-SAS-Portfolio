/*******************************************************************************
Program Name: sdtm_ae.sas
Description:  Creates the SDTM AE (Adverse Events) domain from raw Synthea data.
Specification: Maps raw conditions.csv to CDISC SDTM v3.4 standards.
*******************************************************************************/

/* 1. Setup Library Paths */
libname raw "/home/u63934368/CDISC_Portfolio/01_RAW_DATA";
libname sdtm "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets";

/* 2. Import the Raw CSV Data */
proc import datafile="/home/u63934368/CDISC_Portfolio/01_RAW_DATA/conditions.csv"
    out=work.raw_conditions
    dbms=csv
    replace;
    getnames=yes;
run;

/* 3. Derive Core SDTM AE Variables based on Mapping Spec */
data work.ae_mapped;
    set work.raw_conditions;
    
    /* Identifier Variables */
    length STUDYID $12 DOMAIN $2 USUBJID $50;
    STUDYID = "SYNTHEA-001";
    DOMAIN  = "AE";
    
    /* Extract last 8 chars of PATIENT string and concatenate */
    USUBJID = catx("-", STUDYID, substr(PATIENT, length(PATIENT)-7, 8));
    
    /* Adverse Event Variables */
    length AETERM $200 AESTDTC $10 AEENDTC $10 AEOUT $40;
    AETERM = DESCRIPTION;
    AESTDTC = START;
    AEENDTC = STOP;
    
    /* Outcome Derivation */
    if not missing(AEENDTC) then AEOUT = "RECOVERED/RESOLVED";
    else AEOUT = "NOT RECOVERED/NOT RESOLVED";
    
    keep STUDYID DOMAIN USUBJID AETERM AESTDTC AEENDTC AEOUT;
run;

/* 4. Sort data to prepare for Sequence Number (AESEQ) derivation */
proc sort data=work.ae_mapped;
    by USUBJID AESTDTC AETERM;
run;

/* 5. Derive AESEQ (Sequence Number) */
/* This assigns a sequential number (1, 2, 3...) to each AE for a specific patient */
data work.ae_seq;
    set work.ae_mapped;
    by USUBJID;
    
    if first.USUBJID then AESEQ = 1;
    else AESEQ + 1;
run;

/* 6. Format, Label, and Output Final Dataset */
data sdtm.ae(label="Adverse Events");
    retain STUDYID DOMAIN USUBJID AESEQ AETERM AESTDTC AEENDTC AEOUT;
    set work.ae_seq;
    
    /* Apply standard CDISC labels */
    label STUDYID = "Study Identifier"
          DOMAIN  = "Domain Abbreviation"
          USUBJID = "Unique Subject Identifier"
          AESEQ   = "Sequence Number"
          AETERM  = "Reported Term for the Adverse Event"
          AESTDTC = "Start Date/Time of Adverse Event"
          AEENDTC = "End Date/Time of Adverse Event"
          AEOUT   = "Outcome of Adverse Event";
run;

/* 7. Create the XPT file for the FDA Submission folder */
libname xptout xport "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets/ae.xpt";
proc copy in=sdtm out=xptout;
    select ae;
run;
