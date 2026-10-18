library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-9-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-9-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  pivot_longer(
    cols = c(LA7, `EM Asia`, `EM Europe`, Canada),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("LA7", "EM Asia", "EM Europe", "Canada")
    )
  )

series_colors <- c(
  "LA7" = "#7030A0",
  "EM Asia" = "#00A6AD",
  "EM Europe" = "#C65911",
  "Canada" = "#404040"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_line(
    linewidth = 0.85,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("LA7", "EM Asia", "EM Europe", "Canada"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2000, 2031),
    breaks = seq(2000, 2030, by = 5),
    labels = function(x) sprintf("%d", as.integer(x)),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(30, 110),
    breaks = seq(30, 110, by = 20),
    labels = function(x) sprintf("%d", as.integer(x)),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Total Factor Productivity Relative to the US",
    subtitle = "(Percent)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; Penn World Table 11.0\n",
      "database; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP–weighted averages.\n",
      "EM = emerging; EM Asia = India, Indonesia, Malaysia, Philippines,\n",
      "Thailand; EM Europe = Hungary, Poland, Romania, Serbia; LA7 = Latin\n",
      "America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    )
  ) +
  guides(
    colour = guide_legend(
      nrow = 1,
      byrow = TRUE,
      override.aes = list(linewidth = 0.85)
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
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
      size = 9.5,
      colour = "#111111"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5
    ),
    axis.ticks = element_line(
      colour = "#111111",
      linewidth = 0.4
    ),
    axis.ticks.length = grid::unit(0.10, "cm"),
    axis.line = element_line(
      colour = "#111111",
      linewidth = 0.5
    ),
    legend.position = c(0.50, 0.985),
    legend.justification = c(0.5, 1),
    legend.direction = "horizontal",
    legend.text = element_text(size = 9.5),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.14, "in"),
    legend.spacing.x = grid::unit(0.04, "in"),
    legend.background = element_blank(),
    plot.caption = element_text(
      size = 8.5,
      hjust = 0,
      lineheight = 0.96,
      margin = margin(10, 0, 0, 0)
    ),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.margin = margin(3, 9, 4, 9)
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
