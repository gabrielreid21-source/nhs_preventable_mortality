# Technical Reference — What Everything Does and Why

**Personal reference for Gabriel Camacho-Reid. Not part of the public report.**

This document walks through every tool, function, technique, and design decision in the project so that you can pick it up cold in the future and understand not just what each piece of code does, but why it was chosen.

---

## Table of contents

1. [R Markdown structure and rendering](#1-r-markdown-structure-and-rendering)
2. [Data loading and the setup chunk](#2-data-loading-and-the-setup-chunk)
3. [HTML styling in the executive summary and project overview](#3-html-styling-in-the-executive-summary-and-project-overview)
4. [Data quality assessment](#4-data-quality-assessment)
5. [Multivariate regression](#5-multivariate-regression)
6. [Factor analysis — temporal trajectories](#6-factor-analysis--temporal-trajectories)
7. [Factor analysis — IMD domain structure](#7-factor-analysis--imd-domain-structure)
8. [Formal outlier testing](#8-formal-outlier-testing)
9. [Original findings charts](#9-original-findings-charts)
10. [PostgreSQL and the unified SQL file](#10-postgresql-and-the-unified-sql-file)
11. [Repository structure and supporting files](#11-repository-structure-and-supporting-files)

---

## 1. R Markdown structure and rendering

**What it is.** The file `R/analysis_report.Rmd` is an R Markdown document. It's a plain text file that mixes Markdown (for prose) with R code chunks (for computation and charts). When you click Knit in RStudio (or press `Ctrl+Shift+K`), the `knitr` package executes every R chunk in order, captures the output, and `rmarkdown` converts the whole thing into an HTML file.

**YAML header** (lines 1–11):
```yaml
output:
  html_document:
    toc: true          # Generates a table of contents from ## headings
    toc_float: true    # TOC floats on the left as you scroll
    theme: flatly      # Bootstrap theme — controls fonts, colours, layout
    code_folding: hide # R code is hidden by default, reader can expand it
```

**Why these choices.** `toc_float` makes the document navigable like a webpage. `code_folding: hide` means a recruiter sees the report, not the code, but a technical reviewer can expand any chunk to inspect it. `flatly` is a clean, professional Bootstrap theme — its colour palette (`#2C3E50` dark blue-grey, `#18BC9C` teal) is what I matched in the executive summary and project overview styling.

**Key packages loaded in setup:**
- `dplyr` — the core data manipulation library. The `|>` pipe operator chains transformations left-to-right. Functions like `filter()`, `mutate()`, `group_by()`, `summarise()`, `select()`, `n_distinct()` all come from here.
- `ggplot2` — the charting library. Every chart in the report is built by layering `geom_` functions onto a `ggplot()` call.
- `ggrepel` — adds `geom_label_repel()` which places text labels on charts without overlapping each other. Used in every scatter plot.

---

## 2. Data loading and the setup chunk

```r
analytical_table <- readRDS("../data/cleaned/analytical_table.rds")
gender_split <- read.csv("../data/cleaned/query_result_gender.csv")
```

**`readRDS()` vs `read.csv()`:** RDS is R's native binary format — it preserves column types, factor levels, and is much faster to load than CSV. The analytical table uses RDS because it was saved from R originally. The gender_split file is CSV because it was exported from PostgreSQL.

**Relative paths:** `../data/cleaned/` means "go up one directory from where this Rmd lives (the `R/` folder), then into `data/cleaned/`." This makes the project portable — anyone who clones the repo and has the data files in the right place can knit without editing paths.

**The City of London filter:**
```r
analytical_table <- analytical_table |> filter(AreaCode != "E09000001")
```
This runs immediately on load, so every subsequent chunk works with the already-filtered dataset. Buckinghamshire (`E06000060`) was excluded earlier in the cleaning pipeline, so it's already absent from the RDS file.

---

## 3. HTML styling in the executive summary and project overview

**Why raw HTML in an R Markdown file.** R Markdown renders to HTML, so you can embed raw HTML and CSS directly. The executive summary and project overview use inline `style=""` attributes on `<div>` and `<p>` tags because:
- External CSS files would require additional configuration
- Inline styles are self-contained — they survive copy-pasting and don't depend on the theme
- They render identically in any browser

**The colour scheme:**
- `#2C3E50` (dark blue-grey) — from the flatly Bootstrap theme. Used for dark backgrounds and text.
- `#18BC9C` (teal) — flatly's accent colour. Used for labels, borders, tech stack pills.
- `#E74C3C` (red) — flatly's danger colour. Used for the business case border and SMART goal letters.
- `#9B59B6` (purple), `#3498DB` (blue) — additional flatly palette colours for visual variety.

**CSS grid layout:**
```html
<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:1.5rem;">
```
`grid-template-columns: 1fr 1fr 1fr` creates three equal-width columns. `1fr` means "one fraction of available space." `gap` controls the spacing between columns.

**The pill badges** (tech stack):
```html
<span style="background:#2C3E50;...;border-radius:99px;">R</span>
```
`border-radius: 99px` on a small element creates a fully rounded pill shape.

---

## 4. Data quality assessment

**`n_distinct()`** — from dplyr. Counts unique values. `n_distinct(analytical_table$AreaCode)` gives the number of distinct districts.

**`across()` and `all_of()`** — `across()` applies a function to multiple columns at once. `all_of(key_cols)` tells it to use the exact column names stored in the `key_cols` character vector. Combined with `~ sum(is.na(.))`, this counts NAs in each specified column in a single call.

**`pivot_longer()` and `pivot_wider()`** — from tidyr. These reshape data between "long" and "wide" formats:
- `pivot_longer()` stacks multiple columns into key-value pairs (used to turn the NA count columns into a two-column table of column name + count)
- `pivot_wider()` spreads rows into columns (used to make the suppressed-by-year table have one column per sex category)

**`recode()`** — replaces specific values with new labels. Used to make column names human-readable in the output tables (e.g. `"LowerCI95.0limit"` → `"Lower CI (95%)"`).

**`kable()`** — from knitr. The simplest way to render a data frame as a formatted HTML table in R Markdown. `col.names` overrides the column headers, `caption` adds a title.

**Why `sum()` wraps the suppressed value lookups:**
```r
sum(suppressed$suppressed_n[suppressed$Sex == "Male"])
```
If there are no rows where `Value == 0`, then `suppressed` is an empty data frame. Indexing into an empty data frame returns `integer(0)` (a zero-length vector), which would cause `data.frame()` to error because the Metric and Value vectors would have different lengths. `sum()` on an empty vector returns `0`, avoiding the crash.

**The conditional Table 4:**
```r
if (nrow(suppressed_year) > 0) { kable(...) } else { cat("...") }
```
If no suppressed values exist, printing an empty table with column headers but no rows would confuse a reader. The conditional prints an explanatory sentence instead.

---

## 5. Multivariate regression

### Preparing the panel

```r
panel <- analytical_table |>
  filter(Value != 0) |>
  mutate(
    year   = as.numeric(substr(as.character(TimeperiodSortable), 1, 4)),
    year_c = year - 2014
  )
```

**`substr()`** extracts characters from a string by position. `TimeperiodSortable` is a number like `20110000`. Converting to character and taking the first 4 characters gives `"2011"`, which is then made numeric.

**Centring the year variable** (`year_c = year - 2014`): In regression, centring a continuous variable on its midpoint means the intercept is interpretable as the predicted value at that midpoint (2014), not at year zero (which is meaningless). The coefficient on `year_c` represents the change in mortality per one-year shift. Values: -3, -2, -1, 0, 1, 2, 3.

**`panel_ms`** filters to Male and Female only. The Persons category is excluded from regression because it's the sum of Male + Female — including it would double-count and create perfect collinearity.

### The four models

**`lm()`** — R's built-in function for ordinary least squares (OLS) linear regression. `lm(y ~ x1 + x2)` regresses outcome `y` on predictors `x1` and `x2`.

**Model formulas and what they mean:**

| Formula element | What it does |
|----------------|-------------|
| `Value ~ imd_score` | Simple regression: mortality predicted by IMD alone |
| `+ pct_ethnic_minority` | Adds ethnicity as an additional predictor (multiple regression) |
| `+ Sex` | Adds a dummy variable for sex. R automatically codes `Female` = 0 (reference), `Male` = 1 |
| `+ pct_ethnic_minority:Sex` | Interaction term — asks: does the effect of ethnicity on mortality differ between men and women? The coefficient tells you how much *more* (or less) a one-unit increase in ethnicity affects mortality for males compared to females |
| `+ year_c` | Linear time trend — does mortality rise or fall over the study period? |
| `+ year_c:Sex` | Time × sex interaction — does the rate of change over time differ between men and women? This formally tests whether the gender gap widened or narrowed |

**Why M1 uses different data from M2–M4:** M1 replicates the v1 approach (district-level averages, Persons only). M2–M4 use the full panel. This means their R² values are not directly comparable — M1 explains variation *between districts*, while M2–M4 explain variation across districts, sexes, and years. The note in the report explains this. Within M2–M4, comparison is valid because they share the same dataset.

### Output tools

**`broom::tidy()`** — converts a model object into a clean data frame with one row per coefficient. Columns include `term`, `estimate`, `std.error`, `p.value`. With `conf.int = TRUE`, it adds `conf.low` and `conf.high` for the 95% confidence interval.

**`broom::glance()`** — returns a one-row summary of the whole model: R², adjusted R², AIC, BIC, F-statistic. Used to build the model comparison table.

**`nobs()`** — returns the number of observations used in a model.

**`AIC()`** — Akaike Information Criterion. A measure of model fit that penalises complexity. Lower is better. Unlike R², AIC is comparable across models with different numbers of predictors (but still requires the same dataset). Used to compare M2, M3, M4.

### The coefficient plot

```r
geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), ...)
geom_point(...)
```

**`geom_errorbarh()`** draws horizontal error bars — one per coefficient, spanning from the lower to upper confidence interval. **`geom_point()`** draws the point estimate at the centre. **`geom_vline(xintercept = 0)`** draws a vertical dashed line at zero — if a confidence interval crosses this line, the coefficient is not statistically significant at the 95% level.

**`reorder(term, estimate)`** — sorts the y-axis by coefficient size, so the most important predictors are visually prominent.

---

## 6. Factor analysis — temporal trajectories

### What PCA is and why it's used here

Principal Component Analysis (PCA) finds the directions of maximum variance in multivariate data. If you have 7 variables (mortality rates for 7 years), PCA creates 7 new variables (principal components) that are linear combinations of the originals, ordered by how much variance they explain. The first component (PC1) captures the most variance, PC2 the second most, and so on.

**Why PCA on mortality trajectories:** Each district has 7 mortality values (one per year). Rather than examining each year separately, PCA summarises the pattern. PC1 typically captures the *level* (high vs low mortality districts), while PC2 captures the *direction* (improving vs deteriorating over time). This reduces 7 dimensions to 2 that can be plotted.

### The code

```r
traj_wide <- panel |>
  filter(Sex == "Persons") |>
  select(AreaCode, AreaName, year, Value) |>
  pivot_wider(names_from = year, values_from = Value, names_prefix = "y")
```

**`pivot_wider()`** reshapes from long to wide: each district goes from 7 rows (one per year) to 1 row with 7 columns (`y2011`, `y2012`, ..., `y2017`). `names_prefix = "y"` adds a "y" before the numeric year so column names don't start with a number (which R handles awkwardly).

```r
traj_matrix <- traj_wide |> select(starts_with("y")) |> scale()
```

**`scale()`** standardises each column to mean 0 and standard deviation 1. This is essential before PCA because the components are determined by variance — if one column has larger absolute values, it would dominate the analysis for numerical reasons, not substantive ones. After scaling, each year contributes equally.

```r
pca_traj <- prcomp(traj_matrix, center = FALSE, scale. = FALSE)
```

**`prcomp()`** — R's PCA function. `center = FALSE, scale. = FALSE` because we already scaled manually. The result contains:
- `$sdev` — standard deviations of each component (square these for eigenvalues)
- `$rotation` — the loadings matrix (how much each original variable contributes to each component)
- `$x` — the scores (each district's position on each component)

**`filter(complete.cases(across(starts_with("y"))))`** — drops any district missing a value for any year. PCA cannot handle NAs. `complete.cases()` returns TRUE only for rows with no missing values.

### The scree plot

```r
var_exp = (pca_traj$sdev^2) / sum(pca_traj$sdev^2) * 100
```

The variance explained by each component is its eigenvalue (sdev²) divided by the total. The scree plot shows these as bars, with a cumulative line. You look for the "elbow" — the point where additional components add little. Typically 2–3 components are enough.

### The scores scatter

PC1 on the x-axis, PC2 on y-axis, each point is a district. Coloured by IMD score. If PC1 captures level and correlates strongly with IMD, the colour will grade smoothly from left to right — confirming that the main source of variance in mortality trajectories is deprivation. PC2 will show which districts are improving or deteriorating *relative to their level*.

---

## 7. Factor analysis — IMD domain structure

### Reading the raw xlsx

```r
library(readxl)
imd_domains_raw <- read_excel("../data/raw/direct IMD scores.xlsx", sheet = "IoD2019 Scores")
```

**`readxl::read_excel()`** reads Excel files without requiring Java or Excel installed (unlike some other R packages). `sheet = "IoD2019 Scores"` selects the specific worksheet.

### LSOA-to-district aggregation

```r
group_by(AreaCode) |>
summarise(across(c(income, employment, ...), \(x) mean(x, na.rm = TRUE)))
```

The raw data has one row per LSOA (~33,000 LSOAs in England). Each LSOA belongs to a district. Grouping by district code and taking the mean of each domain score gives a district-level average. The `\(x)` syntax is a lambda function (shorthand for `function(x)`), available in R 4.1+.

**Why unweighted mean:** Ideally you'd weight each LSOA's contribution by its population, but that requires LSOA population data we don't have. The unweighted mean is an approximation. Districts with many small LSOAs will be slightly overrepresented, but in practice the error is small.

**`inner_join()`** — joins two data frames, keeping only rows that match in both. Used to attach the district-level mortality and ethnicity averages to the IMD domain data. Districts that appear in one but not the other are dropped — this is why `inner` rather than `left` join is used; we only want districts with complete data for both mortality and IMD domains.

### What the PCA shows

The 7 IMD domains are: income, employment, education, health, crime, housing (barriers to housing and services), environment (living environment). PCA on these 7 variables asks: do these dimensions of deprivation move together, or do they form separate clusters?

**The loadings table** (`pca_imd$rotation`) shows how much each domain contributes to each component. If income, employment, and health all load strongly on PC1, that means they vary together across districts — districts deprived on one tend to be deprived on all three. This component would represent "material deprivation depth." If housing and environment load separately on PC2, they represent a different kind of deprivation that doesn't track with economic deprivation.

**Why this matters for the project:** If all 7 domains moved perfectly together, the composite IMD score would be a complete summary. But if they separate into components, the composite score hides meaningful variation — two districts with the same IMD score might have very different deprivation profiles, and the profile might matter for mortality risk.

---

## 8. Formal outlier testing

### The district-level model

```r
m_district <- lm(avg_mortality ~ avg_imd + avg_ethnicity, data = persons_avg)
```

This uses district-level averages (Persons), not the panel. Outlier testing is done at district level because the question is "which *districts* are anomalous," not which individual observations are.

### Studentised residuals

```r
stud_resid = rstudent(m_district)
```

**`rstudent()`** computes externally studentised residuals. A regular residual is just `observed - predicted`. A studentised residual divides that by an estimate of its standard deviation, *computed with that observation removed* (hence "externally" studentised). This means each residual is measured in units of "how many standard deviations away from prediction, if this point hadn't influenced the model." Values greater than 2 in absolute value are considered statistical outliers by convention (roughly analogous to 95% significance).

**Why not just use raw residuals:** The earlier analysis flagged districts with residuals > 25 rate points. But whether 25 points is "big" depends on how much variation the model leaves unexplained. In a model with tighter fit, 25 points might be extreme; in a noisier model, it might be typical. Studentised residuals are self-calibrating — they account for model variance.

### Cook's distance

```r
cooks_d = cooks.distance(m_district)
```

**`cooks.distance()`** measures how much all the regression coefficients change when a single observation is removed. A district with high Cook's distance isn't just poorly predicted — it's actively pulling the regression line toward itself. The threshold `4/n` is a standard rule of thumb.

**The distinction:** A district can be an outlier (badly predicted) without being influential (not changing the model). Or it can be influential without being an outlier (well-predicted but sitting in a leverage position that anchors the regression line). Districts flagged as both are the most important to investigate.

### The residual plot

```r
ggplot(outlier_df, aes(x = fitted, y = stud_resid, size = cooks_d, colour = avg_ethnicity))
```

Three dimensions of information on one chart:
- x-axis: fitted (predicted) mortality — where the model thinks this district should be
- y-axis: studentised residual — how far off the model was
- bubble size: Cook's distance — how influential the district is
- colour: ethnicity — to see whether the outliers cluster by ethnic composition

The dashed lines at ±2 mark the outlier threshold. Points outside the band are formal outliers.

---

## 9. Original findings charts

### Actual vs predicted (Figure 1)

```r
model <- lm(avg_mortality ~ avg_imd, data = district_avg)
district_avg$predicted <- predict(model, district_avg)
district_avg$residual <- district_avg$avg_mortality - district_avg$predicted
```

**`predict()`** — generates predicted values from a fitted model for each observation. Here it predicts what each district's mortality *should be* given its IMD score. The residual is the difference between actual and predicted — positive means worse than expected, negative means better.

**`geom_abline(slope = 1, intercept = 0)`** — draws the 45-degree line where actual equals predicted. Points below this line outperform their prediction.

### Gender gap bar chart (Figure 2)

```r
mutate(imd_decile = ntile(imd_score, 10))
```

**`ntile()`** — from dplyr. Divides a variable into n equal-sized groups. `ntile(imd_score, 10)` assigns each observation to a deprivation decile (1 = least deprived, 10 = most deprived). The chart then shows the male-minus-female mortality gap within each decile.

**`geom_col()`** vs `geom_bar()`: `geom_col()` uses values directly as bar heights (pre-computed gaps). `geom_bar()` would count rows, which isn't what we want here.

**`geom_smooth(method = "lm")`** — overlays a linear trend line to show the gradient visually.

### Gender scatter (Figure 3)

```r
geom_point(aes(size = avg_ethnicity), alpha = 0.5)
```

**`aes(size = ...)`** maps bubble size to a variable. Here, larger bubbles represent districts with higher ethnic minority populations. **`alpha = 0.5`** makes points semi-transparent so overlapping points are visible.

**`scale_color_manual()`** — manually assigns colours to categories rather than using the default palette. Pink for female, blue for male — conventional in UK health data visualisation.

---

## 10. PostgreSQL and the unified SQL file

### Why PostgreSQL was used

The three data sources (Fingertips, IMD, Census) needed to be joined on a shared key (`AreaCode`). While R can do joins with `dplyr::left_join()`, loading the data into a relational database makes the join explicit, repeatable, and queryable outside of R. For a portfolio project, it also demonstrates database skills.

### Key SQL concepts in the file

**`CREATE TABLE`** — defines the schema (column names and types). PostgreSQL needs to know the structure before data is loaded.

**`ALTER TABLE ... ALTER COLUMN ... TYPE`** — changes a column's data type after creation. Used because the initial load inferred `TimeperiodSortable` and `Count` as the wrong type.

**`\copy ... CSV HEADER`** — a psql command (not standard SQL) that loads a CSV file into a table. `HEADER` tells it the first row is column names, not data.

**CTEs (`WITH ... AS`):**
```sql
WITH district_avg AS (
    SELECT AreaCode, AVG(Value) AS avg_mortality ...
)
SELECT ... FROM district_avg
```
A Common Table Expression (CTE) is a named temporary result set. It's like creating a variable that holds a query result, which you can then reference in the main query. Makes complex queries readable.

**`REGR_SLOPE()` and `REGR_INTERCEPT()`** — PostgreSQL aggregate functions that compute simple linear regression coefficients directly in SQL. Used in the outlier view to calculate the predicted mortality line without R.

**`CROSS JOIN`** — combines every row from one table with every row from another. Since `england_avg` has exactly one row (the national averages), the cross join attaches those national values to every district row.

**`CREATE OR REPLACE VIEW`** — a saved query that behaves like a virtual table. The `outlier_analysis` view can be queried repeatedly without re-running the CTE logic. `OR REPLACE` means it overwrites any existing view with that name.

---

## 11. Repository structure and supporting files

### `.gitignore`

Lists file patterns that Git should not track. `data/raw/` and `data/cleaned/` exclude data files (too large for GitHub, and potentially sensitive). `*.xlsx` and `*.rds` catch any stray data files outside those folders. `.claude/` excludes the Claude Code configuration directory.

**The UTF-16 encoding fix:** The original `.gitignore` was saved in UTF-16 encoding (Windows Notepad does this sometimes). Git reads `.gitignore` as UTF-8, so the rules weren't being applied — meaning data files could have been accidentally committed. The file was rewritten in UTF-8.

### `docs/METHODS.md`

Standalone documentation of every analytical decision. Exists so that someone reading the GitHub repo can understand the methodology without knitting the Rmd. Covers data sources, exclusions, all six transformation decisions, model specifications, PCA approach, outlier testing thresholds, and software versions.

### `docs/ETL.md`

Documents the data pipeline from raw source to analytical output. Includes an ASCII data flow diagram showing the three source streams converging through R cleaning into PostgreSQL and then into the analysis. Lists every transformation decision with a one-sentence justification — these are the same decisions as METHODS.md but framed as pipeline documentation rather than analytical methods.

### `outputs/case_study.md`

A policy argument document. Structured differently from the report: it leads with the implication (IMD-based allocation may misidentify risk), presents evidence from the regression, factor analysis, and outlier testing, then makes recommendations framed in Core20PLUS5 language. Intended to be converted to PDF for job applications.

### `README.md`

The first thing anyone sees on GitHub. Contains the research question, key findings, tech stack, data sources, folder structure, reproduction instructions, and limitations. The reproduction steps reference the unified SQL file and note that file paths are relative.

### `sql/nhs_preventable_mortality.sql`

Replaces the four original SQL files (`query_createtables.sql`, `query_analytics.sql`, `query_outlier.sql`, `women query.sql`). Organised into four labelled sections: table definitions, data loading instructions, analytical queries, and views. Every query now includes `AreaCode NOT IN ('E09000001', 'E06000060')` to exclude the two anomalous districts consistently.

---

## Quick reference — R functions used

| Function | Package | What it does |
|----------|---------|-------------|
| `readRDS()` | base | Loads an R binary data file |
| `read.csv()` | base | Loads a CSV file into a data frame |
| `filter()` | dplyr | Keeps rows matching a condition |
| `mutate()` | dplyr | Adds or modifies columns |
| `select()` | dplyr | Picks specific columns |
| `group_by()` | dplyr | Groups data for subsequent summarise |
| `summarise()` | dplyr | Collapses groups into summary rows |
| `n_distinct()` | dplyr | Counts unique values |
| `ntile()` | dplyr | Divides into n equal-sized groups |
| `recode()` | dplyr | Replaces specific values with new labels |
| `across()` | dplyr | Applies a function to multiple columns |
| `bind_cols()` | dplyr | Binds columns side-by-side |
| `inner_join()` | dplyr | Joins keeping only matching rows |
| `left_join()` | dplyr | Joins keeping all left-side rows |
| `pivot_wider()` | tidyr | Reshapes long to wide |
| `pivot_longer()` | tidyr | Reshapes wide to long |
| `complete.cases()` | base | TRUE for rows with no NAs |
| `scale()` | base | Standardises to mean 0, SD 1 |
| `prcomp()` | base | Principal component analysis |
| `lm()` | base | Linear regression (OLS) |
| `summary()` | base | Model summary with R², F-stat, etc. |
| `predict()` | base | Predicted values from a model |
| `residuals()` | base | Raw residuals from a model |
| `rstudent()` | base | Externally studentised residuals |
| `cooks.distance()` | base | Cook's distance (influence measure) |
| `fitted()` | base | Fitted/predicted values from a model |
| `nobs()` | base | Number of observations in a model |
| `AIC()` | base | Akaike Information Criterion |
| `tidy()` | broom | Model coefficients as a data frame |
| `glance()` | broom | Model summary stats as one row |
| `kable()` | knitr | Renders a data frame as an HTML table |
| `read_excel()` | readxl | Reads Excel files |
| `rownames_to_column()` | tibble | Moves row names into a column |
| `ggplot()` | ggplot2 | Initialises a chart |
| `geom_point()` | ggplot2 | Scatter plot points |
| `geom_col()` | ggplot2 | Bar chart (pre-computed heights) |
| `geom_line()` | ggplot2 | Line connecting points |
| `geom_smooth()` | ggplot2 | Fitted trend line with optional CI band |
| `geom_abline()` | ggplot2 | Straight line from slope and intercept |
| `geom_hline()` / `geom_vline()` | ggplot2 | Horizontal / vertical reference lines |
| `geom_errorbarh()` | ggplot2 | Horizontal error bars |
| `geom_label_repel()` | ggrepel | Non-overlapping text labels |
| `scale_colour_gradient()` | ggplot2 | Continuous colour scale |
| `scale_color_manual()` | ggplot2 | Manually assigned colours |
| `scale_size_continuous()` | ggplot2 | Maps size to a continuous variable |
| `labs()` | ggplot2 | Sets title, subtitle, axis labels, caption |
| `theme_minimal()` | ggplot2 | Clean chart theme with minimal gridlines |

---

## Quick reference — statistical concepts

| Concept | What it means | Where it's used |
|---------|-------------|-----------------|
| OLS regression | Finds the line/plane that minimises the sum of squared distances between observed and predicted values | All `lm()` models |
| R² | Proportion of outcome variance explained by the model (0 to 1). Higher = better fit | Model comparison table |
| Adjusted R² | R² penalised for number of predictors. More honest when comparing models with different numbers of variables | Model comparison table |
| AIC | Model fit penalised for complexity. Lower = better. Comparable across models with same outcome and data | Model comparison table |
| Confidence interval (95%) | Range within which the true coefficient lies with 95% probability, assuming model assumptions hold | Coefficient table and plot |
| p-value | Probability of seeing a coefficient this large or larger if the true effect were zero. Below 0.05 = conventionally "significant" | Coefficient table |
| Interaction term | Tests whether the effect of one predictor differs across levels of another. `Sex:ethnicity` asks: does ethnicity affect mortality differently for men vs women? | M2–M4 models |
| Centring | Subtracting the mean (or midpoint) from a variable so the intercept is interpretable. Does not change the model's fit or the coefficient on the centred variable | Year centred on 2014 |
| PCA | Finds orthogonal axes of maximum variance in multivariate data. Reduces dimensionality while preserving the main patterns | Both factor analyses |
| Eigenvalue | Variance captured by a principal component. Components with eigenvalue > 1 explain more than a single original variable | Scree plots |
| Loadings | How much each original variable contributes to a component. High loading = strong association | IMD domain loadings table |
| Scores | Each observation's position on a component. Derived from multiplying the original data by the loadings | PCA scatter plots |
| Studentised residual | Residual divided by its estimated standard error (computed without that observation). Measured in standard deviations | Outlier testing |
| Cook's distance | How much all regression coefficients change when one observation is removed. Measures influence, not just prediction error | Outlier testing |
| Ecological analysis | Analysis at area level, not individual level. Associations between area characteristics do not necessarily reflect individual-level relationships | Entire project — stated limitation |
