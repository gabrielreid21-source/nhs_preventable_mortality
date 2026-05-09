# Methods

## Data sources

| Source | Dataset | Geography | Period | Access |
|--------|---------|-----------|--------|--------|
| NHS Fingertips | Preventable mortality under 75 (IndicatorID 93721, E03) | Districts & UAs (2020/21 boundaries, AreaTypeID 301) | 2011–2019 | fingertipsR package |
| MHCLG | Index of Multiple Deprivation 2019 — scores by LSOA | LSOA 2011, aggregated to district | 2019 | [gov.uk](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019) |
| ONS Census 2021 | Ethnic group by usual residents (TS021) | District | 2021 | [nomisweb.co.uk](https://www.nomisweb.co.uk) |

All three sources were joined on ONS area codes in PostgreSQL. The analytical table contains one row per district × sex category × time period.

---

## Exclusions

Two districts were excluded by design:

- **City of London (E09000001)** — a specially constructed administrative unit with a resident population of ~9,000 and a daytime population orders of magnitude larger. Area-level mortality rates are not comparable with standard districts.
- **Buckinghamshire (E06000060)** — created in April 2020 by merging four former districts. The 2020/21 boundary definition used by Fingertips does not correspond to any consistent geography across the 2011–2019 study period.

---

## Analytical decisions

**Three-year rolling averages.** Single-year mortality counts at district level are small and noisy. Three-year rolling averages (e.g. 2011–13, 2012–14) reduce statistical noise while preserving temporal variation. The Fingertips extract supplies these pre-computed.

**Time period: 2011–2019.** The 2020 onwards period is excluded for two reasons: the statistical discontinuity introduced by Covid-19 mortality, and the 2019 ONS revision to the preventable mortality definition which breaks comparability with earlier years.

**IMD 2019 aggregation.** LSOA-level IMD scores were aggregated to district level using an unweighted mean. Population-weighted aggregation would be preferable but requires LSOA population denominators not included in this analysis. The unweighted approach is an approximation; MHCLG's own district-level IMD scores use a population-weighted rank-based method and are used where available as a consistency check.

**Ethnic minority composition.** Derived from the 2021 Census as the percentage of usual residents not identifying as White British. This is an area-level characteristic, not an individual-level attribute. All associations involving this variable are ecological.

**Sex categories.** The Fingertips indicator reports Male, Female, and Persons (combined). Regression models use Male and Female only. Persons is used for district-level averages and factor analysis to avoid double-counting.

**Suppressed values.** Fingertips suppresses counts below a disclosure threshold, returning Value = 0. These rows are excluded from all analyses with `WHERE Value != 0`.

---

## Statistical methods

### Multivariate regression

Four OLS models estimated on the full district × sex × year panel:

| Model | Predictors |
|-------|-----------|
| M1 | IMD score only (v1 baseline, persons averaged) |
| M2 | IMD + % ethnic minority + Sex + Sex × ethnicity |
| M3 | M2 + year trend (centred on 2014) |
| M4 | M3 + year × Sex |

Year is entered as a continuous variable centred on 2014 (the midpoint of the study period), so the intercept corresponds to the 2014 estimate. The year × Sex interaction in M4 tests whether the gender gap in preventable mortality changed over time.

Standard errors are not clustered in these models. Within-district correlation across years means standard errors may be slightly underestimated; this is a known limitation of the panel OLS approach used here.

### Principal component analysis

Two PCAs are run:

**Temporal trajectory PCA.** Districts are observations; the seven annual time points (2011–2017 start years) are variables. Persons-only mortality rates, complete cases only. Variables are standardised (mean 0, SD 1) before PCA. PC1 is expected to capture overall mortality level; PC2 the direction of change over the period.

**IMD domain PCA.** Districts are observations; the seven IMD domain scores (income, employment, education, health, crime, housing, living environment) aggregated from LSOA level are variables. Variables are standardised before PCA. Components with eigenvalue > 1 and cumulative variance ≥ 60% are retained and interpreted.

### Formal outlier testing

Studentised residuals and Cook's distance are computed from a district-level OLS model regressing average mortality (Persons) on IMD score and ethnic minority composition. Thresholds:

- **Outlier:** |studentised residual| > 2
- **High influence:** Cook's distance > 4/n

This replaces the v1 approach of flagging districts with absolute residuals greater than 25 rate points, which was not formally calibrated to the model's variance.

---

## Software

| Tool | Version | Purpose |
|------|---------|---------|
| R | 4.6.0 | Data cleaning, analysis, visualisation, report |
| PostgreSQL | — | Relational database, joins, views |
| Tableau Public | — | Interactive dashboard |
| fingertipsR | CRAN | NHS Fingertips API extraction |
| readxl | CRAN | IMD domain data ingestion |
| ggplot2 | CRAN | All charts |
| ggrepel | CRAN | Non-overlapping chart labels |
| broom | CRAN | Model tidy output |
| dplyr / tidyr | CRAN | Data manipulation |
| knitr | CRAN | Report rendering |
