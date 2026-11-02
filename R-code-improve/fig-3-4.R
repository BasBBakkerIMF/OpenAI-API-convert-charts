# Figure 3.4: Overall and Trade Policy Uncertainties
source("chart_style.R")

stem <- "fig-3-4"

conflict <- as.Date("2026-03-01")
date_range <- as.Date(c("2021-01-01", "2026-08-31"))

colours <- c(WUI = "#00649D", TPU = "#D55E00", `USA (right scale)` = "#666666")

# The USA index (right-hand scale, 0-3) is drawn on the left-hand scale
# (0-14) multiplied by 14 / 3.
plot_data <- read_chart_data(stem) |>
  mutate(date = as.Date(category), `USA (right scale)` = `USA (right scale)` * 14 / 3) |>
  filter(date >= date_range[1], date <= date_range[2]) |>
  pivot_longer(all_of(names(colours)), names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(date, value, colour = series)) +
  geom_line(linewidth = 0.8, lineend = "round") +
  geom_vline(xintercept = conflict, linewidth = 0.35, linetype = "dotted") +
  annotate("text", x = conflict - 15, y = 1.25, label = "Middle East\nconflict",
           family = "Arial", fontface = "italic", size = 3.05, hjust = 1,
           vjust = 0, lineheight = 0.9) +
  scale_colour_manual(values = colours) +
  scale_x_date(limits = date_range, date_breaks = "6 months",
               date_labels = "%b-%y", expand = expansion(0)) +
  scale_y_reo(0, 14, 2, sec.axis = right_axis(14 / 3, breaks = seq(0, 3, 0.5),
                                               labels = function(x) sprintf("%.1f", x))) +
  labs(
    title = "Overall and Trade Policy Uncertainties",
    subtitle = "(Index)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Ahir, H, N Bloom, and D Furceri (2022), “World Uncertainty\n",
      "Index”, NBER Working Paper; Caldara and others (2020); and Haver\n",
      "Analytics.\n",
      "Note: The uncertainty measures are news- and media-outlets-based\n",
      "indices that quantify media attention to global news related to overall\n",
      "uncertainty (WUI) and trade policy uncertainty (TPU). Uncertainty index\n",
      "shown for the United States is from the WUI."
    )
  ) +
  theme_reo() +
  vertical_x_labels() +
  legend_at(0.03, 1)

save_chart(chart, stem)
