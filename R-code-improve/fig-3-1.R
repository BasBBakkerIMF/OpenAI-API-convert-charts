# Figure 3.1: Terms of Trade
source("chart_style.R")

stem <- "fig-3-1"

colours <- c(USA = "#0067A5", CAN = "#454545", LA7 = "#5C277E",
             CAPDR = "#D26717", CARIB = "#00A3A3")

plot_data <- read_chart_data(stem) |>
  pivot_longer(-category, names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series)) +
  axis_line_at(100, x = 2019:2026, tick = 0.45) +
  geom_line(linewidth = 0.8, lineend = "round", linejoin = "round") +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(2018.5, 2026.5), breaks = 2019:2026,
                     expand = expansion(0)) +
  scale_y_reo(90, 125, 5) +
  labs(
    title = "Terms of Trade",
    subtitle = "(Index: 2019 = 100)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay)."
    )
  ) +
  theme_reo(caption_size = 8.4) +
  theme(legend.text = element_text(size = 9.5)) +
  legend_at(0.035, 0.97)

save_chart(chart, stem)
