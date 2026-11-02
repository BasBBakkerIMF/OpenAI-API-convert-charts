"""Figure 13: WHD: Policies in Response to the Iran Shock."""
from chart_style import (
    add_right_axis,
    new_chart,
    read_chart_data,
    save_chart,
    set_y_scale,
)

STEM = "fig-13-0"

# The labels are not part of the extracted data; they are taken from the
# published chart. The left three bars use the left scale (percent of
# countries), the right three the right scale (number of policies).
left_labels = ["Allow or\nincrease", "No effect", "Reduce"]
right_labels = ["Taxes", "Spending", "Other"]
left_group = ("Percent share of countries\nimplementing policies affecting\n"
              "commodity price pass-through")
right_group = "Number of policies\nimplemented"

left = read_chart_data(STEM, "datal")
right = read_chart_data(STEM, "datar")

fig, ax = new_chart(
    title="WHD: Policies in Response to the Iran Shock",
    subtitle=None,
    caption=(
        "Sources: IMF, Global Policy Tracker database; and IMF staff calculations.\n"
        "Note: Examples of policies that increase commodity price pass-through\n"
        "include reductions of fuel tax recoveries, fuel subsidy removals\n"
        "(Spending), removals of the fuel price controls, and increases to\n"
        "domestically controlled fuel prices (Others). Examples of policies that\n"
        "reduce commodity price pass-through include fuel, electricity, and food\n"
        "subsidies (Spending), and reductions in fuel taxes (Taxes). “Others” also\n"
        "includes credit guarantees, export taxes, relaxation of fuel standards,\n"
        "release of strategic reserves, work from home mandates, and public\n"
        "sector energy conservation."
    ),
    title_size=13.5,
    left=0.35,
    right=0.35,
    bottom_gap=0.85,
)

ax.bar([1, 2, 3], left["series_0"], width=0.56, color="#08679D")
set_y_scale(ax, 0, 80, 20)
ax.tick_params(axis="y", length=2.8)

ax_right = add_right_axis(ax, (0, 60), 15)
ax_right.bar([4, 5, 6], right["series_0"], width=0.56, color="#C85F16")
ax_right.tick_params(axis="y", length=2.8)

# Two-row table of labels below the plot.
trans = ax.get_xaxis_transform()
for xi in (0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5):
    depth = -0.42 if xi in (0.5, 3.5, 6.5) else -0.14
    ax.plot([xi, xi], [0, depth], color="black", linewidth=0.6,
            transform=trans, clip_on=False)
for xi, label in enumerate(left_labels + right_labels, start=1):
    ax.text(xi, -0.07, label, ha="center", va="center", transform=trans,
            linespacing=1.0)
for centre, label in ((2, left_group), (5, right_group)):
    ax.text(centre, -0.28, label, ha="center", va="center", transform=trans,
            linespacing=1.0)

ax.set_xlim(0.5, 6.5)
ax.set_xticks([])

save_chart(fig, STEM)
