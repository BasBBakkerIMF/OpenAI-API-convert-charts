# Figure 4: LA5: Drivers of Change in Growth, 2026 (waterfall chart)
source("chart_style.R")

stem <- "fig-4-0"

colours <- c("#78C51C", "#78C51C", "#E1251B", "#B6B7B8", "#5B2A73")
labels <- c("Terms of\ntrade", "Financial\nconditions", "Uncertainty",
            "Residual", "Change in\ngrowth, 2026\nvs. 2025")

# In Excel the waterfall is a stacked column chart: an invisible "Lower band"
# lifts each visible "Upper band" bar to the right height.
plot_data <- read_chart_data(stem) |>
  mutate(position = row_number())

chart <- ggplot(plot_data) +
  geom_rect(aes(xmin = position - 0.5, xmax = position + 0.5,
                ymin = `Lower band`, ymax = `Lower band` + `Upper band`),
            fill = colours) +
  scale_x_continuous(breaks = plot_data$position, labels = labels,
                     expand = expansion(0)) +
  scale_y_reo(0, 0.8, 0.2, labels = function(x) sprintf("%.1f", x)) +
  labs(
    title = "LA5: Drivers of Change in Growth, 2026",
    subtitle = "(Percent)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Ahir, H, N Bloom, and D Furceri (2022), “World Uncertainty\n",
      "Index”, NBER Working Paper; Haver Analytics; IMF, World Economic\n",
      "Outlook database; and IMF staff calculations.\n",
      "Note: Aggregate is purchasing-power-parity GDP-weighted average.\n",
      "Estimates are obtained from a local projection regression of growth on\n",
      "terms of trade, financial conditions, and uncertainty, controlling for US and\n",
      "China growth and inflation, and country- and year- fixed effects. For\n",
      "methodology and variables included in the financial conditions index, refer\n",
      "to the online annex of the October 2018 Global Financial Stability Report.\n",
      "LA5 = Latin America 5 (Brazil, Chile, Colombia, Mexico, Peru)."
    )
  ) +
  theme_reo(caption_size = 8.2)

save_chart(chart, stem)
