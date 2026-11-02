"""Figure 5.1: Labor Productivity Gap against the United States."""
from matplotlib.lines import Line2D

from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-5-1"

data = read_chart_data(STEM)
years = data["category"]

left_series = {"LA7": "#5B2A7F", "CAPDR": "#CE5A0A", "CARIB": "#009EAD"}
canada = "CAN (right scale)"
canada_colour = "#666666"

fig, ax = new_chart(
    title="Labor Productivity Gap against the United States",
    subtitle="(Percent of US labor productivity)",
    caption=(
        "Sources: IMF, World Economic Outlook database; and IMF staff\n"
        "calculations.\n"
        "Note: Labor productivity is measured as real GDP in PPP international\n"
        "dollars divided by total employment. The gap is measured as the\n"
        "difference in the level of labor productivity relative to the United States.\n"
        "Aggregates are purchasing-power-parity GDP-weighted averages.\n"
        "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n"
        "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n"
        "Paraguay, Peru, Uruguay); PPP = purchasing power parity."
    ),
    caption_size=8.4,
    left=0.4,
    right=0.4,
    bottom_gap=0.3,
)

for series, colour in left_series.items():
    ax.plot(years, data[series], color=colour, linewidth=1.8,
            solid_capstyle="round")

ax_right = add_right_axis(ax, (-32, -22), 2)
ax_right.plot(years, data[canada], color=canada_colour, linewidth=1.8,
              solid_capstyle="round")
ax_right.tick_params(axis="y", length=2.8)

ax.set_xlim(2018.5, 2026.5)
ax.set_xticks(years)
ax.tick_params(axis="x", length=2.8, pad=5)

set_y_scale(ax, -75, -50, 5)
ax.tick_params(axis="y", length=2.8)

styles = {**left_series, canada: canada_colour}
ax_right.legend(
    [Line2D([], [], color=c, linewidth=1.8) for c in styles.values()],
    list(styles),
    loc="upper right", bbox_to_anchor=(0.99, 0.98), handlelength=3.0,
    labelspacing=0.1,
)

save_chart(fig, STEM)
