# Figure 1.2.1: Repatriations and Border Apprehensions
source("chart_style.R")

stem <- "fig-1-2-1"

colours <- c(GTM = "#0070C0", HND = "#00A6A6", SLV = "#ED7D31", NIC = "#BFBFBF")
countries <- names(colours)

data <- read_chart_data(stem) %>%
  mutate(date = as.Date(category))

# Each country has an actual series and an estimated one (from December
# 2024): use the actual value where there is one, otherwise the estimate.
# The chart shows thousands.
bars <- data %>%
  transmute(date, !!!setNames(
    lapply(countries, function(c) quo(coalesce(.data[[c]], .data[[paste0(c, "(est)")]]) / 1000)),
    countries
  )) %>%
  pivot_longer(-date, names_to = "country", values_to = "thousands") %>%
  mutate(country = factor(country, levels = countries))

# Apprehensions (0-80 thousand) are drawn on the left-hand scale (0-20)
# divided by 4, with a matching right-hand scale.
apprehensions <- data %>%
  transmute(date, value = `Apprehensions (right scale)` / 1000 / 4)

chart <- ggplot() +
  geom_col(aes(date, thousands, fill = country), data = bars, width = 24,
           position = position_stack(reverse = TRUE), na.rm = TRUE) +
  geom_line(aes(date, value), data = apprehensions, linewidth = 1.15,
            lineend = "round", linejoin = "round") +
  geom_vline(xintercept = as.Date("2024-12-15"), linewidth = 0.4,
             linetype = "dotted") +
  annotate("text", x = as.Date("2025-04-01"), y = 19.45, label = "Estimates",
           family = "Arial", fontface = "italic", size = 3.4, hjust = 0) +
  annotate("text", x = as.Date("2021-09-01"), y = 16.25,
           label = "Apprehensions\n(right scale)", family = "Arial",
           size = 3.25, lineheight = 0.88, hjust = 0) +
  scale_fill_manual(values = colours) +
  scale_x_date(limits = as.Date(c("2020-01-01", "2026-06-30")),
               breaks = seq(as.Date("2020-01-01"), as.Date("2026-06-01"), by = "7 months"),
               date_labels = "%b-%y", expand = expansion(0)) +
  scale_y_reo(0, 20, 4, sec.axis = right_axis(1 / 4, breaks = seq(0, 80, 20))) +
  guides(fill = guide_legend(nrow = 1)) +
  labs(
    title = "Repatriations and Border Apprehensions",
    subtitle = "(Thousands)",
    x = NULL, y = NULL,
    caption = paste0(
      "Sources: US Customs and Border Protection; US Department of\n",
      "Homeland Security; US Immigration and Customs Enforcement (ICE); and\n",
      "IMF staff estimates.\n",
      "Note: Repatriations include removals, administrative and enforcement\n",
      "returns. Title 42 expulsions are not included. Since December 2024,\n",
      "repatriations are estimated using ICE book-ins. The repatriations to book-\n",
      "ins ratio is calculated through November 2024 and projected to remain\n",
      "constant. Since data for book-ins are published through June 2026, this\n",
      "allows to estimate the repatriations in 2026."
    )
  ) +
  theme_reo(caption_size = 7.7) +
  vertical_x_labels() +
  theme(legend.key.width = unit(0.13, "in"), legend.key.height = unit(0.13, "in")) +
  legend_at(0.015, 0.985)

save_chart(chart, stem)
