# Figure 1.1.2: Caribbean Inflation Response to the Oil Price Shocks
source("chart_style.R")

stem <- "fig-1-1-2"

colours <- c(
  "Point estimate (2005–14)" = "#0065A4",
  "Point estimate (2015–24)" = "#C85A0A",
  "Inflation change (2026, simple average)" = "#00A7A7"
)

# In Excel, the confidence bands are drawn as stacked areas, built from four
# helper series (Dummy1-Dummy4). Adding them up gives the band edges.
plot_data <- read_chart_data(stem) %>%
  mutate(
    across(Dummy1:Dummy4, as.numeric),
    blue_low = Dummy1,
    blue_high = Dummy1 + Dummy2,
    orange_low = blue_high + Dummy3,
    orange_high = orange_low + Dummy4
  )

lines <- plot_data %>%
  pivot_longer(all_of(names(colours)), names_to = "series") %>%
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category)) +
  geom_ribbon(aes(ymin = blue_low, ymax = blue_high), fill = "#DCEEF8") +
  geom_ribbon(aes(ymin = orange_low, ymax = orange_high), fill = "#F6E7DA",
              alpha = 0.9) +
  axis_line_at(0, x = 0:6, tick = 0.35) +
  geom_line(aes(y = value, colour = series), data = lines, linewidth = 1.05,
            lineend = "round", na.rm = TRUE) +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(-0.5, 6.5), breaks = 0:6, expand = expansion(0)) +
  scale_y_reo(-6, 12, 3) +
  labs(
    title = "Caribbean Inflation Response to the Oil Price\nShocks",
    subtitle = "(Percentage points difference since shock month)",
    x = "Months", y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: The oil price shock corresponds to about 40-percent increase in oil\n",
      "prices, as materialized in March relative to the January–February 2026\n",
      "average. The inflation response is annualized. Shaded bands represent\n",
      "90 percent Driscoll-Kraay confidence intervals."
    )
  ) +
  theme_reo(caption_size = 8.3) +
  theme(legend.key.width = unit(0.31, "in"), legend.text = element_text(size = 8.5)) +
  legend_at(0.10, 0.01, just = c(0, 0))

save_chart(chart, stem)
