library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-5-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-5-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  pivot_longer(
    cols = c(LA7, CAPDR, CARIB, `CAN (right scale)`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("LA7", "CAPDR", "CARIB", "CAN (right scale)")
    ),
    plot_value = if_else(
      series == "CAN (right scale)",
      (value + 2) / 0.4,
      value
    )
  )

series_colors <- c(
  "LA7" = "#5B2A7F",
  "CAPDR" = "#CE5A0A",
  "CARIB" = "#009EAD",
  "CAN (right scale)" = "#666666"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = plot_value, colour = series, group = series)
) +
  geom_line(
    linewidth = 0.85,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("LA7", "CAPDR", "CARIB", "CAN (right scale)"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2018.5, 2026.5),
    breaks = 2019:2026,
    labels = function(x) sprintf("%d", round(x)),
    expand = expansion(mult = 0),
    sec.axis = dup_axis(labels = NULL, name = NULL)
  ) +
  scale_y_continuous(
    limits = c(-75, -50),
    breaks = seq(-75, -50, by = 5),
    labels = function(x) sprintf("%d", round(x)),
    expand = expansion(mult = 0),
    sec.axis = sec_axis(
      transform = ~ 0.4 * . - 2,
      breaks = seq(-32, -22, by = 2),
      labels = function(x) sprintf("%d", round(x)),
      name = NULL
    )
  ) +
  labs(
    title = "Labor Productivity Gap against the United States",
    subtitle = "(Percent of US labor productivity)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Labor productivity is measured as real GDP in PPP international\n",
      "dollars divided by total employment. The gap is measured as the\n",
      "difference in the level of labor productivity relative to the United States.\n",
      "Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay); PPP = purchasing power parity."
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
      margin = margin(0, 0, 8, 0)
    ),
    panel.border = element_rect(
      colour = "black",
      fill = NA,
      linewidth = 0.4
    ),
    axis.line = element_blank(),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.text.x = element_text(
      margin = margin(t = 5)
    ),
    axis.text.y.left = element_text(
      margin = margin(r = 5)
    ),
    axis.text.y.right = element_text(
      margin = margin(l = 5)
    ),
    axis.text.x.top = element_blank(),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.08, "cm"),
    legend.position = c(0.79, 0.84),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.13, "in"),
    legend.background = element_blank(),
    legend.spacing.y = grid::unit(0, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8,
      lineheight = 0.95,
      margin = margin(12, 0, 0, 0)
    ),
    plot.margin = margin(5, 10, 5, 8)
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
