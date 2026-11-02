"""Figure 1.1.1: US Citizen Departures to the Caribbean."""
import numpy as np
from matplotlib.lines import Line2D
from matplotlib.ticker import FormatStrFormatter, MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-1-1-1"

data = read_chart_data(STEM)

years = ["2019", "2025", "2026"]
year_colours = {"2019": "#0873B2", "2025": "#BFC0C2", "2026": "#A982BA"}
yoy = "Year-over-year percent change (right scale)"

fig, ax = new_chart(
    title="US Citizen Departures to the Caribbean",
    subtitle="(Millions, unless noted otherwise)",
    caption=(
        "Sources: US International Trade Administration; and IMF staff\n"
        "calculations.\n"
        "Note: Data include 15 countries and exclude Jamaica."
    ),
    title_size=13.5,
    subtitle_size=11.5,
    caption_size=9,
    left=0.4,
    right=0.35,
    bottom_gap=0.3,
)

# Bars: one group per month, one bar per year.
x = np.arange(len(data))
bar_width = 0.82 / len(years)
for i, year in enumerate(years):
    offset = (i - (len(years) - 1) / 2) * bar_width
    ax.bar(x + offset, data[year], width=bar_width, color=year_colours[year], label=year)

ax.set_xticks(x, data["category"])
ax.set_xlim(-0.6, len(data) - 0.4)
ax.set_ylim(0, 0.8)
ax.yaxis.set_major_locator(MultipleLocator(0.2))
ax.yaxis.set_major_formatter(FormatStrFormatter("%.1f"))
ax.tick_params(axis="x", length=0, pad=6)
ax.tick_params(axis="y", direction="in", length=3, pad=6)

# Line: year-over-year change, on the right-hand scale.
ax_right = ax.twinx()
ax_right.plot(x, data[yoy], color="black", linewidth=1.8, solid_capstyle="round")
ax_right.set_ylim(0, 8)
ax_right.yaxis.set_major_locator(MultipleLocator(2))
ax_right.spines["right"].set_visible(True)
ax_right.spines["top"].set_visible(False)
ax_right.tick_params(axis="y", direction="in", length=3, pad=6)

handles, labels = ax.get_legend_handles_labels()
handles.append(Line2D([], [], color="black", linewidth=1.8))
labels.append(yoy)
ax_right.legend(
    handles, labels,
    loc="upper left", bbox_to_anchor=(0.0, 1.02),
    handlelength=3.2, handleheight=0.9, labelspacing=0.1,
    borderaxespad=0.2, fontsize=9.5,
)

save_chart(fig, STEM)
