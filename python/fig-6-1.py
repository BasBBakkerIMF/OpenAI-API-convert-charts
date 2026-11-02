"""Figure 6.1: Headline Consumer Price Inflation."""
import matplotlib.dates as mdates
import pandas as pd

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-6-1"

START, END = pd.Timestamp("2024-01-01"), pd.Timestamp("2026-12-31")
CONFLICT = pd.Timestamp("2026-03-01")

data = read_chart_data(STEM)
# Include December 2023, so the lines run in from the left edge as in Excel.
data = data[(data["category"] >= "2023-12-01") & (data["category"] <= END)]

series_colours = {
    "LA7": "#5B267D",
    "CAPDR": "#C45A12",
    "CARIB": "#08A7B5",
    "USA": "#0067A6",
    "CAN": "#666666",
}

fig, ax = new_chart(
    title="Headline Consumer Price Inflation",
    subtitle="(Year-over-year percent change)",
    caption=(
        "Sources: Haver Analytics; IMF, World Economic Outlook database;\n"
        "national authorities; and IMF staff calculations.\n"
        "Note: Aggregates are purchasing-power-parity GDP-weighted averages.\n"
        "CAPDR = Central America, Panama, and the Dominican Republic; CARIB\n"
        "= Caribbean; LA7 = Brazil, Chile, Colombia, Mexico, Paraguay, Peru,\n"
        "Uruguay."
    ),
    left=0.3,
    right=0.25,
    bottom_gap=0.5,
)

# Each series holds monthly data up to its latest month, then a gap, then the
# end-2026 projection in December 2026. The monthly data are drawn as a solid
# line; a dotted line joins the latest month to the projection, which is
# marked with a dot.
for series, colour in series_colours.items():
    values = data.set_index("category")[series].dropna()
    actual, projection = values.iloc[:-1], values.iloc[-1:]
    ax.plot(actual.index, actual, color=colour, linewidth=1.8,
            solid_capstyle="round", label=series)
    ax.plot([actual.index[-1], projection.index[0]],
            [actual.iloc[-1], projection.iloc[0]],
            color=colour, linewidth=1.8, linestyle=(0, (1, 1.5)))
    ax.scatter(projection.index, projection, s=70, color=colour,
               edgecolor="black", linewidth=0.8, zorder=3, clip_on=False)

ax.axvline(CONFLICT, color="black", linewidth=0.6, linestyle=(0, (1, 1.5)))
ax.text(CONFLICT - pd.Timedelta(days=10), 1.08, "Middle East conflict",
        fontsize=9, fontstyle="italic", ha="right", va="bottom")
ax.text(END, 5.55, "End-2026\nprojections", fontsize=9, fontstyle="italic",
        ha="right", va="center", linespacing=1.0)

ax.set_xlim(START, END)
ax.set_xticks(pd.to_datetime([
    "2024-01-31", "2024-07-31", "2025-01-31", "2025-07-31",
    "2026-01-31", "2026-07-31", "2026-12-31",
]))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%b-%y"))
ax.tick_params(axis="x", labelrotation=90, length=2.8)

set_y_scale(ax, 1, 6, 1)
ax.tick_params(axis="y", length=2.8)

# Two-column legend, read row by row: LA7, CAPDR / CARIB, USA / CAN.
handles, labels = ax.get_legend_handles_labels()
order = [0, 2, 4, 1, 3]
ax.legend([handles[i] for i in order], [labels[i] for i in order],
          loc="upper left", bbox_to_anchor=(0.03, 1.0), ncol=2,
          handlelength=2.6, labelspacing=0.1, columnspacing=1.5)

save_chart(fig, STEM)
