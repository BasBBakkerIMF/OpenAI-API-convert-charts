# Figure 5.2: Real Exports Growth
source("chart_style.R")

stem <- "fig-5-2"

colours <- c(USA = "#0868A4", CAN = "#444444", LA7 = "#62317D",
             CAPDR = "#C75B0A", `World trade volume` = "#00A6A6")

plot_data <- read_chart_data(stem) |>
  mutate(category = factor(category, levels = category)) |>
  pivot_longer(-category, names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series, group = series)) +
  axis_line_at(0, x = 1:10, tick = 0.22) +
  geom_line(linewidth = 0.85, lineend = "round", na.rm = TRUE) +
  scale_colour_manual(values = colours) +
  scale_x_discrete(expand = expansion(add = 0.5)) +
  scale_y_reo(-6, 9, 3) +
  labs(
    title = "Real Exports Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: CPB Netherlands Bureau for Economic Policy Analysis; Haver\n",
      "Analytics; national authorities; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; LA7 =\n",
      "Latin America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n",
      "Uruguay)."
    )
  ) +
  theme_reo() +
  vertical_x_labels() +
  legend_at(0.04, 0.03, just = c(0, 0))

save_chart(chart, stem)
