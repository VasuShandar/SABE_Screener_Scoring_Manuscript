# =============================================================
# SABE screener scoring - all R figures (Figures 2, 3, 4, 5)
# Reads the CSVs exported by sabe_screener_scoring_FINAL.sas.
# Run in Google Colab (paths assume /content/) or update the
# read.csv()/ggsave() paths below if running elsewhere.
# =============================================================

install.packages(c("ggplot2", "tidyr", "dplyr"))
library(ggplot2)
library(tidyr)
library(dplyr)


# =============================================================
# FIGURE 2 & FIGURE 4: SABE simple score vs HEI-2020 / AHEI-2010
# Input: scatter_data.csv (score_sabe, HEI2015_TOTAL_SCORE,
# AHEI_TOTAL - NHANES 2017-18 development sample, N = 1,126)
# =============================================================

df <- read.csv("/content/scatter_data.csv")

make_scatter <- function(data, yvar, rho, filename, ybreaks) {
  p <- ggplot(data, aes(x = score_sabe, y = .data[[yvar]])) +
    geom_point(color = "#4472C4", alpha = 0.4, size = 1.5) +
    geom_smooth(method = "lm", se = FALSE, color = "#333333", linewidth = 1) +
    annotate("text", x = min(data$score_sabe, na.rm=T) + 1,
             y = max(data[[yvar]], na.rm=T) * 0.95,
             label = paste0("\u03C1 = ", rho, ", p < 0.0001"),
             hjust = 0, size = 4.5, fontface = "bold", family = "Arial") +
    scale_y_continuous(breaks = ybreaks) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_blank(),
      axis.title = element_blank(),
      axis.text = element_text(color = "black", size = 10),
      panel.grid.minor = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
      plot.background = element_rect(fill = "white", color = NA)
    )
  ggsave(paste0("/content/", filename), plot = p, width = 5, height = 4.5, dpi = 300, bg = "white")
}

# Figure 2: SABE simple score vs HEI-2020 total score
make_scatter(df, "HEI2015_TOTAL_SCORE", "0.73", "scatter_HEI.png", seq(0, 100, 20))

# Figure 4: SABE simple score vs AHEI-2010 total score
# (restricted to participants with a valid AHEI-2010 score)
make_scatter(df[df$AHEI_TOTAL > 0,], "AHEI_TOTAL", "0.67", "scatter_AHEI.png", seq(0, 80, 20))

print("Done: scatter_HEI.png and scatter_AHEI.png")


# =============================================================
# Shared heatmap styling/order - used by both Figure 3 and Figure 5
# =============================================================

item_order <- c(
  "Screener Total Score",
  "Whole Fruit",
  "Whole Grain",
  "Nuts and Seeds",
  "Plant Protein",
  "Dark Green Veg",
  "Olive and Vegetable Oil",
  "Full Fat",
  "Seafood",
  "Red/Orange Veg",
  "Fruit Juice",
  "Milk",
  "Butter and Gravy",
  "Sweetened Beverages",
  "Cheese",
  "Refined Grain"
)

