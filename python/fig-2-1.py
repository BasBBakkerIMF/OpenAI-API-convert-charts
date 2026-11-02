"""Figure 2.1: Financial Conditions Index."""
import numpy as np
from matplotlib.ticker import FormatStrFormatter, MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-2-1"

data = read_chart_data(STEM)

series_colours = {
    "LA5": "#5B267A",
    "United States": "#0066A6",
    "Canada": "#404040",
}

fig, ax = new_chart(
    title="Financial Conditions Index",
    subtitle="(0 = neutral; +/– = tight/loose)",
    caption=(
        "Source: IMF staff calculations.\n"
        "Note: For methodology and variables included in the financial conditions\n"
        "index, refer to the online annex of the October 2018 Global Financial\n"
        "Stability Report. LA5 is purchasing-power-parity GDP-weighted averages.\n"
        "LA5 = Latin America 5 (Brazil, Chile, Colombia, Mexico, Peru)."
    ),
    left=0.4,
    right=0.15,
    bottom_gap=0.62,
)

x = np.arange(len(data))

# The x-axis is drawn at zero, with short tick marks pointing up.
ax.axhline(0, color="black", linewidth=0.9)
ax.vlines(x, 0, 0.035, color="black", linewidth=0.7)

for series, colour in series_colours.items():
    ax.plot(x, data[series], color=colour, linewidth=1.8,
            solid_capstyle="butt", label=series)

ax.set_xticks(x, data["category"], rotation=90)
ax.set_xlim(0, len(data) - 1)
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=7)

ax.set_ylim(-1, 0.6)
ax.yaxis.set_major_locator(MultipleLocator(0.2))
ax.yaxis.set_major_formatter(FormatStrFormatter("%.1f"))
ax.tick_params(axis="y", length=2.8, pad=5)

ax.legend(loc="center left", bbox_to_anchor=(0.05, 0.49),
          handlelength=2.9, labelspacing=0.15)

save_chart(fig, STEM)
