# Clinical Trial Data Pipeline (CDISC SDTM & ADaM)

## Project Overview
This repository contains an end-to-end clinical data pipeline programmed in SAS. It demonstrates the transformation of raw, Real-World Data (RWD) / Electronic Health Records (EHR) into FDA-submission-ready CDISC SDTM datasets, with Analysis Data Model (ADaM) and TFL generation following in subsequent phases.

The raw data was sourced from Synthea (synthetic patient records), providing a highly realistic simulation of the complex data cleaning and mapping required in modern clinical trials.

## Tech Stack & Standards
* **Language:** SAS (Base & Advanced)
* **Environment:** SAS OnDemand for Academics (Linux Cloud)
* **Standards:** CDISC SDTMIG v3.4, ADaMIG
* **Formats:** FDA-compliant SAS Transport Files (`.xpt`)

## Project Architecture
This repository mirrors a professional clinical biometrics server environment:
* `01_RAW_DATA/` - Raw CSV extracts simulating Electronic Data Capture (EDC) / EHR.
* `02_SDTM/` - SAS mapping programs and final `.xpt` datasets.
* `03_ADaM/` - *In Progress: Analysis dataset derivations.*
* `04_TFL/` - *In Progress: Mock Tables, Figures, and Listings.*
* `06_Specifications/` - Source-to-Target mapping documentation (`sdtm_specs.csv`).

## Key Engineering Milestones (SDTM Phase)
* **Demographics (DM):** Engineered core subject-level data, standardizing ISO 8601 dates and mapping to strict CDISC controlled terminology for Race and Ethnicity.
* **Adverse Events (AE):** Handled longitudinal safety data, deriving unique sequence numbers (`AESEQ`) via `first.variable` processing and calculating event outcomes based on date presence.
* **Laboratory Test Results (LB):** Processed a massive observation dataset (>500k rows). Successfully engineered programmatic solutions to handle raw CSV data anomalies (shifted column headers), extracted specific lab records, and standardized LOINC codes to meet the strict 8-character CDISC `LBTESTCD` constraints.

## Next Steps
Currently developing the Subject Level Analysis Dataset (ADSL) to establish the foundation for statistical efficacy and safety analysis.
