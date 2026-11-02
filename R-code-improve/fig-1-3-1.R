# Figure 1.3.1: Exports of Goods (two panels)
source("chart_style.R")
library(patchwork)

stem <- "fig-1-3-1"

bar_colours <- c(Mexico = "#08649B", Canada = "#CB6418")

# One panel: bars (percent of GDP, left scale 0-40) and circles (percent of
# exports, right scale 0-100, drawn on the left scale divided by 2.5).
panel <- function(sheet, title, bar_column, circle_column) {
  data <- read_chart_data(stem, sheet) %>%
    mutate(category = factor(category, levels = names(bar_colours)))
  ggplot(data, aes(category)) +
    geom_col(aes(y = .data[[bar_column]], fill = category), width = 0.56) +
    geom_point(aes(y = .data[[circle_column]] / 2.5), shape = 1, size = 3.8,
               stroke = 1.2) +
    scale_fill_manual(values = bar_colours, guide = "none") +
    scale_x_discrete(expand = expansion(add = 0.28)) +
    scale_y_reo(0, 40, 10, sec.axis = right_axis(1 / 2.5, breaks = seq(0, 100, 25))) +
    labs(title = title, x = NULL, y = NULL) +
    theme_reo(base_size = 10) +
    ticks_inward() +
    theme(plot.title = element_text(colour = "#7F7F7F", size = 11.5,
                                    margin = margin(0, 0, 14, 0)),
          axis.ticks.x = element_blank())
}

left <- panel("datal", "Canada and Mexico Exports\nto the United States",
              "(% GDP)", "(% goods exports)")

# The legend, drawn in the right-hand panel: a square for the bars and a
# circle for the right-hand scale.
right <- panel("datar", "United States Exports to\nCanada and Mexico",
               "Percent of GDP", "Percent of exports (right scale)") +
  annotate("point", x = 0.85, y = c(38, 33.6), shape = c(0, 1), size = 3,
           stroke = 0.9) +
  annotate("text", x = 0.97, y = c(38, 33.6), hjust = 0, family = "Arial",
           size = 3.2, lineheight = 0.95,
           label = c("Percent of GDP", "Percent of exports\n(right scale)"))

chart <- left + right +
  plot_annotation(
    title = "Exports of Goods",
    caption = "Sources: Haver Analytics; national authorities; and IMF staff calculations.",
    theme = theme_reo(title_size = 14, caption_size = 9.5)
  )

save_chart(chart, stem)
