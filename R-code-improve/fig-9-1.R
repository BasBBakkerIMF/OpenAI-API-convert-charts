# Figure 9.1: Contributions to Real GDP Growth
source("chart_style.R")

stem <- "fig-9-1"

# Stacking order, from the bottom up, and colours.
colours <- c(`Total factor productivity` = "#009DA8", Labor = "#0065A8",
             `Capital stock` = "#CE5B13")

# The labels are not part of the extracted data; they are taken from the
# published chart. The first five bars are 2000-19, the last five 2026-31.
regions <- rep(c("LA7", "EME", "EMA", "USA", "CAN"), 2)

data <- read_chart_data(stem) |>
  mutate(position = row_number())

# Total factor productivity is negative only once, by a negligible amount;
# it is drawn from zero, as in Excel.
bars <- data |>
  pivot_longer(all_of(names(colours)), names_to = "component") |>
  mutate(component = factor(component, levels = names(colours)),
         value = pmax(value, 0))

# The category labels sit in a small table inside the plot, between 0 and
# -1 (regions), and below it (periods).
chart <- ggplot(bars, aes(position)) +
  geom_col(aes(y = value, fill = component), width = 0.56,
           position = position_stack(reverse = TRUE)) +
  geom_point(aes(y = `Real GDP growth`, shape = "Real GDP growth"), data = data,
             size = 3.8) +
  geom_hline(yintercept = 0, linewidth = 0.4) +
  annotate("segment", x = 0.5, xend = 10.5, y = -1, yend = -1, linewidth = 0.4) +
  annotate("segment", x = c(1.5:4.5, 6.5:9.5), xend = c(1.5:4.5, 6.5:9.5),
           y = 0, yend = -1, linewidth = 0.35) +
  annotate("segment", x = c(0.5, 5.5, 10.5), xend = c(0.5, 5.5, 10.5),
           y = 0, yend = -2.02, linewidth = 0.35) +
  annotate("text", x = 1:10, y = -0.5, label = regions, family = "Arial", size = 3.45) +
  annotate("text", x = c(3, 8), y = -1.5, label = c("2000–19", "2026–31"),
           family = "Arial", size = 3.45) +
  scale_fill_manual(values = colours) +
  scale_shape_manual(values = 16) +
  scale_x_continuous(expand = expansion(0)) +
  scale_y_reo(-1, 7, 1) +
  coord_cartesian(xlim = c(0.5, 10.5), clip = "off") +
  guides(fill = guide_legend(order = 1), shape = guide_legend(order = 2)) +
  labs(
    title = "Contributions to Real GDP Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; Penn World Table 11.0\n",
      "database; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "EM = emerging; EMA = EM Asia (India, Indonesia, Malaysia, Philippines,\n",
      "Thailand); EME = EM Europe (Bosnia and Herzegovina, Hungary, Poland,\n",
      "Romania, Serbia); LA7 = Latin America 7 (Brazil, Chile, Colombia,\n",
      "Mexico, Paraguay; Peru, Uruguay)."
    )
  ) +
  theme_reo() +
  ticks_inward() +
  theme(axis.line.x = element_blank(), axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.caption = element_text(margin = margin(t = 34)),
        legend.key.width = unit(0.15, "in"), legend.spacing = unit(0, "cm")) +
  legend_at(0.33, 1)

save_chart(chart, stem)
