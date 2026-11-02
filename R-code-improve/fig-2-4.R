# Figure 2.4: US Holdings of Foreign Bonds
source("chart_style.R")

stem <- "fig-2-4"

colours <- c(LA7 = "#5B267A", `EM Asia` = "#00A3AD", `EM Europe` = "#D05A0D")

plot_data <- read_chart_data(stem) %>%
  mutate(category = factor(category, levels = category)) %>%
  pivot_longer(-category, names_to = "series") %>%
  mutate(series = factor(series, levels = names(colours)))

quarters <- levels(plot_data$category)

chart <- ggplot(plot_data, aes(category, value, colour = series, group = series)) +
  geom_line(linewidth = 0.85, lineend = "round", linejoin = "round") +
  scale_colour_manual(values = colours) +
  scale_x_discrete(breaks = quarters[seq(1, length(quarters), 2)],
                   expand = expansion(0)) +
  scale_y_reo(0, 7, 1) +
  labs(
    title = "US Holdings of Foreign Bonds",
    subtitle = "(Percent share of total world)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; and IMF staff calculations.\n",
      "Note: LA7 excludes Paraguay due to data limitations. EM = emerging\n",
      "markets; EM Asia = India, Indonesia, Malaysia, Philippines, Thailand; EM\n",
      "Europe = Hungary, Poland, Romania, Serbia; LA7 = Latin America 7\n",
      "(Brazil, Chile, Colombia, Mexico, Paraguay, Peru)."
    )
  ) +
  theme_reo(base_size = 9.5, title_size = 13.5, subtitle_size = 11.5) +
  ticks_inward() +
  vertical_x_labels() +
  legend_at(0.065, 0.985)

save_chart(chart, stem)
