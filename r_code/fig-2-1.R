library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-2-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-2-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(category = factor(category, levels = category)) %>%
  pivot_longer(
    cols = c(LA5, `United States`, Canada),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("LA5", "United States", "Canada")
    )
  )

tick_data <- tibble(
  category = factor(
    levels(plot_data$category),
    levels = levels(plot_data$category)
  ),
  y = 0,
  yend = 0.035
)

series_colors <- c(
  "LA5" = "#5B267A",
  "United States" = "#0066A6",
  "Canada" = "#404040"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.45
  ) +
  geom_segment(
    data = tick_data,
    aes(x = category, xend = category, y = y, yend = yend),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_line(
    linewidth = 0.85,
    lineend = "butt"
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("LA5", "United States", "Canada"),
    name = NULL
  ) +
  scale_x_discrete(
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(-1, 0.6),
    breaks = seq(-1, 0.6, by = 0.2),
    labels = function(x) sprintf("%.1f", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Financial Conditions Index",
    subtitle = "(0 = neutral, +/− = tight/loose)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: For methodology and variables included in the financial conditions\n",
      "index, refer to the online annex of the October 2018 Global Financial\n",
      "Stability Report. LA5 is purchasing-power-parity GDP-weighted averages.\n",
      "LA5 = Latin America 5 (Brazil, Chile, Colombia, Mexico, Peru)."
    )
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(linewidth = 0.85)
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
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length.y = grid::unit(0.10, "cm"),
    axis.text.x = element_text(
      colour = "black",
      size = 9,
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 7)
    ),
    axis.text.y = element_text(
      colour = "black",
      size = 9,
      margin = margin(r = 5)
    ),
    legend.position = c(0.05, 0.49),
    legend.justification = c(0, 0.5),
    legend.text = element_text(
      size = 9,
      colour = "black"
    ),
    legend.key.width = grid::unit(0.40, "in"),
    legend.key.height = grid::unit(0.14, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.95,
      margin = margin(t = 6)
    ),
    plot.margin = margin(4, 8, 7, 9)
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
