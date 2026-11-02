"""Figure 9.2: Total Factor Productivity Relative to the US."""
from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-9-2"

data = read_chart_data(STEM)

series_colours = {
    "LA7": "#7030A0",
    "EM Asia": "#00A6AD",
    "EM Europe": "#C65911",
    "Canada": "#404040",
}

fig, ax = new_chart(
    title="Total Factor Productivity Relative to the US",
    subtitle="(Percent)",
    caption=(
        "Sources: IMF, World Economic Outlook database; Penn World Table 11.0\n"
        "database; and IMF staff calculations.\n"
        "Note: Aggregates are purchasing-power-parity GDP- weighted averages.\n"
        "EM = emerging; EM Asia = India, Indonesia, Malaysia, Philippines,\n"
        "Thailand; EM Europe = Hungary, Poland, Romania, Serbia; LA7 = Latin\n"
        "America 7 (Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay)."
    ),
    left=0.35,
    right=0.15,
    bottom_gap=0.45,
)

for series, colour in series_colours.items():
    ax.plot(data["category"], data[series], color=colour, linewidth=1.8,
            solid_capstyle="round", label=series)

ax.set_xlim(2000, 2031)
ax.set_xticks(range(2000, 2031, 5))
ax.tick_params(axis="x", labelrotation=90, length=2.8)

set_y_scale(ax, 30, 110, 20)
ax.tick_params(axis="y", length=2.8)

ax.legend(loc="upper center", bbox_to_anchor=(0.5, 1.02), ncol=4,
          handlelength=2.6, handletextpad=0.4, columnspacing=1.0)

save_chart(fig, STEM)
