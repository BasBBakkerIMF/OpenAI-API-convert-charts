"""Figure 2.2: Yields and Spreads (two panels)."""
import matplotlib.dates as mdates
import pandas as pd
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-2-2"

START, END = pd.Timestamp("2024-01-01"), pd.Timestamp("2026-09-30")
CONFLICT = pd.Timestamp("2026-03-01")

# Each panel: (data sheet, title, subtitle, series colours, y-limits, y-step).
panels = [
    ("datal", "Ten-year Bond Yields", "(Percent)",
     {"USA": "#00689D", "CAN": "#404040", "LA7": "#5B2A7B"}, (2, 8), 1),
    ("datar", "Sovereign Spreads", "(Basis points)",
     {"LA7": "#5B2A7B", "CAPDR": "#C55A11", "CARIB": "#00A1A9"}, (50, 400), 50),
]

fig, axes = new_chart(
    title="Yields and Spreads",
    subtitle=None,
    caption=(
        "Sources: Bloomberg Finance L.P.; and IMF staff calculations.\n"
        "Note: Aggregates are medians. Sovereign spread refers to EMBIG\n"
        "spread. CAPDR = Central America, Panama, and the Dominican\n"
        "Republic; CARIB = Caribbean; LA7 = Latin America 7 (Brazil, Chile,\n"
        "Colombia, Mexico, Paraguay, Peru, Uruguay)."
    ),
    caption_size=8.2,
    left=0.3,
    right=0.15,
    top_gap=0.5,
    bottom_gap=0.5,
    ncols=2,
    wspace=0.45,
)

for ax, (sheet, title, subtitle, colours, ylim, ystep) in zip(axes, panels):
    data = read_chart_data(STEM, sheet)
    data = data[(data["category"] >= START) & (data["category"] <= END)]

    ax.axvline(CONFLICT, color="#666666", linewidth=0.8, linestyle=(0, (1, 1.5)))
    for series, colour in colours.items():
        ax.plot(data["category"], data[series], color=colour, linewidth=1.5,
                label=series)
    ax.text(CONFLICT - pd.Timedelta(days=12), ylim[0] + 0.02 * (ylim[1] - ylim[0]),
            "Middle East conflict", fontsize=8, fontstyle="italic",
            ha="right", va="bottom")

    ax.set_xlim(START, END)
    ax.set_xticks(pd.date_range(START, "2026-07-01", freq="6MS"))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%b-%y"))
    ax.tick_params(axis="x", labelrotation=90, labelsize=8.5, length=2.8)

    ax.set_ylim(*ylim)
    ax.yaxis.set_major_locator(MultipleLocator(ystep))
    ax.tick_params(axis="y", labelsize=8.5, length=2.8)

    # Panel title and subtitle, in grey.
    ax.text(0, 1.1, title, transform=ax.transAxes, color="#777777",
            fontsize=11, fontweight="bold", ha="left", va="bottom")
    ax.text(0, 1.1, subtitle, transform=ax.transAxes, color="#777777",
            fontsize=10, fontstyle="italic", ha="left", va="top")

    ax.legend(loc="upper left", bbox_to_anchor=(0.08, 1.0), fontsize=8.5,
              handlelength=2.6, labelspacing=0.05)

save_chart(fig, STEM)
