library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-14-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-14-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    `CTOT (index: 2000 = 100; right scale)` =
      as.numeric(`CTOT (index: 2000 = 100; right scale)`),
    range_upper = Min + `Min-Max range`,
    CTOT_plot = 4 * (`CTOT (index: 2000 = 100; right scale)` - 103)
  )

series_colors <- c(
  "Structural primary balance" = "#5B2A78",
  "CTOT (index: 2000 = 100; right scale)" = "#A2A39D"
)

chart <- ggplot(plot_data, aes(x = category)) +
  geom_ribbon(
    aes(ymin = Min, ymax = range_upper),
    fill = "#E9DFEE",
    alpha = 0.62
  ) +
  geom_line(
    aes(
      y = `Structural primary balance`,
      colour = "Structural primary balance"
    ),
    linewidth = 0.9,
    lineend = "round",
    na.rm = TRUE
  ) +
  geom_line(
    aes(
      y = CTOT_plot,
      colour = "CTOT (index: 2000 = 100; right scale)"
    ),
    linewidth = 0.9,
    lineend = "round",
    na.rm = TRUE
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = names(series_colors),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2004.5, 2027.5),
    breaks = seq(2005, 2027, by = 2),
    labels = function(x) sprintf("%d", round(x)),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(-12, 8),
    breaks = seq(-12, 8, by = 4),
    labels = function(x) sprintf("%d", round(x)),
    expand = expansion(mult = 0),
    sec.axis = sec_axis(
      ~ . / 4 + 103,
      breaks = 100:105,
      labels = function(x) sprintf("%d", round(x)),
      name = NULL
    )
  ) +
  guides(
    colour = guide_legend(
      ncol = 1,
      byrow = TRUE,
      override.aes = list(linewidth = 0.9)
    )
  ) +
  labs(
    title = paste0(
      "LA8 excl. Mexico: Structural Primary Balance and\n",
      "Commodity Terms of Trade"
    ),
    subtitle = "(Percent of GDP; unless noted otherwise)",
    x = NULL,
    y = NULL,
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
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(0, 0, 1, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "#111111"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5
    ),
    axis.ticks = element_line(
      colour = "#111111",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(-0.08, "cm"),
    axis.text.y.left = element_text(
      margin = margin(r = 8)
    ),
    axis.text.y.right = element_text(
      margin = margin(l = 8)
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 7)
    ),
    axis.line = element_line(
      colour = "#111111",
      linewidth = 0.4
    ),
    legend.position = c(0.03, 0.03),
    legend.justification = c(0, 0),
    legend.text = element_text(
      size = 9,
      margin = margin(l = -3)
    ),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.15, "in"),
    legend.background = element_blank(),
    legend.spacing.y = grid::unit(0, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.98,
      margin = margin(12, 0, 0, 0)
    ),
    plot.margin = margin(5, 10, 7, 10)
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
