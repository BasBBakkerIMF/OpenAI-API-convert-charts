library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-1-1-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-1-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    category = factor(category, levels = category),
    yoy_scaled = `Year-over-year percent change (right scale)` / 10
  )

bar_data <- plot_data %>%
  select(category, `2019`, `2025`, `2026`) %>%
  pivot_longer(
    cols = c(`2019`, `2025`, `2026`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(series = factor(series, levels = c("2019", "2025", "2026")))

chart <- ggplot() +
  geom_col(
    data = bar_data,
    aes(x = category, y = value, fill = series),
    width = 0.82,
    position = position_dodge(width = 0.82)
  ) +
  geom_line(
    data = plot_data,
    aes(x = category, y = yoy_scaled, colour = "Year-over-year percent change (right scale)", group = 1),
    linewidth = 0.85,
    lineend = "round"
  ) +
  scale_fill_manual(
    values = c(
      "2019" = "#0873B2",
      "2025" = "#BFC0C2",
      "2026" = "#A982BA"
    ),
    breaks = c("2019", "2025", "2026"),
    name = NULL
  ) +
  scale_colour_manual(
    values = c("Year-over-year percent change (right scale)" = "#000000"),
    breaks = "Year-over-year percent change (right scale)",
    name = NULL
  ) +
  scale_x_discrete(
    expand = expansion(add = 0.10)
  ) +
  scale_y_continuous(
    limits = c(0, 0.8),
    breaks = seq(0, 0.8, 0.2),
    labels = function(x) sprintf("%.1f", x),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . * 10,
      breaks = seq(0, 8, 2),
      labels = function(x) sprintf("%.0f", x),
      name = NULL
    )
  ) +
  guides(
    fill = guide_legend(order = 1),
    colour = guide_legend(order = 2)
  ) +
  labs(
    title = "US Citizen Departures to the Caribbean",
    subtitle = "(Millions, unless noted otherwise)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: US International Trade Administration; and IMF staff\n",
      "calculations.\n",
      "Note: Data include 15 countries and exclude Jamaica."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13.5,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11.5,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text = element_text(
      size = 10,
      colour = "#111111"
    ),
    axis.text.x = element_text(
      margin = margin(t = 7)
    ),
    axis.text.y.left = element_text(
      margin = margin(r = 7)
    ),
    axis.text.y.right = element_text(
      margin = margin(l = 7)
    ),
    axis.line = element_line(
      colour = "#222222",
      linewidth = 0.4
    ),
    axis.ticks = element_line(
      colour = "#222222",
      linewidth = 0.4
    ),
    axis.ticks.length = grid::unit(-0.08, "cm"),
    legend.position = c(0.025, 0.985),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.box = "vertical",
    legend.box.just = "left",
    legend.text = element_text(
      size = 9.5,
      margin = margin(l = 1)
    ),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.14, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.box.spacing = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 9,
      lineheight = 0.95,
      margin = margin(t = 10)
    ),
    plot.margin = margin(4, 10, 7, 10)
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
