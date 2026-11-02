"""Figure 1.1: Real GDP Growth."""
import numpy as np
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-1-1"

data = read_chart_data(STEM)

series_colours = {
    "USA": "#0069A6",
    "CAN": "#444444",
    "LA7": "#682C82",
    "CAPDR": "#C95A0C",
}

fig, ax = new_chart(
    title="Real GDP Growth",
    subtitle="(Year-over-year percent change)",
    caption=(
        "Sources: Haver Analytics; IMF, World Economic Outlook database; and\n"
        "IMF staff calculations.\n"
        "Note: Aggregates are purchasing-power-parity GDP-weighted average.\n"
        "CAPDR = Central America, Panama, and the Dominican Republic; LA7 =\n"
        "Latin America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n"
        "Uruguay)."
    ),
    title_size=13.5,
    left=0.35,
    right=0.2,
    bottom_gap=0.62,
)

# The quarters are categories, plotted at positions 0, 1, 2, ...
x = np.arange(len(data))
for series, colour in series_colours.items():
    # A missing value (CAPDR in the last quarter) leaves a gap in the line.
    values = data[series].astype(float)
    ax.plot(x, values, color=colour, linewidth=1.6,
            solid_capstyle="round", label=series)

ax.set_xticks(x, data["category"], rotation=90)
ax.set_xlim(-0.5, len(data) - 0.5)
ax.tick_params(axis="x", direction="in", length=2, pad=5)

ax.set_ylim(0, 5)
ax.yaxis.set_major_locator(MultipleLocator(1))
ax.tick_params(axis="y", direction="in", length=2, pad=6)

ax.legend(
    loc="lower left", bbox_to_anchor=(0.01, 0.01), ncol=2,
    handlelength=3.0, columnspacing=2.5, labelspacing=0.15,
)

save_chart(fig, STEM)
