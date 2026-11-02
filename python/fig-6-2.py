"""Figure 6.2: LAC: Oil Price Pass-through (distribution)."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-6-2"

data = read_chart_data(STEM)
density = data[data["series"] == "LAC"].dropna(subset=["x", "y"])
average = data[data["series"] == "LAC average"].dropna(subset=["x", "y"])

purple = "#5B2678"

fig, ax = new_chart(
    title="LAC: Oil Price Pass-through",
    subtitle="(Fraction)",
    caption=(
        "Source: IMF staff calculations.\n"
        "Note: Vertical dashed line refers to the median of the region. AE =\n"
        "advanced economies; Pass-through is calculated as the percentage\n"
        "change in domestic dollar retail diesel prices over the percentage change\n"
        "in international diesel prices (both measured in US dollars). Pass-through\n"
        "is trimmed at the 1 percent level. LAC = Latin America and the Caribbean."
    ),
    left=0.3,
    right=0.2,
    bottom_gap=0.3,
)

ax.plot(density["x"], density["y"], color=purple, linewidth=1.9,
        solid_capstyle="round")
ax.plot(average["x"], average["y"], color=purple, linewidth=1.2,
        linestyle=(0, (4, 2.5)))

# The density has no numeric y-axis. A vertical line at x = 0 with tick marks
# takes the place of the y-axis.
ax.spines["left"].set_visible(False)
ax.set_yticks([])
ax.axvline(0, color="black", linewidth=0.7)
ax.hlines(np.arange(0.2, 1.01, 0.2), -0.035, 0, color="black", linewidth=0.6)

ax.set_xlim(-0.5, 2.5)
ax.set_xticks(np.arange(-0.5, 2.51, 0.5))
ax.xaxis.set_major_formatter("{x:.1f}")
ax.tick_params(axis="x", direction="in", length=2.8, pad=5)
ax.set_ylim(0, 1)

save_chart(fig, STEM)
