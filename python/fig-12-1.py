"""
Figure 12.1: Response to Terms-of-Trade Shock by Anchoring Level.

The published chart also shows error bars (90 percent confidence intervals).
Those values are not part of the data extracted from the Excel chart, so
they are not drawn here.
"""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-12-1"

data = read_chart_data(STEM)

# The labels are not part of the extracted data; they are taken from the
# published chart. Bars come in pairs (6 and 12 months) for each anchoring
# level, first for inflation, then for consumption.
horizons = ["6m", "12m"] * 4
anchoring = ["Strongly\nanchored", "Weakly\nanchored"] * 2
outcomes = ["Inflation", "Consumption"]
bar_colours = ["#A6A6A6", "#A6A6A6", "#A678B5", "#A678B5"] * 2

fig, ax = new_chart(
    title="Response to Terms-of-Trade Shock\nby Anchoring Level",
    subtitle="(Percentage points)",
    caption=(
        "Sources: Barrett and others (forthcoming); Bems and others (2021); and\n"
        "IMF staff calculations.\n"
        "Note: Cumulative response to month-on-month percentage change in the\n"
        "commodity terms-of-trade index (Gruss and Kebhaj 2019). Each country-\n"
        "year is classified as strongly (weakly) anchored when it is in the top\n"
        "(bottom) 25 percent of the observations of the anchoring index. Error bars\n"
        "denote 90 percent confidence intervals."
    ),
    left=0.45,
    right=0.15,
    bottom_gap=0.95,
)

x = np.arange(1, len(data) + 1)
ax.bar(x, data["series_0"], width=0.55, color=bar_colours)
ax.axhline(0, color="black", linewidth=0.7)

# A three-row table of labels below the plot: horizon, anchoring level and
# outcome, with separators of increasing length.
trans = ax.get_xaxis_transform()
rows = {"horizon": -0.05, "anchoring": -0.15, "outcome": -0.29}
for xi in np.arange(0.5, 9, 1):
    if xi in (0.5, 4.5, 8.5):
        depth = -0.33
    elif xi in (2.5, 6.5):
        depth = -0.22
    else:
        depth = -0.09
    ax.plot([xi, xi], [0, depth], color="black", linewidth=0.6,
            transform=trans, clip_on=False)
for xi, label in zip(x, horizons):
    ax.text(xi, rows["horizon"], label, ha="center", va="center", transform=trans)
for centre, label in zip((1.5, 3.5, 5.5, 7.5), anchoring):
    ax.text(centre, rows["anchoring"], label, ha="center", va="center",
            transform=trans, linespacing=1.0)
for centre, label in zip((2.5, 6.5), outcomes):
    ax.text(centre, rows["outcome"], label, ha="center", va="center",
            transform=trans)

ax.set_xlim(0.5, 8.5)
ax.set_xticks([])

set_y_scale(ax, -1.2, 1.2, 0.4)
ax.yaxis.set_major_formatter("{x:.1f}")
ax.tick_params(axis="y", direction="in", length=2.3)

save_chart(fig, STEM)
