SELECT COUNT(*) FROM analytical_table;
SELECT AreaName, Timeperiod, Sex, Value, imd_score, pct_ethnic_minority 
FROM analytical_table 
LIMIT 10;
SELECT 
    AreaCode,
    AreaName,
    Sex,
    ROUND(AVG(Value)::numeric, 2) AS avg_mortality_rate,
    ROUND(AVG(imd_score)::numeric, 2) AS avg_imd_score,
    ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_pct_ethnic_minority
FROM analytical_table
WHERE Sex = 'Persons'
AND Value != 0
GROUP BY AreaCode, AreaName, Sex
ORDER BY avg_mortality_rate DESC;

SELECT 
    AreaCode,
    AreaName,
    Sex,
    ROUND(AVG(Value)::numeric, 2) AS avg_mortality_rate,
    ROUND(AVG(imd_score)::numeric, 2) AS avg_imd_score,
    ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_pct_ethnic_minority
FROM analytical_table
WHERE Sex = 'Persons'
AND Value != 0
GROUP BY AreaCode, AreaName, Sex
ORDER BY avg_mortality_rate ASC
LIMIT 10;