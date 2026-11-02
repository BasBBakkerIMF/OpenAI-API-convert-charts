# Figure 12.1: Response to Terms-of-Trade Shock by Anchoring Level
#
# The published chart also shows error bars (90 percent confidence
# intervals). Those values are not part of the data extracted from the Excel
# chart, so they are not drawn here.
source("chart_style.R")

stem <- "fig-12-1"

# The labels are not part of the extracted data; they are taken from the
# published chart. Bars come in pairs (6 and 12 months) for each anchoring
# level, first for inflation, then for consumption.
plot_data <- read_chart_data(stem) |>
  mutate(position = row_number(),
         colour = rep(c("#A6A6A6", "#A6A6A6", "#A678B5", "#A678B5"), 2))

# A three-row table of labels below the plot, with separators of increasing
# length: horizon, anchoring level, outcome.
chart <- ggplot(plot_data, aes(position, series_0)) +
  geom_col(fill = plot_data$colour, width = 0.55) +
  geom_hline(yintercept = 0, linewidth = 0.4) +
  annotate("segment", x = seq(0.5, 8.5), xend = seq(0.5, 8.5), y = -1.2,
           yend = -1.2 - c(0.85, 0.3, 0.55, 0.3, 0.85, 0.3, 0.55, 0.3, 0.85),
           linewidth = 0.35) +
  annotate("text", x = 1:8, y = -1.38, label = rep(c("6m", "12m"), 4),
           family = "Arial", size = 3.1) +
  annotate("text", x = c(1.5, 3.5, 5.5, 7.5), y = -1.67, family = "Arial",
           size = 3.1, lineheight = 0.9,
           label = rep(c("Strongly\nanchored", "Weakly\nanchored"), 2)) +
  annotate("text", x = c(2.5, 6.5), y = -2.0, label = c("Inflation", "Consumption"),
           family = "Arial", size = 3.1) +
  scale_x_continuous(expand = expansion(0)) +
  scale_y_reo(-1.2, 1.2, 0.4, labels = function(x) sprintf("%.1f", x)) +
  coord_cartesian(xlim = c(0.5, 8.5), clip = "off") +
  labs(
    title = "Response to Terms-of-Trade Shock\nby Anchoring Level",
    subtitle = "(Percentage points)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Barrett and others (forthcoming); Bems and others (2021); and\n",
      "IMF staff calculations.\n",
      "Note: Cumulative response to month-on-month percentage change in the\n",
      "commodity terms-of-trade index (Gruss and Kebhaj 2019). Each country-\n",
      "year is classified as strongly (weakly) anchored when it is in the top\n",
      "(bottom) 25 percent of the observations of the anchoring index. Error bars\n",
      "denote 90 percent confidence intervals."
    )
  ) +
  theme_reo() +
  ticks_inward() +
  theme(axis.line.x = element_blank(), axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.caption = element_text(margin = margin(t = 66)))

save_chart(chart, stem)
