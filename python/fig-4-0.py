"""Figure 4: LA5: Drivers of Change in Growth, 2026 (waterfall chart)."""
import numpy as np

from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-4-0"

data = read_chart_data(STEM)

# In Excel the waterfall is a stacked column chart: an invisible "Lower band"
# lifts each visible "Upper band" bar to the right height.
bar_colours = {
    "Terms of trade": "#78C51C",
    "Financial conditions": "#78C51C",
    "Uncertainty": "#E1251B",
    "Residual": "#B6B7B8",
    "Change in growth, 2026 vs. 2025": "#5B2A73",
}
labels = {
    "Terms of trade": "Terms of\ntrade",
    "Financial conditions": "Financial\nconditions",
    "Uncertainty": "Uncertainty",
    "Residual": "Residual",
    "Change in growth, 2026 vs. 2025": "Change in\ngrowth, 2026\nvs. 2025",
}

fig, ax = new_chart(
    title="LA5: Drivers of Change in Growth, 2026",
    subtitle="(Percent)",
    caption=(
        "Sources: Ahir, H, N Bloom, and D Furceri (2022), “World Uncertainty\n"
        "Index”, NBER Working Paper; Haver Analytics; IMF, World Economic\n"
        "Outlook database; and IMF staff calculations.\n"
        "Note: Aggregate is purchasing-power-parity GDP-weighted average.\n"
        "Estimates are obtained from a local projection regression of growth on\n"
        "terms of trade, financial conditions, and uncertainty, controlling for US and\n"
        "China growth and inflation, and country- and year- fixed effects. For\n"
        "methodology and variables included in the financial conditions index, refer\n"
        "to the online annex of the October 2018 Global Financial Stability Report.\n"
        "LA5 = Latin America 5 (Brazil, Chile, Colombia, Mexico, Peru)."
    ),
    caption_size=8.2,
    left=0.4,
    right=0.15,
    bottom_gap=0.55,
)

x = np.arange(len(data))
ax.bar(x, data["Upper band"], bottom=data["Lower band"], width=1.0,
       color=[bar_colours[c] for c in data["category"]])

ax.set_xticks(x, [labels[c] for c in data["category"]])
ax.set_xlim(-0.5, len(data) - 0.5)
ax.tick_params(axis="x", length=3, pad=5, labelsize=9)

set_y_scale(ax, 0, 0.8, 0.2)
ax.yaxis.set_major_formatter("{x:.1f}")
ax.tick_params(axis="y", length=3)

save_chart(fig, STEM)