heatmap_theme <- theme_minimal(base_size = 11) +
  theme(
    plot.title = element_blank(),
    plot.subtitle = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8, color = "black"),
    axis.text.y = element_text(size = 9, color = "black"),
    strip.text = element_text(face = "bold", size = 11),
    strip.background = element_rect(fill = "white", color = "black", linewidth = 0.5),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
    panel.grid = element_blank(),
    panel.spacing = unit(0.3, "lines"),
    legend.position = "right",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 8),
    legend.key.height = unit(1.5, "cm"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

reshape_corr <- function(df) {
  df %>%
    pivot_longer(
      cols = c(starts_with("screen_"), starts_with("yn_"), "score_sabe"),
      names_to = "screener_item",
      values_to = "rho"
    ) %>%
    rename(component = X_NAME_) %>%
    select(component, screener_item, rho, cycle)
}

recode_screener_items <- function(x) {
  recode(x,
    "score_sabe"              = "Screener Total Score",
    "screen_f_other"          = "Whole Fruit",
    "screen_g_whole"          = "Whole Grain",
    "screen_PF_NUTSDS"        = "Nuts and Seeds",
    "screen_plant_prot"       = "Plant Protein",
    "screen_v_drkgr"          = "Dark Green Veg",
    "yn_screen_olive_veg_oil" = "Olive and Vegetable Oil",
    "yn_screen_full_fat"      = "Full Fat",
    "screen_seafood_3"        = "Seafood",
    "screen_v_redor_combined" = "Red/Orange Veg",
    "screen_f_juice"          = "Fruit Juice",
    "screen_d_milk"           = "Milk",
    "yn_screen_butter_gravy"  = "Butter and Gravy",
    "screen_ww_sweetbev_n"    = "Sweetened Beverages",
    "screen_d_cheese"         = "Cheese",
    "screen_g_refined"        = "Refined Grain"
  )
}


# =============================================================
# FIGURE 3: SABE items vs HEI-2020 components heatmap
# Input: corr_hei_1718.csv, corr_hei_1516.csv
# =============================================================

corr_hei_1718 <- read.csv("/content/corr_hei_1718.csv")
corr_hei_1516 <- read.csv("/content/corr_hei_1516.csv")

corr_hei_1718$cycle <- "NHANES cycle 2017-2018"
corr_hei_1516$cycle <- "NHANES cycle 2015-2016"

corr_hei_long <- bind_rows(reshape_corr(corr_hei_1718), reshape_corr(corr_hei_1516))

corr_hei_long <- corr_hei_long %>%
  mutate(
    screener_item = recode_screener_items(screener_item),
    component = recode(component,
      "HEI2015_TOTAL_SCORE"       = "Total Score",
      "HEI2015C9_FATTYACID"       = "Fatty Acid",
      "HEI2015C8_SEAPLANT_PROT"   = "Seafood/Plant Protein",
      "HEI2015C6_TOTALDAIRY"      = "Total Dairy",
      "HEI2015C7_TOTPROT"         = "Total Protein",
      "HEI2015C5_WHOLEGRAIN"      = "Whole Grain",
      "HEI2015C4_WHOLEFRUIT"      = "Whole Fruit",
      "HEI2015C3_TOTALFRUIT"      = "Total Fruit",
      "HEI2015C2_GREEN_AND_BEAN"  = "Greens and Beans",
      "HEI2015C1_TOTALVEG"        = "Total Vegetables",
      "HEI2015C13_ADDSUG"         = "Added Sugar*",
      "HEI2015C12_SFAT"           = "Saturated Fat*",
      "HEI2015C11_REFINEDGRAIN"   = "Refined Grain*",
      "HEI2015C10_SODIUM"         = "Sodium*"
    )
  )

hei_order <- c(
  "Total Score", "Fatty Acid", "Seafood/Plant Protein",
  "Total Dairy", "Total Protein", "Whole Grain",
  "Whole Fruit", "Total Fruit", "Greens and Beans",
  "Total Vegetables", "Added Sugar*", "Saturated Fat*",
  "Refined Grain*", "Sodium*"
)

corr_hei_long$screener_item <- factor(corr_hei_long$screener_item, levels = rev(item_order))
corr_hei_long$component     <- factor(corr_hei_long$component, levels = hei_order)
corr_hei_long$cycle         <- factor(corr_hei_long$cycle,
                                       levels = c("NHANES cycle 2015-2016",
                                                  "NHANES cycle 2017-2018"))

corr_hei_long <- corr_hei_long %>% filter(!is.na(screener_item), !is.na(component))

p_hei <- ggplot(corr_hei_long, aes(x = component, y = screener_item, fill = rho)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_gradient2(
    low = "#8B0000", mid = "white", high = "#006400", midpoint = 0,
    limits = c(-0.7, 1.0), breaks = c(-0.5, 0.0, 0.5, 1.0), name = expression(rho)
  ) +
  facet_wrap(~ cycle, ncol = 2) +
  heatmap_theme

ggsave("/content/SABE_heatmap_HEI_final.png", plot = p_hei,
       width = 13, height = 7, dpi = 300, bg = "white")

print("Done: SABE_heatmap_HEI_final.png")


# =============================================================
# FIGURE 5: SABE items vs AHEI-2010 components heatmap
# Input: corr_ahei_1718.csv, corr_ahei_1516.csv
# =============================================================

corr_ahei_1718 <- read.csv("/content/corr_ahei_1718.csv")
corr_ahei_1516 <- read.csv("/content/corr_ahei_1516.csv")

corr_ahei_1718$cycle <- "NHANES cycle 2017-2018"
corr_ahei_1516$cycle <- "NHANES cycle 2015-2016"

corr_ahei_long <- bind_rows(reshape_corr(corr_ahei_1718), reshape_corr(corr_ahei_1516))

corr_ahei_long <- corr_ahei_long %>%
  mutate(
    screener_item = recode_screener_items(screener_item),
    component = recode(component,
      "AHEI_TOTAL"      = "Total Score",
      "ahei_veg"        = "Vegetables",
      "ahei_fruit"      = "Whole Fruit",
      "ahei_wholegrain" = "Whole Grain",
      "ahei_ssb"        = "SSB + Juice",
      "ahei_nuts"       = "Nuts/Legumes",
      "ahei_meat"       = "Red Meat",
      "ahei_omega3"     = "Omega-3",
      "ahei_pufa"       = "PUFA",
      "ahei_sodium"     = "Sodium",
      "ahei_alcohol"    = "Alcohol"
    )
  )

ahei_comp_order <- c(
  "Total Score", "Vegetables", "Whole Fruit", "Whole Grain",
  "SSB + Juice", "Nuts/Legumes", "Red Meat",
  "Omega-3", "PUFA", "Sodium", "Alcohol"
)

corr_ahei_long$screener_item <- factor(corr_ahei_long$screener_item, levels = rev(item_order))
corr_ahei_long$component     <- factor(corr_ahei_long$component, levels = ahei_comp_order)
corr_ahei_long$cycle         <- factor(corr_ahei_long$cycle,
                                        levels = c("NHANES cycle 2015-2016",
                                                   "NHANES cycle 2017-2018"))

corr_ahei_long <- corr_ahei_long %>% filter(!is.na(screener_item), !is.na(component))

p_ahei <- ggplot(corr_ahei_long, aes(x = component, y = screener_item, fill = rho)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_gradient2(
    low = "#8B0000", mid = "white", high = "#006400", midpoint = 0,
    limits = c(-0.9, 1.0), breaks = c(-0.5, 0.0, 0.5, 1.0), name = expression(rho)
  ) +
  facet_wrap(~ cycle, ncol = 2) +
  heatmap_theme

ggsave("/content/SABE_heatmap_AHEI.png", plot = p_ahei,
       width = 10, height = 7, dpi = 300, bg = "white")

print("Done: SABE_heatmap_AHEI.png")

print("All figures complete: scatter_HEI.png, scatter_AHEI.png, SABE_heatmap_HEI_final.png, SABE_heatmap_AHEI.png")
