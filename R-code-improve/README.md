# Improved R chart scripts

Rewritten versions of the 38 generated R chart scripts in `r_code/`, one per
chart with the same name. They draw the same charts from the same data
(`excel_and_png/<stem>.xlsx`) in much less code.

## Running

Open `R-code-improve.Rproj` in RStudio (so this folder is the working
directory), then:

```r
source("fig-2-3.R")   # one chart
source("runall.R")    # all charts, with a list of failures
```

Each chart is saved as `figures/<stem>.png` (5 x 5 inches, 600 dpi). The
paths are relative to the repository, so the `K:` drive mapping is not
needed.

Packages: readxl, ggplot2, dplyr, tidyr, and for a few charts patchwork and
ggrepel.

## What changed

**Shared code in `chart_style.R`.** Every script starts with
`source("chart_style.R")`, which loads the packages and provides:

| Function | Replaces |
|---|---|
| `read_chart_data(stem, sheet)` | the workbook path and `read_excel()` call |
| `theme_reo()` | 40–60 lines of `theme()` settings per script |
| `scale_y_reo(low, high, by)` | the limits/breaks/expand boilerplate |
| `right_axis(scale, shift)` | hand-written `sec_axis()` transformations |
| `axis_line_at(at, x, tick)` | the zero line with short tick marks |
| `legend_at()`, `ticks_inward()`, `vertical_x_labels()` | repeated `theme()` fragments |
| `smooth_path()` | Excel-style smoothed lines |
| `save_chart(chart, stem)` | the output paths, `dir.create()`, `print()` and `ggsave()` |

Figures 11.1 and 11.2 (the monetary and fiscal policy charts) share all
their code in `policy_mix.R`.

**Simpler data handling.** `pivot_longer(-category)` instead of listing
columns twice; `factor(levels = names(colours))` so the colour list also sets
the legend order; no defensive type conversions where the data are already
numeric.

**Corrections.** Comparing every chart with the published Excel picture
showed some mistakes in the generated code, now fixed:

- `fig-2-2`: the LA7 bond yield was missing (its column starts with many
  empty rows, so `read_excel()` guessed the wrong type and dropped it; all
  data are now read with `guess_max`), and the "Middle East conflict" line
  is at March 2026, not January.
- `fig-1-2-1`: the stacking order of the bars matches Excel (GTM at the
  bottom).
- `fig-2-3`: the "Jan-Sep" pointer runs from the label down to the dot.
- `fig-2-1`, `fig-8-0`, `fig-16-2`: subtitle punctuation matches the
  published charts.
- `fig-3-2`: the line at 100 is restored.
- `fig-6-1`: lines start at the left edge, as in Excel.

## Known differences from the published charts

- `fig-12-1`: the error bars are not drawn, because the confidence intervals
  are not in the extracted data.
- Some category labels are not in the extracted data and are typed into the
  scripts (for example the region names in `fig-9-1` and the years in
  `fig-10-1`).
- `fig-14-2`: Argentina's off-scale value is labelled as 12.5 by hand.
