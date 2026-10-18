library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-15-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-15-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    category_plot = factor(category, levels = category)
  )

chart <- ggplot(
  plot_data,
  aes(x = category_plot, y = series_0)
) +
  geom_col(
    width = 0.56,
    fill = "#5B2875"
  ) +
  scale_x_discrete(
    expand = expansion(add = c(0.28, 0.28))
  ) +
  scale_y_continuous(
    limits = c(0, 8),
    breaks = seq(0, 8, by = 2),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Effect of 2025 US Tariffs on China on LAC Imports\nfrom China",
    subtitle = "(Predicted change in imports from China; percent)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Arizala, Schauer, and Grittayaphong (forthcoming); and IMF staff\n",
      "calculations."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(0, 0, 2, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11.5,
      hjust = 0,
      margin = margin(0, 0, 16, 0)
    ),
    axis.text.x = element_text(
      size = 10,
      colour = "black",
      margin = margin(6, 0, 0, 0)
    ),
    axis.text.y = element_text(
      size = 10,
      colour = "black",
      margin = margin(0, 6, 0, 0)
    ),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    axis.ticks.length.y = grid::unit(-0.10, "cm"),
    panel.grid = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 9.5,
      lineheight = 0.95,
      margin = margin(11, 0, 0, 0)
    ),
    plot.margin = margin(3, 13, 7, 10)
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
