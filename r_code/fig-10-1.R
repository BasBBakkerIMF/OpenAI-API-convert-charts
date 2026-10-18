library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-10-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-10-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    `LA7 financing premium for LC 10y yields (right scale)` =
      suppressWarnings(as.numeric(
        `LA7 financing premium for LC 10y yields (right scale)`
      )),
    plot_position = row_number(),
    year_group = rep(c("2003", "2010", "2020", "2025", "2031"), each = 2)
  )

debt_data <- plot_data %>%
  select(
    plot_position,
    `LA7 gross debt`,
    `OEM gross debt`
  ) %>%
  pivot_longer(
    cols = c(`LA7 gross debt`, `OEM gross debt`),
    names_to = "debt_series",
    values_to = "gross_debt"
  ) %>%
  filter(!is.na(gross_debt)) %>%
  mutate(
    bar_left = plot_position - 0.28,
    bar_right = plot_position + 0.28
  )

premium_data <- plot_data %>%
  filter(
    plot_position %% 2 == 1,
    !is.na(`LA7 financing premium for LC 10y yields (right scale)`)
  ) %>%
  transmute(
    segment_left = plot_position - 0.05,
    segment_right = plot_position + 1.05,
    premium_plot_value =
      20 + 7.5 * `LA7 financing premium for LC 10y yields (right scale)`
  )

year_data <- tibble(
  plot_position = c(1.5, 3.5, 5.5, 7.5, 9.5),
  year_group = c("2003", "2010", "2020", "2025", "2031")
)

chart <- ggplot() +
  geom_rect(
    data = debt_data,
    aes(
      xmin = bar_left,
      xmax = bar_right,
      ymin = 20,
      ymax = gross_debt,
      fill = debt_series
    ),
    colour = NA
  ) +
  geom_segment(
    data = premium_data,
    aes(
      x = segment_left,
      xend = segment_right,
      y = premium_plot_value,
      yend = premium_plot_value
    ),
    colour = "black",
    linewidth = 0.75,
    lineend = "butt"
  ) +
  annotate(
    "segment",
    x = 0.95, xend = 1.90,
    y = 77.7, yend = 77.7,
    colour = "#C7A6D0",
    linewidth = 3.7,
    lineend = "butt"
  ) +
  annotate(
    "text",
    x = 2.02, y = 77.7,
    label = "LA7 gross debt",
    hjust = 0, vjust = 0.5,
    family = "Arial", size = 3.15
  ) +
  annotate(
    "segment",
    x = 0.95, xend = 1.90,
    y = 73.2, yend = 73.2,
    colour = "#69B5DE",
    linewidth = 3.7,
    lineend = "butt"
  ) +
  annotate(
    "text",
    x = 2.02, y = 73.2,
    label = "OEM gross debt",
    hjust = 0, vjust = 0.5,
    family = "Arial", size = 3.15
  ) +
  annotate(
    "segment",
    x = 0.95, xend = 1.90,
    y = 68.7, yend = 68.7,
    colour = "black",
    linewidth = 0.75,
    lineend = "butt"
  ) +
  annotate(
    "text",
    x = 2.02, y = 68.7,
    label = "LA7 financing premium for LC 10y yields (right scale)",
    hjust = 0, vjust = 0.5,
    family = "Arial", size = 3.15
  ) +
  geom_text(
    data = year_data,
    aes(x = plot_position, y = 13.7, label = year_group),
    family = "Arial",
    size = 3.1,
    inherit.aes = FALSE
  ) +
  scale_fill_manual(
    values = c(
      "LA7 gross debt" = "#C7A6D0",
      "OEM gross debt" = "#69B5DE"
    ),
    guide = "none"
  ) +
  scale_x_continuous(
    limits = c(0.5, 10.5),
    breaks = 1:10,
    labels = rep(c("LA7", "OEM"), 5),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    breaks = seq(20, 80, by = 10),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = 0),
    sec.axis = sec_axis(
      transform = ~ (. - 20) / 7.5,
      breaks = seq(0, 8, by = 2),
      labels = function(x) sprintf("%d", x),
      name = NULL
    )
  ) +
  coord_cartesian(
    xlim = c(0.5, 10.5),
    ylim = c(20, 80),
    clip = "off"
  ) +
  labs(
    title = "General Government Gross Debt and\nFinancing Cost",
    subtitle = "(Percent of GDP; unless noted otherwise)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: Haver Analytics; IMF, World Economic Outlook database; and\n",
      "IMF staff calculations.\n",
      "Note: Financing cost in percentage points is the difference between LA7\n",
      "and OEM's nominal 10-year local currency bond yields. Aggregates are\n",
      "simple averages. LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n",
      "Paraguay, Peru, Uruguay); OEM = other emerging markets (Bosnia and\n",
      "Herzegovina, Hungary, India, Indonesia, Malaysia, Philippines, Poland,\n",
      "Romania, Serbia, Thailand)."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13,
      lineheight = 0.9,
      hjust = 0,
      margin = margin(0, 0, 2, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 10.5,
      hjust = 0,
      margin = margin(0, 0, 8, 0)
    ),
    axis.text = element_text(
      size = 8.8,
      colour = "black"
    ),
    axis.text.x = element_text(
      size = 8.8,
      margin = margin(4, 0, 0, 0)
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.10, "cm"),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    legend.position = "none",
    plot.caption = element_text(
      hjust = 0,
      size = 7.8,
      lineheight = 0.96,
      margin = margin(27, 0, 0, 0)
    ),
    plot.margin = margin(4, 12, 5, 7)
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
