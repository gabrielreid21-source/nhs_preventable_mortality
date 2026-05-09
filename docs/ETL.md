# ETL Documentation

## Data flow

```
NHS Fingertips API               ONS IMD 2019 (MHCLG)              ONS Census 2021
     via fingertipsR          direct IMD scores.xlsx              filtered_census2021.csv
           |                  multi_indices_deprivation.xlsx             |
           |                           |                                |
           v                           v                                v
     E03_rolling.rds             (LSOA-level scores                census_clean.rds
           |                    and ranks/deciles)                      |
           |                           |                                |
           +---------------------------+--------------------------------+
                                       |
                                 R cleaning scripts
                                       |
                       +---------------+---------------+
                       |               |               |
                analytical_table   imd_district   census_clean
                     .rds/.csv       .rds/.csv      .rds/.csv
                       |               |               |
                       +-------+-------+
                               |
                          PostgreSQL
                        (joined on AreaCode)
                               |
                       analytical_table
                        (single joined table)
                               |
                     +---------+---------+
                     |                   |
              R analysis           Tableau Public
          (analysis_report.Rmd)    (dashboard.twb)
```

---

## Source inventory

| Dataset | Provider | Format | URL | Licence |
|---------|----------|--------|-----|---------|
| Preventable mortality under 75 (E03, IndicatorID 93721) | NHS Fingertips | API via fingertipsR | [fingertips.phe.org.uk](https://fingertips.phe.org.uk) | Open Government Licence v3 |
| Index of Multiple Deprivation 2019 (domain scores by LSOA) | MHCLG | xlsx | [gov.uk/indices-of-deprivation-2019](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019) | Open Government Licence v3 |
| Ethnic group by usual residents, TS021 | ONS Census 2021 | csv | [nomisweb.co.uk](https://www.nomisweb.co.uk) | Open Government Licence v3 |

---

## Transformation decisions

### 1. Boundary vintage: 2020/21 district definitions

Districts and unitary authorities were extracted using AreaTypeID 301 (Districts & UAs, 2020/21 boundaries). This is the most recent stable boundary set available in Fingertips for the study period. Earlier vintages (2019/20 and prior) would introduce boundary mismatches when joining to 2021 Census data, which uses 2021 local authority geographies that align closely with the 2020/21 definitions.

### 2. Rolling average period: three years

Three-year rolling averages (e.g. 2011–13, 2012–14) were used rather than single-year figures. District-level mortality counts are small, particularly in rural and low-population areas, making single-year rates statistically unreliable. Three-year rolling averages are the standard NHS Fingertips reporting format for this indicator and are supplied pre-computed in the extract.

### 3. Time window: 2011 to 2019

The analysis covers the seven rolling periods from 2011–13 to 2017–19. 2020 onwards is excluded for two reasons: the statistical discontinuity caused by Covid-19 mortality inflating preventable death counts, and the 2019 ONS revision to the preventable mortality definition which changes the cause-of-death list and breaks comparability with pre-2019 data.

### 4. District exclusions: City of London and Buckinghamshire

City of London (E09000001) was excluded because its resident population of approximately 9,000 produces mortality rates that are not comparable with standard districts; the denominator is anomalously small relative to the daytime population that uses local services. Buckinghamshire (E06000060) was excluded because it is a specially constructed unitary authority created in April 2020 by merging four former districts; the 2020/21 boundary definition used by Fingertips does not correspond to any consistent geography across the 2011–2019 study period.

### 5. IMD aggregation: unweighted mean from LSOA to district

IMD scores are published at LSOA level (approximately 1,500 residents per LSOA). These were aggregated to district level by taking the unweighted mean of all LSOA scores within each district boundary. Population-weighted aggregation would be methodologically preferable but requires LSOA-level population denominators not included in this pipeline. The MHCLG's own district-level IMD scores use a rank-based population-weighted method; where these are available they are used as a consistency check. The unweighted mean is an approximation that introduces small errors in districts with highly variable LSOA populations.

### 6. Ethnic minority definition: percentage not identifying as White British

Ethnic composition is expressed as the percentage of usual residents who did not identify as White British in the 2021 Census (TS021). This definition was chosen over broader White or non-White groupings because it is the most commonly used measure in NHS health inequalities research and aligns with the Core20PLUS5 PLUS population framing. It is an area-level characteristic: the analysis does not observe individual-level outcomes by ethnicity, and all associations involving this variable are ecological.

---

## Data quality notes

See `data_quality` section in `R/analysis_report.Rmd` for full coverage tables. Key points:

- **Suppressed values:** Fingertips returns `Value = 0` where counts fall below the disclosure threshold. These rows are excluded from all analyses with `WHERE Value != 0` in SQL and `filter(Value != 0)` in R.
- **Missing join keys:** IMD and Census data join to the Fingertips extract on ONS AreaCode. Any district present in Fingertips but absent from IMD or Census data would produce NA values in `imd_score` or `pct_ethnic_minority`. No such NAs were observed in the analytical dataset.
- **Census vintage mismatch:** Ethnic composition comes from the 2021 Census but the mortality data runs from 2011–2019. Population composition will have changed across the study period. The 2021 Census is used as the best available district-level ethnic composition estimate; a single static value is applied to all years for each district.

---

## Files produced

| File | Location | Description |
|------|----------|-------------|
| `analytical_table.rds` / `.csv` | `data/cleaned/` | Main joined dataset, one row per district × sex × time period |
| `imd_district.rds` / `.csv` | `data/cleaned/` | District-level IMD scores aggregated from LSOA |
| `census_clean.rds` / `.csv` | `data/cleaned/` | District-level ethnic composition from Census 2021 |
| `query_result_gender.csv` | `data/cleaned/` | Male/female averages per district, exported from PostgreSQL |
| `tableau_districts.csv` | `data/cleaned/` | District averages formatted for Tableau |

---

*Edit this document to add extraction dates, specific script names, and any pipeline steps not captured above.*
