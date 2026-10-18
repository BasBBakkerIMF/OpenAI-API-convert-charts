library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-16-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-16-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

series_order <- c(
  "Manufacturing",
  "Mining",
  "ICT and data",
  "Business services",
  "Other"
)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  pivot_longer(
    cols = all_of(series_order),
    names_to = "sector",
    values_to = "value"
  ) %>%
  mutate(
    sector = factor(sector, levels = series_order)
  )

series_colors <- c(
  "Manufacturing" = "#5B2A7E",
  "Mining" = "#C75B12",
  "ICT and data" = "#00649A",
  "Business services" = "#009A9A",
  "Other" = "#B8BCBE"
)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, fill = sector)
) +
  geom_col(
    width = 0.56,
    position = position_stack(reverse = TRUE)
  ) +
  scale_fill_manual(
    values = series_colors,
    breaks = series_order,
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2012.5, 2025.5),
    breaks = seq(2013, 2025, by = 2),
    labels = function(x) sprintf("%d", as.integer(x)),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(0, 300),
    breaks = seq(0, 300, by = 60),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LAC: Composition of FDI Capital Expenditure",
    subtitle = "(Billions of US dollars, annual levels)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Orbis Crossborder Investment database; and IMF staff\n",
      "calculations.\n",
      "Note: Years are announcement years and cover announced and\n",
      "completed projects. Latest available data as of September 2, 2026. FDI =\n",
      "foreign direct investments; ICT = information and communications\n",
      "technology and data; LAC = Latin America and the Caribbean."
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
      margin = margin(0, 0, 10, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "#111111"
    ),
    axis.ticks = element_line(
      colour = "#111111",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.10, "cm"),
    axis.line = element_line(
      colour = "#111111",
      linewidth = 0.45
    ),
    legend.position = c(0.045, 0.995),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.13, "in"),
    legend.key.height = grid::unit(0.14, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.96,
      margin = margin(10, 0, 0, 0)
    ),
    plot.margin = margin(2, 9, 7, 10)
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
