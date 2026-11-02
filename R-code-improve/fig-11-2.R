# Figure 11.2: Monetary and Fiscal Policy, 2024–26 (Brazil, Colombia, Mexico)
source("chart_style.R")
source("policy_mix.R")

stem <- "fig-11-2"

chart <- policy_mix_chart(
  stem,
  colours = c(BRA = "#63277F", COL = "#D05A08", MEX = "#66696A"),
  subtitle = "(Brazil, Colombia, Mexico)",
  xlim = c(-3, 2), ylim = c(-1, 7), ybreaks = -1:7,
  legend = c(0.82, 0.5)
)

save_chart(chart, stem)
