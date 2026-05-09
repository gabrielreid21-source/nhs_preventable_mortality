CREATE VIEW outlier_analysis AS
WITH district_avg AS (
    SELECT 
        AreaCode,
        AreaName,
        ROUND(AVG(Value)::numeric, 2) AS avg_mortality,
        ROUND(AVG(imd_score)::numeric, 2) AS avg_imd,
        ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_ethnicity
    FROM analytical_table
    WHERE Sex = 'Persons'
    AND Value != 0
    GROUP BY AreaCode, AreaName
),
england_avg AS (
    SELECT 
        AVG(avg_mortality) AS mean_mortality,
        STDDEV(avg_mortality) AS sd_mortality,
        REGR_SLOPE(avg_mortality, avg_imd) AS slope,
        REGR_INTERCEPT(avg_mortality, avg_imd) AS intercept
    FROM district_avg
)
SELECT 
    d.AreaCode,
    d.AreaName,
    d.avg_mortality,
    d.avg_imd,
    d.avg_ethnicity,
    ROUND((e.slope * d.avg_imd + e.intercept)::numeric, 2) AS predicted_mortality,
    ROUND((d.avg_mortality - (e.slope * d.avg_imd + e.intercept))::numeric, 2) AS residual,
    CASE 
        WHEN (d.avg_mortality - (e.slope * d.avg_imd + e.intercept)) > e.sd_mortality THEN 'Worse than expected'
        WHEN (d.avg_mortality - (e.slope * d.avg_imd + e.intercept)) < -e.sd_mortality THEN 'Better than expected'
        ELSE 'As expected'
    END AS outlier_status
FROM district_avg d
CROSS JOIN england_avg e;

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
