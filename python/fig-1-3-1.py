"""Figure 1.3.1: Exports of Goods (two panels)."""
from matplotlib.lines import Line2D
from matplotlib.ticker import MultipleLocator

from chart_style import add_right_axis, new_chart, read_chart_data, save_chart

STEM = "fig-1-3-1"

bar_colours = {"Mexico": "#08649B", "Canada": "#CB6418"}

# Each panel: (data sheet, panel title, bar column, circle column).
panels = [
    ("datal", "Canada and Mexico Exports\nto the United States",
     "(% GDP)", "(% goods exports)"),
    ("datar", "United States Exports to\nCanada and Mexico",
     "Percent of GDP", "Percent of exports (right scale)"),
]

fig, axes = new_chart(
    title="Exports of Goods",
    subtitle=None,
    caption="Sources: Haver Analytics; national authorities; and IMF staff calculations.",
    title_size=14,
    caption_size=9.5,
    left=0.35,
    right=0.35,
    top_gap=0.55,
    bottom_gap=0.45,
    ncols=2,
    wspace=0.75,
)

for ax, (sheet, panel_title, bar_column, circle_column) in zip(axes, panels):
    data = read_chart_data(STEM, sheet)
    x = range(len(data))

    # Bars: percent of GDP, on the left scale.
    ax.bar(x, data[bar_column], width=0.56,
           color=[bar_colours[c] for c in data["category"]])
    ax.set_xticks(x, data["category"])
    ax.set_xlim(-0.78, len(data) - 0.22)
    ax.set_ylim(0, 40)
    ax.yaxis.set_major_locator(MultipleLocator(10))
    ax.tick_params(axis="x", length=0, pad=7, labelsize=10)
    ax.tick_params(axis="y", direction="in", length=2.3, pad=7, labelsize=10)
    ax.set_title(panel_title, loc="left", color="#7F7F7F", fontweight="bold",
                 fontsize=11.5, linespacing=0.95, pad=14)

    # Circles: percent of exports, on the right scale.
    ax_right = add_right_axis(ax, (0, 100), 25)
    ax_right.tick_params(axis="y", direction="in", length=2.3, pad=7, labelsize=10)
    ax_right.plot(x, data[circle_column], linestyle="none", marker="o",
                  markersize=11, markerfacecolor="none",
                  markeredgecolor="black", markeredgewidth=1.6)

# Legend, in the right-hand panel.
legend_handles = [
    Line2D([], [], linestyle="none", marker="s", markersize=8,
           markerfacecolor="none", markeredgecolor="black"),
    Line2D([], [], linestyle="none", marker="o", markersize=8,
           markerfacecolor="none", markeredgecolor="black"),
]
axes[1].legend(legend_handles, ["Percent of GDP", "Percent of exports\n(right scale)"],
               loc="upper left", bbox_to_anchor=(0.0, 1.01), fontsize=9,
               handletextpad=0.3, labelspacing=0.4)

save_chart(fig, STEM)
