library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-3-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-3-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data",
  col_types = c("date", rep("numeric", 6))
) %>%
  mutate(date = as.Date(category)) %>%
  filter(
    !is.na(date),
    date >= as.Date("2025-01-01"),
    date <= as.Date("2026-09-30")
  ) %>%
  select(
    date, Oil, Copper, `Iron ore`, Soybeans, Coffee,
    `Gold (right scale)`
  ) %>%
  pivot_longer(
    cols = -date,
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c(
        "Oil", "Copper", "Iron ore", "Soybeans", "Coffee",
        "Gold (right scale)"
      )
    ),
    plot_value = if_else(
      series == "Gold (right scale)",
      value - 30,
      value
    )
  )

series_colors <- c(
  "Oil" = "#0065A0",
  "Copper" = "#00A6B2",
  "Iron ore" = "#C55A11",
  "Soybeans" = "#7F7F7F",
  "Coffee" = "#5DADE2",
  "Gold (right scale)" = "#FFA500"
)

series_widths <- c(
  "Oil" = 1.05,
  "Copper" = 0.58,
  "Iron ore" = 0.58,
  "Soybeans" = 0.58,
  "Coffee" = 0.58,
  "Gold (right scale)" = 0.58
)

x_breaks <- as.Date(c(
  "2025-01-01", "2025-05-01", "2025-09-01",
  "2026-01-01", "2026-05-01", "2026-09-01"
))

conflict_date <- as.Date("2026-03-01")

chart <- ggplot(
  plot_data,
  aes(
    x = date,
    y = plot_value,
    colour = series,
    linewidth = series,
    group = series
  )
) +
  geom_line(
    lineend = "round",
    linejoin = "round",
    na.rm = TRUE
  ) +
  geom_vline(
    xintercept = conflict_date,
    colour = "black",
    linewidth = 0.5,
    linetype = "dotted"
  ) +
  annotate(
    "text",
    x = conflict_date - 8,
    y = 73,
    label = "Middle East conflict",
    family = "Arial",
    fontface = "italic",
    size = 3.4,
    hjust = 1,
    vjust = 0.5
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = names(series_colors),
    drop = FALSE,
    name = NULL
  ) +
  scale_linewidth_manual(
    values = series_widths,
    breaks = names(series_widths),
    guide = "none"
  ) +
  scale_x_date(
    limits = as.Date(c("2025-01-01", "2026-09-30")),
    breaks = x_breaks,
    labels = function(x) format(x, "%b-%y"),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(70, 190),
    breaks = seq(70, 190, by = 30),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . + 30,
      breaks = seq(100, 220, by = 30),
      name = NULL
    )
  ) +
  labs(
    title = "Commodity Prices",
    subtitle = "(Index: January 1, 2025 = 100)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Bloomberg Finance L.P.; and IMF staff calculations.\n",
      "Note: Oil is the average petroleum spot price. Copper is from the London\n",
      "Metal Exchange. Iron ore is Shanghai SteelHome E-Commerce.\n",
      "Soybeans is from the Chicago Board of Trade. Coffee refers to the\n",
      "international coffee composite indicator price."
    )
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(
        linewidth = c(1.05, 0.58, 0.58, 0.58, 0.58, 0.58)
      )
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13.5,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.title = element_blank(),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.10, "cm"),
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    legend.position = c(0.20, 0.83),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(
      size = 8.6,
      colour = "black"
    ),
    legend.key.width = grid::unit(0.45, "in"),
    legend.key.height = grid::unit(0.13, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.margin = margin(0, 0, 0, 0),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.25,
      lineheight = 0.98,
      margin = margin(12, 0, 0, 0)
    ),
    plot.margin = margin(4, 9, 6, 10)
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
