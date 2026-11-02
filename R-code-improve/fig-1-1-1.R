# Figure 1.1.1: US Citizen Departures to the Caribbean
source("chart_style.R")

stem <- "fig-1-1-1"

year_colours <- c(`2019` = "#0873B2", `2025` = "#BFC0C2", `2026` = "#A982BA")
yoy <- "Year-over-year percent change (right scale)"

plot_data <- read_chart_data(stem) %>%
  mutate(category = factor(category, levels = category))

bars <- plot_data %>%
  pivot_longer(all_of(names(year_colours)), names_to = "year")

# The year-over-year change (0-8) is drawn on the left-hand scale (0-0.8)
# divided by 10, with a matching right-hand scale.
chart <- ggplot(plot_data, aes(category)) +
  geom_col(aes(y = value, fill = year), data = bars, width = 0.82,
           position = position_dodge(width = 0.82)) +
  geom_line(aes(y = .data[[yoy]] / 10, colour = yoy, group = 1),
            linewidth = 0.85, lineend = "round") +
  scale_fill_manual(values = year_colours) +
  scale_colour_manual(values = setNames("black", yoy)) +
  scale_y_reo(0, 0.8, 0.2, labels = function(x) sprintf("%.1f", x),
              sec.axis = right_axis(1 / 10, breaks = seq(0, 8, 2))) +
  guides(fill = guide_legend(order = 1), colour = guide_legend(order = 2)) +
  labs(
    title = "US Citizen Departures to the Caribbean",
    subtitle = "(Millions, unless noted otherwise)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: US International Trade Administration; and IMF staff\n",
      "calculations.\n",
      "Note: Data include 15 countries and exclude Jamaica."
    )
  ) +
  theme_reo(base_size = 10, title_size = 13.5, subtitle_size = 11.5,
            caption_size = 9) +
  ticks_inward() +
  theme(axis.ticks.x = element_blank(), legend.box.just = "left",
        legend.spacing = unit(0, "cm"), legend.text = element_text(size = 9.5)) +
  legend_at(0.025, 0.985)

save_chart(chart, stem)
