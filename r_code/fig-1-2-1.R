library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "k:/excel_and_png/fig-1-2-1.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-1-2-1.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    chart_date = as.Date(category),
    GTM_plot = coalesce(GTM, `GTM(est)`),
    HND_plot = coalesce(HND, `HND(est)`),
    SLV_plot = coalesce(SLV, `SLV(est)`),
    NIC_plot = coalesce(NIC, `NIC(est)`),
    apprehensions_plot = `Apprehensions (right scale)` / 4000
  )

bar_data <- plot_data %>%
  select(chart_date, GTM_plot, HND_plot, SLV_plot, NIC_plot) %>%
  pivot_longer(
    cols = c(GTM_plot, HND_plot, SLV_plot, NIC_plot),
    names_to = "country",
    values_to = "repatriations"
  ) %>%
  mutate(
    country = factor(
      country,
      levels = c("GTM_plot", "HND_plot", "SLV_plot", "NIC_plot"),
      labels = c("GTM", "HND", "SLV", "NIC")
    ),
    repatriations = repatriations / 1000
  )

line_data <- plot_data %>%
  select(chart_date, apprehensions_plot) %>%
  filter(!is.na(chart_date), !is.na(apprehensions_plot))

country_colors <- c(
  "GTM" = "#0070C0",
  "HND" = "#00A6A6",
  "SLV" = "#ED7D31",
  "NIC" = "#BFBFBF"
)

x_breaks <- seq(
  from = as.Date("2020-01-01"),
  to = as.Date("2026-06-01"),
  by = "7 months"
)

caption_text <- paste0(
  "Sources: US Customs and Border Protection; US Department of\n",
  "Homeland Security; US Immigration and Customs Enforcement (ICE); and\n",
  "IMF staff estimates.\n",
  "Note: Repatriations include removals, administrative and enforcement\n",
  "returns. Title 42 expulsions are not included. Since December 2024,\n",
  "repatriations are estimated using ICE book-ins. The repatriations to book-\n",
  "ins ratio is calculated through November 2024 and projected to remain\n",
  "constant. Since data for book-ins are published through June 2026, this\n",
  "allows to estimate the repatriations in 2026."
)

chart <- ggplot() +
  geom_col(
    data = bar_data,
    aes(x = chart_date, y = repatriations, fill = country),
    width = 24,
    position = "stack",
    na.rm = TRUE
  ) +
  geom_line(
    data = line_data,
    aes(x = chart_date, y = apprehensions_plot),
    colour = "black",
    linewidth = 1.15,
    lineend = "round",
    linejoin = "round"
  ) +
  geom_vline(
    xintercept = as.Date("2024-12-15"),
    colour = "black",
    linewidth = 0.4,
    linetype = "dotted"
  ) +
  annotate(
    "text",
    x = as.Date("2025-04-01"),
    y = 19.45,
    label = "Estimates",
    family = "Arial",
    fontface = "italic",
    size = 3.4,
    hjust = 0
  ) +
  annotate(
    "text",
    x = as.Date("2021-09-01"),
    y = 16.25,
    label = "Apprehensions\n(right scale)",
    family = "Arial",
    size = 3.25,
    lineheight = 0.88,
    hjust = 0
  ) +
  scale_fill_manual(
    values = country_colors,
    breaks = c("GTM", "HND", "SLV", "NIC"),
    name = NULL
  ) +
  scale_x_date(
    limits = c(as.Date("2020-01-01"), as.Date("2026-06-30")),
    breaks = x_breaks,
    labels = function(x) format(x, "%b-%y"),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 20),
    breaks = seq(0, 16, by = 4),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . * 4,
      breaks = seq(0, 80, by = 20),
      labels = function(x) sprintf("%d", x),
      name = NULL
    )
  ) +
  labs(
    title = "Repatriations and Border Apprehensions",
    subtitle = "(Thousands)",
    x = NULL,
    y = NULL,
    caption = caption_text
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
      angle = 90,
      hjust = 1,
      vjust = 0.5
    ),
    axis.text.y = element_text(
      size = 9,
      colour = "black"
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.09, "cm"),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    legend.position = c(0.015, 0.985),
    legend.justification = c(0, 1),
    legend.direction = "horizontal",
    legend.text = element_text(size = 8.8),
    legend.key.width = grid::unit(0.13, "in"),
    legend.key.height = grid::unit(0.13, "in"),
    legend.spacing.x = grid::unit(0.03, "in"),
    legend.background = element_blank(),
    plot.caption = element_text(
      hjust = 0,
      size = 7.7,
      lineheight = 0.94,
      margin = margin(11, 0, 0, 0)
    ),
    plot.margin = margin(4, 10, 5, 10)
  ) +
  guides(
    fill = guide_legend(
      nrow = 1,
      byrow = TRUE,
      override.aes = list(colour = NA)
    )
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
