# Dataset Source

## Origin

This project uses the **Fannie Mae Single-Family Loan Performance Dataset**, a publicly available loan-level dataset released by Fannie Mae (Federal National Mortgage Association) covering fixed-rate, fully amortizing mortgages acquired by Fannie Mae.

**Quarters used in this project:** 2020 Q1 and 2020 Q2

## Access

The dataset is not redistributed in this repository. It must be downloaded directly from Fannie Mae:

**Portal:** https://capitalmarkets.fanniemae.com/credit-risk-transfer/single-family-credit-risk-transfer/fannie-mae-single-family-loan-performance-data

Access requires free registration and acceptance of Fannie Mae's data use terms.

## Why the Raw Data Is Not Included

1. **License restriction.** Fannie Mae's data use agreement governs redistribution. This repository does not include the raw dataset to remain compliant with those terms.
2. **File size.** The full 2020 Q1–Q2 files exceed 80 million records combined and are not suitable for a Git repository.

Anyone reproducing this project should download the source files directly from the Fannie Mae portal and place them locally before running `03_SQL/mortgage_risk_analysis.sql`.

## File Format

- Delimiter: pipe (`|`)
- Header row: none — column position must be mapped manually
- Encoding: plain text
- Columns: 113 fields per record (108 populated in the 2020 vintage of this dataset; later fields are placeholder/reserved in earlier vintages)

## Structure Notes

Each row represents one loan-month observation, not one loan. A single loan will appear across multiple rows — one per reporting period it was active. This is why the raw record count (84.18 million after cleaning) is far larger than the number of unique loans (~1.92 million), and why the project builds a separate latest-snapshot table for reporting. See `05_Diagrams/Snapshot_Model_Architecture.png` for the reasoning.

## Column Reference

See `Column_Mapping.xlsx` and `Data_Dictionary.pdf` in this folder for the full field-by-field mapping between the raw column positions (`column1`–`column108`) and the business names used throughout this project's SQL and documentation.
