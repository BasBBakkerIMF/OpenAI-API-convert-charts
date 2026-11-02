"""Figure 2.4: US Holdings of Foreign Bonds."""
import numpy as np
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-2-4"

data = read_chart_data(STEM)

series_colours = {
    "LA7": "#5B267A",
    "EM Asia": "#00A3AD",
    "EM Europe": "#D05A0D",
}

fig, ax = new_chart(
    title="US Holdings of Foreign Bonds",
    subtitle="(Percent share of total world)",
    caption=(
        "Sources: Haver Analytics; and IMF staff calculations.\n"
        "Note: LA7 excludes Paraguay due to data limitations. EM = emerging\n"
        "markets; EM Asia = India, Indonesia, Malaysia, Philippines, Thailand; EM\n"
        "Europe = Hungary, Poland, Romania, Serbia; LA7 = Latin America 7\n"
        "(Brazil, Chile, Colombia, Mexico, Paraguay, Peru)."
    ),
    title_size=13.5,
    subtitle_size=11.5,
    left=0.3,
    right=0.2,
    bottom_gap=0.62,
)

x = np.arange(len(data))
for series, colour in series_colours.items():
    ax.plot(x, data[series], color=colour, linewidth=1.8,
            solid_capstyle="round", solid_joinstyle="round", label=series)

# Label every second quarter.
ax.set_xticks(x[::2], data["category"].iloc[::2], rotation=90)
ax.set_xlim(0, len(data) - 1)
ax.tick_params(axis="x", direction="in", length=2.3, pad=5, labelsize=9.5)

ax.set_ylim(0, 7)
ax.yaxis.set_major_locator(MultipleLocator(1))
ax.tick_params(axis="y", direction="in", length=2.3, pad=6, labelsize=9.5)

ax.legend(loc="upper left", bbox_to_anchor=(0.06, 1.0), fontsize=9.5,
          handlelength=3.0, labelspacing=0.15)

save_chart(fig, STEM)
