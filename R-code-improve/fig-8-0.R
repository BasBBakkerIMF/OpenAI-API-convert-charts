# Figure 8: Impact of El Niño on Inflation
source("chart_style.R")

stem <- "fig-8-0"

colours <- c(Andean = "#5A2875", CAPDR = "#C95716")

# In Excel, the confidence bands are drawn as stacked areas, built from four
# helper series (Dummy1-Dummy4). Adding them up gives the band edges.
plot_data <- read_chart_data(stem) |>
  mutate(
    across(Dummy1:Dummy4, as.numeric),
    andean_low = Dummy1,
    andean_high = Dummy1 + Dummy2,
    capdr_low = andean_high + Dummy3,
    capdr_high = capdr_low + Dummy4
  )

lines <- plot_data |>
  pivot_longer(all_of(names(colours)), names_to = "series")

chart <- ggplot(plot_data, aes(category)) +
  geom_ribbon(aes(ymin = andean_low, ymax = andean_high), fill = "#D8C8DE",
              alpha = 0.55) +
  geom_ribbon(aes(ymin = capdr_low, ymax = capdr_high), fill = "#F3C9AD",
              alpha = 0.55) +
  axis_line_at(0, x = 0:12, tick = -0.08) +
  geom_line(aes(y = value, colour = series), data = lines, linewidth = 0.9,
            lineend = "round") +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(-0.5, 12.5), breaks = 0:12, expand = expansion(0)) +
  scale_y_reo(-2, 5, 1) +
  labs(
    title = "Impact of El Niño on Inflation",
    subtitle = "(Percent; cumulative impact)",
    x = "Quarters", y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Shows the estimated impact of El Niño events on inflation using the\n",
      "local projection method in a cross-country panel. Shaded areas\n",
      "correspond to 10th/90th percentile confidence intervals. Andean =\n",
      "Colombia, Ecuador, Peru; CAPDR = Central America, Panama, and the\n",
      "Dominican Republic."
    )
  ) +
  theme_reo() +
  ticks_inward() +
  theme(legend.key.height = unit(0.2, "in")) +
  legend_at(0.05, 0.98)

save_chart(chart, stem)
