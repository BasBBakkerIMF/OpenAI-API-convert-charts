library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-1-2-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-2-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data",
  col_types = c("date", "numeric", "numeric", "numeric")
) %>%
  mutate(
    category_date = as.Date(category),
    band_upper = Min + `Min-Max Band`
  )

chart <- ggplot(
  plot_data,
  aes(x = category_date)
) +
  geom_ribbon(
    aes(ymin = Min, ymax = band_upper),
    fill = "#FCE5D6",
    colour = NA
  ) +
  geom_hline(
    yintercept = 0,
    colour = "#BFBFBF",
    linewidth = 0.35
  ) +
  geom_line(
    aes(y = `Total remittances`),
    colour = "#C55A11",
    linewidth = 1.15,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_x_date(
    limits = as.Date(c("2023-12-15", "2026-06-15")),
    breaks = seq(
      as.Date("2024-01-01"),
      as.Date("2026-05-01"),
      by = "2 months"
    ),
    date_labels = "%b-%y",
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(-10, 50),
    breaks = seq(-10, 50, by = 10),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Remittances to CA4 Countries",
    subtitle = "(Year-over-year percent change)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; national authorities; and IMF staff calculations.\n",
      "Note: Nicaragua’s 2025–26H1 data are IMF staff estimates. CA4 =\n",
      "Central America 4 (El Salvador, Guatemala, Honduras, Nicaragua)."
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
    axis.text = element_text(
      size = 9,
      colour = "#111111"
    ),
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      margin = margin(t = 5)
    ),
    axis.text.y = element_text(
      margin = margin(r = 5)
    ),
    axis.ticks = element_line(
      colour = "#111111",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(-0.10, "cm"),
    axis.line = element_line(
      colour = "#111111",
      linewidth = 0.4
    ),
    plot.caption = element_text(
      hjust = 0,
      size = 7.8,
      lineheight = 1.05,
      margin = margin(12, 0, 0, 0)
    ),
    plot.margin = margin(2, 8, 6, 6)
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
