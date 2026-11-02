# Figure 15.1: Effect of 2025 US Tariffs on China on LAC Imports from China
source("chart_style.R")

stem <- "fig-15-1"

plot_data <- read_chart_data(stem) |>
  mutate(category = factor(category, levels = category))

chart <- ggplot(plot_data, aes(category, series_0)) +
  geom_col(width = 0.56, fill = "#5B2875") +
  scale_y_reo(0, 8, 2) +
  labs(
    title = "Effect of 2025 US Tariffs on China on LAC Imports\nfrom China",
    subtitle = "(Predicted change in imports from China; percent)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Arizala, Schauer, and Grittayaphong (forthcoming); and IMF staff\n",
      "calculations."
    )
  ) +
  theme_reo() +
  ticks_inward(0.10) +
  theme(axis.ticks.x = element_blank())

save_chart(chart, stem)
