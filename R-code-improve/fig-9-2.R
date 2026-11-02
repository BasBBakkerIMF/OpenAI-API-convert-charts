# Figure 9.2: Total Factor Productivity Relative to the US
source("chart_style.R")

stem <- "fig-9-2"

colours <- c(LA7 = "#7030A0", `EM Asia` = "#00A6AD", `EM Europe` = "#C65911",
             Canada = "#404040")

plot_data <- read_chart_data(stem) |>
  pivot_longer(-category, names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series)) +
  geom_line(linewidth = 0.85, lineend = "round") +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(2000, 2031), breaks = seq(2000, 2030, 5),
                     expand = expansion(0)) +
  scale_y_reo(30, 110, 20) +
  guides(colour = guide_legend(nrow = 1)) +
  labs(
    title = "Total Factor Productivity Relative to the US",
    subtitle = "(Percent)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; Penn World Table 11.0\n",
      "database; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP- weighted averages.\n",
      "EM = emerging; EM Asia = India, Indonesia, Malaysia, Philippines,\n",
      "Thailand; EM Europe = Hungary, Poland, Romania, Serbia; LA7 = Latin\n",
      "America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    )
  ) +
  theme_reo() +
  vertical_x_labels() +
  legend_at(0.5, 0.985, just = c(0.5, 1))

save_chart(chart, stem)
