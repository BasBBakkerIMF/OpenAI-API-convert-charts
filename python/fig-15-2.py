"""Figure 15.2: China's Share of Latin American Passenger Car Imports."""
from chart_style import new_chart, read_chart_data, save_chart, set_y_scale

STEM = "fig-15-2"

data = read_chart_data(STEM)
years = data["category"]

fig, ax = new_chart(
    title="China's Share of Latin American Passenger Car\nImports",
    subtitle="(Percent share)",
    caption=(
        "Sources: UN Comtrade; World Bank, World Integrated Trade Solution;\n"
        "and IMF staff calculations.\n"
        "Note: Shaded area refers to the min-max range."
    ),
    left=0.3,
    right=0.15,
    bottom_gap=0.3,
)

# In Excel the min-max range is a stacked area: "Min" plus "Difference".
ax.fill_between(years, data["Min"], data["Min"] + data["Difference"],
                color="#F2EDF4", linewidth=0)
ax.plot(years, data["LATAM"], color="#5B2677", linewidth=1.9,
        solid_capstyle="round")

ax.set_xlim(2014.5, 2025.5)
ax.set_xticks(range(2015, 2026, 2))
ax.tick_params(axis="x", length=2.8, pad=5)

set_y_scale(ax, 0, 50, 10)
ax.tick_params(axis="y", length=2.8)

save_chart(fig, STEM)
