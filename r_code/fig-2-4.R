library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-2-4.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-2-4.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    category = factor(category, levels = unique(category))
  ) %>%
  pivot_longer(
    cols = c(LA7, `EM Asia`, `EM Europe`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(series, levels = c("LA7", "EM Asia", "EM Europe"))
  )

category_levels <- levels(plot_data$category)

chart <- ggplot(
  plot_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_line(
    linewidth = 0.85,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_colour_manual(
    values = c(
      "LA7" = "#5B267A",
      "EM Asia" = "#00A3AD",
      "EM Europe" = "#D05A0D"
    ),
    breaks = c("LA7", "EM Asia", "EM Europe"),
    name = NULL
  ) +
  scale_x_discrete(
    breaks = category_levels[seq(1, length(category_levels), by = 2)],
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 7),
    breaks = 0:7,
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "US Holdings of Foreign Bonds",
    subtitle = "(Percent share of total world)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; and IMF staff calculations.\n",
      "Note: LA7 excludes Paraguay due to data limitations. EM = emerging\n",
      "markets; EM Asia = India, Indonesia, Malaysia, Philippines, Thailand; EM\n",
      "Europe = Hungary, Poland, Romania, Serbia; LA7 = Latin America 7\n",
      "(Brazil, Chile, Colombia, Mexico, Paraguay, Peru)."
    )
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(linewidth = 0.85),
      keywidth = grid::unit(0.42, "in"),
      keyheight = grid::unit(0.13, "in")
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
      margin = margin(0, 0, 12, 0)
    ),
    axis.text = element_text(
      size = 9.5,
      colour = "black"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 5)
    ),
    axis.text.y = element_text(
      margin = margin(r = 7)
    ),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(-0.08, "cm"),
    legend.position = c(0.065, 0.985),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.text = element_text(
      size = 9.5,
      margin = margin(l = 0)
    ),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.margin = margin(0, 0, 0, 0),
    legend.background = element_blank(),
    legend.key = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.96,
      margin = margin(t = 8)
    ),
    plot.margin = margin(2, 12, 6, 10)
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
