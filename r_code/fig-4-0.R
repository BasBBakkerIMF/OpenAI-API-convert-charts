library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-4-0.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-4-0.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    category = factor(category, levels = category),
    bar_midpoint = `Lower band` + (`Upper band` / 2),
    bar_height = `Upper band`,
    bar_fill = case_when(
      category %in% c("Terms of trade", "Financial conditions") ~ "#78C51C",
      category == "Uncertainty" ~ "#E1251B",
      category == "Residual" ~ "#B6B7B8",
      category == "Change in growth, 2026 vs. 2025" ~ "#5B2A73"
    )
  )

x_labels <- c(
  "Terms of trade" = "Terms of\ntrade",
  "Financial conditions" = "Financial\nconditions",
  "Uncertainty" = "Uncertainty",
  "Residual" = "Residual",
  "Change in growth, 2026 vs. 2025" = "Change in\ngrowth, 2026\nvs. 2025"
)

chart <- ggplot(
  plot_data,
  aes(
    x = category,
    y = bar_midpoint,
    height = bar_height,
    fill = bar_fill
  )
) +
  geom_tile(width = 1, colour = NA) +
  scale_fill_identity() +
  scale_x_discrete(
    labels = x_labels,
    expand = expansion(add = 0.5)
  ) +
  scale_y_continuous(
    limits = c(0, 0.8),
    breaks = seq(0, 0.8, by = 0.2),
    labels = function(x) sprintf("%.1f", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LA5: Drivers of Change in Growth, 2026",
    subtitle = "(Percent)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Ahir, H, N Bloom, and D Furceri (2022), “World Uncertainty\n",
      "Index”, NBER Working Paper; Haver Analytics; IMF, World Economic\n",
      "Outlook database; and IMF staff calculations.\n",
      "Note: Aggregate is purchasing-power-parity GDP-weighted average.\n",
      "Estimates are obtained from a local projection regression of growth on\n",
      "terms of trade, financial conditions, and uncertainty, controlling for US and\n",
      "China growth and inflation, and country- and year- fixed effects. For\n",
      "methodology and variables included in the financial conditions index, refer\n",
      "to the online annex of the October 2018 Global Financial Stability Report.\n",
      "LA5 = Latin America 5 (Brazil, Chile, Colombia, Mexico, Peru)."
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
    axis.text.x = element_text(
      size = 8.5,
      colour = "black",
      lineheight = 0.9,
      margin = margin(5, 0, 0, 0)
    ),
    axis.text.y = element_text(
      size = 9,
      colour = "black",
      margin = margin(0, 5, 0, 0)
    ),
    axis.ticks = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.x = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(-0.08, "cm"),
    axis.line = element_line(colour = "black", linewidth = 0.4),
    plot.caption = element_text(
      hjust = 0,
      size = 7.4,
      lineheight = 0.95,
      margin = margin(8, 0, 0, 0)
    ),
    plot.margin = margin(3, 10, 4, 10)
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
