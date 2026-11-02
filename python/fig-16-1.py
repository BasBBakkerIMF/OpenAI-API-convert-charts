"""Figure 16.1: LAC: Share of FDI Global Greenfield Investment."""
from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-16-1"

data = read_chart_data(STEM)

series_colours = {"Capital expenditure": "#0066A6", "Project-count": "#C8580A"}

fig, ax = new_chart(
    title="LAC: Share of FDI Global Greenfield Investment",
    subtitle="(Percent of world total; three-year trailing moving\naverage)",
    caption=(
        "Sources: Orbis Crossborder Investment (OCBI) database; and IMF staff\n"
        "calculations.\n"
        "Note: Shares are computed on announcement years relative to all\n"
        "destination economies in the database and cover announced and\n"
        "completed projects. Latest available data as of September 2, 2026. FDI =\n"
        "foreign direct investments; LAC = Latin America and the Caribbean."
    ),
    left=0.35,
    right=0.15,
    bottom_gap=0.3,
)

for series, colour in series_colours.items():
    ax.plot(data["category"], data[series], color=colour, linewidth=1.9,
            solid_capstyle="round", label=series)

ax.set_xlim(2004.5, 2025.5)
ax.set_xticks(range(2005, 2026, 5))
ax.tick_params(axis="x", length=2.8, pad=5)

set_y_scale(ax, 4, 16, 2)
ax.tick_params(axis="y", length=2.8)

ax.legend(loc="upper left", bbox_to_anchor=(0.04, 0.98), handlelength=3.0,
          labelspacing=0.15)

save_chart(fig, STEM)
