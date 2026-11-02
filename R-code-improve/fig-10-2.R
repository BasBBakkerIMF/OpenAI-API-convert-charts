# Figure 10.2: LA7: General Government Structural Primary Balance
source("chart_style.R")

stem <- "fig-10-2"

colours <- c(`October 2026 WEO` = "#5B267A", `April 2026 WEO` = "#8752AA",
             `October 2025 WEO` = "#AD7CC5")
linetypes <- setNames(c("solid", "52", "22"), names(colours))

plot_data <- read_chart_data(stem) |>
  pivot_longer(-category, names_to = "vintage") |>
  mutate(vintage = factor(vintage, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = vintage, linetype = vintage)) +
  axis_line_at(0, x = 2021:2031, tick = 0.04) +
  geom_line(linewidth = 0.85, na.rm = TRUE) +
  scale_colour_manual(values = colours) +
  scale_linetype_manual(values = linetypes) +
  scale_x_continuous(limits = c(2021, 2031), breaks = seq(2021, 2031, 2),
                     expand = expansion(0)) +
  scale_y_reo(-3, 0.5, 0.5, labels = function(x) sprintf("%.1f", x)) +
  labs(
    title = "LA7: General Government Structural Primary\nBalance",
    subtitle = "(Percent of potential GDP)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: LA7 is simple average. Chile refers to the central government’s\n",
      "structural non-mining primary balance. Colombia refers to the\n",
      "consolidated public sector's structural non-oil primary balance. Peru refers\n",
      "to the nonfinancial public sector’s structural primary balance. LA7 = Latin\n",
      "America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    )
  ) +
  theme_reo() +
  theme(legend.key.width = unit(0.56, "in")) +
  legend_at(1, 0.03, just = c(1, 0))

save_chart(chart, stem)
