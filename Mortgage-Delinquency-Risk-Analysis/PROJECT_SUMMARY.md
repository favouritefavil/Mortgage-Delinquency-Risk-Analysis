# Project Summary — Mortgage Delinquency Risk Analysis

**Reading Time: Approximately 4 minutes**

Full detail lives in `01_Project_Documentation/`.

## Tools Used

PostgreSQL · SQL · Power BI · DAX · Microsoft Excel

## Business Problem

Within a large mortgage portfolio, which borrowers are most likely to become delinquent, why, and what should management do about it? A single portfolio-wide delinquency rate hides the segments where risk and exposure actually concentrate.

## Objectives

- Build a reliable portfolio health baseline from raw loan-servicing data
- Identify which borrower, structural, and geographic factors drive delinquency
- Quantify exposure at risk by segment, not just delinquency rate
- Test whether loan modification status is an independent risk signal
- Convert findings into a monitoring framework with defined thresholds

## Dataset

Fannie Mae Single-Family Loan Performance Dataset, 2020 Q1-Q2. 84.18 million loan-month records after cleaning, reduced to a ~1.92 million row latest-snapshot table for reporting. 108 raw fields mapped against the Fannie Mae glossary.

## Dashboard Preview

Six-page Power BI dashboard: Executive Overview, Borrower Risk, Property & Loan, Geographic Risk, Behavioural Risk, Portfolio Surveillance. Screenshots in `02_Dashboard/`.

## Key Findings

- **Modified loans: 22.8% delinquent vs 0.6% non-modified** (38x), independent of risk segment
- **Credit score is the dominant individual predictor:** 22x spread between Very High Risk and Very Low Risk borrowers
- **Risk layering compounds:** multi-factor risky borrowers delinquent at 2.4% vs 0.3% baseline
- **Geographic risk follows borrower composition, not location** — New York elevated on borrower quality, California carries exposure without elevated risk
- **Moderate Risk segment holds more delinquent dollars ($1.3bn) than High Risk ($0.5bn)** on volume alone
- **Purchase loans run ~2x refinance delinquency**, likely a COVID-period origination timing effect

## Business Recommendations

1. Monitor modified loans as an independent segment, regardless of credit risk tier
2. Apply stricter underwriting where multiple risk factors coincide
3. Treat geographic risk outliers as a borrower-composition question before adjusting state-level lending policy
4. Build house price stress scenarios for high-exposure, low-delinquency states
5. Extend to roll rate and cure rate analysis using the existing 84M-row panel

## Project Deliverables

- Executive Credit Risk Report
- Business Case Study
- Technical Documentation
- Six-page Power BI dashboard
- Full SQL analytical pipeline (eight stages, raw data to reporting layer)
- Column mapping and data dictionary

## Repository Navigation

Start with `README.md` for full detail, or `01_Project_Documentation/Executive_Credit_Risk_Report.docx` for the business-facing findings. Technical reviewers should go to `03_SQL/mortgage_risk_analysis.sql` and `01_Project_Documentation/Technical_Documentation.docx`.

## Links

Full reports: `01_Project_Documentation/`
Portfolio: https://chegwefavourportfolioo.netlify.app/
GitHub: https://github.com/favouritefavil
LinkedIn: http://www.linkedin.com/in/favour-chegwe
