# Figure 16.1: LAC: Share of FDI Global Greenfield Investment
source("chart_style.R")

stem <- "fig-16-1"

colours <- c(`Capital expenditure` = "#0066A6", `Project-count` = "#C8580A")

plot_data <- read_chart_data(stem) |>
  pivot_longer(-category, names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(plot_data, aes(category, value, colour = series)) +
  geom_line(linewidth = 0.9, lineend = "round") +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(2004.5, 2025.5), breaks = seq(2005, 2025, 5),
                     expand = expansion(0)) +
  scale_y_reo(4, 16, 2) +
  labs(
    title = "LAC: Share of FDI Global Greenfield Investment",
    subtitle = "(Percent of world total; three-year trailing moving\naverage)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Orbis Crossborder Investment (OCBI) database; and IMF staff\n",
      "calculations.\n",
      "Note: Shares are computed on announcement years relative to all\n",
      "destination economies in the database and cover announced and\n",
      "completed projects. Latest available data as of September 2, 2026. FDI =\n",
      "foreign direct investments; LAC = Latin America and the Caribbean."
    )
  ) +
  theme_reo() +
  legend_at(0.045, 0.965)

save_chart(chart, stem)
