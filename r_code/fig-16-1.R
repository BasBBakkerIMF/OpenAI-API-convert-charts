library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-16-1.xlsx"
output_dir <- "k:/r_code/figures"
output_file <- file.path(output_dir, "fig-16-1.png")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  pivot_longer(
    cols = c(`Capital expenditure`, `Project-count`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("Capital expenditure", "Project-count")
    )
  )

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_line(linewidth = 0.9, lineend = "round") +
  scale_colour_manual(
    values = c(
      "Capital expenditure" = "#0066A6",
      "Project-count" = "#C8580A"
    ),
    breaks = c("Capital expenditure", "Project-count"),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2004.5, 2025.5),
    breaks = 2005:2025,
    labels = function(x) ifelse(x %% 5 == 0, sprintf("%d", x), ""),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(4, 16),
    breaks = seq(4, 16, by = 2),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LAC: Share of FDI Global Greenfield Investment",
    subtitle = "(Percent of world total; three-year trailing moving\naverage)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Orbis Crossborder Investment (OCBI) database; and IMF staff\n",
      "calculations.\n",
      "Note: Shares are computed on announcement years relative to all\n",
      "destination economies in the database and cover announced and\n",
      "completed projects. Latest available data as of September 2, 2026. FDI =\n",
      "foreign direct investments; LAC = Latin America and the Caribbean."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13,
      hjust = 0,
      margin = margin(0, 0, 1, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text = element_text(size = 9, colour = "black"),
    axis.text.x = element_text(margin = margin(t = 6)),
    axis.text.y = element_text(margin = margin(r = 6)),
    axis.line = element_line(colour = "black", linewidth = 0.4),
    axis.ticks = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(-0.10, "cm"),
    legend.position = c(0.045, 0.965),
    legend.justification = c(0, 1),
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.16, "in"),
    legend.background = element_blank(),
    legend.margin = margin(0, 0, 0, 0),
    legend.spacing.y = grid::unit(0, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.96,
      margin = margin(11, 0, 0, 0)
    ),
    plot.margin = margin(5, 12, 3, 10)
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
