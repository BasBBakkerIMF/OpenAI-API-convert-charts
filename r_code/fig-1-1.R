library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-1-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    CAPDR = suppressWarnings(as.numeric(CAPDR)),
    category = factor(category, levels = unique(category))
  ) %>%
  pivot_longer(
    cols = c(USA, CAN, LA7, CAPDR),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(series, levels = c("USA", "CAN", "LA7", "CAPDR"))
  )

series_colors <- c(
  "USA" = "#0069A6",
  "CAN" = "#444444",
  "LA7" = "#682C82",
  "CAPDR" = "#C95A0C"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_line(
    linewidth = 0.75,
    lineend = "round",
    na.rm = TRUE
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("USA", "CAN", "LA7", "CAPDR"),
    name = NULL
  ) +
  scale_x_discrete(
    drop = FALSE,
    expand = expansion(add = c(0.5, 0.5))
  ) +
  scale_y_continuous(
    limits = c(0, 5),
    breaks = 0:5,
    labels = as.character,
    expand = expansion(mult = c(0, 0))
  ) +
  guides(
    colour = guide_legend(
      ncol = 2,
      byrow = TRUE,
      keywidth = grid::unit(0.42, "in"),
      keyheight = grid::unit(0.14, "in")
    )
  ) +
  labs(
    title = "Real GDP Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; IMF , World Economic Outlook database; and\n",
      "IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted average.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; LA7 =\n",
      "Latin America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n",
      "Uruguay)."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      size = 13.5,
      face = "bold",
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      size = 11,
      face = "italic",
      hjust = 0,
      margin = margin(0, 0, 8, 0)
    ),
    axis.text.x = element_text(
      size = 9,
      colour = "#222222",
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 5)
    ),
    axis.text.y = element_text(
      size = 9,
      colour = "#222222",
      margin = margin(r = 6)
    ),
    axis.line = element_line(
      colour = "#222222",
      linewidth = 0.4
    ),
    axis.ticks = element_line(
      colour = "#222222",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(-0.07, "cm"),
    legend.position = c(0.02, 0.025),
    legend.justification = c(0, 0),
    legend.direction = "horizontal",
    legend.text = element_text(size = 9),
    legend.background = element_blank(),
    legend.key = element_blank(),
    legend.spacing.x = grid::unit(0.12, "cm"),
    legend.spacing.y = grid::unit(0, "cm"),
    plot.caption = element_text(
      size = 8.5,
      hjust = 0,
      lineheight = 0.98,
      margin = margin(t = 8)
    ),
    plot.caption.position = "plot",
    plot.title.position = "plot",
    plot.margin = margin(3, 8, 6, 11)
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
