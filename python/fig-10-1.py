"""Figure 10.1: General Government Gross Debt and Financing Cost."""
import numpy as np
from matplotlib.lines import Line2D
from matplotlib.patches import Patch

from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-10-1"

data = read_chart_data(STEM)

# The rows alternate between LA7 and OEM, for five years. The labels are not
# part of the extracted data; they are taken from the published chart.
years = ["2003", "2010", "2020", "2025", "2031"]
debt_colours = {"LA7 gross debt": "#C7A6D0", "OEM gross debt": "#69B5DE"}
premium = "LA7 financing premium for LC 10y yields (right scale)"

fig, ax = new_chart(
    title="General Government Gross Debt and\nFinancing Cost",
    subtitle="(Percent of GDP; unless noted otherwise)",
    caption=(
        "Sources: Haver Analytics; IMF, World Economic Outlook database; and\n"
        "IMF staff calculations.\n"
        "Note: Financing cost in percentage points is the difference between LA7\n"
        "and OEM's nominal 10-year local currency bond yields. Aggregates are\n"
        "simple averages. LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n"
        "Paraguay, Peru, Uruguay); OEM = other emerging markets (Bosnia and\n"
        "Herzegovina, Hungary, India, Indonesia, Malaysia, Philippines, Poland,\n"
        "Romania, Serbia, Thailand)."
    ),
    caption_size=8.3,
    left=0.35,
    right=0.3,
    bottom_gap=0.5,
)

x = np.arange(1, len(data) + 1)
for series, colour in debt_colours.items():
    ax.bar(x, data[series].fillna(0), width=0.62, color=colour)

ax.set_xlim(0.5, 10.5)
ax.set_xticks(x, ["LA7", "OEM"] * 5)
ax.tick_params(axis="x", length=0, pad=5)
# Separators below the axis: between the bars, and longer between the years.
for xi in np.arange(0.5, 11, 1):
    depth = -0.16 if xi in (0.5, 2.5, 4.5, 6.5, 8.5, 10.5) else -0.07
    ax.plot([xi, xi], [0, depth], color="black", linewidth=0.6,
            transform=ax.get_xaxis_transform(), clip_on=False)
for centre, year in zip(np.arange(1.5, 10, 2), years):
    ax.text(centre, -0.12, year, ha="center", va="center",
            transform=ax.get_xaxis_transform())

set_y_scale(ax, 20, 80, 10)
ax.tick_params(axis="y", length=2.8)

# Financing premium: one black dash per year, across the pair of bars.
ax_right = add_right_axis(ax, (0, 8), 2)
ax_right.tick_params(axis="y", length=2.8)
premium_by_year = data[premium].iloc[::2].to_numpy()
ax_right.hlines(premium_by_year, x[::2] - 0.05, x[::2] + 1.05,
                color="black", linewidth=1.8)

ax.legend(
    [Patch(color=c) for c in debt_colours.values()]
    + [Line2D([], [], color="black", linewidth=1.8)],
    [*debt_colours, premium],
    loc="upper left", bbox_to_anchor=(0.02, 1.0), handlelength=1.6,
    labelspacing=0.3, fontsize=8.8,
)

save_chart(fig, STEM)
