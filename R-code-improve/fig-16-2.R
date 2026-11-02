# Figure 16.2: LAC: Composition of FDI Capital Expenditure
source("chart_style.R")

stem <- "fig-16-2"

# Stacking order, from the bottom up, and colours.
colours <- c(Manufacturing = "#5B2A7E", Mining = "#C75B12",
             `ICT and data` = "#00649A", `Business services` = "#009A9A",
             Other = "#B8BCBE")

plot_data <- read_chart_data(stem) |>
  pivot_longer(-category, names_to = "sector") |>
  mutate(sector = factor(sector, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, fill = sector)) +
  geom_col(width = 0.56, position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = colours) +
  scale_x_continuous(limits = c(2012.5, 2025.5), breaks = seq(2013, 2025, 2),
                     expand = expansion(0)) +
  scale_y_reo(0, 300, 60) +
  labs(
    title = "LAC: Composition of FDI Capital Expenditure",
    subtitle = "(Billions of US dollars; annual levels)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Orbis Crossborder Investment database; and IMF staff\n",
      "calculations.\n",
      "Note: Years are announcement years and cover announced and\n",
      "completed projects. Latest available data as of September 2, 2026. FDI =\n",
      "foreign direct investments; ICT = information and communications\n",
      "technology and data; LAC = Latin America and the Caribbean."
    )
  ) +
  theme_reo() +
  theme(legend.key.width = unit(0.13, "in"), legend.key.height = unit(0.13, "in")) +
  legend_at(0.045, 0.995)

save_chart(chart, stem)
