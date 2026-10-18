library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

workbook_path <- "k:/excel_and_png/fig-2-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)
output_file <- file.path(figures_dir, "fig-2-2.png")

to_date <- function(x) {
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (inherits(x, "Date")) return(x)

  x_chr <- as.character(x)
  result <- suppressWarnings(as.Date(x_chr))
  serial <- suppressWarnings(as.numeric(x_chr))
  use_serial <- is.na(result) & !is.na(serial)
  result[use_serial] <- as.Date(serial[use_serial], origin = "1899-12-30")
  result
}

left_data <- read_excel(
  path = workbook_path,
  sheet = "datal",
  na = c("", "#N/A")
) %>%
  transmute(
    category = to_date(category),
    USA = as.numeric(USA),
    CAN = as.numeric(CAN),
    LA7 = suppressWarnings(as.numeric(LA7))
  ) %>%
  filter(
    !is.na(category),
    category >= as.Date("2024-01-01"),
    category <= as.Date("2026-09-01")
  ) %>%
  pivot_longer(
    cols = c(USA, CAN, LA7),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(series = factor(series, levels = c("USA", "CAN", "LA7")))

right_data <- read_excel(
  path = workbook_path,
  sheet = "datar",
  na = c("", "#N/A")
) %>%
  transmute(
    category = to_date(category),
    LA7 = suppressWarnings(as.numeric(LA7)),
    CAPDR = suppressWarnings(as.numeric(CAPDR)),
    CARIB = suppressWarnings(as.numeric(CARIB))
  ) %>%
  filter(
    !is.na(category),
    category >= as.Date("2024-01-01"),
    category <= as.Date("2026-09-01")
  ) %>%
  pivot_longer(
    cols = c(LA7, CAPDR, CARIB),
    names_to = "series",
    values_to = "value"
  ) %>%
  mutate(series = factor(series, levels = c("LA7", "CAPDR", "CARIB")))

date_breaks <- as.Date(c(
  "2024-01-01", "2024-07-01",
  "2025-01-01", "2025-07-01",
  "2026-01-01", "2026-07-01"
))

event_date <- as.Date("2026-01-01")

panel_theme <- theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      colour = "#777777",
      face = "bold",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 0, 0)
    ),
    plot.subtitle = element_text(
      colour = "#777777",
      face = "italic",
      size = 10,
      hjust = 0,
      margin = margin(0, 0, 10, 0)
    ),
    axis.title = element_blank(),
    axis.text = element_text(colour = "black", size = 8.5),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
    axis.ticks = element_line(colour = "black", linewidth = 0.35),
    axis.ticks.length = grid::unit(0.10, "cm"),
    axis.line = element_line(colour = "black", linewidth = 0.45),
    legend.position = c(0.08, 0.99),
    legend.justification = c(0, 1),
    legend.direction = "vertical",
    legend.title = element_blank(),
    legend.text = element_text(size = 8.5, colour = "black"),
    legend.key.width = grid::unit(0.42, "in"),
    legend.key.height = grid::unit(0.12, "in"),
    legend.spacing.y = grid::unit(-0.05, "cm"),
    legend.background = element_blank(),
    plot.margin = margin(0, 5, 0, 0)
  )

left_chart <- ggplot(
  left_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_vline(
    xintercept = event_date,
    colour = "#666666",
    linewidth = 0.45,
    linetype = "dotted"
  ) +
  geom_line(linewidth = 0.72, na.rm = TRUE) +
  annotate(
    "text",
    x = event_date - 12,
    y = 2.08,
    label = "Middle East conflict",
    hjust = 1,
    vjust = 0,
    family = "Arial",
    fontface = "italic",
    size = 2.8
  ) +
  scale_colour_manual(
    values = c(
      "USA" = "#00689D",
      "CAN" = "#404040",
      "LA7" = "#5B2A7B"
    ),
    breaks = c("USA", "CAN", "LA7"),
    drop = FALSE
  ) +
  scale_x_date(
    limits = as.Date(c("2024-01-01", "2026-09-01")),
    breaks = date_breaks,
    date_labels = "%b-%y",
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(2, 8),
    breaks = 2:8,
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Ten-year Bond Yields",
    subtitle = "(Percent)"
  ) +
  coord_cartesian(clip = "off") +
  panel_theme

right_chart <- ggplot(
  right_data,
  aes(x = category, y = value, colour = series, group = series)
) +
  geom_vline(
    xintercept = event_date,
    colour = "#666666",
    linewidth = 0.45,
    linetype = "dotted"
  ) +
  geom_line(linewidth = 0.72, na.rm = TRUE) +
  annotate(
    "text",
    x = event_date - 12,
    y = 57,
    label = "Middle East conflict",
    hjust = 1,
    vjust = 0,
    family = "Arial",
    fontface = "italic",
    size = 2.8
  ) +
  scale_colour_manual(
    values = c(
      "LA7" = "#5B2A7B",
      "CAPDR" = "#C55A11",
      "CARIB" = "#00A1A9"
    ),
    breaks = c("LA7", "CAPDR", "CARIB"),
    drop = FALSE
  ) +
  scale_x_date(
    limits = as.Date(c("2024-01-01", "2026-09-01")),
    breaks = date_breaks,
    date_labels = "%b-%y",
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(50, 400),
    breaks = seq(50, 400, 50),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Sovereign Spreads",
    subtitle = "(Basis points)"
  ) +
  coord_cartesian(clip = "off") +
  panel_theme +
  theme(plot.margin = margin(0, 0, 0, 5))

caption_text <- paste0(
  "Sources: Bloomberg Finance L.P.; and IMF staff calculations.\n",
  "Note: Aggregates are medians. Sovereign spread refers to EMBIG\n",
  "spread. CAPDR = Central America, Panama, and the Dominican\n",
  "Republic; CARIB = Caribbean; LA7 = Latin America 7 (Brazil, Chile,\n",
  "Colombia, Mexico, Paraguay, Peru, Uruguay)."
)

chart <- (left_chart | right_chart) +
  plot_layout(widths = c(1.08, 1)) +
  plot_annotation(
    title = "Yields and Spreads",
    caption = caption_text,
    theme = theme(
      plot.title = element_text(
        family = "Arial",
        face = "bold",
        size = 13,
        hjust = 0,
        margin = margin(0, 0, 4, 0)
      ),
      plot.caption = element_text(
        family = "Arial",
        size = 8.2,
        lineheight = 0.95,
        hjust = 0,
        colour = "black",
        margin = margin(12, 0, 0, 0)
      ),
      plot.margin = margin(4, 10, 7, 10)
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
