library(readxl)
library(ggplot2)
library(dplyr)
library(patchwork)

workbook_path <- "k:\\excel_and_png\\fig-13-0.xlsx"
output_dir <- "k:\\r_code"
figures_dir <- file.path(output_dir, "figures")
output_file <- file.path(figures_dir, "fig-13-0.png")

dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

category_levels <- c(
  "Allow or\nincrease",
  "No effect",
  "Reduce",
  "Taxes",
  "Spending",
  "Other"
)

left_data <- read_excel(
  path = workbook_path,
  sheet = "datal"
) %>%
  mutate(
    category = factor(category_levels[1:3], levels = category_levels),
    plot_value = series_0,
    bar_group = "left"
  )

right_data <- read_excel(
  path = workbook_path,
  sheet = "datar"
) %>%
  mutate(
    category = factor(category_levels[4:6], levels = category_levels),
    plot_value = series_0 / 0.75,
    bar_group = "right"
  )

plot_data <- bind_rows(left_data, right_data)

main_plot <- ggplot(
  plot_data,
  aes(x = category, y = plot_value, fill = bar_group)
) +
  geom_col(width = 0.56) +
  geom_hline(yintercept = 0, colour = "black", linewidth = 0.45) +
  annotate(
    "text",
    x = factor(category_levels, levels = category_levels),
    y = -6.5,
    label = category_levels,
    family = "Arial",
    size = 3.05,
    lineheight = 0.92,
    vjust = 0.5
  ) +
  annotate(
    "text",
    x = factor("No effect", levels = category_levels),
    y = -23,
    label = paste(
      "Percent share of countries",
      "implementing policies affecting",
      "commodity price pass-through",
      sep = "\n"
    ),
    family = "Arial",
    size = 3.0,
    lineheight = 0.95,
    vjust = 0.5
  ) +
  annotate(
    "text",
    x = factor("Spending", levels = category_levels),
    y = -23,
    label = paste(
      "Number of policies",
      "implemented",
      sep = "\n"
    ),
    family = "Arial",
    size = 3.0,
    lineheight = 0.95,
    vjust = 0.5
  ) +
  scale_fill_manual(
    values = c(
      "left" = "#08679D",
      "right" = "#C85F16"
    ),
    guide = "none"
  ) +
  scale_x_discrete(
    drop = FALSE,
    expand = expansion(add = 0.5)
  ) +
  scale_y_continuous(
    limits = c(-33, 80),
    breaks = seq(0, 80, by = 20),
    labels = function(x) sprintf("%d", x),
    expand = expansion(mult = c(0, 0)),
    sec.axis = sec_axis(
      transform = ~ . * 0.75,
      breaks = seq(0, 60, by = 15),
      labels = function(x) sprintf("%d", x),
      name = NULL
    )
  ) +
  labs(
    title = "WHD: Policies in Response to the Iran Shock",
    x = NULL,
    y = NULL
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 13.5,
      hjust = 0,
      margin = margin(0, 0, 7, 0)
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.line.x = element_blank(),
    axis.text.y = element_text(
      size = 9,
      colour = "black"
    ),
    axis.ticks.y = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(0.08, "cm"),
    axis.line.y = element_line(
      colour = "black",
      linewidth = 0.45
    ),
    plot.margin = margin(2, 10, 0, 10)
  )

caption_text <- paste(
  "Sources: IMF, Global Policy Tracker database; and IMF staff calculations.",
  "Note: Examples of policies that increase commodity price pass-through",
  "include reductions of fuel tax recoveries, fuel subsidy removals",
  "(Spending), removals of the fuel price controls, and increases to",
  "domestically controlled fuel prices (Others). Examples of policies that",
  "reduce commodity price pass-through include fuel, electricity, and food",
  "subsidies (Spending), and reductions in fuel taxes (Taxes). “Others” also",
  "includes credit guarantees, export taxes, relaxation of fuel standards,",
  "release of strategic reserves, work from home mandates, and public",
  "sector energy conservation.",
  sep = "\n"
)

caption_plot <- ggplot() +
  annotate(
    "text",
    x = 0,
    y = 1,
    label = caption_text,
    hjust = 0,
    vjust = 1,
    family = "Arial",
    size = 2.85,
    lineheight = 0.94
  ) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), clip = "off") +
  theme_void() +
  theme(
    plot.margin = margin(2, 10, 4, 10)
  )

chart <- main_plot / caption_plot +
  plot_layout(heights = c(0.67, 0.33))

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
