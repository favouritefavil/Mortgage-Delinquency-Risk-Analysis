/*
    Project   : Mortgage Delinquency Risk Analysis
    Dataset   : Fannie Mae Single-Family Loan Performance — 2020 Q1 and Q2
    Author    : Favour Chegwe
    Purpose   : End-to-end PostgreSQL analytical pipeline covering raw ingestion,
                data profiling, cleaning, type standardisation, feature engineering,
                EDA summary tables, and Power BI reporting layer construction.

    Pipeline stages:

        1. Raw table creation and data ingestion
        2. Analytical table construction (field selection and renaming)
        3. Data profiling and business validation
        4. Data cleaning and type standardisation
        5. Feature engineering
        6. Portfolio KPI and risk metrics
        7. EDA summary tables
        8. Power BI fact table (latest-snapshot model)

    Notes:
        - All 108 source columns loaded as TEXT to guarantee safe ingestion.
        - Credit score nulls (40,190 records) removed at cleaning layer.
        - Q1: 26,745,204 records. Q2: 57,478,202 records. Combined: 84,183,216.
        - Power BI fact table uses ROW_NUMBER() to retain one record per loan,
          representing the most recent monthly observation (latest-snapshot model).
          This eliminates double-counting and supports accurate current-state KPIs.
*/


/* ============================================================
   STAGE 1: RAW TABLE CREATION
   ============================================================ */

CREATE TABLE mortgage_raw (
    column1   TEXT, column2   TEXT, column3   TEXT, column4   TEXT,
    column5   TEXT, column6   TEXT, column7   TEXT, column8   TEXT,
    column9   TEXT, column10  TEXT, column11  TEXT, column12  TEXT,
    column13  TEXT, column14  TEXT, column15  TEXT, column16  TEXT,
    column17  TEXT, column18  TEXT, column19  TEXT, column20  TEXT,
    column21  TEXT, column22  TEXT, column23  TEXT, column24  TEXT,
    column25  TEXT, column26  TEXT, column27  TEXT, column28  TEXT,
    column29  TEXT, column30  TEXT, column31  TEXT, column32  TEXT,
    column33  TEXT, column34  TEXT, column35  TEXT, column36  TEXT,
    column37  TEXT, column38  TEXT, column39  TEXT, column40  TEXT,
    column41  TEXT, column42  TEXT, column43  TEXT, column44  TEXT,
    column45  TEXT, column46  TEXT, column47  TEXT, column48  TEXT,
    column49  TEXT, column50  TEXT, column51  TEXT, column52  TEXT,
    column53  TEXT, column54  TEXT, column55  TEXT, column56  TEXT,
    column57  TEXT, column58  TEXT, column59  TEXT, column60  TEXT,
    column61  TEXT, column62  TEXT, column63  TEXT, column64  TEXT,
    column65  TEXT, column66  TEXT, column67  TEXT, column68  TEXT,
    column69  TEXT, column70  TEXT, column71  TEXT, column72  TEXT,
    column73  TEXT, column74  TEXT, column75  TEXT, column76  TEXT,
    column77  TEXT, column78  TEXT, column79  TEXT, column80  TEXT,
    column81  TEXT, column82  TEXT, column83  TEXT, column84  TEXT,
    column85  TEXT, column86  TEXT, column87  TEXT, column88  TEXT,
    column89  TEXT, column90  TEXT, column91  TEXT, column92  TEXT,
    column93  TEXT, column94  TEXT, column95  TEXT, column96  TEXT,
    column97  TEXT, column98  TEXT, column99  TEXT, column100 TEXT,
    column101 TEXT, column102 TEXT, column103 TEXT, column104 TEXT,
    column105 TEXT, column106 TEXT, column107 TEXT, column108 TEXT,
    column109 TEXT, column110 TEXT, column111 TEXT, column112 TEXT,
    column113 TEXT
);

-- Load Q1 source file via COPY (pipe-delimited, no header row)
-- COPY mortgage_raw FROM '/path/to/2020Q1.txt' DELIMITER '|';

-- Q1 ingestion check: expected ~26.7M rows
SELECT COUNT(*) AS q1_row_count FROM mortgage_raw;
-- Result: 26,745,204


