library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-10-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-10-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    `October 2025 WEO` = suppressWarnings(as.numeric(`October 2025 WEO`))
  ) %>%
  pivot_longer(
    cols = c(`October 2026 WEO`, `April 2026 WEO`, `October 2025 WEO`),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(
    series = factor(
      series,
      levels = c("October 2026 WEO", "April 2026 WEO", "October 2025 WEO")
    )
  )

series_colors <- c(
  "October 2026 WEO" = "#5B267A",
  "April 2026 WEO" = "#8752AA",
  "October 2025 WEO" = "#AD7CC5"
)

series_linetypes <- c(
  "October 2026 WEO" = "solid",
  "April 2026 WEO" = "52",
  "October 2025 WEO" = "22"
)

chart <- ggplot(
  plot_data,
  aes(
    x = category,
    y = value,
    colour = series,
    linetype = series,
    group = series
  )
) +
  geom_hline(
    yintercept = 0,
    colour = "black",
    linewidth = 0.4
  ) +
  geom_segment(
    data = data.frame(category = 2021:2031),
    aes(
      x = category,
      xend = category,
      y = 0,
      yend = 0.065
    ),
    inherit.aes = FALSE,
    colour = "black",
    linewidth = 0.35
  ) +
  geom_line(
    linewidth = 0.85,
    lineend = "round",
    na.rm = TRUE
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = names(series_colors),
    name = NULL
  ) +
  scale_linetype_manual(
    values = series_linetypes,
    breaks = names(series_linetypes),
    name = NULL
  ) +
  scale_x_continuous(
    limits = c(2021, 2031),
    breaks = seq(2021, 2031, by = 2),
    labels = function(x) sprintf("%d", as.integer(x)),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(-3, 0.5),
    breaks = seq(-3, 0.5, by = 0.5),
    labels = function(x) sprintf("%.1f", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "LA7: General Government Structural Primary\nBalance",
    subtitle = "(Percent of potential GDP)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations.\n",
      "Note: LA7 is simple average. Chile refers to the central government’s\n",
      "structural non-mining primary balance. Colombia refers to the\n",
      "consolidated public sector's structural non-oil primary balance. Peru refers\n",
      "to the nonfinancial public sector’s structural primary balance. LA7 = Latin\n",
      "America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 12.5,
      lineheight = 0.9,
      hjust = 0,
      margin = margin(0, 0, 2, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 9, 0)
    ),
    axis.line.x = element_blank(),
    axis.line.y = element_line(colour = "black", linewidth = 0.4),
    axis.text = element_text(size = 9, colour = "black"),
    axis.text.x = element_text(margin = margin(t = 7)),
    axis.text.y = element_text(margin = margin(r = 5)),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(0.09, "cm"),
    legend.position = c(0.74, 0.145),
    legend.justification = c(0.5, 0),
    legend.text = element_text(size = 8.8),
    legend.key.width = grid::unit(0.56, "in"),
    legend.key.height = grid::unit(0.15, "in"),
    legend.spacing.y = grid::unit(0, "cm"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 8.2,
      lineheight = 0.96,
      margin = margin(10, 0, 0, 0)
    ),
    plot.margin = margin(4, 11, 5, 10)
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
