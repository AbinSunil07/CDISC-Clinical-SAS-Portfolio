/*******************************************************************************
Program Name: sdtm_dm.sas
Description:  Creates the SDTM DM (Demographics) domain from raw Synthea data.
Specification: Maps raw patients.csv to CDISC SDTM v3.4 standards.
*******************************************************************************/

/* 1. Setup Library Paths */
libname raw "/home/u63934368/CDISC_Portfolio/01_RAW_DATA";
libname sdtm "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets";

/* 2. Import the Raw CSV Data */
proc import datafile="/home/u63934368/CDISC_Portfolio/01_RAW_DATA/patients.csv"
    out=work.raw_patients
    dbms=csv
    replace;
    getnames=yes;
run;

/* 3. Derive SDTM DM Variables based on Mapping Spec */
data work.dm_mapped;
    set work.raw_patients;
    
    /* Identifier Variables */
    length STUDYID $12 DOMAIN $2 USUBJID $50 SUBJID $8;
    STUDYID = "SYNTHEA-001";
    DOMAIN  = "DM";
    SUBJID  = substr(Id, length(Id)-7, 8); /* Extract last 8 chars of Synthea ID */
    USUBJID = catx("-", STUDYID, SUBJID);
    
    /* Demographic Variables */
    length SEX $1 RACE $50 ETHNIC $40 COUNTRY $3;
    SEX = upcase(GENDER);
    
    /* Race Mapping (Strict CDISC Controlled Terminology) */
    if upcase(RACE) = "WHITE" then RACE = "WHITE";
    else if upcase(RACE) = "BLACK" then RACE = "BLACK OR AFRICAN AMERICAN";
    else if upcase(RACE) = "ASIAN" then RACE = "ASIAN";
    else if upcase(RACE) = "NATIVE" then RACE = "AMERICAN INDIAN OR ALASKA NATIVE";
    else RACE = "MULTIPLE";
    
    /* Ethnicity Mapping */
    if upcase(ETHNICITY) = "NONHISPANIC" then ETHNIC = "NOT HISPANIC OR LATINO";
    else if upcase(ETHNICITY) = "HISPANIC" then ETHNIC = "HISPANIC OR LATINO";
    else ETHNIC = "UNKNOWN";
    
    COUNTRY = "USA";
    
    /* Date Formatting & Flags */
    length BRTHDTC $10 DTHDTC $10 DTHFL $1;
    BRTHDTC = BIRTHDATE; 
    DTHDTC = DEATHDATE;
    
    if not missing(DTHDTC) then DTHFL = "Y";
    else DTHFL = "";
    
    /* Keep only the variables defined in the spec */
    keep STUDYID DOMAIN USUBJID SUBJID BRTHDTC DTHDTC DTHFL SEX RACE ETHNIC COUNTRY;
run;

/* 4. Format, Sort, and Output Final Dataset */
data sdtm.dm(label="Demographics");
    retain STUDYID DOMAIN USUBJID SUBJID BRTHDTC DTHDTC DTHFL SEX RACE ETHNIC COUNTRY;
    set work.dm_mapped;
    
    /* Apply standard CDISC labels */
    label STUDYID = "Study Identifier"
          DOMAIN  = "Domain Abbreviation"
          USUBJID = "Unique Subject Identifier"
          SUBJID  = "Subject Identifier for the Study"
          BRTHDTC = "Date/Time of Birth"
          DTHDTC  = "Date/Time of Death"
          DTHFL   = "Subject Death Flag"
          SEX     = "Sex"
          RACE    = "Race"
          ETHNIC  = "Ethnicity"
          COUNTRY = "Country";
run;

proc sort data=sdtm.dm;
    by USUBJID;
run;

/* 5. Create the XPT file for the FDA Submission folder */
libname xptout xport "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets/dm.xpt";
proc copy in=sdtm out=xptout;
    select dm;
run;
