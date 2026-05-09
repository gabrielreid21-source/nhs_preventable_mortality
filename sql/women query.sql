SELECT 
    AreaCode,
    AreaName,
    Sex,
    ROUND(AVG(Value)::numeric, 2) AS avg_mortality,
    ROUND(AVG(imd_score)::numeric, 2) AS avg_imd,
    ROUND(AVG(pct_ethnic_minority)::numeric, 2) AS avg_ethnicity
FROM analytical_table
WHERE Sex IN ('Male', 'Female')
AND Value != 0
GROUP BY AreaCode, AreaName, Sex
ORDER BY AreaName, Sex;