# Figure 7.1: Real GDP Growth (projections)
source("chart_style.R")

stem <- "fig-7-1"

colours <- c(USA = "#145A8D", CAN = "#4D4D4D", LA7 = "#66338A",
             CAPDR = "#C95A0A", `CARIB (excl. GUY/SUR)` = "#00A1A9",
             `CARIB (right scale)` = "#00A1A9")
linetypes <- setNames(c(rep("solid", 5), "dashed"), names(colours))

# CARIB including Guyana and Suriname (right-hand scale, 4-16) is drawn on
# the left-hand scale (0-6) as (value - 4) / 2.
plot_data <- read_chart_data(stem) |>
  mutate(`CARIB (right scale)` = (`CARIB (right scale)` - 4) / 2) |>
  pivot_longer(-category, names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series, linetype = series)) +
  geom_line(linewidth = 0.85) +
  scale_colour_manual(values = colours) +
  scale_linetype_manual(values = linetypes) +
  scale_x_continuous(limits = c(2021.5, 2028.5), breaks = 2022:2028,
                     expand = expansion(0)) +
  scale_y_reo(0, 6, 1, sec.axis = right_axis(1 / 2, shift = -2,
                                             breaks = seq(4, 16, 2))) +
  labs(
    title = "Real GDP Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted average.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay)."
    )
  ) +
  theme_reo() +
  theme(legend.key.width = unit(0.55, "in")) +
  legend_at(0.4, 1)

save_chart(chart, stem)
