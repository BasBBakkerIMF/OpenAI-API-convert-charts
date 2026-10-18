library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

workbook_path <- "k:/excel_and_png/fig-7-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-7-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

series_order <- c(
  "Tilted to the upside",
  "Tilted to the downside",
  "Balanced"
)

series_colors <- c(
  "Tilted to the upside" = "#C55A11",
  "Tilted to the downside" = "#FFC000",
  "Balanced" = "#7F4AA3"
)

left_data <- read_excel(
  path = workbook_path,
  sheet = "datal"
) %>%
  mutate(.position = row_number()) %>%
  pivot_longer(
    cols = all_of(c(
      "Balanced",
      "Tilted to the downside",
      "Tilted to the upside"
    )),
    names_to = ".series",
    values_to = ".value"
  ) %>%
  mutate(.series = factor(.series, levels = series_order))

right_data <- read_excel(
  path = workbook_path,
  sheet = "datar"
) %>%
  mutate(
    .row = row_number(),
    .position = if_else(.row <= 5, .row, .row + 1)
  ) %>%
  pivot_longer(
    cols = all_of(c(
      "Balanced",
      "Tilted to the downside",
      "Tilted to the upside"
    )),
    names_to = ".series",
    values_to = ".value"
  ) %>%
  mutate(.series = factor(.series, levels = series_order))

common_theme <- theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    axis.title.y = element_blank(),
    axis.text = element_text(size = 9, colour = "black"),
    axis.line = element_line(colour = "black", linewidth = 0.4),
    axis.ticks = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(-0.10, "cm"),
    axis.text.y = element_text(margin = margin(r = 7)),
    panel.grid = element_blank()
  )

left_chart <- ggplot(
  left_data,
  aes(x = .position, y = .value, fill = .series)
) +
  geom_col(width = 0.72) +
  geom_segment(
    aes(x = 2.5, xend = 2.5, y = -25, yend = 0),
    inherit.aes = FALSE,
    linewidth = 0.4
  ) +
  scale_fill_manual(values = series_colors, breaks = series_order) +
  scale_x_continuous(
    limits = c(0.35, 2.65),
    breaks = c(1, 2),
    labels = c("Growth", "Inflation"),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    expand = expansion(mult = c(0, 0))
  ) +
  coord_cartesian(clip = "off") +
  labs(x = "WHD") +
  guides(fill = "none") +
  common_theme +
  theme(
    axis.title.x = element_text(
      size = 9,
      margin = margin(t = 7)
    ),
    plot.margin = margin(4, 7, 33, 0)
  )

right_chart <- ggplot(
  right_data,
  aes(x = .position, y = .value, fill = .series)
) +
  geom_col(width = 0.68) +
  geom_segment(
    aes(x = 0.5, xend = 0.5, y = -24, yend = 0),
    inherit.aes = FALSE,
    linewidth = 0.4
  ) +
  geom_segment(
    aes(x = 5.5, xend = 5.5, y = -24, yend = 0),
    inherit.aes = FALSE,
    linewidth = 0.4
  ) +
  geom_segment(
    aes(x = 6.5, xend = 6.5, y = -24, yend = 0),
    inherit.aes = FALSE,
    linewidth = 0.4
  ) +
  geom_segment(
    aes(x = 11.5, xend = 11.5, y = -24, yend = 0),
    inherit.aes = FALSE,
    linewidth = 0.4
  ) +
  annotate(
    "text",
    x = 3,
    y = -23.5,
    label = "Growth",
    family = "Arial",
    size = 3
  ) +
  annotate(
    "text",
    x = 9,
    y = -23.5,
    label = "Inflation",
    family = "Arial",
    size = 3
  ) +
  scale_fill_manual(
    values = series_colors,
    breaks = series_order,
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(0.5, 11.5),
    breaks = c(1:5, 7:11),
    labels = rep(c("AE", "LA7", "OTSA", "CAPDR", "CARIB"), 2),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 60),
    breaks = seq(0, 50, 10),
    expand = expansion(mult = c(0, 0))
  ) +
  coord_cartesian(clip = "off") +
  labs(x = NULL) +
  common_theme +
  theme(
    axis.text.x = element_text(
      angle = 90,
      hjust = 0.5,
      vjust = 0.5,
      margin = margin(t = 8)
    ),
    legend.position = c(0.55, 0.82),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(size = 8.5),
    legend.key.width = grid::unit(0.12, "in"),
    legend.key.height = grid::unit(0.12, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.margin = margin(0, 0, 0, 0),
    legend.background = element_blank(),
    plot.margin = margin(4, 0, 33, 7)
  )

chart <- (left_chart | right_chart) +
  plot_layout(widths = c(0.75, 1.4)) +
  plot_annotation(
    title = "Western Hemisphere: Growth and Inflation Risks",
    subtitle = "(Percent share of total number of WHD countries)",
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: AE = advanced economies; CAPDR = Central America, Panama,\n",
      "and the Dominican Republic; CARIB = Caribbean; LA7 = Latin America 7\n",
      "(Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay); OTSA =\n",
      "other South America."
    ),
    theme = theme(
      text = element_text(family = "Arial", colour = "black"),
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
        margin = margin(0, 0, 6, 0)
      ),
      plot.caption = element_text(
        size = 8.5,
        lineheight = 0.95,
        hjust = 0,
        margin = margin(5, 0, 0, 0)
      ),
      plot.margin = margin(5, 8, 5, 9)
    )
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
