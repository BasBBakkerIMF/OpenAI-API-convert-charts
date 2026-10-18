library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "K:/excel_and_png/fig-1-2.xlsx"
output_dir <- "K:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  pivot_longer(
    cols = c(`Average pairwise gap`, `Average distance from median`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c(
        "Average pairwise gap",
        "Average distance from median"
      )
    )
  )

smooth_data <- plot_data %>%
  group_by(series) %>%
  group_modify(~ {
    fit <- stats::spline(
      x = .x$category,
      y = .x$value,
      n = 500,
      method = "natural"
    )
    tibble(category = fit$x, value = fit$y)
  }) %>%
  ungroup()

series_colors <- c(
  "Average pairwise gap" = "#0067A9",
  "Average distance from median" = "#00A3AD"
)

chart <- ggplot(
  smooth_data,
  aes(x = category, y = value, colour = series)
) +
  geom_line(
    linewidth = 0.85,
    lineend = "round"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = names(series_colors),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2000, 2025),
    breaks = seq(2000, 2025, by = 5),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 8),
    breaks = seq(0, 8, by = 2),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LAC: Growth Dispersion",
    subtitle = "(Year-over-year percentage change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: Average pairwise gap is the average absolute difference in growth\n",
      "rates across all country pairs. Average distance from median is the\n",
      "average absolute deviation of each country's growth rate from the regional\n",
      "median. Sample excludes Guyana. LAC = Latin America and the\n",
      "Caribbean."
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
      margin = margin(0, 0, 9, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "#222222"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 5)
    ),
    axis.text.y = element_text(
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
    axis.ticks.length = grid::unit(-0.08, "cm"),
    legend.position = c(0.05, 0.96),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.18, "in"),
    legend.background = element_blank(),
    legend.spacing.y = grid::unit(0.01, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.96,
      margin = margin(t = 6)
    ),
    plot.margin = margin(2, 12, 5, 10)
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
