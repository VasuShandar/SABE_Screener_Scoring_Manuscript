# SABE Screener Scoring

SAS code for developing and validating a scoring algorithm for the **¿SABE Lo Que Come?** (SABE) dietary screener — a Spanish-language, culturally adapted version of the Penn Healthy Diet (PHD) screener — using NHANES dietary recall data from Hispanic/Latino adults.

This repository accompanies the manuscript:

> **Development and Scoring of a Diet Quality Screener for Hispanic/Latino Adults Using National Health and Nutrition Examination Survey Data: The ¿SABE Lo Que Come? Tool**
> Pichardo MS, Shandar V, Quinn R, McReynolds V, Townsend Creasy K, Wu GD, Compher C.
> University of Pennsylvania.

## What this code does

Using NHANES 2017–2018 (development sample, N = 1,126) and NHANES 2015–2016 (validation sample, N = 1,633) dietary recall data from self-identified Hispanic/Latino adults, the script:

1. Simulates responses to the 24 SABE screener items (18 continuous food-group items + 6 yes/no behavioral items) from FPED dietary recall variables.
2. Computes reference dietary quality indices: HEI-2020 (pre-calculated in the analytic file) and AHEI-2010 (calculated per Chiuve et al. 2012).
3. Builds two SABE scoring algorithms:
   - **Simple algorithm** — sum of 9 forward-scored + 3 reverse-scored items, range 0–60.
   - **Regression-weighted algorithm** — OLS regression of HEI-2020 total score on all 24 items, coefficients applied as weights.
4. Validates both algorithms against HEI-2020 and AHEI-2010 in both NHANES cycles via Spearman correlation.
5. Produces every table and figure in the manuscript and its supplement.

## Files

| File | Description |
|---|---|
| `sabe_screener_scoring_FINAL.sas` | Complete SAS analysis pipeline: data prep, scoring, statistics, and CSV exports. Run top to bottom. |
| `figures_all.R` | Renders all four R-based figures — Figure 2 & 4 (scatterplots) and Figure 3 & 5 (heatmaps) — from the CSVs the SAS script exports. |

## Requirements

