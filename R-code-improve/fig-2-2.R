# Figure 2.2: Yields and Spreads (two panels)
source("chart_style.R")
library(patchwork)

stem <- "fig-2-2"

conflict <- as.Date("2026-03-01")
date_range <- as.Date(c("2024-01-01", "2026-09-30"))

# One panel: daily series from 2024 on, with the start of the Middle East
# conflict marked.
panel <- function(sheet, title, subtitle, colours, low, high, by) {
  data <- read_chart_data(stem, sheet) %>%
    mutate(date = as.Date(category)) %>%
    filter(date >= date_range[1], date <= date_range[2]) %>%
    pivot_longer(all_of(names(colours)), names_to = "series") %>%
    mutate(series = factor(series, levels = names(colours)))

  ggplot(data, aes(date, value, colour = series)) +
    geom_vline(xintercept = conflict, colour = "#666666", linewidth = 0.45,
               linetype = "dotted") +
    geom_line(linewidth = 0.72, na.rm = TRUE) +
    annotate("text", x = conflict - 12, y = low + 0.02 * (high - low),
             label = "Middle East conflict", hjust = 1, vjust = 0,
             family = "Arial", fontface = "italic", size = 2.8) +
    scale_colour_manual(values = colours) +
    scale_x_date(limits = date_range, date_breaks = "6 months",
                 date_labels = "%b-%y", expand = expansion(0)) +
    scale_y_reo(low, high, by) +
    labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    theme_reo(base_size = 8.5) +
    vertical_x_labels() +
    theme(plot.title = element_text(colour = "#777777", size = 11),
          plot.subtitle = element_text(colour = "#777777", size = 10)) +
    legend_at(0.08, 0.99)
}

yields <- panel("datal", "Ten-year Bond Yields", "(Percent)",
                c(USA = "#00689D", CAN = "#404040", LA7 = "#5B2A7B"), 2, 8, 1)
spreads <- panel("datar", "Sovereign Spreads", "(Basis points)",
                 c(LA7 = "#5B2A7B", CAPDR = "#C55A11", CARIB = "#00A1A9"), 50, 400, 50)

chart <- yields + spreads +
  plot_annotation(
    title = "Yields and Spreads",
    caption = paste0(
      "Sources: Bloomberg Finance L.P.; and IMF staff calculations.\n",
      "Note: Aggregates are medians. Sovereign spread refers to EMBIG\n",
      "spread. CAPDR = Central America, Panama, and the Dominican\n",
      "Republic; CARIB = Caribbean; LA7 = Latin America 7 (Brazil, Chile,\n",
      "Colombia, Mexico, Paraguay, Peru, Uruguay)."
    ),
    theme = theme_reo(caption_size = 8.2)
  )

save_chart(chart, stem)
