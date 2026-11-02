# Figure 1.2.3: CA4: Enforcement Impact on Remittance Growth
source("chart_style.R")

stem <- "fig-1-2-3"

# In Excel the confidence band is a stacked area: "ci_lo" plus "range".
plot_data <- read_chart_data(stem) %>%
  mutate(ci_hi = ci_lo + range)

chart <- ggplot(plot_data, aes(category)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "#FCE4D4", alpha = 0.9) +
  axis_line_at(0, x = setdiff(-6:6, 0), tick = 0.55) +
  geom_vline(xintercept = 0, linewidth = 0.65, linetype = "dotted") +
  geom_line(aes(y = coef), colour = "#C85C0A", linewidth = 1.05,
            lineend = "round", linejoin = "round") +
  scale_x_continuous(limits = c(-6, 6), breaks = -6:6, expand = expansion(0)) +
  scale_y_reo(-15, 15, 5) +
  labs(
    title = "CA4: Enforcement Impact on Remittance Growth",
    subtitle = "(Percentage points)",
    x = "Months relative to shock", y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Estimated response of remittance growth to changes in immigration\n",
      "enforcement based on panel local projections (Carare and others\n",
      "(forthcoming)). Regressions include country and time fixed effects and\n",
      "macroeconomic controls. Shaded area denotes 90 percent wild cluster\n",
      "bootstrap confidence intervals."
    )
  ) +
  theme_reo(title_size = 13.5) +
  ticks_inward(0.09)

save_chart(chart, stem)
