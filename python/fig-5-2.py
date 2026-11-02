"""Figure 5.2: Real Exports Growth."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-5-2"

data = read_chart_data(STEM)

series_colours = {
    "USA": "#0868A4",
    "CAN": "#444444",
    "LA7": "#62317D",
    "CAPDR": "#C75B0A",
    "World trade volume": "#00A6A6",
}

fig, ax = new_chart(
    title="Real Exports Growth",
    subtitle="(Year-over-year percent change)",
    caption=(
        "Sources: CPB Netherlands Bureau for Economic Policy Analysis; Haver\n"
        "Analytics; national authorities; and IMF staff calculations.\n"
        "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n"
        "CAPDR = Central America, Panama, and the Dominican Republic; LA7 =\n"
        "Latin America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n"
        "Uruguay)."
    ),
    left=0.3,
    right=0.2,
    bottom_gap=0.62,
)

x = np.arange(len(data))

# The x-axis is drawn at zero, with short tick marks pointing up; the
# quarter labels stay at the bottom of the chart.
ax.axhline(0, color="black", linewidth=0.8)
ax.vlines(x, 0, 0.22, color="black", linewidth=0.6)

for series, colour in series_colours.items():
    ax.plot(x, data[series], color=colour, linewidth=1.8,
            solid_capstyle="round", label=series)

ax.set_xticks(x, data["category"], rotation=90)
ax.set_xlim(-0.5, len(data) - 0.5)
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=5)

set_y_scale(ax, -6, 9, 3)
ax.tick_params(axis="y", length=2.3)

ax.legend(loc="lower left", bbox_to_anchor=(0.03, 0.02), handlelength=3.0,
          labelspacing=0.05)

save_chart(fig, STEM)
