from __future__ import annotations

import re
import sys
import time
from pathlib import Path
from typing import Any

from helper_for_4_imf_openai_helper import get_client
#from home_openai_helper import get_client

# ================================================================
# SETTINGS
# ================================================================

# subst m: "D:\OneDrive - Dutch Duck Software\OpenAI-API"
# subst k: "D:\OneDrive - Dutch Duck Software\reo-ai-charts"
# subst k: C:\Users\bbakker\International Monetary Fund (PRD)\(WHD) Regional Studies - General\REO\October 2026 REO\Conjunctural\REO materials from Bas\converted-excel-charts

# Optional example R file showing the preferred chart style.
# Leave as None when no example is needed.
example_file: Path | None = Path(r"k:\example.txt")


model = "gpt-5.6-sol"
chart_dir = Path("k:/excel_and_png")
output_dir = Path("k:/r_code")

MAX_ATTEMPTS = 2

client = get_client()

if not chart_dir.exists():
    raise FileNotFoundError(f"The chart directory was not found:\n{chart_dir}")

#output_dir.mkdir(parents=True, exist_ok=True)

prompt = r"""
You are converting an Excel chart image and an accompanying Excel chart-link
workbook into executable R code. The PNG shows the desired appearance; the
workbook contains the data.

You can see the workbook contents. Inspect them and write code that uses the
actual sheet and column names directly. Do not write code that rediscovers
the structure at runtime, and do not add defensive checks (stopifnot,
existence tests, fallback branches). Keep the code short and direct.

DATA
* If the workbook lists external source workbooks with sheets and ranges,
  read from those; otherwise read the chart-link workbook itself at the
  full path supplied below.
* If sheets dataL and dataR exist, dataL supplies the left chart and dataR
  the right; combine them into one chart.
* Blank or duplicated column names may be handled by position.
* Drop only trailing rows that are blank across all relevant columns.
  Do not invent or approximate data. Preserve the workbook series order.
  If a series lacks x-values, use the common x-range of the other series.

CHART
* Return only executable R code — no Markdown fences, no commentary.
* Use readxl and ggplot2, with dplyr/tidyr where useful; include all
  library() calls.
* Reproduce the title, subtitle, legend, colors, axes, caption, annotations,
  line widths, and layout from the PNG. Match the visible x-axis range even
  if the source data extends beyond it.
* Treat four-digit-integer x columns as years and format the axis
  accordingly. Handle Excel serial dates correctly.
* Use a secondary axis only when the PNG or metadata shows one, via
  sec_axis() with an explicit forward transform and inverse.
* Use Windows-compatible paths; preserve non-breaking spaces in supplied
  paths.
* Assign the plot to an object named chart, then print(chart), then save
  with ggsave() into a "figures" subdirectory of the supplied output
  directory (create it if needed), dpi = 600, width = 5, height = 5, units="in",
  filename from the input chart stem.
* Check whether the code is correct. Make sure that in themes you do not duplicate code.

If the data structure genuinely cannot be determined, return exactly:

# FAILED
"""


# ================================================================
# HELPERS
# ================================================================

def remove_markdown_fences(text: str) -> str:
    """
    Remove Markdown code fences, including a stray opening or closing
    fence when the model wraps only part of the response.
    """
    result = text.strip()

    result = re.sub(r"^```[A-Za-z]*\s*\n?", "", result)
    result = re.sub(r"\n?```\s*$", "", result)

    return result.strip()


def response_is_bad(text: str) -> bool:
    """
    Detect empty, failed, or refusal-style responses.

    Refusal phrases are only checked near the start of the response, so
    legitimate R code containing similar wording is not misclassified.
    """
    stripped = text.strip()

    if not stripped or stripped == "# FAILED":
        return True

    head = stripped[:300].lower()

    refusal_phrases = (
        "cannot assist",
        "i'm sorry",
        "i am sorry",
        "i'm unable to",
        "i am unable to",
    )

    return any(phrase in head for phrase in refusal_phrases)


def validate_inputs(chart_stem: str, png_file: Path, excel_file: Path) -> None:
    """Check that the PNG, chart-link workbook, and optional example exist."""
    missing_files = [
        path
        for path in (png_file, excel_file)
        if not path.exists()
    ]

    if missing_files:
        available_files = sorted(
            path.name for path in chart_dir.glob(f"{chart_stem}*")
        )

        available_text = (
            "\n".join(f"- {name}" for name in available_files)
            if available_files
            else "(No similarly named files were found.)"
        )

        missing_text = "\n".join(str(path) for path in missing_files)

        raise FileNotFoundError(
            "The following input files were not found:\n"
            f"{missing_text}\n\n"
            f"Resolved chart directory:\n{chart_dir}\n\n"
            f"Files beginning with '{chart_stem}':\n{available_text}"
        )

    if example_file is not None and not example_file.exists():
        raise FileNotFoundError(f"Example R file not found:\n{example_file}")


def upload_file(path: Path) -> str:
    """Upload one file and return its uploaded file ID."""
    with path.open("rb") as file_handle:
        uploaded_file = client.files.create(
            file=file_handle,
            purpose="assistants",
        )

    return uploaded_file.id


