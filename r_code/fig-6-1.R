library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-6-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)
output_file <- file.path(figures_dir, "fig-6-1.png")

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data",
  na = c("", "#N/A")
) %>%
  mutate(
    category = as.Date(category),
    across(c(LA7, CAPDR, CARIB, USA, CAN, `LA7*`, `CAPDR*`, `CARIB*`, `USA*`, `CAN*`),
           ~ suppressWarnings(as.numeric(.x)))
  ) %>%
  filter(category >= as.Date("2024-01-01"))

historical_data <- plot_data %>%
  filter(category <= as.Date("2026-08-31")) %>%
  select(category, LA7, CAPDR, CARIB, USA, CAN) %>%
  pivot_longer(
    cols = -category,
    names_to = "series",
    values_to = "value"
  ) %>%
  filter(!is.na(value))

projection_data <- plot_data %>%
  select(category, `LA7*`, `CAPDR*`, `CARIB*`, `USA*`, `CAN*`) %>%
  pivot_longer(
    cols = -category,
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(series = sub("\\*$", "", series)) %>%
  filter(!is.na(value))

projection_start <- historical_data %>%
  group_by(series) %>%
  filter(category == max(category)) %>%
  ungroup() %>%
  select(category, series, value)

projection_lines <- bind_rows(projection_start, projection_data) %>%
  arrange(series, category)

series_levels <- c("LA7", "CARIB", "CAN", "CAPDR", "USA")
series_colors <- c(
  "LA7" = "#5B267D",
  "CARIB" = "#08A7B5",
  "CAN" = "#666666",
  "CAPDR" = "#C45A12",
  "USA" = "#0067A6"
)

historical_data <- historical_data %>%
  mutate(series = factor(series, levels = series_levels))

projection_lines <- projection_lines %>%
  mutate(series = factor(series, levels = series_levels))

projection_data <- projection_data %>%
  mutate(series = factor(series, levels = series_levels))

chart <- ggplot() +
  annotate(
    "rect",
    xmin = as.Date("2026-08-31"),
    xmax = as.Date("2026-12-31"),
    ymin = -Inf,
    ymax = Inf,
    fill = "white",
    colour = NA
  ) +
  geom_line(
    data = historical_data,
    aes(x = category, y = value, colour = series, group = series),
    linewidth = 0.85,
    lineend = "round",
    na.rm = TRUE
  ) +
  geom_line(
    data = projection_lines,
    aes(x = category, y = value, colour = series, group = series),
    linewidth = 0.85,
    linetype = "dotted",
    lineend = "round",
    show.legend = FALSE,
    na.rm = TRUE
  ) +
  geom_point(
    data = projection_data,
    aes(x = category, y = value, fill = series),
    shape = 21,
    size = 4.3,
    stroke = 0.75,
    colour = "black",
    show.legend = FALSE
  ) +
  annotate(
    "text",
    x = as.Date("2026-09-15"),
    y = 5.55,
    label = "End-2026\nprojections",
    hjust = 0.5,
    vjust = 1,
    family = "Arial",
    fontface = "italic",
    size = 3.2,
    lineheight = 0.9
  ) +
  annotate(
    "text",
    x = as.Date("2025-09-30"),
    y = 1.08,
    label = "Middle East conflict",
    hjust = 1,
    vjust = 0,
    family = "Arial",
    fontface = "italic",
    size = 3.15
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = series_levels,
    labels = series_levels,
    name = NULL
  ) +
  scale_fill_manual(
    values = series_colors,
    breaks = series_levels,
    guide = "none"
  ) +
  scale_x_date(
    limits = as.Date(c("2024-01-01", "2026-12-31")),
    breaks = as.Date(c(
      "2024-01-31", "2024-07-31", "2025-01-31",
      "2025-07-31", "2026-01-31", "2026-07-31", "2026-12-31"
    )),
    labels = c("Jan-24", "Jul-24", "Jan-25", "Jul-25", "Jan-26", "Jul-26", "Dec-26"),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(1, 6),
    breaks = 1:6,
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Headline Consumer Price Inflation",
    subtitle = "(Year-over-year percent change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; IMF, World Economic Outlook database;\n",
      "national authorities; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n",
      "= Caribbean; LA7 = Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n",
      "Uruguay."
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
    axis.text = element_text(size = 9, colour = "#111111"),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
    axis.ticks = element_line(colour = "#111111", linewidth = 0.35),
    axis.ticks.length = grid::unit(0.09, "cm"),
    axis.line = element_line(colour = "#111111", linewidth = 0.45),
    legend.position = c(0.26, 0.94),
    legend.justification = c(0.5, 1),
    legend.direction = "horizontal",
    legend.box = "vertical",
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.38, "in"),
    legend.key.height = grid::unit(0.13, "in"),
    legend.spacing.x = grid::unit(0.05, "cm"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.98,
      margin = margin(12, 0, 0, 0)
    ),
    plot.margin = margin(2, 10, 4, 10)
  ) +
  guides(
    colour = guide_legend(
      nrow = 3,
      byrow = FALSE,
      override.aes = list(linewidth = 0.85)
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
