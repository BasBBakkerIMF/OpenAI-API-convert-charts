"""Figure 15.1: Effect of 2025 US Tariffs on China on LAC Imports from China."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-15-1"

data = read_chart_data(STEM)

fig, ax = new_chart(
    title="Effect of 2025 US Tariffs on China on LAC Imports\nfrom China",
    subtitle="(Predicted change in imports from China; percent)",
    caption=(
        "Sources: Arizala, Schauer, and Grittayaphong (forthcoming); and IMF staff\n"
        "calculations."
    ),
    left=0.3,
    right=0.15,
    bottom_gap=0.3,
)

x = np.arange(len(data))
ax.bar(x, data["series_0"], width=0.56, color="#5B2875")

ax.set_xticks(x, data["category"])
ax.set_xlim(-0.5, len(data) - 0.5)
ax.tick_params(axis="x", length=0, pad=5)

set_y_scale(ax, 0, 8, 2)
ax.tick_params(axis="y", direction="in", length=2.8)

save_chart(fig, STEM)
