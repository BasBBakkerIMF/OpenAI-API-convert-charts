# Figure 2.1: Financial Conditions Index
source("chart_style.R")

stem <- "fig-2-1"

colours <- c(LA5 = "#5B267A", `United States` = "#0066A6", Canada = "#404040")

plot_data <- read_chart_data(stem) %>%
  mutate(category = factor(category, levels = category)) %>%
  pivot_longer(-category, names_to = "series") %>%
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series, group = series)) +
  axis_line_at(0, x = 1:10, tick = 0.035) +
  geom_line(linewidth = 0.85) +
  scale_colour_manual(values = colours) +
  scale_x_discrete(expand = expansion(0)) +
  scale_y_reo(-1, 0.6, 0.2, labels = function(x) sprintf("%.1f", x)) +
  labs(
    title = "Financial Conditions Index",
    subtitle = "(0 = neutral; +/– = tight/loose)",
    x = NULL, y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: For methodology and variables included in the financial conditions\n",
      "index, refer to the online annex of the October 2018 Global Financial\n",
      "Stability Report. LA5 is purchasing-power-parity GDP-weighted averages.\n",
      "LA5 = Latin America 5 (Brazil, Chile, Colombia, Mexico, Peru)."
    )
  ) +
  theme_reo() +
  vertical_x_labels() +
  legend_at(0.05, 0.49, just = c(0, 0.5))

save_chart(chart, stem)
