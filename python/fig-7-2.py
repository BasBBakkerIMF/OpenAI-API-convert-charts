"""Figure 7.2: Western Hemisphere: Growth and Inflation Risks (two panels)."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-7-2"

# Stacking order, from the bottom up, and colours.
stack_colours = {
    "Balanced": "#7F4AA3",
    "Tilted to the downside": "#FFC000",
    "Tilted to the upside": "#C55A11",
}

# The category labels are not part of the extracted data; they are taken
# from the published chart.
groups = ["AE", "LA7", "OTSA", "CAPDR", "CARIB"]

fig, (ax_left, ax_right) = new_chart(
    title="Western Hemisphere: Growth and Inflation Risks",
    subtitle="(Percent share of total number of WHD countries)",
    caption=(
        "Source: IMF staff calculations.\n"
        "Note: AE = advanced economies; CAPDR = Central America, Panama,\n"
        "and the Dominican Republic; CARIB = Caribbean; LA7 = Latin America 7\n"
        "(Brazil, Chile, Colombia, Mexico, Paraguay, Peru, Uruguay); OTSA =\n"
        "other South America."
    ),
    left=0.35,
    right=0.15,
    bottom_gap=0.75,
    ncols=2,
    wspace=0.4,
)
# The right-hand panel has twice as many bars, so make it wider.
left_box, right_box = ax_left.get_position(), ax_right.get_position()
total = right_box.x1 - left_box.x0
gap = right_box.x0 - left_box.x1
left_width = (total - gap) * 0.35
ax_left.set_position([left_box.x0, left_box.y0, left_width, left_box.height])
ax_right.set_position([left_box.x0 + left_width + gap, right_box.y0,
                       total - left_width - gap, right_box.height])


def stacked_bars(ax, x, data, width):
    bottom = np.zeros(len(data))
    for series, colour in stack_colours.items():
        ax.bar(x, data[series], bottom=bottom, width=width, color=colour,
               label=series)
        bottom += data[series].to_numpy()


def separators(ax, positions, depth):
    """Vertical lines below the axis that separate the category groups."""
    for x in positions:
        ax.plot([x, x], [0, depth], color="black", linewidth=0.6,
                transform=ax.get_xaxis_transform(), clip_on=False)


# Left panel: all WHD countries.
left = read_chart_data(STEM, "datal")
stacked_bars(ax_left, [1, 2], left, width=0.72)
ax_left.set_xlim(0.5, 2.5)
ax_left.set_xticks([1, 2], ["Growth", "Inflation"])
ax_left.tick_params(axis="x", length=0, pad=5)
separators(ax_left, [0.5, 1.5, 2.5], -0.1)
ax_left.text(0.5, -0.17, "WHD", transform=ax_left.transAxes,
             ha="center", va="center")
set_y_scale(ax_left, 0, 100, 20)
ax_left.tick_params(axis="y", length=2.8)

# Right panel: by country group, growth risks then inflation risks.
right = read_chart_data(STEM, "datar")
x = np.array([1, 2, 3, 4, 5, 7, 8, 9, 10, 11])
stacked_bars(ax_right, x, right, width=0.68)
ax_right.set_xlim(0.5, 11.5)
ax_right.set_xticks(x, groups * 2, rotation=90)
ax_right.tick_params(axis="x", length=0, pad=5)
separators(ax_right, [0.5, 6, 11.5], -0.26)
for label, centre in (("Growth", 3), ("Inflation", 9)):
    ax_right.text(centre, -0.22, label, transform=ax_right.get_xaxis_transform(),
                  ha="center", va="center")
set_y_scale(ax_right, 0, 60, 10)
ax_right.tick_params(axis="y", length=2.8)

handles, labels = ax_right.get_legend_handles_labels()
ax_right.legend(handles[::-1], labels[::-1], loc="upper left",
                bbox_to_anchor=(0.02, 1.02), handlelength=0.9,
                handleheight=0.9, labelspacing=0.1)

save_chart(fig, STEM)
