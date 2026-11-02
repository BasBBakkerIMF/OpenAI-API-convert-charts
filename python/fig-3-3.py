"""Figure 3.3: Change in Commodity Terms of Trade."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-3-3"

data = read_chart_data(STEM)

series_colours = {"February 2026": "#C9ADD5", "May 2026": "#00689D"}

fig, ax = new_chart(
    title="Change in Commodity Terms of Trade",
    subtitle="(Percent change relative to January 2025)",
    caption=(
        "Sources: IMF, Commodity Terms of Trade database; and IMF staff\n"
        "calculations.\n"
        "Note: Commodity net export price index, individual commodities weighted\n"
        "by ratio of net exports to GDP."
    ),
    left=0.3,
    right=0.15,
    bottom_gap=0.3,
)

x = np.arange(len(data))
bar_width = 0.38
for i, (series, colour) in enumerate(series_colours.items()):
    ax.bar(x + (i - 0.5) * bar_width, data[series], width=bar_width,
           color=colour, label=series)

# The x-axis is drawn at zero, with short tick marks pointing down; the
# country labels stay at the bottom of the chart.
ax.axhline(0, color="black", linewidth=0.7)
ax.vlines(x, -0.12, 0, color="black", linewidth=0.6)

ax.set_xticks(x, data["category"])
ax.set_xlim(-0.6, len(data) - 0.4)
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=5)

set_y_scale(ax, -2, 7, 1)
ax.tick_params(axis="y", direction="in", length=2.3)

ax.legend(loc="upper right", bbox_to_anchor=(1.0, 0.97), ncol=2,
          handlelength=0.8, handleheight=0.8, handletextpad=0.4,
          columnspacing=1.0)

save_chart(fig, STEM)
