# Figure 2.3: LAC: International Bond Issuance
source("chart_style.R")

stem <- "fig-2-3"

# Legend order (top to bottom of the stack) and colours.
colours <- c(
  Brazil = "#08679B", Chile = "#009999", Colombia = "#D2691E",
  Mexico = "#666666", Paraguay = "#8EC7E0", Peru = "#FDBF22",
  Uruguay = "#9B6AB0", `CAPDR/CARIB` = "#4F8A10", `Rest of LAC` = "#000000"
)

data <- read_chart_data(stem) %>%
  mutate(category = factor(as.character(category), levels = as.character(category)))

bars <- data %>%
  pivot_longer(all_of(names(colours)), names_to = "series") %>%
  mutate(series = factor(series, levels = names(colours)))

# Red dots: issuance in January-September of each earlier year, for
# comparison with the last bar (which has no dot).
dots <- head(data, -1)

chart <- ggplot(bars, aes(category)) +
  geom_col(aes(y = value, fill = series), width = 0.56) +
  annotate("segment", x = 1, xend = 1, y = 82, yend = dots$`Jan-Sep`[1] + 4,
           colour = "#A6A6A6", linewidth = 0.65) +
  geom_point(aes(y = `Jan-Sep`), data = dots, shape = 21, size = 3.6,
             stroke = 1.1, fill = "red") +
  annotate("text", x = 0.9, y = 83, label = "Jan-Sep", colour = "red",
           family = "Arial", size = 3.2, hjust = 0, vjust = 0) +
  scale_fill_manual(values = colours) +
  scale_y_reo(0, 180, 30) +
  guides(fill = guide_legend(ncol = 2, byrow = TRUE)) +
  labs(
    title = "LAC: International Bond Issuance",
    subtitle = "(Billions of US dollars)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Bond Radar; and IMF staff calculations.\n",
      "Note: Includes sovereign and corporate/financial bond issuances. CAPDR\n",
      "= Central America, Panama, and the Dominican Republic; CARIB =\n",
      "Caribbean; LAC = Latin America and the Caribbean."
    )
  ) +
  theme_reo(caption_size = 8.4) +
  theme(legend.key.width = unit(0.12, "in"), legend.key.height = unit(0.12, "in"),
        plot.margin = margin(4, 16, 6, 10)) +
  legend_at(0.035, 1.025)

save_chart(chart, stem)
