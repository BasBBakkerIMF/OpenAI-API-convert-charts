"""Figure 1.2.3: CA4: Enforcement Impact on Remittance Growth."""
from matplotlib.ticker import MultipleLocator

from chart_style import new_chart, read_chart_data, save_chart

STEM = "fig-1-2-3"

data = read_chart_data(STEM)
months = data["category"]

# In Excel the confidence band is a stacked area: "ci_lo" plus "range".
ci_lower = data["ci_lo"]
ci_upper = data["ci_lo"] + data["range"]

fig, ax = new_chart(
    title="CA4: Enforcement Impact on Remittance Growth",
    subtitle="(Percentage points)",
    caption=(
        "Source: IMF staff calculations.\n"
        "Note: Estimated response of remittance growth to changes in immigration\n"
        "enforcement based on panel local projections (Carare and others\n"
        "(forthcoming)). Regressions include country and time fixed effects and\n"
        "macroeconomic controls. Shaded area denotes 90 percent wild cluster\n"
        "bootstrap confidence intervals."
    ),
    title_size=13.5,
    left=0.4,
    right=0.2,
    bottom_gap=0.5,
)

ax.fill_between(months, ci_lower, ci_upper, color="#FCE4D4", alpha=0.9, linewidth=0)

# The x-axis is drawn at zero, with short tick marks pointing up, and a
# dotted line marks the month of the shock.
ax.axhline(0, color="#333333", linewidth=0.9)
ax.vlines(months[months != 0], 0, 0.55, color="#333333", linewidth=0.7)
ax.axvline(0, color="#111111", linewidth=1.0, linestyle=(0, (1, 1.5)))

ax.plot(months, data["coef"], color="#C85C0A", linewidth=2.2,
        solid_capstyle="round", solid_joinstyle="round")

ax.set_xlim(-6, 6)
ax.set_xticks(range(-6, 7))
ax.set_xlabel("Months relative to shock", fontsize=9, labelpad=7)
ax.spines["bottom"].set_visible(False)
ax.tick_params(axis="x", length=0, pad=5)

ax.set_ylim(-15, 15)
ax.yaxis.set_major_locator(MultipleLocator(5))
ax.tick_params(axis="y", direction="in", length=2.5, pad=5)

save_chart(fig, STEM)
