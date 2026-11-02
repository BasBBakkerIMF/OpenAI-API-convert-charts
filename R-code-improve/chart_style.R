# Shared set-up for the REO charts.
#
# Every chart script starts with source("chart_style.R"). It loads the
# packages, and provides the house style and a few building blocks that most
# charts use. Run the scripts with this folder as the working directory
# (open R-code-improve.Rproj in RStudio).

suppressPackageStartupMessages({
  library(readxl)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
})

data_dir <- file.path("..", "excel_and_png")
figures_dir <- "figures"

# Read the data extracted from the Excel chart (step 4 of the pipeline).
# Column types are guessed from all rows: a series that only starts after
# many empty rows would otherwise be read as logical and lose its values.
read_chart_data <- function(stem, sheet = "data") {
  read_excel(file.path(data_dir, paste0(stem, ".xlsx")), sheet = sheet,
             guess_max = 1e6)
}

# Title, subtitle and caption sizes, fonts, axes and legend of the REO charts.
theme_reo <- function(base_size = 9, title_size = 13, subtitle_size = 11,
                      caption_size = 8.5) {
  theme_classic(base_family = "Arial", base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = title_size,
                                lineheight = 0.95, margin = margin(0, 0, 1, 0)),
      plot.subtitle = element_text(face = "italic", size = subtitle_size,
                                   margin = margin(0, 0, 8, 0)),
      plot.caption = element_text(hjust = 0, size = caption_size,
                                  lineheight = 0.96, margin = margin(t = 8)),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.text = element_text(colour = "black", size = base_size),
      axis.line = element_line(colour = "black", linewidth = 0.4),
      axis.ticks = element_line(colour = "black", linewidth = 0.35),
      axis.ticks.length = unit(0.08, "cm"),
      legend.title = element_blank(),
      legend.text = element_text(size = base_size),
      legend.margin = margin(0, 0, 0, 0),
      legend.background = element_blank(),
      legend.key = element_blank(),
      legend.key.width = unit(0.42, "in"),
      legend.key.height = unit(0.14, "in"),
      legend.spacing.y = unit(0, "cm"),
      plot.margin = margin(4, 10, 6, 10)
    )
}

# Tick marks pointing into the plot, as in Excel.
ticks_inward <- function(length = 0.08) {
  theme(axis.ticks.length = unit(-length, "cm"))
}

# Rotate the x-axis labels by 90 degrees.
vertical_x_labels <- function() {
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
}

# Place the legend inside the plot; x and y are fractions of the plot area,
# `just` is the corner of the legend that is placed there.
legend_at <- function(x, y, just = c(0, 1)) {
  theme(legend.position = "inside", legend.position.inside = c(x, y),
        legend.justification = just)
}

# A y-scale from `low` to `high` with a break every `by`, and no padding.
# Values outside the range are kept and clipped at the edge of the plot, as
# in Excel (ggplot's default would drop them), so labels placed below the
# axis also stay. Extra arguments (labels, sec.axis, ...) go to
# scale_y_continuous().
scale_y_reo <- function(low, high, by, ...) {
  scale_y_continuous(limits = c(low, high), breaks = seq(low, high, by),
                     expand = expansion(0), oob = scales::oob_keep, ...)
}

# A right-hand scale for a series plotted as `scale * value + shift` on the
# left-hand scale; `breaks` are in right-hand units.
right_axis <- function(scale, shift = 0, breaks = waiver(), ...) {
  sec_axis(transform = ~ (. - shift) / scale, breaks = breaks, ...)
}

# Draw the x-axis as a line at y = `at` with short tick marks at `x`, instead
# of along the bottom of the plot (the axis labels stay at the bottom).
# `tick` is the tick length in data units: positive points up, negative down.
# On a categorical x-axis, add scale_x_discrete() to the chart, because the
# tick positions are numbers.
axis_line_at <- function(at = 0, x, tick) {
  list(
    geom_hline(yintercept = at, colour = "black", linewidth = 0.4),
    annotate("segment", x = x, xend = x, y = at, yend = at + tick,
             colour = "black", linewidth = 0.35),
    theme(axis.line.x = element_blank(), axis.ticks.x = element_blank())
  )
}

# A smooth curve through the points (x, y), in the order given, like Excel's
# "smoothed line": both coordinates are interpolated with a spline.
smooth_path <- function(x, y, n = 100) {
  step <- seq_along(x)
  tibble(x = spline(step, x, n = n, method = "natural")$y,
         y = spline(step, y, n = n, method = "natural")$y)
}

# Save the chart as figures/<stem>.png, 5 x 5 inches at 600 dpi, and show it
# when working interactively.
save_chart <- function(chart, stem) {
  dir.create(figures_dir, showWarnings = FALSE)
  output_file <- file.path(figures_dir, paste0(stem, ".png"))
  ggsave(output_file, chart, dpi = 600, width = 5, height = 5, units = "in",
         bg = "white")
  if (interactive()) print(chart)
  message("Saved ", output_file)
}
