library(readxl)
library(ggplot2)
library(dplyr)
library(patchwork)

workbook_path <- "k:/excel_and_png/fig-1-3-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-3-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

category_levels <- c("Mexico", "Canada")

left_data <- read_excel(
  path = workbook_path,
  sheet = "datal"
) %>%
  mutate(
    category = factor(category, levels = category_levels),
    export_scaled = `(% goods exports)` / 2.5
  )

right_data <- read_excel(
  path = workbook_path,
  sheet = "datar"
) %>%
  mutate(
    category = factor(category, levels = category_levels),
    export_scaled = `Percent of exports (right scale)` / 2.5
  )

bar_colors <- c(
  "Mexico" = "#08649B",
  "Canada" = "#CB6418"
)

panel_theme <- theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    plot.title = element_text(
      colour = "#7F7F7F",
      face = "bold",
      size = 11.5,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(0, 0, 14, 0)
    ),
    axis.title = element_blank(),
    axis.text = element_text(colour = "black", size = 10),
    axis.text.x = element_text(margin = margin(t = 7)),
    axis.text.y = element_text(margin = margin(r = 7)),
    axis.ticks = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(-0.08, "cm"),
    axis.line = element_line(colour = "black", linewidth = 0.4),
    panel.grid = element_blank(),
    legend.position = "none",
    plot.margin = margin(0, 6, 0, 0)
  )

left_panel <- ggplot(
  left_data,
  aes(x = category)
) +
  geom_col(
    aes(y = `(% GDP)`, fill = category),
    width = 0.56
  ) +
  geom_point(
    aes(y = export_scaled),
    shape = 1,
    size = 3.8,
    stroke = 1.2,
    colour = "black"
  ) +
  scale_fill_manual(values = bar_colors) +
  scale_x_discrete(expand = expansion(add = c(0.28, 0.28))) +
  scale_y_continuous(
    limits = c(0, 40),
    breaks = seq(0, 40, 10),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . * 2.5,
      breaks = seq(0, 100, 25),
      name = NULL
    )
  ) +
  labs(
    title = "Canada and Mexico Exports\nto the United States"
  ) +
  panel_theme +
  theme(
    plot.margin = margin(0, 18, 0, 0)
  )

right_panel <- ggplot(
  right_data,
  aes(x = category)
) +
  geom_col(
    aes(y = `Percent of GDP`, fill = category),
    width = 0.56
  ) +
  geom_point(
    aes(y = export_scaled),
    shape = 1,
    size = 3.8,
    stroke = 1.2,
    colour = "black"
  ) +
  annotate(
    "point",
    x = 0.68, y = 39.2,
    shape = 0, size = 3,
    stroke = 0.8
  ) +
  annotate(
    "text",
    x = 0.79, y = 39.2,
    label = "Percent of GDP",
    hjust = 0, vjust = 0.5,
    family = "Arial", size = 3.2
  ) +
  annotate(
    "point",
    x = 0.70, y = 34.8,
    shape = 1, size = 3,
    stroke = 0.9
  ) +
  annotate(
    "text",
    x = 0.81, y = 34.8,
    label = "Percent of exports\n(right scale)",
    hjust = 0, vjust = 0.5,
    family = "Arial", size = 3.2,
    lineheight = 0.95
  ) +
  scale_fill_manual(values = bar_colors) +
  scale_x_discrete(expand = expansion(add = c(0.28, 0.28))) +
  scale_y_continuous(
    limits = c(0, 40),
    breaks = seq(0, 40, 10),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . * 2.5,
      breaks = seq(0, 100, 25),
      name = NULL
    )
  ) +
  labs(
    title = "United States Exports to\nCanada and Mexico"
  ) +
  panel_theme +
  theme(
    plot.margin = margin(0, 0, 0, 6)
  )

chart <- left_panel + right_panel +
  plot_layout(widths = c(1, 1), guides = "collect") +
  plot_annotation(
    title = "Exports of Goods",
    caption = paste0(
      "Sources: Haver Analytics; national authorities; and IMF staff calculations."
    ),
    theme = theme(
      plot.background = element_rect(fill = "white", colour = NA),
      plot.title = element_text(
        family = "Arial",
        face = "bold",
        size = 14,
        hjust = 0,
        margin = margin(0, 0, 4, 0)
      ),
      plot.caption = element_text(
        family = "Arial",
        size = 9.5,
        hjust = 0,
        colour = "black",
        margin = margin(12, 0, 0, 0)
      ),
      plot.margin = margin(4, 10, 4, 10)
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
