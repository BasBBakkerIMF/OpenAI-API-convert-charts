library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-1-1-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-1-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    across(c(Dummy1, Dummy2, Dummy3, Dummy4), as.numeric),
    blue_upper = Dummy1,
    blue_lower = Dummy1 + Dummy2,
    orange_upper = Dummy1 + Dummy2 + Dummy3,
    orange_lower = Dummy1 + Dummy2 + Dummy3 + Dummy4
  )

chart <- ggplot(plot_data, aes(x = category)) +
  geom_ribbon(
    aes(ymin = blue_lower, ymax = blue_upper),
    fill = "#DCEEF8",
    alpha = 1
  ) +
  geom_ribbon(
    aes(ymin = orange_lower, ymax = orange_upper),
    fill = "#F6E7DA",
    alpha = 0.9
  ) +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.45
  ) +
  geom_segment(
    data = data.frame(category = 0:6),
    aes(x = category, xend = category, y = 0, yend = 0.35),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_line(
    aes(
      y = `Point estimate (2005–14)`,
      colour = "Point estimate (2005–14)"
    ),
    linewidth = 1.05,
    lineend = "round"
  ) +
  geom_line(
    aes(
      y = `Point estimate (2015–24)`,
      colour = "Point estimate (2015–24)"
    ),
    linewidth = 1.05,
    lineend = "round"
  ) +
  geom_line(
    aes(
      y = `Inflation change (2026, simple average)`,
      colour = "Inflation change (2026, simple average)"
    ),
    linewidth = 1.05,
    lineend = "round",
    na.rm = TRUE
  ) +
  scale_colour_manual(
    values = c(
      "Point estimate (2005–14)" = "#0065A4",
      "Point estimate (2015–24)" = "#C85A0A",
      "Inflation change (2026, simple average)" = "#00A7A7"
    ),
    breaks = c(
      "Point estimate (2005–14)",
      "Point estimate (2015–24)",
      "Inflation change (2026, simple average)"
    ),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(-0.5, 6.5),
    breaks = 0:6,
    labels = as.character(0:6),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(-6, 12),
    breaks = seq(-6, 12, by = 3),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Caribbean Inflation Response to the Oil Price\nShocks",
    subtitle = "(Percentage points difference since shock month)",
    x = "Months",
    y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: The oil price shock corresponds to about 40-percent increase in oil\n",
      "prices, as materialized in March relative to the January–February 2026\n",
      "average. The inflation response is annualized. Shaded bands represent\n",
      "90 percent Driscoll-Kraay confidence intervals."
    )
  ) +
  guides(
    colour = guide_legend(
      override.aes = list(linewidth = 1.05)
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13,
      lineheight = 0.93,
      hjust = 0,
      margin = margin(0, 0, 1, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 9, 0)
    ),
    axis.title.x = element_text(
      size = 9,
      margin = margin(8, 0, 0, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.text.x = element_text(
      margin = margin(5, 0, 0, 0)
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length.y = grid::unit(0.08, "cm"),
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    legend.position = c(0.10, 0.01),
    legend.justification = c(0, 0),
    legend.direction = "vertical",
    legend.text = element_text(size = 8.5),
    legend.key.width = grid::unit(0.31, "in"),
    legend.key.height = grid::unit(0.13, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.3,
      lineheight = 0.97,
      margin = margin(8, 0, 0, 0)
    ),
    plot.margin = margin(5, 7, 4, 7)
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