- SAS Viya Workbench (analysis was run on Version 2026.04, SAS Institute, Cary, NC).
- NHANES 2017–2018 and 2015–2016 dietary recall + demographic data, pre-merged into flat CSV exports with HEI-2020 total/component scores already calculated (via the NCI HEI scoring macro) and FPED food-group variables attached. **Raw NHANES data is not included in this repository** — it must be obtained from the [CDC NHANES website](https://www.cdc.gov/nchs/nhanes/) and processed into the expected input format (see *Expected input variables* below).
- R with `ggplot2`, `tidyr`, and `dplyr` (run separately, e.g. via Google Colab) to render Figures 2–5 from the CSVs this script exports — `figures_all.R` (included) covers all four.

## How to run

1. Update the two `libname` paths and the `%let outpath` / `%let figpath` macro variables at the top of the script to match your environment.
2. Place `NHANES_1718_export.csv` and `NHANES_1516_export.csv` in the `raw_data` folder referenced by `libname rawdata`.
3. Run the script top to bottom in SAS Viya Workbench. It is **not** designed to be run in isolated chunks — later sections (e.g., regression models, sensitivity analysis) depend on datasets built earlier in the script.
4. Outputs:
   - Printed tables (survey means, frequencies, correlations, regression models) go to the SAS results/log viewer.
   - Figures 2–5 are **not** rendered by the SAS script — it exports the underlying data as CSVs to `<outpath>/`:
     - `scatter_data.csv` → Figures 2 and 4
     - `corr_hei_1718.csv`, `corr_hei_1516.csv` → Figure 3
     - `corr_ahei_1718.csv`, `corr_ahei_1516.csv` → Figure 5
   - Download these CSVs and run `figures_all.R`, which renders all four (paths assume Google Colab's `/content/` — update if running elsewhere).

### Expected input variables

Each input CSV (`NHANES_1718_export.csv`, `NHANES_1516_export.csv`) is expected to contain, at minimum: NHANES demographic/survey-design variables (`RIDAGEYR`, `RIDRETH3`, `RIAGENDR`, `DMDEDUC2`, `INDFMPIR`, `BMXBMI`, `WTDRD1`, `SDMVSTRA`, `SDMVPSU`), FPED food-group variables (`F_JUICE`, `F_OTHER`, `F_TOTAL`, `V_DRKGR`, `V_REDOR_OTHER`, `V_REDOR_TOMATO`, `V_TOTAL`, `V_STARCHY_TOTAL`, `G_WHOLE`, `G_REFINED`, `D_MILK`, `D_YOGURT`, `D_CHEESE`, `D_TOTAL`, `PF_EGGS`, `PF_POULT`, `PF_NUTSDS`, `PF_MEAT`, `PF_CUREDMEAT`, `PF_SEAFD_HI`, `PF_SEAFD_LOW`, `PF_SOY`, `PF_LEGUMES`), NHANES dietary behavior/food-category flags (`fcat_*` variables, `DBD900_daily`, `ww_sweetbev_n`, `ww_Savory_n`, `ww_dessert_n`, `ww_bakery_n`), nutrient totals (`DR1TKCAL`, `DR1TSODI`, `DR1TPFAT`, `DR1TP205`, `DR1TP226`, `ADD_SUGARS`, `A_DRINKS`), and pre-calculated HEI-2020 total/component scores (`HEI2015_TOTAL_SCORE`, `HEI2015C1_TOTALVEG` through `HEI2015C13_ADDSUG` — note these retain the `HEI2015` naming convention from the NCI SAS scoring macro even though they contain HEI-**2020** values).

## Manuscript table/figure → code section map

| Manuscript item | Script section |
|---|---|
| Figure 1 (CONSORT flow diagram) | `FIGURE 1: CONSORT-STYLE FLOW DIAGRAM COUNTS` produces the sample-size numbers at each exclusion step. The diagram itself is built in BioRender from these counts — not generated by this script. |
| Table 1 (demographics) | `TABLE 1: DEMOGRAPHIC TABLE` |
| Figure 2 (SABE vs HEI-2020 scatter) | SAS exports `scatter_data.csv` (Figure 2 section); rendered by `figures_all.R` |
| Figure 3 (SABE items vs HEI-2020 heatmap) | SAS exports `corr_hei_1718.csv` / `corr_hei_1516.csv` (Figure 3 source data section); rendered by `figures_all.R` |
| Table 2 (SABE score vs HEI/AHEI, both cycles) | `TABLE 2: SABE TOTAL SCORE vs HEI-2020 / AHEI-2010` |
| Figure 4 (SABE vs AHEI-2010 scatter) | Same `scatter_data.csv` (AHEI_TOTAL column); rendered by `figures_all.R` |
| Figure 5 (SABE items vs AHEI-2010 heatmap) | SAS exports `corr_ahei_1718.csv` / `corr_ahei_1516.csv` (Figure 5 source data section); rendered by `figures_all.R` |
| Supplemental Table 1 (% of max score by ethnicity) | `SUPPLEMENTAL TABLE 1` |
| Supplemental Table 2 (item selection| `SUPPLEMENTAL TABLE 2` |
| Supplemental Table 3 (regression weights, HEI-2020) | `SUPPLEMENTAL TABLE 3` — also the model whose coefficients are hardcoded into `score_sabe_reg` |
| Supplemental Table 4 (regression weights, AHEI-2010) | `SUPPLEMENTAL TABLE 4` |
| Supplemental Table 5 (SABE items vs AHEI-2010 components) | `SUPPLEMENTAL TABLE 5` |



## Citation

If you use this code, please cite:

> Pichardo MS, Shandar V, Quinn R, McReynolds V, Townsend Creasy K, Wu GD, Compher C. Development and Scoring of a Diet Quality Screener for Hispanic/Latino Adults Using National Health and Nutrition Examination Survey Data: The ¿SABE Lo Que Come? Tool. Under Review. 2026.

## Contact

Vasuprada Shandar, BS — University of Pennsylvania, Perelman School of Medicine — vasuprada.shandar@pennmedicine.upenn.edu
