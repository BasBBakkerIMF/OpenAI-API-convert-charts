library(readxl)
library(ggplot2)
library(dplyr)

workbook_path <- "k:/excel_and_png/fig-15-2.xlsx"
output_dir <- "k:/r_code/figures"
output_file <- file.path(output_dir, "fig-15-2.png")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

plot_data <- read_excel(
  path = workbook_path,
  sheet = "data"
) %>%
  mutate(
    Upper = Min + Difference
  )

chart <- ggplot(
  plot_data,
  aes(x = category)
) +
  geom_ribbon(
    aes(ymin = Min, ymax = Upper),
    fill = "#F2EDF4",
    colour = NA
  ) +
  geom_line(
    aes(y = LATAM),
    colour = "#5B2677",
    linewidth = 0.9,
    lineend = "round",
    linejoin = "round"
  ) +
  scale_x_continuous(
    limits = c(2014.5, 2025.5),
    breaks = 2015:2025,
    labels = function(x) ifelse(x %% 2 == 1, sprintf("%d", x), ""),
    expand = expansion(mult = 0)
  ) +
  scale_y_continuous(
    limits = c(0, 50),
    breaks = seq(0, 50, 10),
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "China's Share of Latin American Passenger Car\nImports",
    subtitle = "(Percent share)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Sources: UN Comtrade; World Bank, World Integrated Trade Solution;\n",
      "and IMF staff calculations.\n",
      "Note: Shaded area refers to the min-max range."
    )
  ) +
  theme_classic(base_family = "Arial", base_size = 9) +
  theme(
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = element_text(
      face = "bold",
      size = 13,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(0, 0, 2, 0)
    ),
    plot.subtitle = element_text(
      face = "italic",
      size = 11,
      hjust = 0,
      margin = margin(0, 0, 15, 0)
    ),
    axis.text = element_text(
      size = 9,
      colour = "black"
    ),
    axis.text.x = element_text(
      margin = margin(t = 7)
    ),
    axis.text.y = element_text(
      margin = margin(r = 7)
    ),
    axis.line = element_line(
      colour = "black",
      linewidth = 0.4
    ),
    axis.ticks = element_line(
      colour = "black",
      linewidth = 0.35
    ),
    axis.ticks.length = grid::unit(-0.10, "cm"),
    plot.caption = element_text(
      size = 8.5,
      lineheight = 0.95,
      hjust = 0,
      margin = margin(t = 10)
    ),
    plot.margin = margin(4, 10, 8, 10)
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
