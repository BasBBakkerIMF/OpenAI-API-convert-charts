library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-1-2-3.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-2-3.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(ci_hi = ci_lo + range)

chart <- ggplot(
  plot_data,
  aes(x = category)
) +
  geom_ribbon(
    aes(ymin = ci_lo, ymax = ci_hi),
    fill = "#FCE4D4",
    alpha = 0.9
  ) +
  geom_hline(
    yintercept = 0,
    colour = "#333333",
    linewidth = 0.45
  ) +
  geom_vline(
    xintercept = 0,
    colour = "#111111",
    linewidth = 0.65,
    linetype = "dotted"
  ) +
  geom_segment(
    data = filter(plot_data, category != 0),
    aes(
      x = category,
      xend = category,
      y = 0,
      yend = 0.55
    ),
    inherit.aes = FALSE,
    colour = "#333333",
    linewidth = 0.35
  ) +
  geom_line(
    aes(y = coef),
    colour = "#C85C0A",
    linewidth = 1.05,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_x_continuous(
    limits = c(-6, 6),
    breaks = seq(-6, 6, 1),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(-15, 15),
    breaks = seq(-15, 15, 5),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "CA4: Enforcement Impact on Remittance Growth",
    subtitle = "(Percentage points)",
    x = "Months relative to shock",
    y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Estimated response of remittance growth to changes in immigration\n",
      "enforcement based on panel local projections (Carare and others\n",
      "(forthcoming)). Regressions include country and time fixed effects and\n",
      "macroeconomic controls. Shaded area denotes 90 percent wild cluster\n",
      "bootstrap confidence intervals."
    )
  ) +
  coord_cartesian(clip = "on") +
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
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.title.x = element_text(
      size = 9,
      margin = margin(7, 0, 0, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "#111111"
    ),
    axis.text.x = element_text(
      margin = margin(5, 0, 0, 0)
    ),
    axis.text.y = element_text(
      margin = margin(0, 5, 0, 0)
    ),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(
      colour = "#333333",
      linewidth = 0.35
    ),
    axis.ticks.length.y = grid::unit(-0.09, "cm"),
    axis.line.x = element_blank(),
    axis.line.y = element_line(
      colour = "#333333",
      linewidth = 0.45
    ),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.97,
      margin = margin(5, 0, 0, 0)
    ),
    plot.margin = margin(2, 10, 5, 10)
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
