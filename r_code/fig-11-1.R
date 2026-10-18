library(readxl)
library(ggplot2)
library(dplyr)
library(grid)

workbook_path <- "k:/excel_and_png/fig-11-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-11-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    series = factor(series, levels = c("USA", "CAN"))
  )

segment_data <- plot_data %>%
  group_by(series) %>%
  mutate(
    xend = lead(x),
    yend = lead(y)
  ) %>%
  filter(!is.na(xend), !is.na(yend)) %>%
  ungroup()

x_tick_data <- data.frame(x = c(-1, 0, 1, 2))
y_tick_data <- data.frame(y = seq(-1, 1.5, by = 0.5))

series_colors <- c(
  "USA" = "#0065A8",
  "CAN" = "#454545"
)

chart <- ggplot() +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.4
  ) +
  geom_vline(
    xintercept = 0,
    colour = "black",
    linewidth = 0.4
  ) +
  geom_segment(
    data = x_tick_data,
    aes(x = x, xend = x, y = 0, yend = 0.035),
    inherit.aes = FALSE,
    linewidth = 0.35,
    colour = "black"
  ) +
  geom_segment(
    data = y_tick_data,
    aes(x = 0, xend = 0.025, y = y, yend = y),
    inherit.aes = FALSE,
    linewidth = 0.35,
    colour = "black"
  ) +
  geom_segment(
    data = segment_data,
    aes(
      x = x,
      y = y,
      xend = xend,
      yend = yend,
      colour = series
    ),
    linewidth = 1.05,
    lineend = "round",
    arrow = arrow(
      angle = 25,
      length = unit(0.10, "inches"),
      type = "open"
    )
  ) +
  geom_point(
    data = plot_data,
    aes(x = x, y = y, colour = series),
    shape = 21,
    fill = "white",
    stroke = 0.8,
    size = 3.2
  ) +
  annotate(
    "text",
    x = -0.92, y = 1.51,
    label = "Exp FP\nCon MP",
    hjust = 0,
    vjust = 1,
    family = "Arial",
    fontface = "italic",
    colour = "#777777",
    size = 3.0,
    lineheight = 0.9
  ) +
  annotate(
    "text",
    x = 1.61, y = 1.48,
    label = "Con FP\nCon MP",
    hjust = 0,
    vjust = 1,
    family = "Arial",
    fontface = "italic",
    colour = "#777777",
    size = 3.0,
    lineheight = 0.9
  ) +
  annotate(
    "text",
    x = -0.94, y = -0.82,
    label = "Exp FP\nExp MP",
    hjust = 0,
    vjust = 1,
    family = "Arial",
    fontface = "italic",
    colour = "#777777",
    size = 3.0,
    lineheight = 0.9
  ) +
  annotate(
    "text",
    x = 1.59, y = -0.82,
    label = "Con FP\nExp MP",
    hjust = 0,
    vjust = 1,
    family = "Arial",
    fontface = "italic",
    colour = "#777777",
    size = 3.0,
    lineheight = 0.9
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("USA", "CAN"),
    labels = c("USA", "CAN"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(-1, 2),
    breaks = c(-1, 0, 1, 2),
    labels = function(z) sprintf("%.0f", z),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(-1, 1.5),
    breaks = seq(-1, 1.5, by = 0.5),
    labels = function(z) sprintf("%.1f", z),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Monetary and Fiscal Policy, 2024–26",
    subtitle = "(United States and Canada)",
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
  guides(
    colour = guide_legend(
      override.aes = list(
        shape = 21,
        fill = "white",
        size = 3,
        linewidth = 0.9
      )
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 12.5,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 8, 0)
    ),
    axis.title.x = element_text(
      size = 9,
      lineheight = 0.95,
      margin = margin(5, 0, 0, 0)
    ),
    axis.title.y = element_text(
      size = 9,
      lineheight = 0.95,
      margin = margin(0, 5, 0, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    legend.position = c(0.48, 0.86),
    legend.justification = c(0.5, 0.5),
    legend.direction = "vertical",
    legend.text = element_text(size = 9.5),
    legend.key.width = unit(0.42, "inches"),
    legend.key.height = unit(0.16, "inches"),
    legend.spacing.y = unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.96,
      margin = margin(8, 0, 0, 0)
    ),
    plot.margin = margin(6, 12, 6, 10)
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
