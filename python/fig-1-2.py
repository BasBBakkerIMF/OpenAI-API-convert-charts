"""Figure 1.2: LAC: Growth Dispersion."""
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart, smooth_line

STEM = "fig-1-2"

data = read_chart_data(STEM)

series_colours = {
    "Average pairwise gap": "#0067A9",
    "Average distance from median": "#00A3AD",
}

fig, ax = new_chart(
    title="LAC: Growth Dispersion",
    subtitle="(Year-over-year percentage change)",
    caption=(
        "Sources: IMF, World Economic Outlook database; and IMF staff\n"
        "calculations.\n"
        "Note: Average pairwise gap is the average absolute difference in growth\n"
        "rates across all country pairs. Average distance from median is the\n"
        "average absolute deviation of each country's growth rate from the regional\n"
        "median. Sample excludes Guyana. LAC = Latin America and the\n"
        "Caribbean."
    ),
    caption_size=8.2,
    left=0.3,
    right=0.2,
    bottom_gap=0.5,
)

# The Excel chart uses smoothed lines.
for series, colour in series_colours.items():
    ax.plot(*smooth_line(data["category"], data[series]), color=colour,
            linewidth=1.8, solid_capstyle="round", label=series)

ax.set_xlim(2000, 2025)
ax.xaxis.set_major_locator(MultipleLocator(5))
ax.tick_params(axis="x", labelrotation=90, direction="in", length=2.3, pad=5)

ax.set_ylim(0, 8)
ax.yaxis.set_major_locator(MultipleLocator(2))
ax.tick_params(axis="y", direction="in", length=2.3, pad=6)

ax.legend(loc="upper left", bbox_to_anchor=(0.05, 0.98),
          handlelength=3.0, labelspacing=0.3)

save_chart(fig, STEM)
