# Figure 1.2: LAC: Growth Dispersion
source("chart_style.R")

stem <- "fig-1-2"

colours <- c("Average pairwise gap" = "#0067A9",
             "Average distance from median" = "#00A3AD")

# The Excel chart uses smoothed lines: interpolate each series with a spline.
plot_data <- read_chart_data(stem) %>%
  pivot_longer(-category, names_to = "series") %>%
  group_by(series) %>%
  reframe(as_tibble(spline(category, value, n = 500, method = "natural"))) %>%
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(x, y, colour = series)) +
  geom_line(linewidth = 0.85, lineend = "round") +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(2000, 2025), breaks = seq(2000, 2025, 5),
                     expand = expansion(0)) +
  scale_y_reo(0, 8, 2) +
  labs(
    title = "LAC: Growth Dispersion",
    subtitle = "(Year-over-year percentage change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Average pairwise gap is the average absolute difference in growth\n",
      "rates across all country pairs. Average distance from median is the\n",
      "average absolute deviation of each country's growth rate from the regional\n",
      "median. Sample excludes Guyana. LAC = Latin America and the\n",
      "Caribbean."
    )
  ) +
  theme_reo(caption_size = 8.2) +
  ticks_inward() +
  vertical_x_labels() +
  legend_at(0.05, 0.96)

save_chart(chart, stem)
