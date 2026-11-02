# Shared by figures 11.1 and 11.2: the monetary and fiscal policy mix of a
# few countries over three years, as smoothed paths with an arrow, in four
# labelled quadrants. Source chart_style.R first.

policy_mix_chart <- function(stem, colours, subtitle, xlim, ylim, ybreaks,
                             ylabels = waiver(), legend = c(0.48, 0.86)) {
  points <- read_chart_data(stem) |>
    mutate(series = factor(series, levels = names(colours)))
  paths <- points |>
    group_by(series) |>
    reframe(smooth_path(x, y))

  quadrants <- tibble(
    x = rep(xlim, 2) + c(0.05, -0.05),
    y = rep(ylim, each = 2),
    hjust = c(0, 1, 0, 1),
    vjust = c(0, 0, 1, 1),
    label = c("Exp FP\nExp MP", "Con FP\nExp MP", "Exp FP\nCon MP", "Con FP\nCon MP")
  )

  ggplot(points, aes(x, y, colour = series)) +
    # Axes cross at zero, with short tick marks; the scale labels stay at
    # the left and bottom edges.
    geom_hline(yintercept = 0, linewidth = 0.4) +
    geom_vline(xintercept = 0, linewidth = 0.4) +
    annotate("segment", x = setdiff(seq(xlim[1], xlim[2]), 0),
             xend = setdiff(seq(xlim[1], xlim[2]), 0),
             y = 0, yend = 0.035 * diff(ylim), linewidth = 0.35) +
    annotate("segment", x = 0, xend = 0.025 * diff(xlim), y = ybreaks,
             yend = ybreaks, linewidth = 0.35) +
    geom_path(data = paths, linewidth = 1.05,
              arrow = arrow(angle = 25, length = unit(0.08, "in"), type = "closed")) +
    geom_point(shape = 21, fill = "white", size = 3, stroke = 1) +
    geom_text(aes(x, y, label = label, hjust = hjust, vjust = vjust),
              data = quadrants, inherit.aes = FALSE, colour = "#777777",
              fontface = "italic", family = "Arial", size = 3.0, lineheight = 0.95) +
    scale_colour_manual(values = colours) +
    scale_x_continuous(limits = xlim, breaks = seq(xlim[1], xlim[2]),
                       expand = expansion(0)) +
    scale_y_continuous(limits = ylim, breaks = ybreaks, labels = ylabels,
                       expand = expansion(0)) +
    coord_cartesian(clip = "off") +
    labs(
      title = "Monetary and Fiscal Policy, 2024–26",
      subtitle = subtitle,
      x = "Change in structural primary balance\n(percentage points of potential GDP)",
      y = "Real ex ante policy rate gap\n(percentage points)",
      caption = paste0(
        "Sources: Consensus Economics; Haver Analytics; IMF, World Economic\n",
        "Outlook database; and IMF staff calculations.\n",
        "Note: The real ex ante policy rate gap is the difference between the real\n",
        "ex ante policy rate and the real neutral rate. The real ex ante policy rate is\n",
        "the difference between the nominal policy rate and the 1-year ahead\n",
        "inflation expectations. Con = contractionary; Exp = expansionary; MP =\n",
        "monetary policy; FP = fiscal policy."
      )
    ) +
    theme_reo() +
    theme(axis.line = element_blank(), axis.ticks = element_blank(),
          axis.text.x = element_text(margin = margin(t = 4)),
          axis.text.y = element_text(margin = margin(r = 4))) +
    legend_at(legend[1], legend[2], just = c(0, 0.5))
}
