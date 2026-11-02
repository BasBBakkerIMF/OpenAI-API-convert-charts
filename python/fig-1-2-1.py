"""Figure 1.2.1: Repatriations and Border Apprehensions."""
import matplotlib.dates as mdates
import numpy as np
import pandas as pd
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-1-2-1"

data = read_chart_data(STEM)
dates = pd.to_datetime(data["category"])

country_colours = {
    "GTM": "#0070C0",
    "HND": "#00A6A6",
    "SLV": "#ED7D31",
    "NIC": "#BFBFBF",
}

# Each country has an actual series and an estimated one (from December
# 2024). Use the actual value where there is one, otherwise the estimate.
# Both are in persons; the chart shows thousands.
repatriations = {
    country: data[country].fillna(data[f"{country}(est)"]) / 1000
    for country in country_colours
}
apprehensions = data["Apprehensions (right scale)"] / 1000

fig, ax = new_chart(
    title="Repatriations and Border Apprehensions",
    subtitle="(Thousands)",
    caption=(
        "Sources: US Customs and Border Protection; US Department of\n"
        "Homeland Security; US Immigration and Customs Enforcement (ICE); and\n"
        "IMF staff estimates.\n"
        "Note: Repatriations include removals, administrative and enforcement\n"
        "returns. Title 42 expulsions are not included. Since December 2024,\n"
        "repatriations are estimated using ICE book-ins. The repatriations to book-\n"
        "ins ratio is calculated through November 2024 and projected to remain\n"
        "constant. Since data for book-ins are published through June 2026, this\n"
        "allows to estimate the repatriations in 2026."
    ),
    caption_size=7.7,
    left=0.35,
    right=0.35,
    bottom_gap=0.5,
)

# Stacked bars, one per month.
bottom = np.zeros(len(data))
for country, colour in country_colours.items():
    values = repatriations[country].fillna(0).to_numpy()
    ax.bar(dates, values, bottom=bottom, width=24, color=colour,
           label=country, align="center")
    bottom += values

ax.axvline(pd.Timestamp("2024-12-15"), color="black", linewidth=0.8,
           linestyle=(0, (1, 1.5)))
ax.text(pd.Timestamp("2025-04-01"), 19.45, "Estimates",
        fontsize=9.7, fontstyle="italic", ha="left", va="center")

ax.set_xlim(pd.Timestamp("2020-01-01"), pd.Timestamp("2026-06-30"))
ax.set_xticks(pd.date_range("2020-01-01", "2026-06-01", freq="7MS"))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%b-%y"))
ax.tick_params(axis="x", labelrotation=90, labelsize=8.5, length=2.5)

ax.set_ylim(0, 20)
ax.yaxis.set_major_locator(MultipleLocator(4))
ax.tick_params(axis="y", length=2.5)

ax.legend(
    loc="upper left", bbox_to_anchor=(0.0, 1.0), ncol=4,
    handlelength=0.9, handleheight=0.9, handletextpad=0.3,
    columnspacing=0.8, fontsize=8.8,
)

# Line: apprehensions, on the right-hand scale.
ax_right = ax.twinx()
ax_right.plot(dates, apprehensions, color="black", linewidth=2.4,
              solid_capstyle="round", solid_joinstyle="round")
ax_right.set_ylim(0, 80)
ax_right.yaxis.set_major_locator(MultipleLocator(20))
ax_right.spines["right"].set_visible(True)
ax_right.spines["top"].set_visible(False)
ax_right.tick_params(axis="y", length=2.5)
ax_right.text(pd.Timestamp("2021-09-01"), 65, "Apprehensions\n(right scale)",
              fontsize=9.2, ha="left", va="center", linespacing=0.95)

save_chart(fig, STEM)
