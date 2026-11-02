"""Figure 1.1.2: Caribbean Inflation Response to the Oil Price Shocks."""
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-1-1-2"

data = read_chart_data(STEM)

# In Excel, the confidence bands are drawn as stacked areas, built from four
# helper series (Dummy1-Dummy4). Adding them up gives the band edges.
d1, d2, d3, d4 = (data[f"Dummy{i}"].astype(float) for i in range(1, 5))
blue_band = (d1, d1 + d2)
orange_band = (d1 + d2 + d3, d1 + d2 + d3 + d4)

lines = {
    "Point estimate (2005–14)": "#0065A4",
    "Point estimate (2015–24)": "#C85A0A",
    "Inflation change (2026, simple average)": "#00A7A7",
}

fig, ax = new_chart(
    title="Caribbean Inflation Response to the Oil Price\nShocks",
    subtitle="(Percentage points difference since shock month)",
    caption=(
        "Source: IMF staff calculations.\n"
        "Note: The oil price shock corresponds to about 40-percent increase in oil\n"
        "prices, as materialized in March relative to the January–February 2026\n"
        "average. The inflation response is annualized. Shaded bands represent\n"
        "90 percent Driscoll-Kraay confidence intervals."
    ),
    caption_size=8.3,
    left=0.35,
    right=0.2,
    bottom_gap=0.45,
)

months = data["category"]
ax.fill_between(months, *blue_band, color="#DCEEF8", linewidth=0)
ax.fill_between(months, *orange_band, color="#F6E7DA", alpha=0.9, linewidth=0)

# The x-axis is drawn at zero, with short tick marks pointing up.
ax.axhline(0, color="black", linewidth=0.9)
ax.vlines(range(0, 7), 0, 0.35, color="black", linewidth=0.7)

for label, colour in lines.items():
    ax.plot(months, data[label], color=colour, linewidth=2.2,
            solid_capstyle="round", label=label)

ax.set_xlim(-0.5, 6.5)
ax.set_xticks(range(0, 7))
ax.set_xlabel("Months", fontsize=9, labelpad=8)
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=5)

ax.set_ylim(-6, 12)
ax.yaxis.set_major_locator(MultipleLocator(3))
ax.tick_params(axis="y", length=2.5)

ax.legend(
    loc="lower left", bbox_to_anchor=(0.08, 0.0),
    handlelength=2.6, labelspacing=0.15, fontsize=8.5,
)

save_chart(fig, STEM)
