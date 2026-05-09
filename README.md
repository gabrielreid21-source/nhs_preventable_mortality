# NHS Preventable Mortality Under 75 — District-Level Variation in England

## Research question

Which English districts over or underperform their deprivation-predicted preventable mortality rate, and what area-level characteristics distinguish them?

## Key findings

- Deprivation is the strongest predictor of preventable mortality under 75 but does not explain all variation
- High ethnic minority districts — concentrated in London — consistently outperform their deprivation profile, consistent with health selection effects among economic migrants
- The gender gap in preventable mortality widens significantly with deprivation
- Ethnic minority composition predicts male mortality more consistently than female, pointing to gendered migration pathways
- IMD domain analysis shows income and employment deprivation load most strongly on preventable mortality; housing and environment are separable dimensions

## Tech stack

- **R** — data extraction via fingertipsR, cleaning, analysis, ggplot2 visualisation, R Markdown report
- **PostgreSQL** — relational database storing and joining all data sources
- **Tableau Public** — interactive dashboard
- **Git / GitHub** — version control and portfolio hosting

## Data sources

- NHS Fingertips — E03 Preventable mortality under 75 (IndicatorID 93721)
- ONS IMD 2019 — Index of Multiple Deprivation scores at LSOA level (MHCLG)
- ONS Census 2021 — Ethnic group composition by district (TS021)

## Folder structure

```
/R          — R Markdown report (analysis, charts, data quality, statistical methods)
/sql        — Unified PostgreSQL schema and queries (nhs_preventable_mortality.sql)
/docs       — METHODS.md (analytical decisions, model specifications, software)
/outputs    — Charts, Tableau workbook, case study
/data       — Raw and cleaned data (not committed — see below)
```

## Reproducing the analysis

1. Download raw data files:
   - NHS Fingertips: extracted via `fingertipsR` (IndicatorID 93721, AreaTypeID 301)
   - IMD 2019: File 5 (scores) from [gov.uk indices of deprivation](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019)
   - Census 2021 TS021: from [nomisweb.co.uk](https://www.nomisweb.co.uk)
2. Load CSVs into PostgreSQL using `sql/nhs_preventable_mortality.sql` — Section 1 creates the schema, Section 2 has the `\copy` commands
3. Run remaining queries in Section 3 to produce the analytical outputs
4. Knit `R/analysis_report.Rmd` in RStudio — all file paths are relative, so no path edits are needed if the folder structure is intact

See `docs/METHODS.md` for full analytical decisions, model specifications, and software versions.

## Time period

2011–2019. Three-year rolling averages used throughout. 2020 onwards excluded due to Covid discontinuity and 2019 ONS definition change.

## Exclusions

Two districts excluded by design — City of London (anomalous population size) and Buckinghamshire UA (boundary mismatch with study period). See `docs/METHODS.md` for detail.

## Limitations

- Analysis is ecological — all associations are at area level, not individual level
- Ethnic minority composition is an area characteristic, not an individual outcome measure
- Deprivation and ethnic minority composition are correlated, limiting independent interpretation
- IMD domain aggregation from LSOA to district uses unweighted means
- Standard errors in panel regression models are not clustered for within-district correlation
