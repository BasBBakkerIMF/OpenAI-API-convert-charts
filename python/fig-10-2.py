"""Figure 10.2: LA7: General Government Structural Primary Balance."""
from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-10-2"

data = read_chart_data(STEM)
years = data["category"]

# Each vintage of the projections: (colour, line style).
vintages = {
    "October 2026 WEO": ("#5B267A", "solid"),
    "April 2026 WEO": ("#8752AA", (0, (5, 2))),
    "October 2025 WEO": ("#AD7CC5", (0, (2, 2))),
}

fig, ax = new_chart(
    title="LA7: General Government Structural Primary\nBalance",
    subtitle="(Percent of potential GDP)",
    caption=(
        "Sources: IMF, World Economic Outlook database; and IMF staff\n"
        "calculations.\n"
        "Note: LA7 is simple average. Chile refers to the central government’s\n"
        "structural non-mining primary balance. Colombia refers to the\n"
        "consolidated public sector's structural non-oil primary balance. Peru refers\n"
        "to the nonfinancial public sector’s structural primary balance. LA7 = Latin\n"
        "America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    ),
    left=0.4,
    right=0.2,
    bottom_gap=0.35,
)

# The x-axis is drawn at zero, with short tick marks pointing up; the year
# labels stay at the bottom of the chart.
ax.axhline(0, color="black", linewidth=0.8)
ax.vlines(range(2021, 2032), 0, 0.04, color="black", linewidth=0.6)

for vintage, (colour, style) in vintages.items():
    ax.plot(years, data[vintage], color=colour, linestyle=style, linewidth=1.8,
            label=vintage)

ax.set_xlim(2021, 2031)
ax.set_xticks(range(2021, 2032, 2))
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=5)

set_y_scale(ax, -3, 0.5, 0.5)
ax.yaxis.set_major_formatter("{x:.1f}")
ax.tick_params(axis="y", length=2.8)

ax.legend(loc="lower right", bbox_to_anchor=(1.0, 0.03), handlelength=3.4,
          labelspacing=0.1)

save_chart(fig, STEM)
