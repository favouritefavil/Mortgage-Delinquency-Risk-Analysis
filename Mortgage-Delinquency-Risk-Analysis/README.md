# Mortgage Delinquency Risk Analysis

Portfolio-grade credit risk analytics project using the Fannie Mae Single-Family Loan Performance Dataset (2020 Q1-Q2). Built to simulate how a Risk Analytics team inside a bank or mortgage institution would investigate portfolio delinquency, quantify exposure, and produce an operational monitoring framework.

**Author:** Favour Chegwe
**Portfolio:** [Favour Chegwe](https://chegwefavourportfolioo.netlify.app/)
**GitHub:** [Favouritefavil](https://github.com/favouritefavil)
**LinkedIn:** [Favour Chegwe](http://www.linkedin.com/in/favour-chegwe)

---

## Business Problem

Given a large mortgage portfolio, which borrowers are most likely to become delinquent, why, and what should management do about it? A delinquency rate on its own tells you almost nothing actionable. This project builds the analytical layer underneath that number: which borrower, structural, geographic, and behavioural characteristics drive delinquency, how much money is actually at risk in each segment, and what an operational surveillance framework looks like once those answers are known.

## Objectives

- Establish a reliable portfolio health baseline from 84 million raw loan-servicing records
- Identify borrower-level risk drivers (credit score, DTI, risk segment)
- Assess structural and collateral risk (loan purpose, LTV, property type)
- Diagnose geographic risk concentration and its underlying drivers
- Quantify the impact of loan modification status on delinquency behaviour
- Translate findings into a monitoring framework with defined thresholds

## Business Value

This project demonstrates how raw, unstructured mortgage servicing data, 84 million records with no schema, no documentation, and no analytical structure can be transformed into decision-grade portfolio risk intelligence. The output is not just a dashboard; it is a repeatable framework an institution could use to prioritise which borrowers need attention, which segments are quietly accumulating exposure, and where a monitoring threshold should trigger action rather than a quarterly review. For a credit risk or portfolio management function, that distinction matters: knowing your overall delinquency rate is reporting, knowing which 5% of your book explains 40% of your exposure at risk is strategy. This project is built to demonstrate that second capability turning data into a basis for decisions, not just a summary of what already happened.

## Dataset

- **Source:** Fannie Mae Single-Family Loan Performance Dataset, 2020 Q1 and Q2
- **Raw scale:** 84,223,406 loan-month observations across two quarterly files
- **After cleaning:** 84,183,216 records (40,190 removed for missing credit score)
- **Reporting layer:** ~1.92 million unique loans (latest-snapshot model, one row per loan)
- **Fields:** 108 columns per record, no header row, mapped against the official Fannie Mae glossary

Full column mapping and glossary notes are in [04_Data/ Folder](04_Data/)

## Solution Architecture

Raw pipe-delimited files are loaded into PostgreSQL as TEXT to guarantee safe ingestion, then progressively cleaned, typed, and enriched through a sequence of views. Feature engineering derives risk bands and composite risk segments. Thirteen summary tables sit on top of the full 84M-row analytical panel to keep EDA fast. A separate latest-snapshot fact table (~1.92M rows, one record per loan) is built specifically for Power BI so the dashboard reports current portfolio state rather than cumulative historical exposure.

See [Solution Architecture Diagram](05_Diagrams/Solution_Architecture.png) and [Snapshot Model Architecture Diagram](05_Diagrams/Snapshot_Model_Architecture.png) for the full pipeline and the reasoning behind the snapshot approach.

## Analytical Methodology

Risk features engineered directly in SQL:

| Feature | Logic |
|---|---|
| Credit Score Band | Very High Risk (<640) to Very Low Risk (760+) |
| LTV Band | Low Risk (<60%) to High Risk (90%+) |
| DTI Band | Low Risk (<28%) to Very High Risk (43%+) |
| Risk Factor Count | 0-3 points across credit score, LTV, DTI thresholds |
| Risk Segment | Low / Moderate / High, from composite risk factor count |
| Delinquency Flag | Status not equal to 00 |
| Serious Delinquency Flag | Status 03+ (90+ DPD, IFRS 9 Stage 3 equivalent) |

Full SQL is in [mortgage_risk_analysis.sql](03_SQL/mortgage_risk_analysis.sql), structured across eight stages from raw table creation to the Power BI fact table.

## Dashboard

Six-page Power BI dashboard, each page built around one executive question:

| Page | Question |
|---|---|
| 1. Executive Overview | How healthy is the portfolio overall? |
| 2. Borrower Risk | Which borrowers are most likely to become delinquent? |
| 3. Property & Loan | Which loan and property structures carry elevated risk? |
| 4. Geographic Risk | Why are certain markets riskier than others? |
| 5. Behavioural Risk | How does modification status affect delinquency? |
| 6. Portfolio Surveillance | Which segments need continuous monitoring? |

Screenshots: [Executive Overview](02_Dashboard/Dashboard_Page_1.png) through [Deep-Dive Details](02_Dashboard/Dashboard_Page_6.png)

## Key Findings

**Modification status is the single strongest risk signal in the portfolio.** Modified loans are 22.8% delinquent versus 0.6% for non-modified loans, a 38x difference, and this holds independently across every risk segment. Modified loans are under 1% of exposure but drive a disproportionate share of delinquent balances.

**Credit quality is the dominant individual predictor.** Very High Risk borrowers are delinquent at 4.4% versus 0.2% for Very Low Risk, a 22x spread.

**Risk layering compounds non-linearly.** Borrowers with two or more concurrent risk conditions (weak credit, high LTV, high DTI) are delinquent at 2.4%, nearly eight times the 0.3% rate for low-risk borrowers.

**Geographic risk tracks borrower composition, not location.** New York's elevated delinquency (1.18%) and modification rate (1.03%) reflect who is borrowing there, not the state itself. California carries 16.6% of portfolio exposure but only 0.47% delinquency because its borrower quality is strong.

**Exposure concentration does not follow delinquency rate.** The Moderate Risk segment holds $1.3bn in delinquent exposure, more than the High Risk segment's $0.5bn, purely on volume.

**Purchase loans run roughly double the delinquency rate of refinances** (1.1% vs 0.6%), consistent with COVID-period origination timing effects.

## Business Recommendations

1. Establish a dedicated monthly monitoring track for modified loans, independent of risk segment classification
2. Apply enhanced underwriting scrutiny where multiple risk conditions are present simultaneously, rather than relying on single-variable cutoffs
3. Treat geographic outliers as a borrower-composition question first, not a location question, before adjusting lending policy by state
4. Build HPI stress scenarios for high-exposure, low-delinquency states like California, since the risk there is concentration, not credit quality
5. Extend the panel-based SQL work to roll rate and cure rate analysis, which the current snapshot model cannot support but the 84M-row panel already has the data for

## Technical Stack

PostgreSQL · Power BI · Excel · Python

## Repository Structure

```
Mortgage-Delinquency-Risk-Analysis/
├── 01_Project_Documentation/
│   ├── Project_Summary.pdf
│   ├── Executive_Credit_Risk_Report.docx
│   ├── Executive_Credit_Risk_Report.pdf
│   ├── Business_Case_Study.docx
│   ├── Business_Case_Study.pdf
│   ├── Technical_Documentation.docx
│   ├── Technical_Documentation.pdf
│   └── Portfolio_Publication.pdf
├── 02_Dashboard/
│   ├── Mortgage_Delinquency_Dashboard.pbix
│   ├── Dashboard_Page_1.png
│   ├── Dashboard_Page_2.png
│   ├── Dashboard_Page_3.png
│   ├── Dashboard_Page_4.png
│   ├── Dashboard_Page_5.png
│   └── Dashboard_Page_6.png
├── 03_SQL/
│   └── mortgage_risk_analysis.sql
├── 04_Data/
│   ├── Data_Dictionary.pdf
│   ├── Column_Mapping.xlsx
│   └── Dataset_Source.md
├── 05_Diagrams/
│   ├── Solution_Architecture.png
│   ├── Snapshot_Model_Architecture.png
│   ├── Dashboard_Storytelling_Framework.png
│   └── Project_Lifecycle.png
├── README.md
├── PROJECT_SUMMARY.md
├── LICENSE
└── .gitignore
```

## Analytical Value Chain

This project demonstrates the complete analytical value chain a credit risk or data analytics role actually requires: raw data engineering at real scale (84M+ rows), defensible feature engineering grounded in industry underwriting standards, a data modelling decision (the snapshot model) made for a specific business reason rather than convenience, an executive-ready dashboard, and documentation written for four different audiences (executive, technical, business case, and public-facing).

## Future Improvements

- Roll rate and cure rate analysis from the full 84M-row panel
- Integration of FHFA House Price Index and BLS unemployment data for macro-adjusted geographic risk
- Formal PD/LGD/EAD estimation and a directional IFRS 9 Expected Credit Loss calculation
- Automated monitoring refresh with threshold-based alerting

## Repository Guide

Recommended reading order for first-time visitors:

1. [Project Summary](01_Project_Documentation/Project_Summary.pdf)— five-minute overview
2. [Executive Credit Risk Report](01_Project_Documentation/Executive_Credit_Risk_Report.pdf) — findings and recommendations for a business audience
3. [Portfolio Publication](01_Project_Documentation/Portfolio_Publication.pdf) — polished, presentation-ready version of the full case study
4. [Business Case Study](01_Project_Documentation/Business_Case_Study.pdf) — full narrative of the business problem, methodology, and impact
5. [Technical Documentation](01_Project_Documentation/Technical_Documentation.pdf) — detailed technical walkthrough for reviewers assessing execution
6. [Browse 02_Dashboard/ Folder](02_Dashboard/) — six-page Power BI dashboard screenshots
7. [mortgage_risk_analysis.sql](03_SQL/mortgage_risk_analysis.sql) — full analytical pipeline, raw data to reporting layer

## Connect

Favour Chegwe
Portfolio:  [Favour Chegwe](https://chegwefavourportfolioo.netlify.app/)
GitHub:[Favouritefavil](https://github.com/favouritefavil)
LinkedI [Favour Chegwe](http://www.linkedin.com/in/favour-chegwe)
