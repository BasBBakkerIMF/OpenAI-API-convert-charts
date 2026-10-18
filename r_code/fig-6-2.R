library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-6-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-6-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
)

curve_data <- plot_data %>%
  filter(series == "LAC", !is.na(x), !is.na(y)) %>%
  arrange(x)

average_data <- plot_data %>%
  filter(series == "LAC average", !is.na(x), !is.na(y)) %>%
  arrange(y)

y_ticks <- data.frame(
  y = seq(0.2, 1, by = 0.2),
  x = 0,
  xend = 0.035
)

chart <- ggplot() +
  geom_line(
    data = curve_data,
    aes(x = x, y = y),
    colour = "#5B2678",
    linewidth = 0.9,
    lineend = "round"
  ) +
  geom_line(
    data = average_data,
    aes(x = x, y = y),
    colour = "#5B2678",
    linewidth = 0.55,
    linetype = "dashed",
    lineend = "butt"
  ) +
  geom_segment(
    aes(x = 0, xend = 0, y = 0, yend = 1),
    colour = "black",
    linewidth = 0.3
  ) +
  geom_segment(
    data = y_ticks,
    aes(x = x, xend = xend, y = y, yend = y),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.3
  ) +
  scale_x_continuous(
    limits = c(-0.5, 2.5),
    breaks = seq(-0.5, 2.5, by = 0.5),
    labels = function(z) sprintf("%.1f", z),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = NULL,
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LAC: Oil Price Pass-through",
    subtitle = "(Fraction)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Vertical dashed line refers to the median of the region. AE =\n",
      "advanced economies; Pass-through is calculated as the percentage\n",
      "change in domestic dollar retail diesel prices over the percentage change\n",
      "in international diesel prices (both measured in US dollars). Pass-through\n",
      "is trimmed at the 1 percent level. LAC = Latin America and the Caribbean."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 12,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text.x = element_text(
      size = 9.5,
      colour = "black",
      margin = margin(t = 5)
    ),
    axis.text.y = element_blank(),
    axis.ticks.x = element_line(colour = "black", linewidth = 0.3),
    axis.ticks.y = element_blank(),
    axis.ticks.length.x = grid::unit(-0.10, "cm"),
    axis.line.x = element_line(colour = "black", linewidth = 0.3),
    axis.line.y = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.98,
      margin = margin(t = 8)
    ),
    plot.margin = margin(2, 11, 5, 10)
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
