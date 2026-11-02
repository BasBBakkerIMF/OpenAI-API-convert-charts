"""Figure 3.4: Overall and Trade Policy Uncertainties."""
import matplotlib.dates as mdates
import pandas as pd
from matplotlib.lines import Line2D
from matplotlib.ticker import FormatStrFormatter

from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-3-4"

START, END = pd.Timestamp("2021-01-01"), pd.Timestamp("2026-08-31")
CONFLICT = pd.Timestamp("2026-03-01")

data = read_chart_data(STEM)
data = data[(data["category"] >= START) & (data["category"] <= END)]

left_series = {"WUI": "#00649D", "TPU": "#D55E00"}
usa = "USA (right scale)"
usa_colour = "#666666"

fig, ax = new_chart(
    title="Overall and Trade Policy Uncertainties",
    subtitle="(Index)",
    caption=(
        "Sources: Ahir, H, N Bloom, and D Furceri (2022), “World Uncertainty\n"
        "Index”, NBER Working Paper; Caldara and others (2020); and Haver\n"
        "Analytics.\n"
        "Note: The uncertainty measures are news- and media-outlets-based\n"
        "indices that quantify media attention to global news related to overall\n"
        "uncertainty (WUI) and trade policy uncertainty (TPU). Uncertainty index\n"
        "shown for the United States is from the WUI."
    ),
    left=0.3,
    right=0.4,
    bottom_gap=0.5,
)

for series, colour in left_series.items():
    ax.plot(data["category"], data[series], color=colour, linewidth=1.7,
            solid_capstyle="round")

# USA is on the right-hand scale.
ax_right = add_right_axis(ax, (0, 3), 0.5)
ax_right.yaxis.set_major_formatter(FormatStrFormatter("%.1f"))
ax_right.tick_params(axis="y", length=2.8)
ax_right.plot(data["category"], data[usa], color=usa_colour, linewidth=1.7,
              solid_capstyle="round")

ax.axvline(CONFLICT, color="black", linewidth=0.6, linestyle=(0, (1, 1.5)))
ax.text(CONFLICT - pd.Timedelta(days=15), 1.25, "Middle East\nconflict",
        fontsize=8.7, fontstyle="italic", ha="right", va="bottom",
        linespacing=1.0)

ax.set_xlim(START, END)
ax.set_xticks(pd.date_range(START, "2026-07-01", freq="6MS"))
ax.xaxis.set_major_formatter(mdates.DateFormatter("%b-%y"))
ax.tick_params(axis="x", labelrotation=90, length=2.8)

set_y_scale(ax, 0, 14, 2)
ax.tick_params(axis="y", length=2.8)

styles = {**left_series, usa: usa_colour}
ax_right.legend(
    [Line2D([], [], color=c, linewidth=1.8) for c in styles.values()],
    list(styles),
    loc="upper left", bbox_to_anchor=(0.03, 1.0), handlelength=3.0,
    labelspacing=0.1,
)

save_chart(fig, STEM)
