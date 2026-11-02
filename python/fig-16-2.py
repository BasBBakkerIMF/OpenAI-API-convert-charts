"""Figure 16.2: LAC: Composition of FDI Capital Expenditure."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-16-2"

data = read_chart_data(STEM)
years = data["category"]

# Stacking order, from the bottom up, and colours.
sector_colours = {
    "Manufacturing": "#5B2A7E",
    "Mining": "#C75B12",
    "ICT and data": "#00649A",
    "Business services": "#009A9A",
    "Other": "#B8BCBE",
}

fig, ax = new_chart(
    title="LAC: Composition of FDI Capital Expenditure",
    subtitle="(Billions of US dollars; annual levels)",
    caption=(
        "Sources: Orbis Crossborder Investment database; and IMF staff\n"
        "calculations.\n"
        "Note: Years are announcement years and cover announced and\n"
        "completed projects. Latest available data as of September 2, 2026. FDI =\n"
        "foreign direct investments; ICT = information and communications\n"
        "technology and data; LAC = Latin America and the Caribbean."
    ),
    left=0.35,
    right=0.15,
    bottom_gap=0.3,
)

bottom = np.zeros(len(data))
for sector, colour in sector_colours.items():
    ax.bar(years, data[sector], bottom=bottom, width=0.56, color=colour,
           label=sector)
    bottom += data[sector].to_numpy()

ax.set_xlim(2012.5, 2025.5)
ax.set_xticks(range(2013, 2026, 2))
ax.tick_params(axis="x", length=2.8, pad=5)

set_y_scale(ax, 0, 300, 60)
ax.tick_params(axis="y", length=2.8)

ax.legend(loc="upper left", bbox_to_anchor=(0.04, 1.0), handlelength=0.9,
          handleheight=0.9, handletextpad=0.4, labelspacing=0.15)

save_chart(fig, STEM)
