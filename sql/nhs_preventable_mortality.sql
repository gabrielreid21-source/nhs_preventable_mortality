-- =============================================================================
-- NHS Preventable Mortality Under 75 — District-Level Variation in England
-- PostgreSQL schema, data loading notes, and all analytical queries
-- Gabriel Camacho-Reid · 2011–2019 · IMD 2019 · Census 2021
-- =============================================================================


-- =============================================================================
-- SECTION 1: TABLE DEFINITIONS
-- =============================================================================

CREATE TABLE analytical_table (
    IndicatorID             INTEGER,
    IndicatorName           TEXT,
    ParentCode              TEXT,
    ParentName              TEXT,
    AreaCode                TEXT,
    AreaName                TEXT,
    AreaType                TEXT,
    Sex                     TEXT,
    Age                     TEXT,
    CategoryType            TEXT,
    Category                TEXT,
    Timeperiod              TEXT,
    Value                   NUMERIC,
    LowerCI95_0limit        NUMERIC,
    UpperCI95_0limit        NUMERIC,
    LowerCI99_8limit        NUMERIC,
    UpperCI99_8limit        NUMERIC,
    Count                   NUMERIC,
    Denominator             NUMERIC,
    Valuenote               TEXT,
    RecentTrend             TEXT,
    ComparedtoEngland       TEXT,
    ComparedtoRegions       TEXT,
    TimeperiodSortable      NUMERIC,
    Newdata                 TEXT,
    Comparedtogoal          TEXT,
    Timeperiodrange         TEXT,
    imd_score               NUMERIC,
    district_name           TEXT,
    total_population        INTEGER,
    ethnic_minority         INTEGER,
    pct_ethnic_minority     NUMERIC
);

CREATE TABLE imd_district (
    AreaCode                TEXT,
    imd_score               NUMERIC,
    district_name           TEXT
);

CREATE TABLE census_clean (
    AreaCode                TEXT,
    total_population        INTEGER,
    ethnic_minority         INTEGER,
    pct_ethnic_minority     NUMERIC
);

-- Type corrections applied after initial load
ALTER TABLE analytical_table
    ALTER COLUMN TimeperiodSortable TYPE NUMERIC,
    ALTER COLUMN Count              TYPE NUMERIC,
    ALTER COLUMN Denominator        TYPE NUMERIC;


-- =============================================================================
-- SECTION 2: DATA LOADING
-- =============================================================================
-- Load the three source CSVs using COPY or psql \copy.
-- Adjust file paths to match your local environment.
--
-- \copy analytical_table FROM '/path/to/analytical_table.csv' CSV HEADER;
-- \copy imd_district     FROM '/path/to/imd_district.csv'     CSV HEADER;
-- \copy census_clean     FROM '/path/to/census_clean.csv'     CSV HEADER;
--
-- Exclusions applied downstream in R and in query WHERE clauses:
--   E09000001  City of London  — anomalous population size (~9,000 residents)
--   E06000060  Buckinghamshire — specially constructed UA, boundary mismatch
-- =============================================================================


-- =============================================================================
-- SECTION 3: ANALYTICAL QUERIES
-- =============================================================================

-- 3.1  Row count and structure check
SELECT COUNT(*) FROM analytical_table;

SELECT AreaName, Timeperiod, Sex, Value, imd_score, pct_ethnic_minority
FROM analytical_table
LIMIT 10;


-- 3.2  District averages — all districts ranked by mortality (persons, descending)
SELECT
    AreaCode,
    AreaName,
    Sex,
    ROUND(AVG(Value)::numeric,              2) AS avg_mortality_rate,
    ROUND(AVG(imd_score)::numeric,          2) AS avg_imd_score,
    ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_pct_ethnic_minority
FROM analytical_table
WHERE Sex   = 'Persons'
  AND Value != 0
  AND AreaCode NOT IN ('E09000001', 'E06000060')
GROUP BY AreaCode, AreaName, Sex
ORDER BY avg_mortality_rate DESC;


-- 3.3  Ten lowest-mortality districts (persons)
SELECT
    AreaCode,
    AreaName,
    Sex,
    ROUND(AVG(Value)::numeric,              2) AS avg_mortality_rate,
    ROUND(AVG(imd_score)::numeric,          2) AS avg_imd_score,
    ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_pct_ethnic_minority
FROM analytical_table
WHERE Sex   = 'Persons'
  AND Value != 0
  AND AreaCode NOT IN ('E09000001', 'E06000060')
GROUP BY AreaCode, AreaName, Sex
ORDER BY avg_mortality_rate ASC
LIMIT 10;


-- 3.4  Gender split — male and female averages per district
--      Used for the gender gap and scatter analyses in R
SELECT
    AreaCode,
    AreaName,
    Sex,
    ROUND(AVG(Value)::numeric,              2) AS avg_mortality,
    ROUND(AVG(imd_score)::numeric,          2) AS avg_imd,
    ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_ethnicity
FROM analytical_table
WHERE Sex IN ('Male', 'Female')
  AND Value != 0
  AND AreaCode NOT IN ('E09000001', 'E06000060')
GROUP BY AreaCode, AreaName, Sex
ORDER BY AreaName, Sex;


-- =============================================================================
-- SECTION 4: VIEWS
-- =============================================================================

-- 4.1  Outlier analysis view
--      Flags districts as better/worse/as expected relative to IMD prediction.
--      Uses a ±1 SD residual threshold (informal v1 approach).
--      Formal outlier testing (studentised residuals, Cook's distance) is
--      handled in R using the regression model objects.
CREATE OR REPLACE VIEW outlier_analysis AS
WITH district_avg AS (
    SELECT
        AreaCode,
        AreaName,
        ROUND(AVG(Value)::numeric,              2) AS avg_mortality,
        ROUND(AVG(imd_score)::numeric,          2) AS avg_imd,
        ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_ethnicity
    FROM analytical_table
    WHERE Sex     = 'Persons'
      AND Value   != 0
      AND AreaCode NOT IN ('E09000001', 'E06000060')
    GROUP BY AreaCode, AreaName
),
england_avg AS (
    SELECT
        AVG(avg_mortality)              AS mean_mortality,
        STDDEV(avg_mortality)           AS sd_mortality,
        REGR_SLOPE(avg_mortality, avg_imd)      AS slope,
        REGR_INTERCEPT(avg_mortality, avg_imd)  AS intercept
    FROM district_avg
)
SELECT
    d.AreaCode,
    d.AreaName,
    d.avg_mortality,
    d.avg_imd,
    d.avg_ethnicity,
    ROUND((e.slope * d.avg_imd + e.intercept)::numeric,                    2) AS predicted_mortality,
    ROUND((d.avg_mortality - (e.slope * d.avg_imd + e.intercept))::numeric, 2) AS residual,
    CASE
        WHEN (d.avg_mortality - (e.slope * d.avg_imd + e.intercept)) >  e.sd_mortality THEN 'Worse than expected'
        WHEN (d.avg_mortality - (e.slope * d.avg_imd + e.intercept)) < -e.sd_mortality THEN 'Better than expected'
        ELSE 'As expected'
    END AS outlier_status
FROM district_avg d
CROSS JOIN england_avg e;


-- 4.2  High ethnic minority districts — outlier status
--      Districts with >40% ethnic minority population and their residuals
SELECT
    AreaName,
    avg_mortality,
    avg_imd,
    avg_ethnicity,
    residual,
    outlier_status
FROM outlier_analysis
WHERE avg_ethnicity > 40
ORDER BY residual ASC;
