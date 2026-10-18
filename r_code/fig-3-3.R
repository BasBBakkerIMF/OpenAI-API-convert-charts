library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-3-3.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-3-3.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(category = factor(category, levels = category)) %>%
  pivot_longer(
    cols = c(`February 2026`, `May 2026`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("February 2026", "May 2026")
    )
  )

tick_data <- plot_data %>%
  distinct(category)

chart <- ggplot(plot_data, aes(x = category, y = value, fill = series)) +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_segment(
    data = tick_data,
    aes(x = category, xend = category, y = 0, yend = -0.12),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.3
  ) +
  geom_col(
    position = position_dodge(width = 0.76),
    width = 0.35
  ) +
  scale_fill_manual(
    values = c(
      "February 2026" = "#C9ADD5",
      "May 2026" = "#00689D"
    ),
    breaks = c("February 2026", "May 2026"),
    name = NULL
  ) +
  scale_x_discrete(
    expand = expansion(add = c(0.15, 0.15))
  ) +
  scale_y_continuous(
    limits = c(-2, 7),
    breaks = seq(-2, 7, by = 1),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Change in Commodity Terms of Trade",
    subtitle = "(Percent change relative to January 2025)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, Commodity Terms of Trade database; and IMF staff\n",
      "calculations.\n",
      "Note: Commodity net export price index, individual commodities weighted\n",
      "by ratio of net exports to GDP."
    )
  ) +
  guides(
    fill = guide_legend(
      nrow = 1,
      byrow = TRUE,
      keywidth = grid::unit(0.11, "in"),
      keyheight = grid::unit(0.11, "in")
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
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.3
    ),
    axis.ticks.length.y = grid::unit(-0.08, "cm"),
    axis.text.x = element_text(
      colour = "black",
      size = 9,
      margin = margin(t = 7)
    ),
    axis.text.y = element_text(
      colour = "black",
      size = 9,
      margin = margin(r = 7)
    ),
    legend.position = c(0.69, 0.91),
    legend.justification = c(0.5, 0.5),
    legend.direction = "horizontal",
    legend.text = element_text(size = 9),
    legend.spacing.x = grid::unit(0.05, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.95,
      margin = margin(10, 0, 0, 0)
    ),
    plot.margin = margin(3, 10, 5, 10)
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
