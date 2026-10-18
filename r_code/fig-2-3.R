library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-2-3.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-2-3.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

series_order <- c(
  "Brazil", "Chile", "Colombia", "Mexico", "Paraguay",
  "Peru", "Uruguay", "CAPDR/CARIB", "Rest of LAC"
)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(category = as.character(category))

category_order <- plot_data$category

bar_data <- plot_data %>%
  select(category, all_of(series_order)) %>%
  pivot_longer(
    cols = all_of(series_order),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    category = factor(category, levels = category_order),
    series = factor(series, levels = series_order)
  )

marker_data <- plot_data %>%
  slice_head(n = 4) %>%
  transmute(
    category = factor(as.character(category), levels = category_order),
    value = `Jan-Sep`
  )

series_colors <- c(
  "Brazil" = "#08679B",
  "Chile" = "#009999",
  "Colombia" = "#D2691E",
  "Mexico" = "#666666",
  "Paraguay" = "#8EC7E0",
  "Peru" = "#FDBF22",
  "Uruguay" = "#9B6AB0",
  "CAPDR/CARIB" = "#4F8A10",
  "Rest of LAC" = "#000000"
)

chart <- ggplot(bar_data, aes(x = category, y = value, fill = series)) +
  geom_col(width = 0.56) +
  geom_segment(
    data = marker_data %>% slice(1),
    aes(x = category, xend = category, y = 92, yend = value + 3),
    inherit.aes = FALSE,
    colour = "#A6A6A6",
    linewidth = 0.65
  ) +
  geom_point(
    data = marker_data,
    aes(x = category, y = value),
    inherit.aes = FALSE,
    shape = 21,
    size = 3.6,
    stroke = 1.1,
    fill = "red",
    colour = "black"
  ) +
  annotate(
    "text",
    x = 1,
    y = 97,
    label = "Jan-Sep",
    colour = "red",
    family = "Arial",
    size = 3.2,
    hjust = 0
  ) +
  scale_fill_manual(
    values = series_colors,
    breaks = series_order,
    name = NULL
  ) +
  scale_x_discrete(
    limits = category_order,
    expand = expansion(add = c(0.22, 0.22))
  ) +
  scale_y_continuous(
    limits = c(0, 180),
    breaks = seq(0, 180, by = 30),
    expand = expansion(mult = c(0, 0))
  ) +
  guides(
    fill = guide_legend(
      ncol = 2,
      byrow = TRUE,
      keywidth = grid::unit(0.12, "in"),
      keyheight = grid::unit(0.12, "in")
    )
  ) +
  labs(
    title = "LAC: International Bond Issuance",
    subtitle = "(Billions of US dollars)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Bond Radar; and IMF staff calculations.\n",
      "Note: Includes sovereign and corporate/financial bond issuances. CAPDR\n",
      "= Central America, Panama, and the Dominican Republic; CARIB =\n",
      "Caribbean; LAC = Latin America and the Caribbean."
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
    axis.text = element_text(size = 9, colour = "#222222"),
    axis.text.x = element_text(margin = margin(t = 7)),
    axis.ticks = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(0.11, "cm"),
    axis.line = element_line(colour = "black", linewidth = 0.45),
    legend.position = c(0.035, 1.025),
    legend.justification = c(0, 1),
    legend.text = element_text(size = 9),
    legend.key = element_rect(colour = NA),
    legend.spacing.x = grid::unit(0.08, "cm"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.4,
      lineheight = 0.96,
      margin = margin(10, 0, 0, 0)
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
