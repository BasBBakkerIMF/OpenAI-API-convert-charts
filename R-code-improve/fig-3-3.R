# Figure 3.3: Change in Commodity Terms of Trade
source("chart_style.R")

stem <- "fig-3-3"

colours <- c(`February 2026` = "#C9ADD5", `May 2026` = "#00689D")

plot_data <- read_chart_data(stem) |>
  mutate(category = factor(category, levels = category)) |>
  pivot_longer(-category, names_to = "series")

chart <- ggplot(plot_data, aes(category, value, fill = series)) +
  axis_line_at(0, x = 1:11, tick = -0.12) +
  geom_col(position = position_dodge(width = 0.76), width = 0.76) +
  scale_fill_manual(values = colours) +
  scale_x_discrete() +
  scale_y_reo(-2, 7, 1) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(
    title = "Change in Commodity Terms of Trade",
    subtitle = "(Percent change relative to January 2025)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, Commodity Terms of Trade database; and IMF staff\n",
      "calculations.\n",
      "Note: Commodity net export price index, individual commodities weighted\n",
      "by ratio of net exports to GDP."
    )
  ) +
  theme_reo() +
  ticks_inward() +
  theme(legend.key.width = unit(0.11, "in"), legend.key.height = unit(0.11, "in")) +
  legend_at(1, 0.97, just = c(1, 1))

save_chart(chart, stem)
