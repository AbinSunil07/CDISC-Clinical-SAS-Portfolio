/*******************************************************************************
Program Name: adam_adlb.sas
Description:  Creates the ADaM ADLB (Laboratory Analysis) dataset.
Specification: Merges SDTM LB with ADSL. Derives Baseline flags (ABLFL), 
               Baseline values (BASE), and Change from baseline (CHG).
*******************************************************************************/

/* 1. Setup Library Paths */
libname sdtm "/home/u63934368/CDISC_Portfolio/02_SDTM/datasets";
libname adam "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets";

/* 2. Sort input datasets by Unique Subject ID before merging */
proc sort data=sdtm.lb out=work.lb_sorted;
    by USUBJID;
run;

proc sort data=adam.adsl out=work.adsl_sorted;
    by USUBJID;
run;

/* 3. Merge ADSL and LB, and derive basic Analysis Variables */
data work.adlb_mapped;
    merge work.lb_sorted(in=in_lb) 
          work.adsl_sorted(in=in_adsl keep=USUBJID STUDYID SUBJID TRT01P TRT01PN);
    by USUBJID;
    
    if in_lb; /* Only keep patients who had lab tests */
    
    /* Treatment Variables */
    length TRTA $20;
    TRTA = TRT01P;
    TRTAN = TRT01PN;
    
    /* Parameter Variables (ADaM standard uses PARAM and PARAMCD instead of LBTEST) */
    length PARAMCD $8 PARAM $100;
    PARAMCD = LBTESTCD;
    PARAM = LBTEST;
    
    /* Date Conversion: Character to Numeric (SAS Date) */
    format ADT date9.;
    if length(LBDTC) >= 10 then ADT = input(substr(LBDTC, 1, 10), yymmdd10.);
    
    /* Value Conversion: Character to Numeric */
    /* Use the ?? modifier to suppress errors if some lab results are text (like "TRACE" or "N/A") */
    AVAL = input(LBORRES, ?? best12.);
    
    keep STUDYID USUBJID SUBJID TRTA TRTAN PARAMCD PARAM ADT AVAL;
run;

/* 4. Sort data chronologically per patient, per lab test */
proc sort data=work.adlb_mapped;
    by USUBJID PARAMCD ADT;
run;

/* 5. Derive Baseline Flag (ABLFL), Baseline Value (BASE), and Change (CHG) */
data work.adlb_base;
    set work.adlb_mapped;
    by USUBJID PARAMCD;
    
    length ABLFL $1;
    retain BASE; /* Retains the baseline value for subsequent records */
    
    /* The first chronoloical record for a test is our Baseline */
    if first.PARAMCD then do;
        ABLFL = 'Y';
        BASE = AVAL;
    end;
    else do;
        ABLFL = '';
    end;
    
    /* Calculate Change from Baseline */
    if not missing(AVAL) and not missing(BASE) then CHG = AVAL - BASE;
run;

/* 6. Format, Label, and Output Final Dataset */
data adam.adlb(label="Laboratory Analysis Dataset");
    retain STUDYID USUBJID SUBJID TRTA TRTAN PARAMCD PARAM ADT AVAL ABLFL BASE CHG;
    set work.adlb_base;
    
    /* Apply standard ADaM labels */
    label TRTA    = "Actual Treatment"
          TRTAN   = "Actual Treatment (N)"
          PARAMCD = "Parameter Code"
          PARAM   = "Parameter"
          ADT     = "Analysis Date"
          AVAL    = "Analysis Value"
          ABLFL   = "Baseline Record Flag"
          BASE    = "Baseline Value"
          CHG     = "Change from Baseline";
run;

/* 7. Create the XPT file for the FDA Submission folder */
libname xptout xport "/home/u63934368/CDISC_Portfolio/03_ADaM/datasets/adlb.xpt";
proc copy in=adam out=xptout;
    select adlb;
run;
