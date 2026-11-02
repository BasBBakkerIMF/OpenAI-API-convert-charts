"""Figure 3.1: Terms of Trade."""
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-3-1"

data = read_chart_data(STEM)

series_colours = {
    "USA": "#0067A5",
    "CAN": "#454545",
    "LA7": "#5C277E",
    "CAPDR": "#D26717",
    "CARIB": "#00A3A3",
}

fig, ax = new_chart(
    title="Terms of Trade",
    subtitle="(Index: 2019 = 100)",
    caption=(
        "Sources: IMF, World Economic Outlook database; and IMF staff\n"
        "calculations.\n"
        "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n"
        "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n"
        "= Caribbean; LA7 = Latin America 7 (Brazil, Chile, Colombia, Mexico,\n"
        "Paraguay, Peru, Uruguay)."
    ),
    caption_size=8.4,
    left=0.4,
    right=0.15,
    bottom_gap=0.35,
)

years = data["category"]

# The x-axis is drawn at 100, with short tick marks pointing up.
ax.axhline(100, color="#222222", linewidth=0.7)
ax.vlines(years, 100, 100.45, color="#222222", linewidth=0.6)

for series, colour in series_colours.items():
    ax.plot(years, data[series], color=colour, linewidth=1.7,
            solid_capstyle="round", solid_joinstyle="round", label=series)

ax.set_xlim(2018.5, 2026.5)
ax.set_xticks(years)
ax.tick_params(axis="x", length=2.3, pad=5)

ax.set_ylim(90, 125)
ax.yaxis.set_major_locator(MultipleLocator(5))
ax.tick_params(axis="y", length=2.3, pad=5)

ax.legend(loc="upper left", bbox_to_anchor=(0.03, 0.99), fontsize=9.5,
          handlelength=3.0, labelspacing=0.1)

save_chart(fig, STEM)
