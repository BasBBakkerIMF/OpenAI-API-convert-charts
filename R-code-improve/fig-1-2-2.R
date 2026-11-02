# Figure 1.2.2: Remittances to CA4 Countries
source("chart_style.R")

stem <- "fig-1-2-2"

# In Excel the band is a stacked area: "Min" plus the "Min-Max Band" on top.
date_range <- as.Date(c("2023-12-15", "2026-06-15"))

plot_data <- read_chart_data(stem) %>%
  mutate(date = as.Date(category), band_high = Min + `Min-Max Band`) %>%
  filter(date >= date_range[1], date <= date_range[2])

chart <- ggplot(plot_data, aes(date)) +
  geom_ribbon(aes(ymin = Min, ymax = band_high), fill = "#FCE5D6") +
  geom_hline(yintercept = 0, colour = "#BFBFBF", linewidth = 0.35) +
  geom_line(aes(y = `Total remittances`), colour = "#C55A11", linewidth = 1.15,
            lineend = "round", linejoin = "round") +
  scale_x_date(limits = date_range,
               breaks = seq(as.Date("2024-01-01"), as.Date("2026-05-01"), by = "2 months"),
               date_labels = "%b-%y", expand = expansion(0)) +
  scale_y_reo(-10, 50, 10) +
  labs(
    title = "Remittances to CA4 Countries",
    subtitle = "(Year-over-year percent change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; national authorities; and IMF staff calculations.\n",
      "Note: Nicaragua’s 2025–26H1 data are IMF staff estimates. CA4 =\n",
      "Central America 4 (El Salvador, Guatemala, Honduras, Nicaragua)."
    )
  ) +
  theme_reo(caption_size = 7.8) +
  ticks_inward(0.10) +
  vertical_x_labels()

save_chart(chart, stem)
