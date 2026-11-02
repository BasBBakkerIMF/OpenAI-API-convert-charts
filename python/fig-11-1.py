"""Figure 11.1: Monetary and Fiscal Policy, 2024–26 (United States and Canada)."""
import numpy as np
from matplotlib.lines import Line2D

from chart_style import new_chart, read_chart_data, save_chart, smooth_line

STEM = "fig-11-1"

data = read_chart_data(STEM)

series_colours = {"USA": "#0065A8", "CAN": "#454545"}

fig, ax = new_chart(
    title="Monetary and Fiscal Policy, 2024–26",
    subtitle="(United States and Canada)",
    caption=(
        "Sources: Consensus Economics; Haver Analytics; IMF, World Economic\n"
        "Outlook database; and IMF staff calculations.\n"
        "Note: The real ex ante policy rate gap is the difference between the real\n"
        "ex ante policy rate and the real neutral rate. The real ex ante policy rate is\n"
        "the difference between the nominal policy rate and the 1-year ahead\n"
        "inflation expectations. Con = contractionary; Exp = expansionary; MP =\n"
        "monetary policy; FP = fiscal policy."
    ),
    left=0.8,
    right=0.25,
    bottom_gap=0.65,
)

# Each country moves through three years (2024, 2025, 2026). The path is a
# smoothed line, as in Excel, with an arrow showing the direction.
for country, colour in series_colours.items():
    path = data[data["series"] == country]
    xs, ys = smooth_line(path["x"], path["y"])
    ax.plot(xs[:-3], ys[:-3], color=colour, linewidth=2.0)
    ax.annotate("", xy=(xs[-1], ys[-1]), xytext=(xs[-4], ys[-4]),
                arrowprops=dict(arrowstyle="-|>", color=colour, linewidth=2.0,
                                mutation_scale=12, shrinkA=0, shrinkB=4))
    ax.scatter(path["x"], path["y"], s=40, facecolor="white", edgecolor=colour,
               linewidth=1.5, zorder=3)

# Axes cross at zero; the scale labels stay at the left and bottom edges.
for side in ("left", "bottom"):
    ax.spines[side].set_visible(False)
ax.axhline(0, color="black", linewidth=0.7)
ax.axvline(0, color="black", linewidth=0.7)
ax.vlines([-1, 1, 2], 0, 0.035, color="black", linewidth=0.6)
ax.hlines(np.arange(-1, 1.51, 0.5), 0, 0.025, color="black", linewidth=0.6)
ax.tick_params(length=0, pad=5)

ax.set_xlim(-1, 2)
ax.set_xticks([-1, 0, 1, 2])
ax.set_ylim(-1, 1.5)
ax.set_yticks(np.arange(-1, 1.51, 0.5))
ax.yaxis.set_major_formatter("{x:.1f}")
ax.set_xlabel("Change in structural primary balance\n(percentage points of potential GDP)",
              fontsize=9, labelpad=4)
ax.set_ylabel("Real ex ante policy rate gap\n(percentage points)", fontsize=9,
              labelpad=4)

# Quadrant labels.
quadrants = [
    (-0.95, 1.5, "left", "top", "Exp FP\nCon MP"),
    (1.95, 1.5, "right", "top", "Con FP\nCon MP"),
    (-0.95, -1.0, "left", "bottom", "Exp FP\nExp MP"),
    (1.95, -1.0, "right", "bottom", "Con FP\nExp MP"),
]
for qx, qy, ha, va, label in quadrants:
    ax.text(qx, qy, label, ha=ha, va=va, color="#777777", fontstyle="italic",
            fontsize=8.5, linespacing=1.0)

ax.legend(
    [Line2D([], [], color=c, linewidth=2.0, marker="o", markersize=5,
            markerfacecolor="white") for c in series_colours.values()],
    list(series_colours),
    loc="upper left", bbox_to_anchor=(0.45, 0.95), handlelength=2.6,
    labelspacing=0.2,
)

save_chart(fig, STEM)