CREATE TABLE mortgage_raw2 (
    column1   TEXT, column2   TEXT, column3   TEXT, column4   TEXT,
    column5   TEXT, column6   TEXT, column7   TEXT, column8   TEXT,
    column9   TEXT, column10  TEXT, column11  TEXT, column12  TEXT,
    column13  TEXT, column14  TEXT, column15  TEXT, column16  TEXT,
    column17  TEXT, column18  TEXT, column19  TEXT, column20  TEXT,
    column21  TEXT, column22  TEXT, column23  TEXT, column24  TEXT,
    column25  TEXT, column26  TEXT, column27  TEXT, column28  TEXT,
    column29  TEXT, column30  TEXT, column31  TEXT, column32  TEXT,
    column33  TEXT, column34  TEXT, column35  TEXT, column36  TEXT,
    column37  TEXT, column38  TEXT, column39  TEXT, column40  TEXT,
    column41  TEXT, column42  TEXT, column43  TEXT, column44  TEXT,
    column45  TEXT, column46  TEXT, column47  TEXT, column48  TEXT,
    column49  TEXT, column50  TEXT, column51  TEXT, column52  TEXT,
    column53  TEXT, column54  TEXT, column55  TEXT, column56  TEXT,
    column57  TEXT, column58  TEXT, column59  TEXT, column60  TEXT,
    column61  TEXT, column62  TEXT, column63  TEXT, column64  TEXT,
    column65  TEXT, column66  TEXT, column67  TEXT, column68  TEXT,
    column69  TEXT, column70  TEXT, column71  TEXT, column72  TEXT,
    column73  TEXT, column74  TEXT, column75  TEXT, column76  TEXT,
    column77  TEXT, column78  TEXT, column79  TEXT, column80  TEXT,
    column81  TEXT, column82  TEXT, column83  TEXT, column84  TEXT,
    column85  TEXT, column86  TEXT, column87  TEXT, column88  TEXT,
    column89  TEXT, column90  TEXT, column91  TEXT, column92  TEXT,
    column93  TEXT, column94  TEXT, column95  TEXT, column96  TEXT,
    column97  TEXT, column98  TEXT, column99  TEXT, column100 TEXT,
    column101 TEXT, column102 TEXT, column103 TEXT, column104 TEXT,
    column105 TEXT, column106 TEXT, column107 TEXT, column108 TEXT,
    column109 TEXT, column110 TEXT, column111 TEXT, column112 TEXT,
    column113 TEXT
);

-- Load Q2 source file via COPY (pipe-delimited, no header row)
-- COPY mortgage_raw2 FROM '/path/to/2020Q2.txt' DELIMITER '|';

-- Q2 ingestion check: expected ~57.4M rows
SELECT COUNT(*) AS q2_row_count FROM mortgage_raw2;
-- Result: 57,478,202


/* ============================================================
   STAGE 2: ANALYTICAL TABLE CONSTRUCTION
   Selects the 30 fields required for credit risk analysis
   and assigns business-readable column names.
   Field positions reference the Fannie Mae glossary.
   Column 2 = Field Position 1 (leading pipe offset applies).
   ============================================================ */

CREATE TABLE mortgage_analysis_q1 AS
SELECT
    column2  AS loan_id,
    column3  AS monthly_reporting_period,
    column24 AS credit_score,
    column23 AS dti_ratio,
    column22 AS num_borrowers,
    column26 AS first_time_homebuyer,
    column20 AS orig_ltv,
    column21 AS orig_cltv,
    column8  AS orig_interest_rate,
    column13 AS orig_loan_term,
    column27 AS loan_purpose,
    column35 AS amortization_type,
    column37 AS interest_only_flag,
    column4  AS origination_channel,
    column28 AS property_type,
    column29 AS num_units,
    column30 AS occupancy_status,
    column31 AS property_state,
    column32 AS msa_code,
    column33 AS zip_short,
    column86 AS property_valuation_method,
    column10 AS orig_upb,
    column12 AS current_upb,
    column16 AS loan_age,
    column14 AS origination_date,
    column40 AS delinquency_status,
    column41 AS payment_history,
    column42 AS modification_flag,
    column44 AS zero_balance_code,
    column46 AS upb_at_removal,
    column52 AS foreclosure_date
FROM mortgage_raw;


CREATE TABLE mortgage_analysis_q2 AS
SELECT
    column2  AS loan_id,
    column3  AS monthly_reporting_period,
    column24 AS credit_score,
    column23 AS dti_ratio,
    column22 AS num_borrowers,
    column26 AS first_time_homebuyer,
    column20 AS orig_ltv,
    column21 AS orig_cltv,
    column8  AS orig_interest_rate,
    column13 AS orig_loan_term,
    column27 AS loan_purpose,
    column35 AS amortization_type,
    column37 AS interest_only_flag,
    column4  AS origination_channel,
    column28 AS property_type,
    column29 AS num_units,
    column30 AS occupancy_status,
    column31 AS property_state,
    column32 AS msa_code,
    column33 AS zip_short,
    column86 AS property_valuation_method,
    column10 AS orig_upb,
    column12 AS current_upb,
    column16 AS loan_age,
    column14 AS origination_date,
    column40 AS delinquency_status,
    column41 AS payment_history,
    column42 AS modification_flag,
    column44 AS zero_balance_code,
    column46 AS upb_at_removal,
    column52 AS foreclosure_date
FROM mortgage_raw2;


/* ============================================================
   STAGE 3: DATA PROFILING AND BUSINESS VALIDATION
   Conducted on Q1 using TABLESAMPLE SYSTEM to manage cost
   at scale. Results documented inline.
   ============================================================ */

-- Credit score distribution
SELECT DISTINCT credit_score
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.1)
ORDER BY credit_score;
-- Min: 620  |  Max: 825  |  Nulls: present  |  Above 850: none

