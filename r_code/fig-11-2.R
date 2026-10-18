library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-11-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-11-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    stage = ave(seq_len(n()), series, FUN = seq_along),
    series = factor(series, levels = c("BRA", "COL", "MEX"))
  )

smooth_path <- function(data, points = 160) {
  data <- data %>% arrange(stage)
  parameter <- seq_len(nrow(data))

  tibble(
    series = data$series[1],
    path_order = seq_len(points),
    x = spline(parameter, data$x, n = points, method = "natural")$y,
    y = spline(parameter, data$y, n = points, method = "natural")$y
  )
}

smooth_data <- bind_rows(
  lapply(split(plot_data, plot_data$series), smooth_path)
) %>%
  mutate(series = factor(series, levels = c("BRA", "COL", "MEX")))

arrow_data <- smooth_data %>%
  group_by(series) %>%
  slice_tail(n = 9) %>%
  ungroup()

series_colors <- c(
  "BRA" = "#63277F",
  "COL" = "#D05A08",
  "MEX" = "#66696A"
)

x_ticks <- tibble(x = -3:2)
y_ticks <- tibble(y = -1:7)

chart <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.45
  ) +
  geom_vline(
    xintercept = 0,
    colour = "black",
    linewidth = 0.45
  ) +
  geom_segment(
    data = x_ticks,
    aes(x = x, xend = x, y = 0, yend = 0.14),
    inherit.aes = FALSE,
    linewidth = 0.35,
    colour = "black"
  ) +
  geom_segment(
    data = y_ticks,
    aes(x = 0, xend = 0.055, y = y, yend = y),
    inherit.aes = FALSE,
    linewidth = 0.35,
    colour = "black"
  ) +
  geom_path(
    data = smooth_data,
    aes(x = x, y = y, colour = series, group = series),
    linewidth = 1.15,
    lineend = "round",
    arrow = grid::arrow(
      angle = 24,
      length = grid::unit(0.12, "cm"),
      type = "closed"
    )
  ) +
  geom_point(
    data = plot_data,
    aes(x = x, y = y, colour = series),
    shape = 21,
    fill = "white",
    stroke = 0.9,
    size = 3
  ) +
  geom_path(
    data = arrow_data,
    aes(x = x, y = y, colour = series, group = series),
    linewidth = 1.15,
    lineend = "round",
    arrow = grid::arrow(
      angle = 24,
      length = grid::unit(0.12, "cm"),
      type = "closed"
    ),
    show.legend = FALSE
  ) +
  annotate(
    "text",
    x = -2.92, y = 6.98,
    label = "Exp FP\nCon MP",
    hjust = 0, vjust = 1,
    family = "Arial", fontface = "italic",
    size = 3.2, lineheight = 0.95,
    colour = "#777777"
  ) +
  annotate(
    "text",
    x = 1.27, y = 6.98,
    label = "Con FP\nCon MP",
    hjust = 0, vjust = 1,
    family = "Arial", fontface = "italic",
    size = 3.2, lineheight = 0.95,
    colour = "#777777"
  ) +
  annotate(
    "text",
    x = -2.95, y = -0.30,
    label = "Exp FP\nExp MP",
    hjust = 0, vjust = 1,
    family = "Arial", fontface = "italic",
    size = 3.2, lineheight = 0.95,
    colour = "#777777"
  ) +
  annotate(
    "text",
    x = 1.35, y = -0.30,
    label = "Con FP\nExp MP",
    hjust = 0, vjust = 1,
    family = "Arial", fontface = "italic",
    size = 3.2, lineheight = 0.95,
    colour = "#777777"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("BRA", "COL", "MEX"),
    labels = c("BRA", "COL", "MEX"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(-3, 2),
    breaks = -3:2,
    labels = as.character(-3:2),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(-1, 7),
    breaks = -1:7,
    labels = as.character(-1:7),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Monetary and Fiscal Policy, 2024–26",
    subtitle = "(Brazil, Colombia, Mexico)",
    x = "Change in structural primary balance\n(percentage points of potential GDP)",
    y = "Real ex ante policy rate gap\n(percentage points)",
    caption = paste0(
      "Sources: Consensus Economics; Haver Analytics; IMF, World Economic\n",
      "Outlook database; and IMF staff calculations.\n",
      "Note: The real ex ante policy rate gap is the difference between the real\n",
      "ex ante policy rate and the real neutral rate. The real ex ante policy rate is\n",
      "the difference between the nominal policy rate and the 1-year ahead\n",
      "inflation expectations. Con = contractionary; Exp = expansionary; MP =\n",
      "monetary policy; FP = fiscal policy."
    )
  ) +
  coord_cartesian(clip = "off") +
  theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_text(
      size = 9.5,
      colour = "black"
    ),
    axis.text.x = element_text(
      margin = margin(t = 5)
    ),
    axis.text.y = element_text(
      margin = margin(r = 7)
    ),
    axis.title.x = element_text(
      size = 9.5,
      lineheight = 0.95,
      margin = margin(t = 9)
    ),
    axis.title.y = element_text(
      size = 9.5,
      lineheight = 0.95,
      margin = margin(r = 10)
    ),
    plot.title = element_text(
      face = "bold",
      size = 13,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11.5,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    legend.position = "inside",
    legend.position.inside = c(0.91, 0.49),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(size = 10),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.17, "in"),
    legend.background = element_blank(),
    legend.spacing.y = grid::unit(0, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.98,
      margin = margin(t = 7)
    ),
    plot.margin = margin(7, 12, 6, 11)
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
