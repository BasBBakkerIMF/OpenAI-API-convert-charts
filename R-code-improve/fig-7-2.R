# Figure 7.2: Western Hemisphere: Growth and Inflation Risks (two panels)
source("chart_style.R")
library(patchwork)

stem <- "fig-7-2"

# Stacking order, from the bottom up, and colours.
colours <- c(Balanced = "#7F4AA3", `Tilted to the downside` = "#FFC000",
             `Tilted to the upside` = "#C55A11")

# The category labels are not part of the extracted data; they are taken
# from the published chart.
groups <- c("AE", "LA7", "OTSA", "CAPDR", "CARIB")

# One panel of stacked bars, with category labels on the axis, group labels
# below them, and separators between the groups. `label_y` and `separator_y`
# are in data units (below zero).
panel <- function(sheet, labels, group_labels, group_x, separators,
                  high, by, label_y, separator_y, angle = 0) {
  data <- read_chart_data(stem, sheet) |>
    mutate(position = row_number()) |>
    pivot_longer(-position, names_to = "risk") |>
    mutate(risk = factor(risk, levels = names(colours)))

  ggplot(data, aes(position, value, fill = risk)) +
    geom_col(width = 0.7, position = position_stack(reverse = TRUE)) +
    annotate("segment", x = separators, xend = separators, y = 0,
             yend = separator_y, linewidth = 0.35) +
    annotate("text", x = group_x, y = label_y, label = group_labels,
             family = "Arial", size = 3.2) +
    scale_fill_manual(values = colours) +
    scale_x_continuous(breaks = seq_along(labels), labels = labels,
                       expand = expansion(0)) +
    scale_y_reo(0, high, by) +
    coord_cartesian(xlim = range(separators), ylim = c(0, high), clip = "off") +
    labs(x = NULL, y = NULL) +
    theme_reo() +
    theme(axis.ticks.x = element_blank(),
          axis.text.x = element_text(angle = angle, vjust = 0.5,
                                     hjust = if (angle) 1 else 0.5),
          plot.margin = margin(0, 4, 26, 0))
}

whd <- panel("datal", c("Growth", "Inflation"), "WHD", 1.5, c(0.5, 1.5, 2.5),
             high = 100, by = 20, label_y = -19, separator_y = -13) +
  theme(legend.position = "none")

by_group <- panel("datar", rep(groups, 2), c("Growth", "Inflation"), c(3, 8),
                  c(0.5, 5.5, 10.5), high = 60, by = 10, label_y = -16,
                  separator_y = -19, angle = 90) +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme(legend.key.width = unit(0.12, "in"), legend.key.height = unit(0.12, "in")) +
  legend_at(0.02, 1.02)

chart <- whd + by_group +
  plot_layout(widths = c(0.75, 1.4)) +
  plot_annotation(
    title = "Western Hemisphere: Growth and Inflation Risks",
    subtitle = "(Percent share of total number of WHD countries)",
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: AE = advanced economies; CAPDR = Central America, Panama,\n",
      "and the Dominican Republic; CARIB = Caribbean; LA7 = Latin America 7\n",
      "(Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay); OTSA =\n",
      "other South America."
    ),
    theme = theme_reo()
  )

save_chart(chart, stem)
