# Python versions of the REO charts

Python (matplotlib) versions of all 38 generated R chart scripts in `r_code/`,
one script per chart, with the same names (`fig-2-3.py` for `fig-2-3.R`).

Each script reads the chart's data from `excel_and_png/<stem>.xlsx`, the same
file the R script uses, and saves the chart as `python/figures/<stem>.png`
(5 x 5 inches, 600 dpi).

`chart_style.py` holds what all charts share: the fonts, the title, subtitle
and source-note layout, reading the data, a right-hand scale, Excel-style
smoothed lines, and saving the figure.

## Running

From this folder, with the project's virtual environment:

```powershell
..\.venv\Scripts\python.exe fig-2-3.py     # one chart
..\.venv\Scripts\python.exe run_all.py     # all charts, with a list of failures
```

The paths are relative to the repository, so the `K:` drive mapping is not
needed.

## Differences from the published charts

- `fig-12-1`: the published chart has error bars, but the confidence
  intervals are not part of the data extracted from Excel, so they are not
  drawn.
- For some charts the category labels are not in the extracted data (for
  example the region names in `fig-9-1`, the years in `fig-10-1`, and the
  labels in `fig-7-2`, `fig-12-1` and `fig-13-0`). They are written into the
  scripts, taken from the published chart.
