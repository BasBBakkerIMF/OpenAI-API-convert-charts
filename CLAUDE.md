# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Converts the Excel charts of an IMF WHD Regional Economic Outlook (REO) into reproducible R/ggplot2 scripts. Python extracts each chart's PNG and underlying data from the source Excel workbooks, then an OpenAI model (via the Responses API) writes R code that reproduces the chart from that data.

## Setup

```powershell
.\install.ps1   # creates .venv and installs requirements.txt
```

There is no build, lint or test suite. `generate_requirements.py` regenerates `requirements.txt`. `test_openAi.py` is a manual connectivity check for the OpenAI client.

## Pipeline

The numbered scripts run in order, each as `python <script>.py`. All configuration (paths, REO edition, sheet names) is hardcoded in each script's `__main__` block or top-level settings, so a new REO edition means editing those values (e.g. `"October 2026"`, `"October 2026 REO Figure"`).

1. `1_map_drives.py` uses `subst` to map **`L:`** to the network chart folder and **`K:`** to this repo's location. Every later script uses `K:\...` / `L:\...` paths, so this must run first on each machine/session.
2. `2_export_pictures_from_file_locator.py` reads the "WHD REO File Locator" workbook and exports every embedded picture on the given sheet to `excel_and_png/<picture name>.png`. It parses the OOXML zip directly (sheet → drawing → blip → media).
3. `3_create_chart_list.py` turns the locator sheet into `chart-list.xlsx` (columns include `File Location`, `Sheet`, `Chart name in sheet`, `Second chart`, `Picture name in this file`).
4. `4_read_all_chart_data_and_put_in_excel.py` uses `helper_for_4_read_data_from_excel_chart_and_export.read_chart_data` to pull each chart's series out of the source workbook's chart XML (category or XY-scatter series, skipping hidden rows/cols) and writes `excel_and_png/<stem>.xlsx`. One chart → sheet `data`; a dual chart (`Second chart` set) → sheets `datal` and `datar`.5. `5_create_stems_file.py` writes `stems.txt` (one chart stem per line, e.g. `fig-2-3`) from `Picture name in this file`.
6. `6_generate_r_code_for_charts.py` is the core step. For each stem it pairs `excel_and_png/<stem>.png` with `<stem>.xlsx`, uploads both plus `example.txt` (the house-style example R code, a copy of `example.R`), and asks the model for R code. It writes `r_code/<stem>.R` or, on failure, `r_code/<stem>_error.txt`.
   - `python 6_generate_r_code_for_charts.py` processes the stems in `stems.txt`. Pass stems as args (`... fig-2-3 fig-9-2`) to process only those, or `--all` for every PNG/XLSX pair.
7. `7_create_runall.py` generates `r_code/runall.R`, which sources each `K:/r_code/<stem>.R` with tryCatch and reports failures. The R scripts save output to `r_code/figures/<stem>.png`.

The **stem** (`fig-<chapter>-<n>`) is the join key across `excel_and_png/`, `r_code/`, `r_code/figures/`, and `stems.txt`.

## OpenAI client (step 6)

- `helper_for_6_imf_openai_helper.get_client()` is the default. It connects to the IMF API gateway using MSAL interactive auth with a token cache in `%LOCALAPPDATA%\.IdentityService`. It needs `.env` with `API_KEY`, `CLIENT_ID`, `TENANT_ID`, `API_URL`.
- `helper_for_6_home_openai.get_client()` is for direct OpenAI access (`OPENAI_API_KEY` in `.env`). To switch, change the commented import in step 6.
- The model name is the `model` setting at the top of step 6.

## Prompt design in step 6

Before each request, `get_workbook_structure()` inspects the extracted `.xlsx` locally (sheet names, column names, observed types such as "text containing numeric values", and sample rows) and injects it into the prompt as the authoritative **VERIFIED WORKBOOK STRUCTURE**. Most of the prompt's rules exist to stop the model from inventing column or sheet names and to force `as.numeric()` on numeric-looking text. Keep that contract intact when editing the prompt. Responses that are empty, `# FAILED`, or look like refusals are retried up to `MAX_ATTEMPTS`.

## Other

- `archive/` holds superseded scripts and is not part of the pipeline.
- R side: `OpenAI-API-convert-charts.Rproj` and `r_code/r_code.Rproj`. The generated scripts use readxl, ggplot2, dplyr/tidyr and sometimes patchwork.
