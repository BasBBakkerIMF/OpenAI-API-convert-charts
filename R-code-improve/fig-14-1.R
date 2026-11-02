# Figure 14.1: LA8 excl. Mexico: Structural Primary Balance and Commodity Terms of Trade
source("chart_style.R")

stem <- "fig-14-1"

balance <- "Structural primary balance"
ctot <- "CTOT (index: 2000 = 100; right scale)"
colours <- setNames(c("#5B2A78", "#A2A39D"), c(balance, ctot))

# CTOT (right-hand scale, 100-105) is drawn on the left-hand scale (-12 to 8)
# as 4 * value - 412. In Excel the shaded range is a stacked area: "Min" plus
# "Min-Max range".
data <- read_chart_data(stem) |>
  mutate(range_high = Min + `Min-Max range`, !!ctot := 4 * .data[[ctot]] - 412)

lines <- data |>
  pivot_longer(all_of(names(colours)), names_to = "series") |>
  mutate(series = factor(series, levels = names(colours)))

chart <- ggplot(data, aes(category)) +
  geom_ribbon(aes(ymin = Min, ymax = range_high), fill = "#E9DFEE") +
  geom_hline(yintercept = 0, linewidth = 0.4) +
  geom_line(aes(y = value, colour = series), data = lines, linewidth = 0.9,
            na.rm = TRUE) +
  scale_colour_manual(values = colours) +
  scale_x_continuous(limits = c(2004.5, 2027.5), breaks = seq(2005, 2027, 2),
                     expand = expansion(0)) +
  scale_y_reo(-12, 8, 4, sec.axis = right_axis(4, shift = -412, breaks = 100:105)) +
  labs(
    title = "LA8 excl. Mexico: Structural Primary Balance and\nCommodity Terms of Trade",
    subtitle = "(Percent of GDP; unless noted otherwise)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, Commodity Terms of Trade database; IMF, World\n",
      "Economic Outlook database; and IMF staff calculations.\n",
      "Note: Structural primary balance is simple average. Chile refers to the\n",
      "central government’s structural non-mining primary balance. Colombia\n",
      "refers to the consolidated public sector’s structural non-oil primary\n",
      "balance. Peru refers to the nonfinancial public sector’s structural primary\n",
      "balance. CTOT is purchasing-power-parity GDP-weighted average. CTOT\n",
      "= commodity terms of trade; LA8 = Latin America 8 (Argentina, Brazil,\n",
      "Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    )
  ) +
  theme_reo() +
  vertical_x_labels() +
  legend_at(0.03, 0.03, just = c(0, 0))

save_chart(chart, stem)
