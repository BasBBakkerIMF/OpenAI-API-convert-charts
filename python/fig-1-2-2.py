"""Figure 1.2.2: Remittances to CA4 Countries."""
import matplotlib.dates as mdates
import pandas as pd
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-1-2-2"

data = read_chart_data(STEM)
dates = pd.to_datetime(data["category"])

# In Excel the band is a stacked area: "Min" plus the "Min-Max Band" on top.
band_lower = data["Min"]
band_upper = data["Min"] + data["Min-Max Band"]

fig, ax = new_chart(
    title="Remittances to CA4 Countries",
    subtitle="(Year-over-year percent change)",
    caption=(
        "Sources: Haver Analytics; national authorities; and IMF staff calculations.\n"
        "Note: Nicaragua’s 2025–26H1 data are IMF staff estimates. CA4 =\n"
        "Central America 4 (El Salvador, Guatemala, Honduras, Nicaragua)."
    ),
    caption_size=7.8,
    left=0.4,
    right=0.2,
    bottom_gap=0.55,
)

ax.fill_between(dates, band_lower, band_upper, color="#FCE5D6", linewidth=0)
ax.axhline(0, color="#BFBFBF", linewidth=0.7)
ax.plot(dates, data["Total remittances"], color="#C55A11", linewidth=2.4,
        solid_capstyle="round", solid_joinstyle="round")

ax.set_xlim(pd.Timestamp("2023-12-15"), pd.Timestamp("2026-06-15"))
ax.set_xticks(pd.date_range("2024-01-01", "2026-05-01", freq="2MS"))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%b-%y"))
ax.tick_params(axis="x", labelrotation=90, direction="in", length=2.8, pad=5)

ax.set_ylim(-10, 50)
ax.yaxis.set_major_locator(MultipleLocator(10))
ax.tick_params(axis="y", direction="in", length=2.8, pad=5)

save_chart(fig, STEM)
