"""Figure 14.1: LA8 excl. Mexico: Structural Primary Balance and Commodity Terms of Trade."""
from matplotlib.lines import Line2D

from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-14-1"

data = read_chart_data(STEM)
years = data["category"]

balance = "Structural primary balance"
ctot = "CTOT (index: 2000 = 100; right scale)"
colours = {balance: "#5B2A78", ctot: "#A2A39D"}

fig, ax = new_chart(
    title="LA8 excl. Mexico: Structural Primary Balance and\nCommodity Terms of Trade",
    subtitle="(Percent of GDP; unless noted otherwise)",
    caption=(
        "Sources: IMF, Commodity Terms of Trade database; IMF, World\n"
        "Economic Outlook database; and IMF staff calculations.\n"
        "Note: Structural primary balance is simple average. Chile refers to the\n"
        "central government’s structural non-mining primary balance. Colombia\n"
        "refers to the consolidated public sector’s structural non-oil primary\n"
        "balance. Peru refers to the nonfinancial public sector’s structural primary\n"
        "balance. CTOT is purchasing-power-parity GDP-weighted average. CTOT\n"
        "= commodity terms of trade; LA8 = Latin America 8 (Argentina, Brazil,\n"
        "Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    ),
    left=0.35,
    right=0.4,
    bottom_gap=0.4,
)

# In Excel the shaded range is a stacked area: "Min" plus "Min-Max range".
ax.fill_between(years, data["Min"], data["Min"] + data["Min-Max range"],
                color="#E9DFEE", linewidth=0)
ax.axhline(0, color="black", linewidth=0.7)
ax.plot(years, data[balance], color=colours[balance], linewidth=2.0)

ax_right = add_right_axis(ax, (100, 105), 1)
ax_right.plot(years, data[ctot], color=colours[ctot], linewidth=2.0)
ax_right.tick_params(axis="y", length=2.8)

ax.set_xlim(2004.5, 2027.5)
ax.set_xticks(range(2005, 2028, 2))
ax.tick_params(axis="x", labelrotation=90, length=2.8)

set_y_scale(ax, -12, 8, 4)
ax.tick_params(axis="y", length=2.8)

ax.legend([Line2D([], [], color=c, linewidth=2.0) for c in colours.values()],
          list(colours), loc="lower left", bbox_to_anchor=(0.03, 0.03),
          handlelength=3.0, labelspacing=0.2)

save_chart(fig, STEM)
