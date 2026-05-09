# Case study: When deprivation stops predicting mortality

**Gabriel Camacho-Reid · NHS Health Inequalities Analysis · 2011–2019**

---

## The problem with deprivation as a risk signal

NHS resource allocation depends heavily on deprivation as a proxy for health need. The Index of Multiple Deprivation underpins Core20PLUS5 — NHS England's framework for targeting the most deprived 20% of the population — and feeds into ICB planning across preventable mortality, chronic disease management, and mental health. The assumption is straightforward: higher deprivation means higher need.

This analysis shows that assumption breaks down in a predictable and policy-relevant way.

Across 288 English districts between 2011 and 2019, IMD score explains a substantial share of variation in preventable mortality under 75 — but a multivariate regression controlling for ethnic composition and sex leaves a significant residual that clusters geographically. Districts with high ethnic minority populations, concentrated in London, consistently achieve lower preventable mortality than their deprivation score predicts. Harrow, Enfield, Newham, Barnet, and Brent all sit well below the regression line. The pattern is not noise — it is structural, persistent across the full nine-year period, and stronger for men than for women.

---

## What the data shows

**The deprivation-mortality relationship is real but incomplete.** IMD score alone explains roughly half the variance in district-level preventable mortality. Adding ethnic minority composition, sex, and their interaction raises model fit substantially and reveals that the relationship between deprivation and mortality operates differently across population types.

**High ethnic minority areas outperform their deprivation profile.** Formal outlier testing using studentised residuals identifies a cluster of London boroughs as statistically significant positive outliers — districts achieving lower mortality than the model predicts even after controlling for deprivation. The healthy migrant effect is the most plausible mechanism: economic migrants are positively selected for health through visa income thresholds and fitness requirements, meaning areas with high migrant populations contain people healthier than their area deprivation implies. Urban service concentration in London — higher density of NHS infrastructure and specialist services — is a complementary explanation that cannot be separated from migration effects at area level.

**The gender gap widens with deprivation — and ethnic composition affects men and women differently.** Men bear a disproportionately greater mortality burden in the most deprived areas, and the gap increases with each deprivation decile. Ethnic minority composition predicts male mortality more consistently than female, which is consistent with gendered migration pathways: male economic migrants face stronger health selection than women who more commonly enter through family reunion routes. The regression interaction term between sex and ethnic composition is statistically significant, formally confirming a pattern that was only visible descriptively in the earlier analysis.

**IMD domain structure reveals which dimensions of deprivation matter most.** A principal component analysis on the seven IMD domain scores shows that income and employment deprivation load most strongly on the first component — the one most tightly correlated with preventable mortality. Housing and environment load onto separate components, suggesting that not all forms of deprivation carry the same mortality risk. This has implications for how ICBs interpret composite deprivation scores: two districts with identical IMD scores but different domain profiles may warrant different interventions.

---

## What this means for resource allocation

Core20PLUS5 identifies the most deprived 20% of the population using IMD rank as the Core20 and allows ICBs to define PLUS groups — populations experiencing poorer access or outcomes who fall outside the Core20. This analysis provides empirical grounding for how PLUS groups should be operationalised.

High migration urban areas with significant ethnic minority populations may be systematically underrepresented in Core20 targeting because their observed mortality rates are suppressed relative to deprivation — not because their underlying need is lower, but because of health selection effects that are unlikely to persist across generations. Using IMD alone to allocate preventable mortality intervention in these areas risks directing resource toward a signal that overstates relative risk compared to deprivation-matched non-urban districts.

Conversely, the widening gender gap with deprivation suggests that male-targeted intervention in the most deprived areas is undersupported by allocation models that do not account for sex-specific mortality burdens.

---

## Methods in brief

District-level preventable mortality data (NHS Fingertips, E03, IndicatorID 93721) was combined with ONS IMD 2019 domain scores and 2021 Census ethnic composition data for 288 English districts. Analysis covers 2011–2019 using three-year rolling averages to reduce small-area statistical noise. Two specially constructed districts — City of London and Buckinghamshire UA — were excluded. All data was joined in PostgreSQL and analysed in R using multivariate OLS regression, principal component analysis, and formal outlier testing. Charts produced in ggplot2; interactive dashboard in Tableau.

Full methods, reproducible code, and data documentation are available in the accompanying GitHub repository.
