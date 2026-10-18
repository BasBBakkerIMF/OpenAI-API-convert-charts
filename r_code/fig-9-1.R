library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-9-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-9-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    plot_position = row_number(),
    category_display = rep(c("LA7", "EME", "EMA", "USA", "CAN"), 2)
  )

stack_data <- bind_rows(
  plot_data %>%
    transmute(
      plot_position,
      component = "Total factor productivity",
      ymin = pmin(0, `Total factor productivity`),
      ymax = pmax(0, `Total factor productivity`)
    ),
  plot_data %>%
    transmute(
      plot_position,
      component = "Labor",
      ymin = pmax(0, `Total factor productivity`),
      ymax = pmax(0, `Total factor productivity`) + Labor
    ),
  plot_data %>%
    transmute(
      plot_position,
      component = "Capital stock",
      ymin = pmax(0, `Total factor productivity`) + Labor,
      ymax = pmax(0, `Total factor productivity`) + Labor + `Capital stock`
    )
) %>%
  mutate(
    component = factor(
      component,
      levels = c("Total factor productivity", "Labor", "Capital stock")
    )
  )

category_separators <- data.frame(
  x = c(1.5, 2.5, 3.5, 4.5, 6.5, 7.5, 8.5, 9.5)
)

group_separators <- data.frame(
  x = c(0.5, 5.5, 10.5)
)

chart <- ggplot() +
  geom_rect(
    data = stack_data,
    aes(
      xmin = plot_position - 0.28,
      xmax = plot_position + 0.28,
      ymin = ymin,
      ymax = ymax,
      fill = component
    ),
    linewidth = 0
  ) +
  geom_point(
    data = plot_data,
    aes(x = plot_position, y = `Real GDP growth`),
    shape = 16,
    size = 3.8,
    colour = "black"
  ) +
  geom_hline(yintercept = 0, colour = "black", linewidth = 0.45) +
  geom_segment(
    data = category_separators,
    aes(x = x, xend = x, y = -0.08, yend = -0.98),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_segment(
    aes(x = 0.5, xend = 10.5, y = -1, yend = -1),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_segment(
    data = group_separators,
    aes(x = x, xend = x, y = -0.08, yend = -2.02),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.4
  ) +
  geom_text(
    data = plot_data,
    aes(x = plot_position, y = -0.56, label = category_display),
    family = "Arial",
    size = 3.45,
    colour = "black"
  ) +
  annotate(
    "text",
    x = c(3, 8),
    y = -1.49,
    label = c("2000–19", "2026–31"),
    family = "Arial",
    size = 3.45
  ) +
  annotate(
    "rect",
    xmin = 4.00, xmax = 4.17,
    ymin = 6.48, ymax = 6.69,
    fill = "#009DA8",
    colour = NA
  ) +
  annotate(
    "rect",
    xmin = 4.00, xmax = 4.17,
    ymin = 6.05, ymax = 6.26,
    fill = "#0065A8",
    colour = NA
  ) +
  annotate(
    "rect",
    xmin = 4.00, xmax = 4.17,
    ymin = 5.62, ymax = 5.83,
    fill = "#CE5B13",
    colour = NA
  ) +
  annotate(
    "point",
    x = 4.085,
    y = 5.28,
    shape = 16,
    size = 3.2,
    colour = "black"
  ) +
  annotate(
    "text",
    x = 4.22,
    y = c(6.585, 6.155, 5.725, 5.28),
    label = c(
      "Total factor productivity",
      "Labor",
      "Capital stock",
      "Real GDP growth"
    ),
    hjust = 0,
    vjust = 0.5,
    family = "Arial",
    size = 3.35,
    colour = "black"
  ) +
  scale_fill_manual(
    values = c(
      "Total factor productivity" = "#009DA8",
      "Labor" = "#0065A8",
      "Capital stock" = "#CE5B13"
    ),
    guide = "none"
  ) +
  scale_x_continuous(
    limits = c(0.5, 10.5),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(-1, 7),
    breaks = -1:7,
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0))
  ) +
  coord_cartesian(clip = "off") +
  labs(
    title = "Contributions to Real GDP Growth",
    subtitle = "(Year-over-year percent change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; Penn World Table 11.0\n",
      "database; and IMF staff calculations.\n",
      "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n",
      "EM = emerging; EMA = EM Asia (India, Indonesia, Malaysia, Philippines,\n",
      "Thailand); EME = EM Europe (Bosnia and Herzegovina, Hungary, Poland,\n",
      "Romania, Serbia); LA7 = Latin America 7 (Brazil, Chile, Colombia,\n",
      "Mexico, Paraguay; Peru, Uruguay)."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
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
    axis.line.x = element_blank(),
    axis.line.y = element_line(colour = "black", linewidth = 0.4),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(
      size = 9,
      colour = "black",
      margin = margin(r = 5)
    ),
    axis.ticks.y = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length.y = grid::unit(-0.08, "cm"),
    legend.position = "none",
    plot.caption = element_text(
      family = "Arial",
      size = 8.2,
      lineheight = 0.94,
      hjust = 0,
      margin = margin(t = 43)
    ),
    plot.margin = margin(3, 12, 5, 10)
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
