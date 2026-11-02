"""Figure 8: Impact of El Niño on Inflation."""
from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-8-0"

data = read_chart_data(STEM)
quarters = data["category"]

# In Excel, the confidence bands are drawn as stacked areas, built from four
# helper series (Dummy1-Dummy4). Adding them up gives the band edges.
d1, d2, d3, d4 = (data[f"Dummy{i}"] for i in range(1, 5))
bands = {
    "Andean": (d1, d1 + d2, "#D8C8DE"),
    "CAPDR": (d1 + d2 + d3, d1 + d2 + d3 + d4, "#F3C9AD"),
}
line_colours = {"Andean": "#5A2875", "CAPDR": "#C95716"}

fig, ax = new_chart(
    title="Impact of El Niño on Inflation",
    subtitle="(Percent; cumulative impact)",
    caption=(
        "Source: IMF staff calculations.\n"
        "Note: Shows the estimated impact of El Niño events on inflation using the\n"
        "local projection method in a cross-country panel. Shaded areas\n"
        "correspond to 10th/90th percentile confidence intervals. Andean =\n"
        "Colombia, Ecuador, Peru; CAPDR = Central America, Panama, and the\n"
        "Dominican Republic."
    ),
    left=0.3,
    right=0.15,
    bottom_gap=0.5,
)

for lower, upper, colour in bands.values():
    ax.fill_between(quarters, lower, upper, color=colour, alpha=0.55, linewidth=0)

# The x-axis is drawn at zero, with short tick marks pointing down; the
# quarter labels stay at the bottom of the chart.
ax.axhline(0, color="black", linewidth=0.8)
ax.vlines(quarters, -0.08, 0, color="black", linewidth=0.6)

for series, colour in line_colours.items():
    ax.plot(quarters, data[series], color=colour, linewidth=2.0,
            solid_capstyle="round", label=series)

ax.set_xlim(-0.5, 12.5)
ax.set_xticks(quarters)
ax.set_xlabel("Quarters", fontsize=9, labelpad=7)
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=5)

set_y_scale(ax, -2, 5, 1)
ax.tick_params(axis="y", direction="in", length=2.3)

ax.legend(loc="upper left", bbox_to_anchor=(0.05, 0.98), handlelength=3.0,
          labelspacing=0.4)

save_chart(fig, STEM)
