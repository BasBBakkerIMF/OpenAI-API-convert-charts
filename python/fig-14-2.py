"""
Figure 14.2: Real Export and Real Consumption Growth during Commodity Price
Booms (box plots, two panels).
"""
import numpy as np
from matplotlib.patches import Rectangle

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-14-2"

purple = "#61257D"
box_colours = {1: "#A8DFE1", 2: "#FFD77D"}   # 1 = exports, 2 = consumption

# Argentina's export growth in 2023-26 (12.5 percent) is off the scale; in
# the extracted data it is capped at 7.8, the top of the chart, and it is
# labelled with its true value.
OFF_SCALE = {("datar", "ARG", 1): "ARG (12.5)"}

panels = [("datal", "2005–12"), ("datar", "2023–26")]

fig, axes = new_chart(
    title="Real Export and Real Consumption Growth during\nCommodity Price Booms",
    subtitle="(Average annual growth; percent)",
    caption="Sources: IMF, World Economic Outlook database; and IMF staff\ncalculations.",
    left=0.3,
    right=0.1,
    top_gap=0.25,
    bottom_gap=0.55,
    ncols=2,
    wspace=0.1,
)


def quartiles(values):
    """Quartiles, computed as in the published chart (inclusive median)."""
    return np.percentile(values, [25, 50, 75])


def spread_labels(ys, min_gap):
    """Move label positions apart so that they do not overlap."""
    order = np.argsort(ys)
    placed = np.array(ys, dtype=float)
    for previous, current in zip(order, order[1:]):
        placed[current] = max(placed[current], placed[previous] + min_gap)
    return placed


for ax, (sheet, period) in zip(axes, panels):
    data = read_chart_data(STEM, sheet)
    for group, colour in box_colours.items():
        points = data[data["x"] == group]
        y = points["y"].to_numpy()
        q1, median, q3 = quartiles(y)

        # Whisker from minimum to maximum (leaving out the off-scale point),
        # box from first to third quartile.
        on_scale = [yi for yi, c in zip(y, points["label"])
                    if (sheet, c, group) not in OFF_SCALE]
        ax.vlines(group, min(on_scale), max(on_scale), color=purple, linewidth=1.2)
        ax.add_patch(Rectangle((group - 0.29, q1), 0.58, q3 - q1,
                               facecolor=colour, edgecolor="#555555",
                               linewidth=0.8, zorder=2))
        ax.hlines(median, group - 0.29, group + 0.29, color="#555555",
                  linewidth=0.8, zorder=3)
        ax.scatter(np.full(len(y), group), y, s=30, color=purple, zorder=4)

        # Country labels to the right, spread out where they would overlap.
        labels = [OFF_SCALE.get((sheet, c, group), c) for c in points["label"]]
        label_y = spread_labels(y, 0.32)
        for yi, ly, label in zip(y, label_y, labels):
            ax.annotate(label, xy=(group + 0.04, yi), xytext=(group + 0.17, ly),
                        color=purple, fontsize=8.7, va="center",
                        arrowprops=dict(arrowstyle="-", color="#A0A0A0",
                                        linewidth=0.5, shrinkA=0, shrinkB=2))

    ax.set_xlim(0.5, 2.7)
    ax.set_xticks([1, 2], ["Exports", "Consumption"])
    ax.tick_params(axis="x", length=0, pad=5)
    trans = ax.get_xaxis_transform()
    for xi in (0.5, 1.6, 2.7):
        depth = -0.17 if xi != 1.6 else -0.09
        ax.plot([xi, xi], [0, depth], color="black", linewidth=0.6,
                transform=trans, clip_on=False)
    ax.text(1.6, -0.13, period, ha="center", va="center", transform=trans)

    set_y_scale(ax, 0, 8, 2)

# Only the left panel has a y-axis. Its top tick stands for the off-scale
# value (14), with a break mark on the axis below it.
axes[0].set_yticks([0, 2, 4, 6, 8], ["0", "2", "4", "6", "14"])
axes[0].tick_params(axis="y", length=2.8)
for ax in axes:
    for dy in (-0.12, 0.12):
        ax.plot([-0.025, 0.025], [7.45 + dy - 0.08, 7.45 + dy + 0.08],
                color="black", linewidth=0.8, transform=ax.get_yaxis_transform(),
                clip_on=False)
axes[1].set_yticks([])

save_chart(fig, STEM)
