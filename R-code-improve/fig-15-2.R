# Figure 15.2: China's Share of Latin American Passenger Car Imports
source("chart_style.R")

stem <- "fig-15-2"

# In Excel the min-max range is a stacked area: "Min" plus "Difference".
plot_data <- read_chart_data(stem) |>
  mutate(range_high = Min + Difference)

chart <- ggplot(plot_data, aes(category)) +
  geom_ribbon(aes(ymin = Min, ymax = range_high), fill = "#F2EDF4") +
  geom_line(aes(y = LATAM), colour = "#5B2677", linewidth = 0.9, lineend = "round") +
  scale_x_continuous(limits = c(2014.5, 2025.5), breaks = seq(2015, 2025, 2),
                     expand = expansion(0)) +
  scale_y_reo(0, 50, 10) +
  labs(
    title = "China's Share of Latin American Passenger Car\nImports",
    subtitle = "(Percent share)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: UN Comtrade; World Bank, World Integrated Trade Solution;\n",
      "and IMF staff calculations.\n",
      "Note: Shaded area refers to the min-max range."
    )
  ) +
  theme_reo()

save_chart(chart, stem)
