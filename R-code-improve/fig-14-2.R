# Figure 14.2: Real Export and Real Consumption Growth during Commodity
# Price Booms (box plots, two panels)
source("chart_style.R")
library(patchwork)
library(ggrepel)

stem <- "fig-14-2"

purple <- "#61257D"
box_colours <- c(Exports = "#A8DFE1", Consumption = "#FFD77D")

# Argentina's export growth in 2023-26 (12.5 percent) is off the scale; in
# the extracted data it is capped at 7.8, the top of the chart. It is
# labelled with its true value and left out of the whisker.
panel <- function(sheet, period, off_scale = NULL) {
  points <- read_chart_data(stem, sheet) |>
    mutate(group = factor(names(box_colours)[x], levels = names(box_colours)),
           off_scale = paste(label, x) %in% off_scale,
           label = if_else(off_scale, paste0(label, " (12.5)"), label))

  boxes <- points |>
    group_by(x, group) |>
    summarise(lower = quantile(y, 0.25), middle = median(y),
              upper = quantile(y, 0.75), ymin = min(y[!off_scale]),
              ymax = max(y[!off_scale]), .groups = "drop")

  ggplot(points, aes(x, y)) +
    geom_boxplot(aes(x = x, ymin = ymin, lower = lower, middle = middle, upper = upper,
                     ymax = ymax, fill = group, group = x), data = boxes,
                 inherit.aes = FALSE, stat = "identity", width = 0.58,
                 colour = "#555555", linewidth = 0.35, staplewidth = 0) +
    geom_point(colour = purple, size = 2.2) +
    geom_text_repel(aes(label = label), colour = purple, family = "Arial",
                    size = 3.05, nudge_x = 0.17, direction = "y", hjust = 0,
                    segment.colour = "#A0A0A0", segment.size = 0.3,
                    box.padding = 0.08, min.segment.length = 0, seed = 1) +
    annotate("segment", x = c(0.5, 1.6, 2.7), xend = c(0.5, 1.6, 2.7), y = 0,
             yend = c(-1.0, -0.45, -1.0), linewidth = 0.35) +
    annotate("text", x = 1.6, y = -0.72, label = period, family = "Arial", size = 3.1) +
    scale_fill_manual(values = box_colours, guide = "none") +
    scale_x_continuous(breaks = 1:2, labels = names(box_colours), expand = expansion(0)) +
    scale_y_continuous(breaks = c(0, 2, 4, 6, 8), labels = c(0, 2, 4, 6, 14),
                       expand = expansion(0), oob = scales::oob_keep) +
    coord_cartesian(xlim = c(0.5, 2.7), ylim = c(0, 8), clip = "off") +
    labs(x = NULL, y = NULL) +
    theme_reo() +
    theme(axis.ticks.x = element_blank(), plot.margin = margin(0, 2, 30, 0))
}

# The y-axis breaks between 6 and 14, marked with two slashes.
axis_break <- annotate("segment", x = 0.47, xend = 0.53, y = c(7.28, 7.52),
                       yend = c(7.43, 7.67), linewidth = 0.4)

chart <- (panel("datal", "2005–12") + axis_break) +
  (panel("datar", "2023–26", off_scale = "ARG 1") + axis_break +
     theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())) +
  plot_annotation(
    title = "Real Export and Real Consumption Growth during\nCommodity Price Booms",
    subtitle = "(Average annual growth; percent)",
    caption = "Sources: IMF, World Economic Outlook database; and IMF staff\ncalculations.",
    theme = theme_reo()
  )

save_chart(chart, stem)
