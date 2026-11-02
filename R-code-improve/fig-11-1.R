# Figure 11.1: Monetary and Fiscal Policy, 2024–26 (United States and Canada)
source("chart_style.R")
source("policy_mix.R")

stem <- "fig-11-1"

chart <- policy_mix_chart(
  stem,
  colours = c(USA = "#0065A8", CAN = "#454545"),
  subtitle = "(United States and Canada)",
  xlim = c(-1, 2), ylim = c(-1, 1.5), ybreaks = seq(-1, 1.5, 0.5),
  ylabels = function(y) sprintf("%.1f", y),
  legend = c(0.45, 0.86)
)

save_chart(chart, stem)
