/*******************************************************************************
Program Name: adam_adae.sas
Description:  Creates the ADaM ADAE (Adverse Event Analysis) dataset.
Specification: Merges SDTM AE with ADSL. Derives numeric dates and duration.
*******************************************************************************/

/* 1. Setup Library Paths */
libname sdtm "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets";
libname adam "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets";

/* 2. Sort input datasets by Unique Subject ID before merging */
proc sort data=sdtm.ae out=work.ae_sorted;
    by USUBJID;
run;

proc sort data=adam.adsl out=work.adsl_sorted;
    by USUBJID;
run;

/* 3. Merge ADSL and AE, and derive Analysis Variables */
data work.adae_mapped;
    /* Merge keeping only records that exist in the AE domain */
    merge work.ae_sorted(in=in_ae) 
          work.adsl_sorted(in=in_adsl keep=USUBJID STUDYID SUBJID TRT01P TRT01PN AGE SEX RACE);
    by USUBJID;
    
    if in_ae; /* Crucial: Only keep patients who had an AE */
    
    /* Treatment Variables (Actual Treatment = Planned Treatment for this simulation) */
    length TRTA $20;
    TRTA = TRT01P;
    TRTAN = TRT01PN;
    
    /* Date Conversions: Character (ISO 8601) to Numeric (SAS Date) */
    format ASTDT AENDT date9.;
    if length(AESTDTC) >= 10 then ASTDT = input(substr(AESTDTC, 1, 10), yymmdd10.);
    if length(AEENDTC) >= 10 then AENDT = input(substr(AEENDTC, 1, 10), yymmdd10.);
    
    /* Duration Calculation: End Date - Start Date + 1 */
    if not missing(ASTDT) and not missing(AENDT) then ADURN = (AENDT - ASTDT) + 1;
    
    keep STUDYID USUBJID SUBJID TRTA TRTAN AGE SEX RACE AETERM AEOUT ASTDT AENDT ADURN;
run;

/* 4. Format, Label, and Output Final Dataset */
data adam.adae(label="Adverse Events Analysis Dataset");
    retain STUDYID USUBJID SUBJID TRTA TRTAN AGE SEX RACE AETERM ASTDT AENDT ADURN AEOUT;
    set work.adae_mapped;
    
    /* Apply standard ADaM labels */
    label TRTA   = "Actual Treatment"
          TRTAN  = "Actual Treatment (N)"
          ASTDT  = "Analysis Start Date"
          AENDT  = "Analysis End Date"
          ADURN  = "AE Duration (N)";
run;

/* 5. Create the XPT file for the FDA Submission folder */
libname xptout xport "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets/adae.xpt";
proc copy in=adam out=xptout;
    select adae;
run;
