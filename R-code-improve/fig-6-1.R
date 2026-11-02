# Figure 6.1: Headline Consumer Price Inflation
source("chart_style.R")

stem <- "fig-6-1"

conflict <- as.Date("2026-03-01")
date_range <- as.Date(c("2024-01-01", "2026-12-31"))

colours <- c(LA7 = "#5B267D", CAPDR = "#C45A12", CARIB = "#08A7B5",
             USA = "#0067A6", CAN = "#666666")

# Each series holds monthly data up to its latest month, then a gap, then
# the end-2026 projection in December 2026. (December 2023 is included so
# the lines run in from the left edge, as in Excel.)
series <- read_chart_data(stem) |>
  mutate(date = as.Date(category)) |>
  filter(date >= as.Date("2023-12-01"), date <= date_range[2]) |>
  pivot_longer(all_of(names(colours)), names_to = "series") |>
  filter(!is.na(value)) |>
  mutate(series = factor(series, levels = names(colours))) |>
  group_by(series) |>
  mutate(projection = row_number() == n()) |>
  ungroup()

actual <- filter(series, !projection)
projection <- filter(series, projection)
# Dotted line from the latest month to the projection.
link <- series |>
  group_by(series) |>
  slice_tail(n = 2) |>
  ungroup()

chart <- ggplot(actual, aes(date, value, colour = series, group = series)) +
  geom_line(linewidth = 0.85) +
  geom_line(data = link, linewidth = 0.85, linetype = "dotted") +
  geom_point(aes(fill = series), data = projection, shape = 21, size = 3.2,
             colour = "black", stroke = 0.4, show.legend = FALSE) +
  geom_vline(xintercept = conflict, linewidth = 0.35, linetype = "dotted") +
  annotate("text", x = conflict - 10, y = 1.08, label = "Middle East conflict",
           family = "Arial", fontface = "italic", size = 3.15, hjust = 1, vjust = 0) +
  annotate("text", x = date_range[2], y = 5.55, label = "End-2026\nprojections",
           family = "Arial", fontface = "italic", size = 3.2, hjust = 1,
           lineheight = 0.9) +
  scale_colour_manual(values = colours) +
  scale_fill_manual(values = colours) +
  scale_x_date(expand = expansion(0), date_labels = "%b-%y",
               breaks = as.Date(c("2024-01-31", "2024-07-31", "2025-01-31",
                                  "2025-07-31", "2026-01-31", "2026-07-31",
                                  "2026-12-31"))) +
  scale_y_reo(1, 6, 1) +
  # Clip the lines at the start of 2024, but leave room for the projection
  # dots at the right-hand edge.
  coord_cartesian(xlim = date_range + c(0, 12)) +
  guides(colour = guide_legend(ncol = 2, byrow = TRUE)) +
  labs(
    title = "Headline Consumer Price Inflation",
    subtitle = "(Year-over-year percent change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; IMF, World Economic Outlook database;\n",
      "national authorities; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n",
      "Uruguay."
    )
  ) +
  theme_reo() +
  vertical_x_labels() +
  theme(legend.key.width = unit(0.38, "in")) +
  legend_at(0.03, 1)

save_chart(chart, stem)