-- LTV ratio distribution
SELECT DISTINCT orig_ltv
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.1)
ORDER BY orig_ltv;
-- Min: 11  |  Max: 97  |  Nulls: none  |  Above 100: none

-- CLTV ratio distribution
SELECT DISTINCT orig_cltv
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.1)
ORDER BY orig_cltv;
-- Min: 12  |  Max: 102  |  Nulls: none  |  Above 100: yes (within Fannie Mae limits)

-- DTI ratio distribution
SELECT DISTINCT dti_ratio
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.1)
ORDER BY dti_ratio;
-- Min: 1  |  Max: 50  |  Nulls: none

-- Delinquency status values
SELECT DISTINCT delinquency_status
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.1)
ORDER BY delinquency_status;
-- Range: 00 to 25  |  Nulls: none  |  'XX' observed (unknown status)

-- Categorical field checks
SELECT DISTINCT loan_purpose       FROM mortgage_analysis_q1 TABLESAMPLE SYSTEM (0.1);
-- Values: C, P, R

SELECT DISTINCT occupancy_status   FROM mortgage_analysis_q1 TABLESAMPLE SYSTEM (0.1);
-- Values: I, P, S

SELECT DISTINCT property_type      FROM mortgage_analysis_q1 TABLESAMPLE SYSTEM (0.1);
-- Values: CO, CP, MH, PU, SF

SELECT DISTINCT modification_flag  FROM mortgage_analysis_q1 TABLESAMPLE SYSTEM (0.1);
-- Values: N, Y  |  Nulls: present (treated as Not Modified downstream)

SELECT DISTINCT interest_only_flag FROM mortgage_analysis_q1 TABLESAMPLE SYSTEM (0.1);
-- Values: N only (no IO loans in this extract)

-- Payment history sample (48-character monthly performance string)
SELECT DISTINCT payment_history
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.01)
LIMIT 20;
-- Mix of nulls (loans < 24 months old) and encoded strings e.g.
--   '000000000001000000010000000000000000000000000000'
--   'XXXXXXXXXXXXXXXXXXXXXXXXXXXX00010000000000000000'

-- Zero balance code distribution
SELECT DISTINCT zero_balance_code
FROM mortgage_analysis_q1
TABLESAMPLE SYSTEM (0.1)
ORDER BY zero_balance_code;
-- Values: 01, 08, null (majority null — expected for active loans)

-- Foreclosure record count
SELECT COUNT(*) AS foreclosure_records
FROM mortgage_analysis_q1
WHERE foreclosure_date IS NOT NULL;
-- Result: 458 (near-zero — reflects COVID-19 foreclosure moratorium)


/* ============================================================
   STAGE 4: DATA CLEANING AND TYPE STANDARDISATION

   Step 4a — Combine Q1 and Q2 into a single analytical panel.
   Step 4b — Remove records with null credit score (40,190 removed,
             representing 0.048% of total records).
   Step 4c — Cast fields from TEXT to correct analytical types.
             Categorical codes and date strings kept as TEXT.
   ============================================================ */

-- Step 4a: Combined analytical panel (84.18M loan-month observations)
CREATE VIEW mortgage_portfolio AS
SELECT * FROM mortgage_analysis_q1
UNION ALL
SELECT * FROM mortgage_analysis_q2;

SELECT COUNT(*) AS combined_panel_rows FROM mortgage_portfolio;
-- Result: 84,183,216  (Q1: 26,745,204 + Q2: 57,438,012)

-- Null check across core variables before cleaning
SELECT
    COUNT(*)                                            AS total_rows,
    COUNT(*) FILTER (WHERE credit_score    IS NULL)     AS credit_score_nulls,
    COUNT(*) FILTER (WHERE modification_flag IS NULL)   AS modification_flag_nulls,
    COUNT(*) FILTER (WHERE foreclosure_date  IS NULL)   AS foreclosure_date_nulls
FROM mortgage_portfolio;

-- Business validity check — flag non-numeric values in numeric fields
SELECT
    COUNT(*) FILTER (WHERE credit_score  !~ '^[0-9]+$') AS non_numeric_credit_score,
    COUNT(*) FILTER (WHERE orig_ltv      !~ '^[0-9]+$') AS non_numeric_ltv,
    COUNT(*) FILTER (WHERE orig_cltv     !~ '^[0-9]+$') AS non_numeric_cltv,
    COUNT(*) FILTER (WHERE dti_ratio     !~ '^[0-9]+$') AS non_numeric_dti
FROM mortgage_portfolio;

-- Categorical distribution checks
SELECT modification_flag, COUNT(*) FROM mortgage_portfolio GROUP BY 1 ORDER BY 2 DESC;
SELECT delinquency_status, COUNT(*) FROM mortgage_portfolio GROUP BY 1 ORDER BY 1;
SELECT loan_purpose, COUNT(*) FROM mortgage_portfolio GROUP BY 1;
SELECT occupancy_status, COUNT(*) FROM mortgage_portfolio GROUP BY 1;
SELECT property_type, COUNT(*) FROM mortgage_portfolio GROUP BY 1;
SELECT zero_balance_code, COUNT(*) AS record_count FROM mortgage_portfolio GROUP BY 1 ORDER BY 1;


