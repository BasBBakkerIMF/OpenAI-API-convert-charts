library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-3-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-3-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  pivot_longer(
    cols = c(USA, CAN, LA7, CAPDR, CARIB),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("USA", "CAN", "LA7", "CAPDR", "CARIB")
    )
  )

tick_data <- plot_data %>%
  distinct(category)

series_colors <- c(
  "USA" = "#0067A5",
  "CAN" = "#454545",
  "LA7" = "#5C277E",
  "CAPDR" = "#D26717",
  "CARIB" = "#00A3A3"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_hline(
    yintercept = 100,
    colour = "#222222",
    linewidth = 0.35
  ) +
  geom_segment(
    data = tick_data,
    aes(
      x = category,
      xend = category,
      y = 100,
      yend = 100.45
    ),
    inherit.aes = FALSE,
    colour = "#222222",
    linewidth = 0.3
  ) +
  geom_line(
    linewidth = 0.8,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("USA", "CAN", "LA7", "CAPDR", "CARIB"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2018.5, 2026.5),
    breaks = 2019:2026,
    labels = function(x) sprintf("%d", as.integer(x)),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(90, 125),
    breaks = seq(90, 125, 5),
    labels = function(x) sprintf("%d", as.integer(x)),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Terms of Trade",
    subtitle = "(Index: 2019 = 100)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay)."
    )
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(linewidth = 0.8)
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 10) +
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
      colour = "#111111"
    ),
    axis.text.x = element_text(
      margin = margin(t = 7)
    ),
    axis.text.y = element_text(
      margin = margin(r = 6)
    ),
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "#222222",
      linewidth = 0.4
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "#222222",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.08, "cm"),
    legend.position = c(0.035, 0.97),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.text = element_text(
      size = 9.5,
      margin = margin(l = 1)
    ),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.15, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.4,
      lineheight = 0.96,
      margin = margin(t = 10)
    ),
    plot.margin = margin(4, 10, 5, 10)
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
