# Figure 5.1: Labor Productivity Gap against the United States
source("chart_style.R")

stem <- "fig-5-1"

colours <- c(LA7 = "#5B2A7F", CAPDR = "#CE5A0A", CARIB = "#009EAD",
             `CAN (right scale)` = "#666666")

# Canada (right-hand scale, -32 to -22) is drawn on the left-hand scale
# (-75 to -50) as 2.5 * value + 5.
plot_data <- read_chart_data(stem) |>
  mutate(`CAN (right scale)` = 2.5 * `CAN (right scale)` + 5) |>
  pivot_longer(-category, names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series)) +
  geom_line(linewidth = 0.85, lineend = "round") +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(2018.5, 2026.5), breaks = 2019:2026,
                     expand = expansion(0)) +
  scale_y_reo(-75, -50, 5, sec.axis = right_axis(2.5, shift = 5,
                                                 breaks = seq(-32, -22, 2))) +
  labs(
    title = "Labor Productivity Gap against the United States",
    subtitle = "(Percent of US labor productivity)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Labor productivity is measured as real GDP in PPP international\n",
      "dollars divided by total employment. The gap is measured as the\n",
      "difference in the level of labor productivity relative to the United States.\n",
      "Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay); PPP = purchasing power parity."
    )
  ) +
  theme_reo(caption_size = 8.4) +
  legend_at(0.99, 0.98, just = c(1, 1))

save_chart(chart, stem)
