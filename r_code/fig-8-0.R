library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-8-0.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-8-0.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    across(c(Dummy2, Dummy3, Dummy4), as.numeric),
    Andean_lower = Dummy1,
    Andean_upper = Dummy1 + Dummy2,
    CAPDR_lower = Dummy1 + Dummy2 + Dummy3,
    CAPDR_upper = Dummy1 + Dummy2 + Dummy3 + Dummy4
  )

x_ticks <- tibble(
  category = 0:12,
  tick_bottom = -0.08,
  tick_top = 0.08
)

chart <- ggplot(plot_data, aes(x = category)) +
  geom_ribbon(
    aes(ymin = Andean_lower, ymax = Andean_upper),
    fill = "#D8C8DE",
    alpha = 0.38
  ) +
  geom_ribbon(
    aes(ymin = CAPDR_lower, ymax = CAPDR_upper),
    fill = "#F3C9AD",
    alpha = 0.48
  ) +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_segment(
    data = x_ticks,
    aes(
      x = category,
      xend = category,
      y = tick_bottom,
      yend = tick_top
    ),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.3
  ) +
  geom_line(
    aes(y = Andean, colour = "Andean"),
    linewidth = 0.9,
    lineend = "round"
  ) +
  geom_line(
    aes(y = CAPDR, colour = "CAPDR"),
    linewidth = 0.9,
    lineend = "round"
  ) +
  scale_colour_manual(
    values = c(
      "Andean" = "#5A2875",
      "CAPDR" = "#C95716"
    ),
    breaks = c("Andean", "CAPDR"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(-0.5, 12.5),
    breaks = 0:12,
    labels = as.character(0:12),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(-2, 5),
    breaks = -2:5,
    labels = as.character(-2:5),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Impact of El Niño on Inflation",
    subtitle = "(Percent, cumulative impact)",
    x = "Quarters",
    y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Shows the estimated impact of El Niño events on inflation using the\n",
      "local projection method in a cross-country panel. Shaded areas\n",
      "correspond to 10th/90th percentile confidence intervals. Andean =\n",
      "Colombia, Ecuador, Peru; CAPDR = Central America, Panama, and the\n",
      "Dominican Republic."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13.5,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11.5,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.text.x = element_text(
      margin = margin(t = 6)
    ),
    axis.text.y = element_text(
      margin = margin(r = 5)
    ),
    axis.title.x = element_text(
      size = 9.5,
      margin = margin(t = 7)
    ),
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length.y = grid::unit(-0.08, "cm"),
    legend.position = c(0.07, 0.97),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.text = element_text(size = 9.5),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.18, "in"),
    legend.background = element_blank(),
    legend.margin = margin(0, 0, 0, 0),
    legend.spacing.y = grid::unit(0, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.95,
      margin = margin(6, 0, 0, 0)
    ),
    plot.margin = margin(4, 10, 4, 10)
  )

print(chart)

ggsave(
  filename = output_file,
  plot = chart,
  dpi = 600,
  width = 5,
  height = 5,
  units = "in",
  bg = "white"
)