-- Step 4b: Cleaned view — remove null credit scores
CREATE OR REPLACE VIEW mortgage_clean_v AS
SELECT *
FROM mortgage_portfolio
WHERE credit_score IS NOT NULL;

SELECT COUNT(*) AS cleaned_row_count FROM mortgage_clean_v;
-- Result: 84,183,216 (40,190 null credit score records removed)


-- Step 4c: Typed view — cast to correct data types
-- Delinquency status, zero balance code, MSA code, and zip code
-- are retained as TEXT — casting to INTEGER destroys leading zeros
-- and breaks categorical filter logic.
CREATE OR REPLACE VIEW mortgage_typed_v AS
SELECT
    loan_id,
    monthly_reporting_period,
    NULLIF(credit_score,       '')::INTEGER              AS credit_score,
    NULLIF(dti_ratio,          '')::NUMERIC              AS dti_ratio,
    NULLIF(num_borrowers,      '')::INTEGER              AS num_borrowers,
    first_time_homebuyer,
    NULLIF(orig_ltv,           '')::NUMERIC              AS orig_ltv,
    NULLIF(orig_cltv,          '')::NUMERIC              AS orig_cltv,
    NULLIF(orig_interest_rate, '')::NUMERIC              AS orig_interest_rate,
    NULLIF(orig_loan_term,     '')::INTEGER              AS orig_loan_term,
    loan_purpose,
    amortization_type,
    interest_only_flag,
    origination_channel,
    property_type,
    NULLIF(num_units,          '')::INTEGER              AS num_units,
    occupancy_status,
    property_state,
    msa_code,
    zip_short,
    property_valuation_method,
    NULLIF(orig_upb,           '')::NUMERIC              AS orig_upb,
    NULLIF(current_upb,        '')::NUMERIC              AS current_upb,
    NULLIF(loan_age,           '')::INTEGER              AS loan_age,
    origination_date,
    delinquency_status,
    payment_history,
    modification_flag,
    zero_balance_code,
    NULLIF(upb_at_removal,     '')::NUMERIC              AS upb_at_removal,
    foreclosure_date
FROM mortgage_clean_v;


/* ============================================================
   STAGE 5: FEATURE ENGINEERING
   Derives risk classification features used throughout EDA,
   the reporting layer, and the Power BI dashboard.
   All thresholds aligned to Fannie Mae underwriting guidelines
   and Basel/IFRS 9 default definitions.
   ============================================================ */

CREATE OR REPLACE VIEW mortgage_typed_fe_v AS
SELECT
    *,

    -- Credit score risk band
    CASE
        WHEN credit_score BETWEEN 620 AND 639 THEN 'Very High Risk'
        WHEN credit_score BETWEEN 640 AND 679 THEN 'High Risk'
        WHEN credit_score BETWEEN 680 AND 719 THEN 'Moderate Risk'
        WHEN credit_score BETWEEN 720 AND 759 THEN 'Low Risk'
        WHEN credit_score >= 760              THEN 'Very Low Risk'
    END AS credit_score_band,

    -- LTV risk band (PMI threshold at 80%; high LTV at 90%)
    CASE
        WHEN orig_ltv < 60                          THEN 'Very Low Risk'
        WHEN orig_ltv >= 60  AND orig_ltv < 80      THEN 'Low Risk'
        WHEN orig_ltv >= 80  AND orig_ltv < 90      THEN 'Moderate Risk'
        ELSE                                             'High Risk'
    END AS ltv_band,

    -- DTI risk band (28/36 rule; 43% Fannie Mae standard maximum)
    CASE
        WHEN dti_ratio <= 28                        THEN 'Low Risk'
        WHEN dti_ratio >  28 AND dti_ratio <= 36    THEN 'Moderate Risk'
        WHEN dti_ratio >  36 AND dti_ratio <= 43    THEN 'High Risk'
        ELSE                                             'Very High Risk'
    END AS dti_band,

    -- Risk factor count: one point each for weak credit, high LTV, high DTI
    (
        CASE WHEN credit_score < 680 THEN 1 ELSE 0 END +
        CASE WHEN orig_ltv     > 90  THEN 1 ELSE 0 END +
        CASE WHEN dti_ratio    > 43  THEN 1 ELSE 0 END
    ) AS risk_factor_count,

    -- Risk segment based on cumulative risk factor count
    CASE
        WHEN (
            CASE WHEN credit_score < 680 THEN 1 ELSE 0 END +
            CASE WHEN orig_ltv     > 90  THEN 1 ELSE 0 END +
            CASE WHEN dti_ratio    > 43  THEN 1 ELSE 0 END
        ) = 0 THEN 'Low Risk'
        WHEN (
            CASE WHEN credit_score < 680 THEN 1 ELSE 0 END +
            CASE WHEN orig_ltv     > 90  THEN 1 ELSE 0 END +
            CASE WHEN dti_ratio    > 43  THEN 1 ELSE 0 END
        ) = 1 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS risk_segment,

    -- Delinquency flag (excludes unknown status 'XX')
    CASE
        WHEN delinquency_status <> '00'
         AND delinquency_status <> 'XX' THEN 1
        ELSE 0
    END AS delinquency_flag,

    -- Serious delinquency flag (90+ DPD — Basel/IFRS 9 default threshold)
    CASE
        WHEN delinquency_status IN (
            '03','04','05','06','07','08','09','10',
            '11','12','13','14','15','16','17','18',
            '19','20','21','22','23','24','25'
        ) THEN 1
        ELSE 0
    END AS serious_delinquency_flag

