"""Figure 7.1: Real GDP Growth (projections)."""
from matplotlib.lines import Line2D

from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-7-1"

data = read_chart_data(STEM)
years = data["category"]

left_series = {
    "USA": "#145A8D",
    "CAN": "#4D4D4D",
    "LA7": "#66338A",
    "CAPDR": "#C95A0A",
    "CARIB (excl. GUY/SUR)": "#00A1A9",
}
right_series = "CARIB (right scale)"
right_colour = "#00A1A9"
dashed = (0, (3, 2))

fig, ax = new_chart(
    title="Real GDP Growth",
    subtitle="(Year-over-year percent change)",
    caption=(
        "Sources: IMF, World Economic Outlook database; and IMF staff\n"
        "calculations.\n"
        "Note: Aggregates are purchasing-power-parity GDP-weighted average.\n"
        "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n"
        "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n"
        "Paraguay, Peru, Uruguay)."
    ),
    left=0.3,
    right=0.35,
    bottom_gap=0.3,
)

for series, colour in left_series.items():
    ax.plot(years, data[series], color=colour, linewidth=1.8,
            solid_capstyle="round")

# CARIB including Guyana and Suriname grows much faster, so it is shown
# dashed on the right-hand scale.
ax_right = add_right_axis(ax, (4, 16), 2)
ax_right.plot(years, data[right_series], color=right_colour, linewidth=1.8,
              linestyle=dashed)
ax_right.tick_params(axis="y", length=2.8)

ax.set_xlim(2021.5, 2028.5)
ax.set_xticks(years)
ax.tick_params(axis="x", length=2.8, pad=5)

set_y_scale(ax, 0, 6, 1)
ax.tick_params(axis="y", length=2.8)

handles = [Line2D([], [], color=c, linewidth=1.8) for c in left_series.values()]
handles.append(Line2D([], [], color=right_colour, linewidth=1.8, linestyle=dashed))
ax_right.legend(handles, [*left_series, right_series],
                loc="upper left", bbox_to_anchor=(0.4, 1.0),
                handlelength=3.4, labelspacing=0.05)

save_chart(fig, STEM)
