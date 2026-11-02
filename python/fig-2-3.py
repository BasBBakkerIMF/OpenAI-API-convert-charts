"""Figure 2.3: LAC: International Bond Issuance."""
import numpy as np
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-2-3"

data = read_chart_data(STEM)
categories = data["category"].astype(str)

# Stacking order, from the bottom up, and colours.
stack_colours = {
    "Rest of LAC": "#000000",
    "CAPDR/CARIB": "#4F8A10",
    "Uruguay": "#9B6AB0",
    "Peru": "#FDBF22",
    "Paraguay": "#8EC7E0",
    "Mexico": "#666666",
    "Colombia": "#D2691E",
    "Chile": "#009999",
    "Brazil": "#08679B",
}

fig, ax = new_chart(
    title="LAC: International Bond Issuance",
    subtitle="(Billions of US dollars)",
    caption=(
        "Sources: Bond Radar; and IMF staff calculations.\n"
        "Note: Includes sovereign and corporate/financial bond issuances. CAPDR\n"
        "= Central America, Panama, and the Dominican Republic; CARIB =\n"
        "Caribbean; LAC = Latin America and the Caribbean."
    ),
    caption_size=8.4,
    left=0.35,
    right=0.15,
    bottom_gap=0.3,
)

x = np.arange(len(data))
bottom = np.zeros(len(data))
bars = {}
for series, colour in stack_colours.items():
    bars[series] = ax.bar(x, data[series], bottom=bottom, width=0.56, color=colour)
    bottom += data[series].to_numpy()

# Red dots: issuance in January-September of each earlier year, for
# comparison with the last bar. There is no dot on the last bar itself.
jan_sep = data["Jan-Sep"].iloc[:-1]
ax.scatter(x[:-1], jan_sep, s=90, color="red", edgecolor="black",
           linewidth=1.2, zorder=3)
ax.annotate("Jan-Sep", xy=(x[0], jan_sep.iloc[0] + 3.5), xytext=(x[0] - 0.1, 83),
            color="red", fontsize=9, ha="left", va="bottom",
            arrowprops=dict(arrowstyle="-", color="#A6A6A6", linewidth=1.2,
                            shrinkA=0, shrinkB=0))

ax.set_xticks(x, categories)
ax.set_xlim(-0.5, len(data) - 0.5)
ax.tick_params(axis="x", length=3, pad=5)

ax.set_ylim(0, 180)
ax.yaxis.set_major_locator(MultipleLocator(30))
ax.tick_params(axis="y", length=3)

# Legend in two columns, read row by row: Brazil, Chile / Colombia, Mexico ...
# (matplotlib fills legend columns top to bottom, so reorder accordingly).
row_order = list(stack_colours)[::-1]
legend_order = row_order[0::2] + row_order[1::2]
ax.legend([bars[s] for s in legend_order], legend_order,
          loc="upper left", bbox_to_anchor=(0.03, 1.02), ncol=2,
          handlelength=1.0, handleheight=1.0, labelspacing=0.15,
          columnspacing=1.8, fontsize=9)

save_chart(fig, STEM)
