CREATE TABLE analytical_table (
    IndicatorID INTEGER,
    IndicatorName TEXT,
    ParentCode TEXT,
    ParentName TEXT,
    AreaCode TEXT,
    AreaName TEXT,
    AreaType TEXT,
    Sex TEXT,
    Age TEXT,
    CategoryType TEXT,
    Category TEXT,
    Timeperiod TEXT,
    Value NUMERIC,
    LowerCI95_0limit NUMERIC,
    UpperCI95_0limit NUMERIC,
    LowerCI99_8limit NUMERIC,
    UpperCI99_8limit NUMERIC,
    Count NUMERIC,
    Denominator NUMERIC,
    Valuenote TEXT,
    RecentTrend TEXT,
    ComparedtoEngland TEXT,
    ComparedtoRegions TEXT,
    TimeperiodSortable INTEGER,
    Newdata TEXT,
    Comparedtogoal TEXT,
    Timeperiodrange TEXT,
    imd_score NUMERIC,
    district_name TEXT,
    total_population INTEGER,
    ethnic_minority INTEGER,
    pct_ethnic_minority NUMERIC
);
CREATE TABLE imd_district (
    AreaCode TEXT,
    imd_score NUMERIC,
    district_name TEXT
);

CREATE TABLE census_clean (
    AreaCode TEXT,
    total_population INTEGER,
    ethnic_minority INTEGER,
    pct_ethnic_minority NUMERIC
);
ALTER TABLE analytical_table 
    ALTER COLUMN TimeperiodSortable TYPE NUMERIC,
    ALTER COLUMN Count TYPE NUMERIC,
    ALTER COLUMN Denominator TYPE NUMERIC;