FROM mortgage_typed_v;


/* ============================================================
   STAGE 6: PORTFOLIO KPI AND RISK METRICS
   Spot-check queries run against the feature-engineered view
   before creating pre-aggregated summary tables.
   ============================================================ */

SELECT
    ROUND(100.0 * SUM(delinquency_flag)        / COUNT(*), 2) AS delinquency_rate_pct
FROM mortgage_typed_fe_v;

SELECT
    ROUND(100.0 * SUM(serious_delinquency_flag) / COUNT(*), 2) AS serious_delinquency_rate_pct
FROM mortgage_typed_fe_v;

SELECT ROUND(SUM(current_upb), 2) AS portfolio_exposure        FROM mortgage_typed_fe_v;

SELECT ROUND(SUM(current_upb), 2) AS delinquent_exposure
FROM mortgage_typed_fe_v WHERE delinquency_flag = 1;

SELECT ROUND(SUM(current_upb), 2) AS serious_delinquent_exposure
FROM mortgage_typed_fe_v WHERE serious_delinquency_flag = 1;

SELECT
    risk_segment,
    COUNT(*)                      AS loan_count,
    ROUND(SUM(current_upb), 2)   AS exposure
FROM mortgage_typed_fe_v
GROUP BY risk_segment
ORDER BY exposure DESC;


/* ============================================================
   STAGE 7: EDA SUMMARY TABLES
   Pre-aggregated tables that serve as the reporting layer
   for the Power BI dashboard. Running repeated GROUP BY
   operations against 84M rows is not practical for iterative
   analysis — these tables bring query times from minutes to
   seconds.
   ============================================================ */


/* Portfolio health — executive KPI summary row */
DROP TABLE IF EXISTS mortgage_portfolio_kpi_summary;

CREATE TABLE mortgage_portfolio_kpi_summary AS
SELECT
    COUNT(*)                                                AS total_loan_observations,
    ROUND(SUM(current_upb), 2)                              AS total_portfolio_exposure,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,

    SUM(
        CASE
            WHEN delinquency_status ~ '^[0-9]+$'
             AND delinquency_status::INT >= 3 THEN 1
            ELSE 0
        END
    )                                                       AS serious_delinquent_loans,

    ROUND(
        SUM(
            CASE
                WHEN delinquency_status ~ '^[0-9]+$'
                 AND delinquency_status::INT >= 3 THEN 1
                ELSE 0
            END
        )::NUMERIC / COUNT(*), 4
    )                                                       AS serious_delinquency_rate,

    ROUND(
        SUM(CASE WHEN delinquency_flag = 1 THEN current_upb ELSE 0 END), 2
    )                                                       AS delinquent_exposure,

    ROUND(
        SUM(
            CASE
                WHEN delinquency_status ~ '^[0-9]+$'
                 AND delinquency_status::INT >= 3 THEN current_upb
                ELSE 0
            END
        ), 2
    )                                                       AS serious_delinquent_exposure,

    ROUND(1 - (SUM(delinquency_flag)::NUMERIC / COUNT(*)), 4) AS current_performing_rate

FROM mortgage_typed_fe_v;


/* Credit score risk — how does delinquency change across credit score bands? */
DROP TABLE IF EXISTS mortgage_credit_score_summary;

CREATE TABLE mortgage_credit_score_summary AS
SELECT
    credit_score_band,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY credit_score_band
ORDER BY
    CASE credit_score_band
        WHEN 'Very Low Risk' THEN 1
        WHEN 'Low Risk'      THEN 2
        WHEN 'Moderate Risk' THEN 3
        WHEN 'High Risk'     THEN 4
        WHEN 'Very High Risk'THEN 5
        ELSE 6
    END;


/* LTV risk — at what leverage level does risk become material? */
DROP TABLE IF EXISTS mortgage_ltv_summary;

CREATE TABLE mortgage_ltv_summary AS
SELECT
    ltv_band,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY ltv_band
ORDER BY
    CASE ltv_band
        WHEN 'Very Low Risk' THEN 1
        WHEN 'Low Risk'      THEN 2
        WHEN 'Moderate Risk' THEN 3
        WHEN 'High Risk'     THEN 4
        ELSE 5
    END;


/* DTI risk — does repayment capacity influence delinquency? */
DROP TABLE IF EXISTS mortgage_dti_summary;