def delete_uploaded_files(file_ids: list[str]) -> None:
    """Delete uploaded files, ignoring cleanup failures."""
    for file_id in file_ids:
        try:
            client.files.delete(file_id)
        except Exception:
            pass


def build_request_content(
    chart_stem: str,
    png_file: Path,
    excel_file: Path,
    uploaded_image_id: str,
    uploaded_excel_id: str,
    uploaded_example_id: str | None = None,
) -> list[dict[str, Any]]:
    """Build the Responses API request using uploaded file IDs."""
    instruction_text = (
        f"{prompt}\n\n"
        "The files attached to this request were uploaded immediately "
        "before the request was submitted.\n\n"
        "ATTACHED CHART IMAGE:\n"
        f"- Filename: {png_file.name}\n\n"
        "ATTACHED EXCEL WORKBOOK:\n"
        f"- Filename: {excel_file.name}\n"
        f"- Full on-disk path: {excel_file}\n\n"
        "INPUT CHART STEM:\n"
        f"{chart_stem}\n\n"
        "OUTPUT R SCRIPT DIRECTORY:\n"
        f"{output_dir}"
    )

    if uploaded_example_id is not None and example_file is not None:
        instruction_text += (
            "\n\n"
            "ATTACHED EXAMPLE R FILE:\n"
            f"- Filename: {example_file.name}\n"
            "- Use this file as an example of the preferred R coding and "
            "chart-formatting style."
        )

    content: list[dict[str, Any]] = [
        {"type": "input_text", "text": instruction_text},
        {"type": "input_image", "file_id": uploaded_image_id, "detail": "high"},
        {"type": "input_file", "file_id": uploaded_excel_id},
    ]

    if uploaded_example_id is not None:
        content.append({"type": "input_file", "file_id": uploaded_example_id})

    return content


def save_error(error: Exception | str, error_file: Path) -> None:
    """Save an exception or model failure response to the error log."""
    if isinstance(error, Exception):
        error_text = f"{type(error).__name__}: {error}"
    else:
        error_text = error

    error_file.write_text(error_text, encoding="utf-8")


# ================================================================
# MAIN
# ================================================================

def generate_chart(chart_stem: str) -> Path | None:
    """Generate an R script for one chart and return its output path."""
    png_file = chart_dir / f"{chart_stem}.png"
    excel_file = chart_dir / f"{chart_stem}.xlsx"
    output_file = output_dir / f"{chart_stem}.R"
    error_file = output_dir / f"{chart_stem}_error.txt"

    validate_inputs(chart_stem, png_file, excel_file)

    print(f"Chart directory: {chart_dir}")
    print(f"Processing:      {png_file.name}")
    print(f"Workbook:        {excel_file.name}")

    uploaded_ids: list[str] = []

    try:
        uploaded_image_id = upload_file(png_file)
        uploaded_ids.append(uploaded_image_id)
        print(f"Uploaded image:    {uploaded_image_id}")

        uploaded_excel_id = upload_file(excel_file)
        uploaded_ids.append(uploaded_excel_id)
        print(f"Uploaded workbook: {uploaded_excel_id}")

        uploaded_example_id: str | None = None

        if example_file is not None:
            uploaded_example_id = upload_file(example_file)
            uploaded_ids.append(uploaded_example_id)
            print(f"Uploaded example:  {uploaded_example_id}")

        content = build_request_content(
            chart_stem=chart_stem,
            png_file=png_file,
            excel_file=excel_file,
            uploaded_image_id=uploaded_image_id,
            uploaded_excel_id=uploaded_excel_id,
            uploaded_example_id=uploaded_example_id,
        )

        r_code = ""

        for attempt in range(1, MAX_ATTEMPTS + 1):
            print(f"Submitting request (attempt {attempt})...")

            response = client.responses.create(
                model=model,
                max_output_tokens=16000,
                input=[{"role": "user", "content": content}],
            )

            r_code = remove_markdown_fences(response.output_text or "")

            if not response_is_bad(r_code):
                break

            if attempt < MAX_ATTEMPTS:
                time.sleep(2)

        if response_is_bad(r_code):
            save_error(r_code or "(empty response)", error_file)
            print("Generation failed.")
            print(f"Saved response to: {error_file}")
            return None

        output_file.write_text(r_code.rstrip() + "\n", encoding="utf-8")
        print(f"Saved R code to: {output_file}")
        return output_file

    except Exception as error:
        save_error(error, error_file)
        print(f"Failed: {png_file.name}")
        print(f"Saved error log to: {error_file}")
        raise

    finally:
        delete_uploaded_files(uploaded_ids)


def resolve_stems(args: list[str]) -> list[str]:
    """Resolve chart stems from the command line.

    With no arguments, the default stem is used. With --all, every PNG in
    the chart directory that has a matching xlsx is processed.
    """
    if not args:
        return ["fig-1-1"]

    if args == ["--all"]:
        stems = sorted(
            png.stem
            for png in chart_dir.glob("*.png")
            if (chart_dir / f"{png.stem}.xlsx").exists()
        )

        if not stems:
            raise FileNotFoundError(f"No PNG/xlsx pairs found in {chart_dir}")

        return stems

    return args


if __name__ == "__main__":
    generate_chart("fig-1-2")