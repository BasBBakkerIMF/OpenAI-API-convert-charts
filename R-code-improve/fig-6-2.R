# Figure 6.2: LAC: Oil Price Pass-through (distribution)
source("chart_style.R")

stem <- "fig-6-2"

purple <- "#5B2678"

data <- read_chart_data(stem) |>
  filter(!is.na(x), !is.na(y))

chart <- ggplot(mapping = aes(x, y)) +
  geom_line(data = filter(data, series == "LAC"), colour = purple,
            linewidth = 0.9, lineend = "round") +
  geom_line(data = filter(data, series == "LAC average"), colour = purple,
            linewidth = 0.55, linetype = "dashed") +
  # The density has no numeric y-axis: a vertical line at x = 0 with tick
  # marks takes its place.
  geom_vline(xintercept = 0, linewidth = 0.4) +
  annotate("segment", x = -0.035, xend = 0, y = seq(0.2, 1, 0.2),
           yend = seq(0.2, 1, 0.2), linewidth = 0.35) +
  scale_x_continuous(limits = c(-0.5, 2.5), breaks = seq(-0.5, 2.5, 0.5),
                     labels = function(x) sprintf("%.1f", x), expand = expansion(0)) +
  scale_y_continuous(breaks = NULL, expand = expansion(0)) +
  coord_cartesian(ylim = c(0, 1)) +
  labs(
    title = "LAC: Oil Price Pass-through",
    subtitle = "(Fraction)",
    x = NULL, y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Vertical dashed line refers to the median of the region. AE =\n",
      "advanced economies; Pass-through is calculated as the percentage\n",
      "change in domestic dollar retail diesel prices over the percentage change\n",
      "in international diesel prices (both measured in US dollars). Pass-through\n",
      "is trimmed at the 1 percent level. LAC = Latin America and the Caribbean."
    )
  ) +
  theme_reo() +
  ticks_inward(0.10) +
  theme(axis.line.y = element_blank())

save_chart(chart, stem)