CREATE TABLE mortgage_dti_summary AS
SELECT
    dti_band,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY dti_band
ORDER BY
    CASE dti_band
        WHEN 'Low Risk'      THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk'     THEN 3
        WHEN 'Very High Risk'THEN 4
        ELSE 5
    END;


/* Risk segmentation — does layering multiple risk factors compound delinquency? */
DROP TABLE IF EXISTS mortgage_risk_segment_summary;

CREATE TABLE mortgage_risk_segment_summary AS
SELECT
    risk_segment,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY risk_segment
ORDER BY
    CASE risk_segment
        WHEN 'Low Risk'      THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk'     THEN 3
        ELSE 4
    END;


/* Property type risk — which collateral types experience the highest delinquency? */
DROP TABLE IF EXISTS mortgage_property_type_summary;

CREATE TABLE mortgage_property_type_summary AS
SELECT
    property_type,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY property_type
ORDER BY delinquency_rate DESC;


/* Occupancy risk — does borrower occupancy type affect delinquency behaviour? */
DROP TABLE IF EXISTS mortgage_occupancy_summary;

CREATE TABLE mortgage_occupancy_summary AS
SELECT
    occupancy_status,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY occupancy_status
ORDER BY delinquency_rate DESC;


/* Loan purpose risk — are purchase loans riskier than refinance loans? */
DROP TABLE IF EXISTS mortgage_loan_purpose_summary;

CREATE TABLE mortgage_loan_purpose_summary AS
SELECT
    loan_purpose,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY loan_purpose
ORDER BY delinquency_rate DESC;


/* Geographic risk — which states have the highest delinquency rates and exposure? */
DROP TABLE IF EXISTS mortgage_state_risk_summary;

CREATE TABLE mortgage_state_risk_summary AS
SELECT
    property_state,

    CASE property_state
        WHEN 'AK' THEN 'Alaska'              WHEN 'AL' THEN 'Alabama'
        WHEN 'AR' THEN 'Arkansas'            WHEN 'AZ' THEN 'Arizona'
        WHEN 'CA' THEN 'California'          WHEN 'CO' THEN 'Colorado'
        WHEN 'CT' THEN 'Connecticut'         WHEN 'DC' THEN 'District of Columbia'
        WHEN 'DE' THEN 'Delaware'            WHEN 'FL' THEN 'Florida'
        WHEN 'GA' THEN 'Georgia'             WHEN 'GU' THEN 'Guam'
        WHEN 'HI' THEN 'Hawaii'              WHEN 'IA' THEN 'Iowa'
        WHEN 'ID' THEN 'Idaho'               WHEN 'IL' THEN 'Illinois'
        WHEN 'IN' THEN 'Indiana'             WHEN 'KS' THEN 'Kansas'
        WHEN 'KY' THEN 'Kentucky'            WHEN 'LA' THEN 'Louisiana'
        WHEN 'MA' THEN 'Massachusetts'       WHEN 'MD' THEN 'Maryland'
        WHEN 'ME' THEN 'Maine'               WHEN 'MI' THEN 'Michigan'
        WHEN 'MN' THEN 'Minnesota'           WHEN 'MO' THEN 'Missouri'
        WHEN 'MS' THEN 'Mississippi'         WHEN 'MT' THEN 'Montana'
        WHEN 'NC' THEN 'North Carolina'      WHEN 'ND' THEN 'North Dakota'
        WHEN 'NE' THEN 'Nebraska'            WHEN 'NH' THEN 'New Hampshire'
        WHEN 'NJ' THEN 'New Jersey'          WHEN 'NM' THEN 'New Mexico'
        WHEN 'NV' THEN 'Nevada'              WHEN 'NY' THEN 'New York'
        WHEN 'OH' THEN 'Ohio'                WHEN 'OK' THEN 'Oklahoma'
        WHEN 'OR' THEN 'Oregon'              WHEN 'PA' THEN 'Pennsylvania'
        WHEN 'PR' THEN 'Puerto Rico'         WHEN 'RI' THEN 'Rhode Island'
        WHEN 'SC' THEN 'South Carolina'      WHEN 'SD' THEN 'South Dakota'
        WHEN 'TN' THEN 'Tennessee'           WHEN 'TX' THEN 'Texas'
        WHEN 'UT' THEN 'Utah'                WHEN 'VA' THEN 'Virginia'
        WHEN 'VI' THEN 'U.S. Virgin Islands' WHEN 'VT' THEN 'Vermont'
        WHEN 'WA' THEN 'Washington'          WHEN 'WI' THEN 'Wisconsin'
        WHEN 'WV' THEN 'West Virginia'       WHEN 'WY' THEN 'Wyoming'
        ELSE 'Unknown'
    END AS state_name,

    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure

FROM mortgage_typed_fe_v
GROUP BY property_state
ORDER BY delinquency_rate DESC;


/* Modification risk — are modified loans materially riskier than non-modified loans? */
DROP TABLE IF EXISTS mortgage_modification_summary;

