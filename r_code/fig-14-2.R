library(readxl)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(patchwork)

workbook_path <- "k:/excel_and_png/fig-14-2.xlsx"
output_dir <- "k:/r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-14-2.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- bind_rows(
  read_excel(workbook_path, sheet = "datal") %>%
    mutate(panel = "2005–12"),
  read_excel(workbook_path, sheet = "datar") %>%
    mutate(panel = "2023–26")
) %>%
  mutate(
    category = factor(
      x,
      levels = c(1, 2),
      labels = c("Exports", "Consumption")
    ),
    plot_label = if_else(
      panel == "2023–26" & label == "ARG" & x == 1,
      "ARG (12.5)",
      label
    )
  )

make_panel <- function(data, show_y_axis = TRUE) {
  p <- ggplot(data, aes(x = x, y = y, group = x)) +
    geom_boxplot(
      aes(fill = category),
      width = 0.58,
      linewidth = 0.45,
      colour = "black",
      outlier.shape = NA
    ) +
    geom_point(
      colour = "#61257D",
      size = 2.8
    ) +
    geom_text_repel(
      aes(label = plot_label),
      colour = "#61257D",
      size = 3.05,
      family = "Arial",
      direction = "y",
      hjust = 0,
      nudge_x = 0.17,
      box.padding = 0.08,
      point.padding = 0.05,
      min.segment.length = 0,
      segment.colour = "#A0A0A0",
      segment.size = 0.3,
      max.overlaps = Inf,
      seed = 142,
      xlim = c(0.95, 2.65),
      ylim = c(0.15, 7.95)
    ) +
    annotate(
      "segment",
      x = c(0.46, 0.46),
      xend = c(0.58, 0.58),
      y = c(7.28, 7.52),
      yend = c(7.48, 7.72),
      linewidth = 0.45,
      colour = "#555555"
    ) +
    scale_fill_manual(
      values = c(
        "Exports" = "#A8DFE1",
        "Consumption" = "#FFD77D"
      ),
      guide = "none"
    ) +
    scale_x_continuous(
      limits = c(0.5, 2.7),
      breaks = c(1, 2),
      labels = c("Exports", "Consumption"),
      expand = expansion(mult = 0)
    ) +
    scale_y_continuous(
      limits = c(0, 8),
      breaks = c(0, 2, 4, 6, 8),
      labels = c("0", "2", "4", "6", "14"),
      expand = expansion(mult = c(0, 0))
    ) +
    coord_cartesian(clip = "off") +
    labs(
      x = unique(data$panel),
      y = NULL
    ) +
    theme_classic(base_family = "Arial", base_size = 9.5) +
    theme(
      axis.line = element_line(colour = "black", linewidth = 0.45),
      axis.ticks = element_line(colour = "black", linewidth = 0.4),
      axis.ticks.length = grid::unit(-0.08, "cm"),
      axis.text.x = element_text(
        size = 9.5,
        colour = "black",
        margin = margin(t = 8)
      ),
      axis.text.y = element_text(
        size = 9.5,
        colour = "black",
        margin = margin(r = 8)
      ),
      axis.title.x = element_text(
        size = 9.5,
        colour = "black",
        margin = margin(t = 12)
      ),
      plot.margin = margin(3, 6, 0, 6)
    )

  if (!show_y_axis) {
    p <- p +
      theme(
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()
      )
  }

  p
}

left_panel <- make_panel(
  filter(plot_data, panel == "2005–12"),
  show_y_axis = TRUE
)

right_panel <- make_panel(
  filter(plot_data, panel == "2023–26"),
  show_y_axis = FALSE
)

chart <- left_panel + right_panel +
  plot_layout(ncol = 2, widths = c(1, 1)) +
  plot_annotation(
    title = "Real Export and Real Consumption Growth during\nCommodity Price Booms",
    subtitle = "(Average annual growth; percent)",
    caption = paste0(
      "Sources: IMF, World Economic Outlook database; and IMF staff\n",
      "calculations."
    ),
    theme = theme(
      text = element_text(family = "Arial", colour = "black"),
      plot.title = element_text(
        face = "bold",
        size = 13.5,
        lineheight = 0.95,
        hjust = 0,
        margin = margin(0, 0, 2, 0)
      ),
      plot.subtitle = element_text(
        face = "italic",
        size = 11,
        hjust = 0,
        margin = margin(0, 0, 8, 0)
      ),
      plot.caption = element_text(
        size = 8.8,
        lineheight = 0.95,
        hjust = 0,
        margin = margin(9, 0, 0, 0)
      ),
      plot.margin = margin(4, 8, 5, 7)
    )
  ) &
  theme(panel.spacing = grid::unit(0.12, "cm"))

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
