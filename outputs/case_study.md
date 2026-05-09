# Case study: Service access, not deprivation, as the primary determinant of preventable mortality

**Gabriel Camacho-Reid · NHS Health Inequalities Analysis · 2011–2019**

---

## The measurement problem at the heart of NHS allocation

NHS resource allocation under Core20PLUS5 uses the Index of Multiple Deprivation to identify the most deprived 20% of the population. The assumption is that deprivation predicts health need, and that directing resource toward deprivation reduces preventable mortality. This analysis suggests the causal relationship is more complicated, and that the complication actually strengthens the case for continued targeted investment rather than weakening it.

The problem is one of causal identification. IMD is used in this and almost every comparable study as a predictor of mortality outcomes. But IMD is simultaneously the primary input variable for NHS funding allocation formulas. If NHS investment suppresses mortality in deprived areas (the stated goal of Core20PLUS5), then deprived areas that receive more NHS resource will show lower mortality than their deprivation score alone would predict. The observed correlation between IMD and mortality is not purely a relationship between poverty and death; it is partly a signal that NHS targeting is working.

This matters because it reframes what the outliers in this analysis are actually showing.

---

## What the outliers reveal

Formal outlier testing using studentised residuals identifies 23 districts whose mortality rate is poorly explained by deprivation and ethnic composition alone. These split into two distinct patterns.

**Negative outliers**, districts achieving lower mortality than their deprivation profile predicts, are concentrated in a cluster of high ethnic minority London boroughs: Enfield, Haringey, Brent, Barnet, Harrow, Newham, Redbridge, Ealing, and Kensington and Chelsea. These fall within North Central, North West, and North East London ICBs, which represent the highest NHS service density in England. Active health inequalities monitoring programmes are documented in these CCGs during the study period. NHS Health Check programmes were running in east London from 2009. Tower Hamlets CCG was the top-ranked CCG in England for diabetes, COPD, and CVD management in 2012/13.

Three mechanisms are consistent with this pattern: health selection among economic migrants (visa income thresholds select for healthier people), urban NHS service concentration (London has more NHS infrastructure per capita than other regions), and NHS investment effects (Core20PLUS5 predecessors directed funding to these areas). All three predict lower-than-expected mortality in deprived urban areas with high ethnic minority populations. None can be separated from the others at area level.

**Positive outliers**, districts with higher mortality than predicted, include Manchester, Tower Hamlets, Salford, and Blackpool. These require different explanations. Greater Manchester's health and social care was devolved to the Combined Authority in April 2016, mid-study. A Lancet study (2022) confirmed healthy life expectancy rose faster post-devolution, but within the 2011–2019 window the effect was time-limited. Tower Hamlets, despite being the top-ranked CCG in England for clinical quality management, still had higher-than-predicted mortality across the study period. This is the strongest evidence in the dataset that IMD understates structural deprivation in some urban areas: exceptional NHS quality could not overcome it.

---

## The causal chain

The standard account of deprivation and mortality runs: poverty → poor living conditions and health behaviours → preventable death. IMD predicts mortality because it captures material circumstances that cause illness.

The service access account runs differently:

**Deprivation → NHS targeting → funding allocation → service access and quality → mortality outcomes**

Under this account, IMD and mortality correlate not only because poverty causes death, but because the same indicator that measures poverty is the one used to direct the resource that prevents it. IMD is both a risk signal and a policy lever, and using it as an independent predictor of outcomes without accounting for the funding it generates produces a confounded model.

The migration dimension is downstream of this. Economic migrants concentrate in urban areas with work. Urban areas have higher NHS infrastructure density. Areas with high migrant populations therefore tend to be areas with high service access, regardless of individual migrant health status. The ethnic minority coefficient in the regression may be capturing a service access effect, a migration selection effect, or both simultaneously.

---

## What this means for Core20PLUS5

The tempting conclusion from this analysis (that high ethnic minority areas outperform their deprivation profile, so deprivation-based allocation may misdirect resource) is the wrong one.

If the lower-than-expected mortality in deprived London boroughs is partly produced by NHS investment in those areas, then the analysis is describing the framework working, not failing. Redirecting resource away from areas where observed mortality has been suppressed relative to deprivation would risk dismantling the mechanism that produces the suppression.

The more useful conclusion is additive. Core20PLUS5 deprivation targeting is justified and the evidence here is consistent with its effectiveness. What the analysis identifies is a set of refinements:

First, the allocation model would benefit from sex-stratified need assessments. The gender gap in preventable mortality widens with deprivation in ways that composite IMD scores do not capture. Men in the most deprived areas bear a disproportionate mortality burden that sex-neutral deprivation targeting does not fully address.

Second, IMD-only targeting cannot distinguish between areas where deprivation is the primary driver and areas where suppressed mortality reflects NHS investment. Making per-capita ICB spend an explicit variable in outcome models would allow this distinction to be made empirically rather than assumed.

Third, the outlier districts identified here, particularly Tower Hamlets, Manchester, and Knowsley, each have characteristics that generate specific testable hypotheses. A programme of secondary research mapping documented NHS interventions to district-level mortality trends would produce more actionable findings than the statistical pattern alone.

---

## Methods in brief

District-level preventable mortality data (NHS Fingertips, E03, IndicatorID 93721) was combined with ONS IMD 2019 domain scores and 2021 Census ethnic composition data for English districts. Analysis covers 2011–2019 using three-year rolling averages. Three districts were excluded: City of London and the Isles of Scilly (anomalous population sizes), and Buckinghamshire UA (no matching IMD records for its 2020/21 boundary). All data joined in PostgreSQL and analysed in R using multivariate OLS regression, principal component analysis, and formal outlier testing. Secondary research on ICB context conducted for all formally identified outlier districts.

Full methods, reproducible code, data documentation, and ICB context notes are available in the accompanying GitHub repository.

---

*Key references: Britteon et al. (2022), 'Effect of devolution on health in Greater Manchester', The Lancet Public Health. ONS Avoidable Mortality QMI. NHS England Core20PLUS5 framework. NHS Tower Hamlets CCG Annual Report 2020–21.*
