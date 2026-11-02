# Figure 3.2: Commodity Prices
source("chart_style.R")

stem <- "fig-3-2"

conflict <- as.Date("2026-03-01")
date_range <- as.Date(c("2025-01-01", "2026-09-30"))

colours <- c(Oil = "#0065A0", Copper = "#00A6B2", `Iron ore` = "#C55A11",
             Soybeans = "#7F7F7F", Coffee = "#5DADE2",
             `Gold (right scale)` = "#FFA500")
widths <- c(1.05, rep(0.58, 5))   # oil is drawn thicker

# Gold is on the right-hand scale (100-220), which is the left-hand scale
# (70-190) plus 30; it is drawn on the left-hand scale minus 30.
plot_data <- read_chart_data(stem) |>
  mutate(date = as.Date(category)) |>
  filter(date >= date_range[1], date <= date_range[2]) |>
  pivot_longer(all_of(names(colours)), names_to = "series") |>
  mutate(series = factor(series, levels = rev(names(colours))),
         value = if_else(series == "Gold (right scale)", value - 30, value))

chart <- ggplot(plot_data, aes(date, value, colour = series, linewidth = series)) +
  geom_hline(yintercept = 100, linewidth = 0.35) +
  geom_line(lineend = "round", linejoin = "round", na.rm = TRUE) +
  geom_vline(xintercept = conflict, linewidth = 0.5, linetype = "dotted") +
  annotate("text", x = conflict - 8, y = 73, label = "Middle East conflict",
           family = "Arial", fontface = "italic", size = 3.4, hjust = 1) +
  scale_colour_manual(values = colours, breaks = names(colours)) +
  scale_linewidth_manual(values = setNames(widths, names(colours)),
                         breaks = names(colours)) +
  scale_x_date(limits = date_range, date_breaks = "4 months",
               date_labels = "%b-%y", expand = expansion(0)) +
  scale_y_reo(70, 190, 30,
              sec.axis = right_axis(1, shift = -30, breaks = seq(100, 220, 30))) +
  labs(
    title = "Commodity Prices",
    subtitle = "(Index: January 1, 2025 = 100)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Bloomberg Finance L.P.; and IMF staff calculations.\n",
      "Note: Oil is the average petroleum spot price. Copper is from the London\n",
      "Metal Exchange. Iron ore is Shanghai SteelHome E-Commerce.\n",
      "Soybeans is from the Chicago Board of Trade. Coffee refers to the\n",
      "international coffee composite indicator price."
    )
  ) +
  theme_reo(title_size = 13.5, caption_size = 8.25) +
  vertical_x_labels() +
  theme(axis.line.x = element_blank(), axis.ticks.x = element_blank(),
        legend.text = element_text(size = 8.6)) +
  legend_at(0.01, 1)

save_chart(chart, stem)
