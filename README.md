# Clinical Trial Data Pipeline (CDISC SDTM, ADaM & TFLs)

## Project Overview
This repository contains an end-to-end clinical data pipeline programmed entirely in SAS. It demonstrates the transformation of raw, Real-World Data (RWD) / Electronic Health Records (EHR) into FDA-submission-ready CDISC datasets, concluding with the generation of Clinical Study Report (CSR) outputs.

The raw data was sourced from Synthea (synthetic patient records), providing a highly realistic simulation of the complex data cleaning, programmatic problem-solving, and mapping required in modern clinical trials.

## Tech Stack & Standards
* **Language:** SAS (Base & Advanced, Macro Facility, SQL)
* **Environment:** SAS OnDemand for Academics (Linux Cloud Environment)
* **Standards:** CDISC SDTMIG v3.4, ADaMIG
* **Reporting:** Output Delivery System (ODS RTF), PROC TABULATE, PROC REPORT
* **Formats:** FDA-compliant SAS Transport Files (`.xpt`)

## Project Architecture
This repository mirrors a professional clinical biometrics server environment:
* `01_RAW_DATA/` - Raw CSV extracts simulating Electronic Data Capture (EDC) / EHR.
* `02_SDTM/` - SDTM mapping programs and final `.xpt` datasets (DM, AE, LB).
* `03_ADaM/` - Analysis dataset derivations and final `.xpt` datasets (ADSL, ADAE, ADLB).
* `04_TFL/` - SAS reporting programs and presentation-ready RTF outputs.
* `06_Specifications/` - Source-to-Target mapping documentation (`sdtm_specs.csv`, `adam_specs.csv`).

## Key Engineering Milestones
### 1. Data Engineering & SDTM
* **Data Anomaly Resolution:** Programmatically aligned shifted CSV column headers in the massive (>500k row) Laboratory dataset during `PROC IMPORT` without hardcoding.
* **Standardization:** Mapped raw conditions and observations to strict CDISC controlled terminology. Standardized LOINC codes to meet the 8-character `LBTESTCD` constraints and converted raw timestamps to ISO 8601 `YYYY-MM-DD` formats.
* **Longitudinal Data:** Engineered unique sequence numbers (`AESEQ`, `LBSEQ`) across multiple patient visits using `first.variable` processing.

### 2. Analysis Data Model (ADaM)
* **Demographics (ADSL):** Calculated subject ages relative to a static study reference date using the `INTCK` function and deterministically simulated treatment group randomizations. 
* **Safety & Efficacy (ADAE, ADLB):** Merged SDTM domains with ADSL to establish safety flags. Utilized `RETAIN` statements and sorting algorithms to flag baseline lab records (`ABLFL`) and calculate continuous change from baseline (`CHG`).

### 3. Tables, Figures, and Listings (TFLs)
* **Table 14.1.1 (Demographics):** Utilized `PROC TABULATE` to calculate continuous (n, mean, SD, median, min, max) and categorical (counts, percentages) statistics split by treatment group.
* **Table 14.3.1 (AE Incidence):** Applied `NODUPKEY` to correctly calculate the number of unique subjects experiencing an adverse event, ensuring FDA reporting compliance.
* **Listing 16.2.8 (Lab Results):** Generated patient-level data listings using `PROC REPORT` with `compute after` blocks for clean, readable clinical review.
