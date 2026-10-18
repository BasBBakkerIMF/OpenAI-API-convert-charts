library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-3-4.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-3-4.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

to_date <- function(x) {
  if (inherits(x, "Date")) return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))
  as.Date(substr(as.character(x), 1, 10))
}

right_scale_factor <- 14 / 3

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(category_date = to_date(category)) %>%
  filter(
    !is.na(category_date),
    category_date >= as.Date("2021-01-01"),
    category_date <= as.Date("2026-08-31")
  ) %>%
  pivot_longer(
    cols = c(WUI, TPU, `USA (right scale)`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("WUI", "TPU", "USA (right scale)")
    ),
    plot_value = if_else(
      series == "USA (right scale)",
      value * right_scale_factor,
      value
    )
  )

series_colors <- c(
  "WUI" = "#00649D",
  "TPU" = "#D55E00",
  "USA (right scale)" = "#666666"
)

chart <- ggplot(
  plot_data,
  aes(x = category_date, y = plot_value, colour = series, group = series)
) +
  geom_line(linewidth = 0.8, lineend = "round") +
  annotate(
    "text",
    x = as.Date("2025-07-15"),
    y = 1.25,
    label = "Middle East\nconflict",
    family = "Arial",
    fontface = "italic",
    size = 3.05,
    lineheight = 0.95
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = c("WUI", "TPU", "USA (right scale)"),
    name = NULL
  ) +
  scale_x_date(
    limits = as.Date(c("2021-01-01", "2026-08-31")),
    breaks = seq(
      as.Date("2021-01-01"),
      as.Date("2026-07-01"),
      by = "6 months"
    ),
    date_labels = "%b-%y",
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 14),
    breaks = seq(0, 14, by = 2),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      trans = ~ . / right_scale_factor,
      breaks = seq(0, 3, by = 0.5),
      labels = function(x) sprintf("%.1f", x),
      name = NULL
    )
  ) +
  labs(
    title = "Overall and Trade Policy Uncertainties",
    subtitle = "(Index)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Ahir, H, N Bloom, and D Furceri (2022), “World Uncertainty\n",
      "Index”, NBER Working Paper; Caldara and others (2020); and Haver\n",
      "Analytics.\n",
      "Note: The uncertainty measures are news- and media-outlets-based\n",
      "indices that quantify media attention to global news related to overall\n",
      "uncertainty (WUI) and trade policy uncertainty (TPU). Uncertainty index\n",
      "shown for the United States is from the WUI."
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
      size = 13.5,
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
      colour = "black"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 0.5,
      vjust = 0.5,
      margin = margin(t = 5)
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.10, "cm"),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    legend.position = c(0.22, 0.88),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.15, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.15,
      lineheight = 0.96,
      margin = margin(14, 0, 0, 0)
    ),
    plot.margin = margin(3, 10, 7, 10)
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
