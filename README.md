\# NHS Preventable Mortality Under 75 — District-Level Variation in England



\## Research question

Which English districts over or underperform their deprivation-predicted preventable mortality rate, and what area-level characteristics distinguish them?



\## Key findings

\- Deprivation is the strongest predictor of preventable mortality under 75 but does not explain all variation

\- High ethnic minority districts — concentrated in London — consistently outperform their deprivation profile

\- The gender gap in preventable mortality widens significantly with deprivation

\- Ethnic minority composition predicts male mortality more consistently than female mortality



\## Tech stack

\- \*\*R\*\* — data extraction via fingertipsR, cleaning, analysis, ggplot2 visualisation, R Markdown report

\- \*\*PostgreSQL\*\* — relational database storing and joining all data sources

\- \*\*Tableau Public\*\* — interactive dashboard

\- \*\*Git/GitHub\*\* — version control and portfolio hosting



\## Data sources

\- NHS Fingertips — E03 Preventable mortality under 75 (IndicatorID 93721)

\- ONS IMD 2019 — Index of Multiple Deprivation scores at LSOA level

\- ONS Census 2021 — Ethnic group composition by district (TS021)



\## Folder structure

\- /R — analysis scripts and R Markdown report

\- /sql — PostgreSQL query files

\- /outputs — charts, knitted report, Tableau workbook

\- /data — raw and cleaned data (not committed — see below)



\## Reproducing the analysis

1\. Download raw data files following instructions in /data/README.md

2\. Run R/01\_load\_clean.R to prepare cleaned datasets

3\. Load CSVs into PostgreSQL using schema in sql/schema.sql

4\. Run remaining SQL queries in /sql

5\. Knit R/analysis\_report.Rmd to reproduce the report



\## Time period

2011–2019. Three-year rolling averages used throughout. 2020 onwards excluded due to Covid discontinuity and 2019 ONS definition change.



\## Limitations

See limitations section in the R Markdown report for full details.