CREATE TABLE mortgage_modification_summary AS
SELECT
    CASE
        WHEN modification_flag = 'Y' THEN 'Modified'
        ELSE 'Not Modified'
    END AS modification_status,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY 1
ORDER BY delinquency_rate DESC;


/* Delinquency severity distribution — how severe are delinquency events? */
DROP TABLE IF EXISTS mortgage_delinquency_distribution_summary;

CREATE TABLE mortgage_delinquency_distribution_summary AS
SELECT
    delinquency_status,
    COUNT(*) AS observations
FROM mortgage_typed_fe_v
GROUP BY delinquency_status
ORDER BY delinquency_status;


/* Zero balance analysis — why are loans leaving the portfolio? */
DROP TABLE IF EXISTS mortgage_zero_balance_summary;

CREATE TABLE mortgage_zero_balance_summary AS
SELECT
    zero_balance_code,
    COUNT(*)                        AS loan_count,
    ROUND(SUM(upb_at_removal), 2)   AS removed_balance
FROM mortgage_typed_fe_v
WHERE zero_balance_code IS NOT NULL
GROUP BY zero_balance_code
ORDER BY loan_count DESC;


/* Vintage analysis — do newer origination cohorts perform differently from older ones? */
DROP TABLE IF EXISTS mortgage_vintage_summary;

CREATE TABLE mortgage_vintage_summary AS
SELECT
    TO_CHAR(
        DATE_TRUNC('quarter', TO_DATE(origination_date, 'MMYYYY')),
        'YYYY "Q"Q'
    )                                                       AS vintage,
    COUNT(*)                                                AS loan_count,
    SUM(delinquency_flag)                                   AS delinquent_loans,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate,
    ROUND(SUM(current_upb), 2)                              AS exposure
FROM mortgage_typed_fe_v
GROUP BY 1
ORDER BY MIN(DATE_TRUNC('quarter', TO_DATE(origination_date, 'MMYYYY')));


/* Modification exposure — does the elevated modification delinquency rate
   translate into a disproportionate concentration of delinquent exposure? */
DROP TABLE IF EXISTS mortgage_modification_exposure_summary;

CREATE TABLE mortgage_modification_exposure_summary AS
SELECT
    CASE
        WHEN modification_flag = 'Y' THEN 'Modified'
        ELSE 'Not Modified'
    END AS modification_status,
    COUNT(*)                                                AS loan_count,
    ROUND(SUM(current_upb), 2)                              AS exposure,
    ROUND(SUM(current_upb)::NUMERIC / SUM(SUM(current_upb)) OVER (), 4) AS exposure_share,
    ROUND(SUM(delinquency_flag)::NUMERIC / COUNT(*), 4)     AS delinquency_rate
FROM mortgage_typed_fe_v
GROUP BY 1
ORDER BY exposure DESC;


/* Reporting layer audit — confirm all summary tables were created successfully */
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename LIKE 'mortgage_%summary'
ORDER BY tablename;

SELECT COUNT(*) AS rows FROM mortgage_credit_score_summary;
SELECT COUNT(*) AS rows FROM mortgage_dti_summary;
SELECT COUNT(*) AS rows FROM mortgage_ltv_summary;
SELECT COUNT(*) AS rows FROM mortgage_risk_segment_summary;
SELECT COUNT(*) AS rows FROM mortgage_property_type_summary;
SELECT COUNT(*) AS rows FROM mortgage_occupancy_summary;
SELECT COUNT(*) AS rows FROM mortgage_loan_purpose_summary;
SELECT COUNT(*) AS rows FROM mortgage_state_risk_summary;
SELECT COUNT(*) AS rows FROM mortgage_modification_summary;
SELECT COUNT(*) AS rows FROM mortgage_delinquency_distribution_summary;
SELECT COUNT(*) AS rows FROM mortgage_zero_balance_summary;
SELECT COUNT(*) AS rows FROM mortgage_vintage_summary;
SELECT COUNT(*) AS rows FROM mortgage_modification_exposure_summary;


/* ============================================================
   STAGE 8: POWER BI FACT TABLE — LATEST-SNAPSHOT MODEL

   Produces one record per loan, retaining only the most recent
   monthly observation for each unique loan_id.

   This eliminates double-counting of loan balances across
   reporting periods, which would otherwise inflate portfolio
   exposure and distort delinquency rate calculations.

   The ROW_NUMBER() window function partitions by loan_id and
   orders by monthly_reporting_period descending. Only records
   where rn = 1 (most recent observation) are retained.

   Categorical codes are decoded to readable labels here so
   that Power BI consumes human-readable values directly,
   avoiding the need for lookup tables in the data model.

   Output: ~1.92M unique loan records representing the
   current state of the portfolio.
   ============================================================ */

DROP TABLE IF EXISTS mortgage_powerbi_fact;

CREATE TABLE mortgage_powerbi_fact AS

