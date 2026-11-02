# Figure 1.1: Real GDP Growth
source("chart_style.R")

stem <- "fig-1-1"

colours <- c(USA = "#0069A6", CAN = "#444444", LA7 = "#682C82", CAPDR = "#C95A0C")

plot_data <- read_chart_data(stem) %>%
  mutate(category = factor(category, levels = category)) %>%
  pivot_longer(-category, names_to = "series") %>%
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series, group = series)) +
  geom_line(linewidth = 0.75, lineend = "round", na.rm = TRUE) +
  scale_colour_manual(values = colours) +
  scale_x_discrete(expand = expansion(add = 0.5)) +
  scale_y_reo(0, 5, 1) +
  guides(colour = guide_legend(ncol = 2, byrow = TRUE)) +
  labs(
    title = "Real GDP Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; IMF, World Economic Outlook database; and\n",
      "IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted average.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; LA7 =\n",
      "Latin America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n",
      "Uruguay)."
    )
  ) +
  theme_reo(title_size = 13.5) +
  ticks_inward(0.07) +
  vertical_x_labels() +
  legend_at(0.02, 0.025, just = c(0, 0))

save_chart(chart, stem)
