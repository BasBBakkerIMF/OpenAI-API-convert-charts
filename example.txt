library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

workbook_path <- "//Data2/whd/DATA/RS/REO/2026 Fall/Charts/Pass-through_KDE_chart_template.xlsx"
output_dir <- "L:/created-code"
output_file <- file.path(output_dir, "fig-5-2.png")

read_excel_vector <- function(range_ref) {
  values <- read_excel(
    path = workbook_path,
    sheet = "Data2",
    range = range_ref,
    col_names = FALSE,
    .name_repair = "minimal"
  )[[1]]
  values
}

to_excel_numeric <- function(x) {
  if (inherits(x, "POSIXt")) {
    return(as.numeric(as.Date(x)))
  }
  if (inherits(x, "Date")) {
    return(as.numeric(x))
  }
  suppressWarnings(as.numeric(x))
}

read_series_name <- function(range_ref, fallback_name) {
  value <- read_excel_vector(range_ref)
  value <- value[!is.na(value) & trimws(as.character(value)) != ""]
  if (length(value) == 0) {
    fallback_name
  } else {
    as.character(value[1])
  }
}

common_x_raw <- read_excel_vector("A2:A88")
common_x <- to_excel_numeric(common_x_raw)

extract_series <- function(x_range, y_range, common_x_values = NULL) {
  x_raw <- read_excel_vector(x_range)
  y_raw <- read_excel_vector(y_range)
  
  x_values <- to_excel_numeric(x_raw)
  y_values <- to_excel_numeric(y_raw)
  
  if (all(is.na(x_values)) && !is.null(common_x_values)) {
    x_values <- common_x_values
  }
  
  n <- min(length(x_values), length(y_values))
  
  tibble(
    x = x_values[seq_len(n)],
    y = y_values[seq_len(n)]
  ) %>%
    filter(!is.na(x), !is.na(y)) %>%
    arrange(x)
}

main_specs <- tibble(
  id = c("LAC", "EDA", "AE", "MENAP - CCA", "SSA"),
  name_range = c("B1", "C1", "D1", "E1", "F1"),
  x_range = rep("A2:A88", 5),
  y_range = c("B2:B88", "C2:C88", "D2:D88", "E2:E88", "F2:F88"),
  order = 1:5
)

average_specs <- tibble(
  id = c("LAC", "EDA", "AE", "MENAP - CCA", "SSA"),
  name_range = c("O2", "O4", "O6", "O8", "O10"),
  x_range = c("P2:P3", "P4:P5", "P6:P7", "P8:P9", "P10:P11"),
  y_range = c("Q2:Q3", "Q4:Q5", "Q6:Q7", "Q8:Q9", "Q10:Q11"),
  order = 6:10
)

main_labels <- vapply(
  seq_len(nrow(main_specs)),
  function(i) read_series_name(main_specs$name_range[i], main_specs$id[i]),
  character(1)
)

main_data <- bind_rows(lapply(seq_len(nrow(main_specs)), function(i) {
  extract_series(
    x_range = main_specs$x_range[i],
    y_range = main_specs$y_range[i],
    common_x_values = common_x
  ) %>%
    mutate(
      id = main_specs$id[i],
      display_name = main_labels[i],
      plot_order = main_specs$order[i]
    )
}))

average_data <- bind_rows(lapply(seq_len(nrow(average_specs)), function(i) {
  extract_series(
    x_range = average_specs$x_range[i],
    y_range = average_specs$y_range[i],
    common_x_values = common_x
  ) %>%
    mutate(
      id = average_specs$id[i],
      plot_order = average_specs$order[i]
    )
}))

smooth_series <- function(data) {
  data <- data %>%
    arrange(x) %>%
    group_by(x) %>%
    summarise(y = mean(y), .groups = "drop")
  
  if (nrow(data) < 4 || length(unique(data$x)) < 4) {
    return(data)
  }
  
  spline_fit <- stats::spline(
    x = data$x,
    y = data$y,
    n = 400,
    method = "natural"
  )
  
  tibble(
    x = spline_fit$x,
    y = spline_fit$y
  )
}

smooth_main_data <- bind_rows(lapply(seq_len(nrow(main_specs)), function(i) {
  series_id <- main_specs$id[i]
  
  smooth_series(main_data %>% filter(id == series_id)) %>%
    mutate(
      id = series_id,
      display_name = main_labels[i],
      plot_order = main_specs$order[i]
    )
}))

series_colors <- c(
  "LAC" = "#7030A0",
  "EDA" = "#00A6B4",
  "AE" = "#0070C0",
  "MENAP - CCA" = "#FFC000",
  "SSA" = "#C55A11"
)

legend_labels <- stats::setNames(main_labels, main_specs$id)

x_is_year <- all(
  is.finite(main_data$x) &
    abs(main_data$x - round(main_data$x)) < 1e-8 &
    main_data$x >= 1000 &
    main_data$x <= 9999
)

if (x_is_year) {
  x_breaks <- sort(unique(round(main_data$x)))
  x_labels <- function(x) sprintf("%d", round(x))
  x_limits <- range(x_breaks, na.rm = TRUE)
} else {
  x_breaks <- seq(-0.5, 4.0, by = 0.5)
  x_labels <- function(x) sprintf("%.1f", x)
  x_limits <- c(-0.5, 4.0)
}

chart <- ggplot() +
  geom_line(
    data = smooth_main_data,
    aes(x = x, y = y, colour = id, group = id),
    linewidth = 0.85,
    lineend = "round"
  ) +
  geom_line(
    data = average_data,
    aes(x = x, y = y, colour = id, group = interaction(id, plot_order)),
    linewidth = 0.8,
    linetype = "dashed",
    lineend = "butt",
    show.legend = FALSE
  ) +
  scale_colour_manual(
    values = series_colors,
    breaks = main_specs$id,
    labels = legend_labels,
    name = NULL
  ) +
  scale_x_continuous(
    limits = x_limits,
    breaks = x_breaks,
    labels = x_labels,
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = function(x) sprintf("%.1f", x),
    expand = expansion(mult = c(0, 0))
  ) +
  labs(
    title = "Oil Price Pass-through",
    subtitle = "(1 = full)",
    x = NULL,
    y = NULL,
    caption = paste0(
      "Source: IMF staff calculations.\n",
      "Note: Vertical dashed line refers to the median of the region. AE =\n",
      "advanced economies; EDA = emerging and developing Asia; LAC = Latin\n",
      "America and the Caribbean; MENAP-CCA = Middle East, North Africa,\n",
      "Afghanistan, and Pakistan - Caucasus and Central Asia; SSA = Sub-\n",
      "Saharan Africa."
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
    axis.text = element_text(size = 9, colour = "#333333"),
    axis.ticks = element_line(colour = "#333333", linewidth = 0.35),
    axis.ticks.length = grid::unit(0.11, "cm"),
    axis.line = element_line(colour = "#333333", linewidth = 0.45),
    legend.position = c(0.82, 0.80),
    legend.justification = c(0.5, 0.5),
    legend.text = element_text(size = 9),
    legend.key.width = grid::unit(0.38, "in"),
    legend.key.height = grid::unit(0.16, "in"),
    legend.background = element_blank(),
    legend.spacing.y = grid::unit(0.01, "cm"),
    plot.caption = element_text(
      hjust = 0,
      size = 8.5,
      lineheight = 0.95,
      margin = margin(12, 0, 0, 0)
    ),
    plot.margin = margin(6, 12, 8, 10)
  )

print(chart)

ggsave(
  filename = output_file,
  plot = chart,
  width = 5,
  height = 5,
  units = "in",
  dpi = 600,
  bg = "white"
)
