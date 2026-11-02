# Figure 13: WHD: Policies in Response to the Iran Shock
source("chart_style.R")

stem <- "fig-13-0"

# The labels are not part of the extracted data; they are taken from the
# published chart. The left three bars use the left-hand scale (percent of
# countries, 0-80), the right three the right-hand scale (number of
# policies, 0-60), drawn on the left-hand scale multiplied by 4/3.
labels <- c("Allow or\nincrease", "No effect", "Reduce", "Taxes", "Spending", "Other")

plot_data <- bind_rows(
  read_chart_data(stem, "datal") |> mutate(fill = "#08679D"),
  read_chart_data(stem, "datar") |> mutate(fill = "#C85F16", series_0 = series_0 * 4 / 3)
) |>
  mutate(position = row_number())

# Two rows of labels below the plot, with separators.
chart <- ggplot(plot_data, aes(position, series_0)) +
  geom_col(fill = plot_data$fill, width = 0.56) +
  annotate("segment", x = seq(0.5, 6.5), xend = seq(0.5, 6.5), y = 0,
           yend = c(-27, -9, -9, -27, -9, -9, -27), linewidth = 0.35) +
  annotate("text", x = 1:6, y = -4.5, label = labels, family = "Arial",
           size = 3.05, lineheight = 0.9) +
  annotate("text", x = c(2, 5), y = -17.5, family = "Arial", size = 3.0,
           lineheight = 0.9,
           label = c("Percent share of countries\nimplementing policies affecting\ncommodity price pass-through",
                     "Number of policies\nimplemented")) +
  scale_x_continuous(expand = expansion(0)) +
  scale_y_reo(0, 80, 20, sec.axis = right_axis(4 / 3, breaks = seq(0, 60, 15))) +
  coord_cartesian(xlim = c(0.5, 6.5), clip = "off") +
  labs(
    title = "WHD: Policies in Response to the Iran Shock",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, Global Policy Tracker database; and IMF staff calculations.\n",
      "Note: Examples of policies that increase commodity price pass-through\n",
      "include reductions of fuel tax recoveries, fuel subsidy removals\n",
      "(Spending), removals of the fuel price controls, and increases to\n",
      "domestically controlled fuel prices (Others). Examples of policies that\n",
      "reduce commodity price pass-through include fuel, electricity, and food\n",
      "subsidies (Spending), and reductions in fuel taxes (Taxes). “Others” also\n",
      "includes credit guarantees, export taxes, relaxation of fuel standards,\n",
      "release of strategic reserves, work from home mandates, and public\n",
      "sector energy conservation."
    )
  ) +
  theme_reo(title_size = 13.5) +
  theme(axis.line.x = element_blank(), axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.caption = element_text(margin = margin(t = 72)))

save_chart(chart, stem)