WITH latest_snapshot AS (
    SELECT
        loan_id,
        monthly_reporting_period,
        origination_date,
        current_upb,
        delinquency_flag,
        delinquency_status,
        credit_score_band,
        risk_segment,
        ltv_band,
        dti_band,

        CASE property_type
            WHEN 'SF' THEN 'Single Family'
            WHEN 'CO' THEN 'Condominium'
            WHEN 'PU' THEN 'Planned Unit Development'
            WHEN 'MH' THEN 'Manufactured Housing'
            WHEN 'CP' THEN 'Cooperative'
            ELSE 'Unknown'
        END AS property_type,

        CASE occupancy_status
            WHEN 'P' THEN 'Primary Residence'
            WHEN 'S' THEN 'Second Home'
            WHEN 'I' THEN 'Investment Property'
            ELSE 'Unknown'
        END AS occupancy_status,

        CASE loan_purpose
            WHEN 'P' THEN 'Purchase'
            WHEN 'C' THEN 'Cash-Out Refinance'
            WHEN 'N' THEN 'No Cash-Out Refinance'
            ELSE 'Not Recorded'
        END AS loan_purpose,

        CASE
            WHEN modification_flag = 'Y' THEN 'Modified'
            ELSE 'Not Modified'
        END AS modification_status,

        CASE property_state
            WHEN 'AK' THEN 'Alaska'              WHEN 'AL' THEN 'Alabama'
            WHEN 'AR' THEN 'Arkansas'            WHEN 'AZ' THEN 'Arizona'
            WHEN 'CA' THEN 'California'          WHEN 'CO' THEN 'Colorado'
            WHEN 'CT' THEN 'Connecticut'         WHEN 'DC' THEN 'District of Columbia'
            WHEN 'DE' THEN 'Delaware'            WHEN 'FL' THEN 'Florida'
            WHEN 'GA' THEN 'Georgia'             WHEN 'GU' THEN 'Guam'
            WHEN 'HI' THEN 'Hawaii'              WHEN 'IA' THEN 'Iowa'
            WHEN 'ID' THEN 'Idaho'               WHEN 'IL' THEN 'Illinois'
            WHEN 'IN' THEN 'Indiana'             WHEN 'KS' THEN 'Kansas'
            WHEN 'KY' THEN 'Kentucky'            WHEN 'LA' THEN 'Louisiana'
            WHEN 'MA' THEN 'Massachusetts'       WHEN 'MD' THEN 'Maryland'
            WHEN 'ME' THEN 'Maine'               WHEN 'MI' THEN 'Michigan'
            WHEN 'MN' THEN 'Minnesota'           WHEN 'MO' THEN 'Missouri'
            WHEN 'MS' THEN 'Mississippi'         WHEN 'MT' THEN 'Montana'
            WHEN 'NC' THEN 'North Carolina'      WHEN 'ND' THEN 'North Dakota'
            WHEN 'NE' THEN 'Nebraska'            WHEN 'NH' THEN 'New Hampshire'
            WHEN 'NJ' THEN 'New Jersey'          WHEN 'NM' THEN 'New Mexico'
            WHEN 'NV' THEN 'Nevada'              WHEN 'NY' THEN 'New York'
            WHEN 'OH' THEN 'Ohio'                WHEN 'OK' THEN 'Oklahoma'
            WHEN 'OR' THEN 'Oregon'              WHEN 'PA' THEN 'Pennsylvania'
            WHEN 'PR' THEN 'Puerto Rico'         WHEN 'RI' THEN 'Rhode Island'
            WHEN 'SC' THEN 'South Carolina'      WHEN 'SD' THEN 'South Dakota'
            WHEN 'TN' THEN 'Tennessee'           WHEN 'TX' THEN 'Texas'
            WHEN 'UT' THEN 'Utah'                WHEN 'VA' THEN 'Virginia'
            WHEN 'VI' THEN 'U.S. Virgin Islands' WHEN 'VT' THEN 'Vermont'
            WHEN 'WA' THEN 'Washington'          WHEN 'WI' THEN 'Wisconsin'
            WHEN 'WV' THEN 'West Virginia'       WHEN 'WY' THEN 'Wyoming'
            ELSE 'Unknown'
        END AS state_name,

        TO_CHAR(
            DATE_TRUNC('quarter', TO_DATE(origination_date, 'MMYYYY')),
            'YYYY "Q"Q'
        ) AS vintage,

        ROW_NUMBER() OVER (
            PARTITION BY loan_id
            ORDER BY TO_DATE(monthly_reporting_period, 'MMYYYY') DESC
        ) AS rn

    FROM mortgage_typed_fe_v
)

SELECT
    loan_id,
    monthly_reporting_period,
    vintage,
    current_upb,
    delinquency_flag,
    delinquency_status,
    credit_score_band,
    risk_segment,
    ltv_band,
    dti_band,
    property_type,
    occupancy_status,
    loan_purpose,
    modification_status,
    state_name

FROM latest_snapshot
WHERE rn = 1;

SELECT COUNT(*) AS unique_loans FROM mortgage_powerbi_fact;
-- Result: ~1,920,000 unique loans
