"""Figure 3.2: Commodity Prices."""
import matplotlib.dates as mdates
import pandas as pd
from matplotlib.lines import Line2D

from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-3-2"

START, END = pd.Timestamp("2025-01-01"), pd.Timestamp("2026-09-30")
CONFLICT = pd.Timestamp("2026-03-01")

data = read_chart_data(STEM)
data = data[(data["category"] >= START) & (data["category"] <= END)]

# Series: (colour, line width). Oil is drawn thicker.
left_series = {
    "Oil": ("#0065A0", 2.2),
    "Copper": ("#00A6B2", 1.2),
    "Iron ore": ("#C55A11", 1.2),
    "Soybeans": ("#7F7F7F", 1.2),
    "Coffee": ("#5DADE2", 1.2),
}
gold = "Gold (right scale)"
gold_style = ("#FFA500", 1.2)

fig, ax = new_chart(
    title="Commodity Prices",
    subtitle="(Index: January 1, 2025 = 100)",
    caption=(
        "Sources: Bloomberg Finance L.P.; and IMF staff calculations.\n"
        "Note: Oil is the average petroleum spot price. Copper is from the London\n"
        "Metal Exchange. Iron ore is Shanghai SteelHome E-Commerce.\n"
        "Soybeans is from the Chicago Board of Trade. Coffee refers to the\n"
        "international coffee composite indicator price."
    ),
    title_size=13.5,
    caption_size=8.25,
    left=0.4,
    right=0.4,
    bottom_gap=0.55,
)

# Gold is on the right-hand scale; draw it first so the others lie on top.
ax_right = add_right_axis(ax, (100, 220), 30)
ax_right.plot(data["category"], data[gold], color=gold_style[0],
              linewidth=gold_style[1])
ax_right.tick_params(axis="y", length=2.8)
ax.set_zorder(ax_right.get_zorder() + 1)
ax.patch.set_visible(False)

for series, (colour, width) in left_series.items():
    ax.plot(data["category"], data[series], color=colour, linewidth=width,
            solid_joinstyle="round")

ax.axvline(CONFLICT, color="black", linewidth=1.0, linestyle=(0, (1, 1.5)))
ax.text(CONFLICT - pd.Timedelta(days=8), 73, "Middle East conflict",
        fontsize=9.7, fontstyle="italic", ha="right", va="bottom")

ax.set_xlim(START, END)
ax.set_xticks(pd.date_range(START, "2026-09-01", freq="4MS"))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%b-%y"))
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", labelrotation=90, length=0, pad=5)

set_y_scale(ax, 70, 190, 30)
ax.axhline(100, color="black", linewidth=0.7)
ax.tick_params(axis="y", length=2.8)

legend_styles = {**left_series, gold: gold_style}
ax.legend(
    [Line2D([], [], color=c, linewidth=w) for c, w in legend_styles.values()],
    list(legend_styles),
    loc="upper left", bbox_to_anchor=(0.01, 1.0), fontsize=8.6,
    handlelength=2.6, labelspacing=0.05,
)

save_chart(fig, STEM)
