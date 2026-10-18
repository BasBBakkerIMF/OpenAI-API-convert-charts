library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-12-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-12-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    category = factor(row_number(), levels = seq_len(n())),
    fill_color = rep(c("#A6A6A6", "#A6A6A6", "#A678B5", "#A678B5"), 2)
  )

chart <- ggplot(plot_data, aes(x = category, y = series_0)) +
  geom_hline(yintercept = 0, colour = "black", linewidth = 0.35) +
  geom_col(
    aes(fill = fill_color),
    width = 0.55,
    colour = NA
  ) +
  annotate(
    "segment",
    x = seq(0.5, 8.5, by = 1),
    xend = seq(0.5, 8.5, by = 1),
    y = -1.2,
    yend = -1.42,
    linewidth = 0.35
  ) +
  annotate(
    "segment",
    x = c(0.5, 2.5, 4.5, 6.5, 8.5),
    xend = c(0.5, 2.5, 4.5, 6.5, 8.5),
    y = -1.2,
    yend = -1.98,
    linewidth = 0.35
  ) +
  annotate(
    "text",
    x = 1:8,
    y = -1.38,
    label = rep(c("6m", "12m"), 4),
    family = "Arial",
    size = 3.1
  ) +
  annotate(
    "text",
    x = c(1.5, 3.5, 5.5, 7.5),
    y = -1.67,
    label = c(
      "Strongly\nanchored",
      "Weakly\nanchored",
      "Strongly\nanchored",
      "Weakly\nanchored"
    ),
    family = "Arial",
    size = 3.1,
    lineheight = 1
  ) +
  annotate(
    "text",
    x = c(2.5, 6.5),
    y = -2.02,
    label = c("Inflation", "Consumption"),
    family = "Arial",
    size = 3.1
  ) +
  scale_fill_identity() +
  scale_x_discrete(
    expand = expansion(add = 0.5)
  ) +
  scale_y_continuous(
    breaks = seq(-1.2, 1.2, by = 0.4),
    labels = function(x) sprintf("%.1f", x),
    expand = expansion(mult = c(0, 0))
  ) +
  coord_cartesian(
    ylim = c(-1.2, 1.2),
    clip = "off"
  ) +
  labs(
    title = "Response to Terms-of-Trade Shock\nby Anchoring Level",
    subtitle = "(Percentage points)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Barrett and others (forthcoming); Bems and others (2021); and\n",
      "IMF staff calculations.\n",
      "Note: Cumulative response to month-on-month percentage change in the\n",
      "commodity terms-of-trade index (Gruss and Kebhaj 2019). Each country-\n",
      "year is classified as strongly (weakly) anchored when it is in the top\n",
      "(bottom) 25 percent of the observations of the anchoring index. Error bars\n",
      "denote 90 percent confidence intervals."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 10) +
  theme(
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(
      face = "bold",
      size = 14,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(0, 0, 1, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.line.x = element_blank(),
    axis.text.y = element_text(
      size = 9.5,
      colour = "black",
      margin = margin(r = 6)
    ),
    axis.ticks.y = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length.y = grid::unit(-0.08, "cm"),
    axis.line.y = element_line(colour = "black", linewidth = 0.4),
    plot.caption = element_text(
      size = 8.4,
      hjust = 0,
      lineheight = 0.98,
      margin = margin(t = 78)
    ),
    plot.margin = margin(4, 10, 5, 10)
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
