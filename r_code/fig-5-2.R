library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-5-2.xlsx"
output_dir <- "k:/r_code/figures"
output_file <- file.path(output_dir, "fig-5-2.png")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    CAPDR = suppressWarnings(as.numeric(CAPDR)),
    category = factor(category, levels = unique(category))
  ) %>%
  pivot_longer(
    cols = c(USA, CAN, LA7, CAPDR, `World trade volume`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("USA", "CAN", "LA7", "CAPDR", "World trade volume")
    )
  )

tick_data <- tibble(
  category = factor(
    levels(plot_data$category),
    levels = levels(plot_data$category)
  )
)

series_colors <- c(
  "USA" = "#0868A4",
  "CAN" = "#444444",
  "LA7" = "#62317D",
  "CAPDR" = "#C75B0A",
  "World trade volume" = "#00A6A6"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.4
  ) +
  geom_segment(
    data = tick_data,
    aes(x = category, xend = category, y = 0, yend = 0.22),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.3
  ) +
  geom_line(
    linewidth = 0.85,
    lineend = "round",
    na.rm = TRUE
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = names(series_colors),
    name = NULL
  ) +
  scale_x_discrete(
    drop = FALSE,
    expand = expansion(add = 0.5)
  ) +
  scale_y_continuous(
    limits = c(-6, 9),
    breaks = seq(-6, 9, by = 3),
    labels = function(x) sprintf("%g", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Real Exports Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: CPB Netherlands Bureau for Economic Policy Analysis; Haver\n",
      "Analytics; national authorities; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; LA7 =\n",
      "Latin America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n",
      "Uruguay)."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(
      size = 13,
      face = "bold",
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      size = 11,
      face = "italic",
      hjust = 0,
      margin = margin(0, 0, 9, 0)
    ),
    axis.text.y = element_text(
      size = 9,
      colour = "black",
      margin = margin(r = 5)
    ),
    axis.text.x = element_text(
      size = 9,
      colour = "black",
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 5)
    ),
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.3
    ),
    axis.ticks.length.y = grid::unit(0.08, "cm"),
    legend.position = c(0.04, 0.03),
    legend.justification = c(0, 0),
    legend.direction = "vertical",
    legend.text = element_text(size = 9, colour = "black"),
    legend.key.width = grid::unit(0.40, "in"),
    legend.key.height = grid::unit(0.13, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      size = 8.3,
      lineheight = 0.96,
      hjust = 0,
      margin = margin(t = 10)
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
