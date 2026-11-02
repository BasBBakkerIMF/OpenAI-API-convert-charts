# Figure 10.1: General Government Gross Debt and Financing Cost
source("chart_style.R")

stem <- "fig-10-1"

premium <- "LA7 financing premium for LC 10y yields (right scale)"
debt_colours <- c(`LA7 gross debt` = "#C7A6D0", `OEM gross debt` = "#69B5DE")

# The rows alternate between LA7 and OEM, for five years. The labels are not
# part of the extracted data; they are taken from the published chart.
years <- c("2003", "2010", "2020", "2025", "2031")

data <- read_chart_data(stem) |>
  mutate(position = row_number())

bars <- data |>
  pivot_longer(all_of(names(debt_colours)), names_to = "series") |>
  filter(!is.na(value))

# Financing premium: one dash per year, across the pair of bars. It is on
# the right-hand scale (0-8), drawn on the left-hand scale (20-80) as
# 20 + 7.5 * value.
dashes <- data |>
  filter(position %% 2 == 1, !is.na(.data[[premium]])) |>
  mutate(y = 20 + 7.5 * .data[[premium]])

chart <- ggplot(bars, aes(position)) +
  geom_rect(aes(xmin = position - 0.31, xmax = position + 0.31, ymin = 20,
                ymax = value, fill = series)) +
  geom_segment(aes(x = position - 0.05, xend = position + 1.05, y = y, yend = y,
                   colour = premium), data = dashes, linewidth = 0.75) +
  annotate("segment", x = seq(0.5, 10.5, 2), xend = seq(0.5, 10.5, 2),
           y = 20, yend = 10.5, linewidth = 0.35) +
  annotate("segment", x = seq(1.5, 9.5, 2), xend = seq(1.5, 9.5, 2),
           y = 20, yend = 16, linewidth = 0.35) +
  annotate("text", x = seq(1.5, 9.5, 2), y = 13, label = years,
           family = "Arial", size = 3.1) +
  scale_fill_manual(values = debt_colours) +
  scale_colour_manual(values = setNames("black", premium)) +
  scale_x_continuous(breaks = 1:10, labels = rep(c("LA7", "OEM"), 5),
                     expand = expansion(0)) +
  scale_y_reo(20, 80, 10, sec.axis = right_axis(7.5, shift = 20,
                                                breaks = seq(0, 8, 2))) +
  coord_cartesian(xlim = c(0.5, 10.5), ylim = c(20, 80), clip = "off") +
  guides(fill = guide_legend(order = 1), colour = guide_legend(order = 2)) +
  labs(
    title = "General Government Gross Debt and\nFinancing Cost",
    subtitle = "(Percent of GDP; unless noted otherwise)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; IMF, World Economic Outlook database; and\n",
      "IMF staff calculations.\n",
      "Note: Financing cost in percentage points is the difference between LA7\n",
      "and OEM's nominal 10-year local currency bond yields. Aggregates are\n",
      "simple averages. LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay); OEM = other emerging markets (Bosnia and\n",
      "Herzegovina, Hungary, India, Indonesia, Malaysia, Philippines, Poland,\n",
      "Romania, Serbia, Thailand)."
    )
  ) +
  theme_reo(caption_size = 8.3) +
  theme(axis.ticks.x = element_blank(),
        plot.caption = element_text(margin = margin(t = 24)),
        legend.key.width = unit(0.25, "in"), legend.spacing = unit(0, "cm"),
        legend.text = element_text(size = 8.8)) +
  legend_at(0.02, 1)

save_chart(chart, stem)
