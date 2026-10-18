library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-7-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-7-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
)

series_order <- c(
  "USA",
  "CAN",
  "LA7",
  "CAPDR",
  "CARIB (excl. GUY/SUR)",
  "CARIB (right scale)"
)

chart_data <- plot_data %>%
  pivot_longer(
    cols = c(
      USA,
      CAN,
      LA7,
      CAPDR,
      `CARIB (excl. GUY/SUR)`,
      `CARIB (right scale)`
    ),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(series, levels = series_order),
    plot_value = if_else(
      series == "CARIB (right scale)",
      (value - 4) / 2,
      value
    )
  )

series_colors <- c(
  "USA" = "#145A8D",
  "CAN" = "#4D4D4D",
  "LA7" = "#66338A",
  "CAPDR" = "#C95A0A",
  "CARIB (excl. GUY/SUR)" = "#00A1A9",
  "CARIB (right scale)" = "#00A1A9"
)

series_linetypes <- c(
  "USA" = "solid",
  "CAN" = "solid",
  "LA7" = "solid",
  "CAPDR" = "solid",
  "CARIB (excl. GUY/SUR)" = "solid",
  "CARIB (right scale)" = "dashed"
)

chart <- ggplot(
  chart_data,
  aes(
    x = category,
    y = plot_value,
    colour = series,
    linetype = series,
    group = series
  )
) +
  geom_line(
    linewidth = 0.85,
    lineend = "round"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = series_order,
    name = NULL
  ) +
  scale_linetype_manual(
    values = series_linetypes,
    breaks = series_order,
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2021.5, 2028.5),
    breaks = 2022:2028,
    labels = function(x) sprintf("%d", round(x)),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 6),
    breaks = 0:6,
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . * 2 + 4,
      breaks = seq(4, 16, by = 2),
      name = NULL
    )
  ) +
  labs(
    title = "Real GDP Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted average.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay)."
    )
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(linewidth = 0.85),
      keywidth = grid::unit(0.55, "in")
    ),
    linetype = guide_legend(
      override.aes = list(linewidth = 0.85),
      keywidth = grid::unit(0.55, "in")
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.text.x = element_text(
      margin = margin(t = 7)
    ),
    axis.text.y.left = element_text(
      margin = margin(r = 7)
    ),
    axis.text.y.right = element_text(
      margin = margin(l = 7)
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(-0.08, "cm"),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    legend.position = c(0.73, 0.82),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(
      size = 9,
      lineheight = 0.9
    ),
    legend.key.height = grid::unit(0.14, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.95,
      margin = margin(13, 0, 0, 0)
    ),
    plot.margin = margin(3, 10, 5, 10)
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
