


from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any

from imf_openai_helper import get_client


# ================================================================
# SETTINGS
# ================================================================

# Optional example R file showing the preferred chart style.
# Leave as None when no example is needed.
#example_file: Path | None = None

example_file: Path | None = Path(
    r"c:\test\example.txt"
)


client = get_client()

#model="gpt-5.6-terra"
model="gpt-5.6-sol"

#chart_dir = Path("L:/reo-chart-exports")
chart_dir = Path("c:/test")
#
# in Powershell subst L:  "D:\OneDrive - Dutch Duck Software\REO materials from Bas\"
# C:\Users\bbakker\International Monetary Fund (PRD)\(WHD) Regional Studies - General\REO\October 2026 REO\Conjunctural\REO materials from Bas
# to remove subst L: /D

if not chart_dir.exists():
    raise FileNotFoundError(
        "The chart directory was not found:\n"
        f"{chart_dir}"
    )

output_dir = Path("c:/test/created-code")
output_dir.mkdir(parents=True, exist_ok=True)




# Example:
# example_file = Path(r"C:\path\to\example_chart.R")


# ================================================================
# FIND THE CORRECT CHART DIRECTORY
# ================================================================
# ================================================================
# ================================================================
# ================================================================

# PROMPT

# ================================================================

prompt = r"""
You are converting an Excel chart image and an accompanying Excel workbook
into executable R code.

The PNG shows the desired visual appearance.

The attached Excel workbook contains the actual chart data and chart metadata,
including:

* the source workbook path
* worksheet names
* series names
* series order
* x-value ranges
* y-value ranges
* primary-axis and secondary-axis information
* chart layout information

Your task is to write self-contained R code that reads the actual source data
from the Excel workbook and reproduces the chart as closely as practical.

# ================================================================

# DATA REQUIREMENTS

# ================================================================

* Use readxl to read the actual source workbook.
* Use the exact workbook path, worksheet names, and cell ranges found in the
  attached workbook.
* Read the x-values and y-values from the actual chart-series ranges.
* Do not infer column meanings from worksheet position.
* Do not invent source column names.
* Do not assume that the worksheet is a conventional rectangular data table.
* Do not assume that columns are named index, year, date, category, or similar
  generic names unless those names actually appear in the workbook.
* If several series use the same x-value range, read that range once and reuse
  it.
* If a series has no x-value range, use the common x-value range used by the
  other series in the same chart.
* Remove trailing blank cells from long Excel ranges.
* Preserve internal missing values.
* Do not replace missing values with zero unless the workbook clearly indicates
  that zero is intended.
* Do not manually approximate or type chart data from the PNG.
* Ensure that x-value and y-value vectors are correctly aligned before combining
  them.
* If data are read from separate ranges, explicitly create the R vectors and
  data frames from those ranges.
* Any internal variable name used in the R code must be explicitly created from
  imported data.

# ================================================================

# MULTI-PANEL CHARTS

# ================================================================

If the workbook contains worksheets named dataL and dataR:

* dataL contains the data for the left chart.
* dataR contains the data for the right chart.
* Read and process the two sheets separately.
* Determine the relevant chart ranges separately for each sheet.
* Build the two chart panels separately.
* Combine them into one final chart.
* Remove columns that are completely blank.
* Do not remove partially populated columns.
* Do not assume that dataL and dataR have identical structures.
* Preserve the panel order, relative sizes, spacing, and legend arrangement
  shown in the PNG.

# ================================================================

# CHART REQUIREMENTS

# ================================================================

* Use ggplot2.
* Use dplyr and tidyr where useful.
* Use patchwork when needed for multi-panel charts.
* Include all required library() calls.
* Reproduce the chart as closely as practical, including:

  * title
  * subtitle
  * chart type
  * panel layout
  * series order
  * legend
  * legend position
  * legend order
  * colors
  * fills
  * line types
  * line widths
  * markers
  * bars
  * bar widths
  * axes
  * axis limits
  * axis breaks
  * axis labels
  * date labels
  * annotations
  * caption
  * fonts
  * background
  * grid lines
  * spacing
  * margins
* Preserve the chart-series order shown in the workbook metadata.
* Match the visible x-axis range shown in the PNG even if the source Excel range
  contains additional observations.
* Handle Excel dates correctly.
* If x-values are four-digit years, treat and format them as years.
* Do not use row numbers as x-values unless the workbook metadata explicitly
  indicates that row position is the intended x-axis.

# ================================================================

# SECONDARY AXIS

# ================================================================

For a series shown on a secondary axis:

* Use ggplot2 sec_axis().
* Transform the secondary-axis values onto the primary-axis plotting scale.
* Define the forward transformation explicitly.
* Define the inverse transformation explicitly.
* Match the visible left-axis and right-axis limits and breaks shown in the PNG.
* Preserve the original series label in the legend.
* Do not use an arbitrary transformation when the required relationship can be
  inferred from the chart or workbook metadata.

# ================================================================

# WINDOWS PATHS

# ================================================================

* Preserve all characters in source workbook paths.
* Preserve real non-breaking spaces in Windows or SharePoint paths.
* Do not automatically replace non-breaking spaces.
* Convert UNC paths such as \server\folder into valid R string literals
  without changing the underlying path.
* Use Windows-compatible file paths.

# ================================================================

# OUTPUT REQUIREMENTS

# ================================================================

* Return ONLY executable R code.

* Do not use Markdown code fences.

* Do not include explanations before or after the code.

* Do not include placeholders.

* Make the code self-contained and immediately executable.

* Do not require manual copying or editing of data.

* Assign the final plot to an object named chart.

* Print the chart using:

  print(chart)

* Save the chart using ggsave().

* Create a subdirectory named figures in the same directory as the generated
  R script.

* Create the directory if needed using:

  dir.create(
  figures_dir,
  recursive = TRUE,
  showWarnings = FALSE
  )

* Use a filename based on the input chart stem.

* Use dpi = 600.

* Use width = 5 inches.

* Use height = 5 inches.

* Use units = "in".

* Use bg = "white".

If valid executable R code cannot be produced, return exactly:

# FAILED

"""


# ================================================================
# HELPERS
# ================================================================

def remove_markdown_fences(text: str) -> str:
    """
    Remove Markdown code fences if the model adds them despite the prompt.
    """
    result = text.strip()

    fence_pattern = re.compile(
        r"^```(?:r|R)?\s*(.*?)\s*```$",
        flags=re.DOTALL,
    )

    match = fence_pattern.match(result)

    if match:
        result = match.group(1).strip()

    return result


def response_is_bad(text: str) -> bool:
    """
    Detect empty, failed, explanatory, or refusal-style responses.
    """
    stripped = text.strip()
    lowered = stripped.lower()

    return (
        not stripped
        or stripped == "# FAILED"
        or "cannot assist" in lowered
        or "i'm sorry" in lowered
        or "i am sorry" in lowered
        or "unable to" in lowered
        or stripped.startswith("```")
    )


def validate_inputs(
    chart_stem: str,
    png_file: Path,
    excel_file: Path,
) -> None:
    """
    Check that the PNG, chart-link text file, and optional example exist.
    """
    required_files = [
        png_file,
        excel_file,
    ]

    missing_files = [
        path
        for path in required_files
        if not path.exists()
    ]

    if missing_files:
        available_files = sorted(
            path.name
            for path in chart_dir.glob(f"{chart_stem}*")
        )

        available_text = (
            "\n".join(f"- {name}" for name in available_files)
            if available_files
            else "(No similarly named files were found.)"
        )

        missing_text = "\n".join(
            str(path)
            for path in missing_files
        )

        raise FileNotFoundError(
            "The following input files were not found:\n"
            f"{missing_text}\n\n"
            f"Resolved chart directory:\n{chart_dir}\n\n"
            f"Files beginning with '{chart_stem}':\n"
            f"{available_text}"
        )

    if example_file is not None and not example_file.exists():
        raise FileNotFoundError(
            f"Example R file not found:\n{example_file}"
        )


def upload_file(path: Path) -> str:
    """
    Upload one file and return its uploaded file ID.

    No file contents are included inline in the Responses request.
    """
    with path.open("rb") as file_handle:
        uploaded_file = client.files.create(
            file=file_handle,
            purpose="assistants",
        )

    return uploaded_file.id


def build_request_content(
    chart_stem: str,
    png_file: Path,
    text_file: Path,
    uploaded_image_id: str,
    uploaded_text_id: str,
    uploaded_example_id: str | None = None,
) -> list[dict[str, Any]]:
    """
    Build a Responses API request using only uploaded file IDs.
    """
    instruction_text = (
        f"{prompt}\n\n"
        "The files attached to this request were uploaded immediately "
        "before the request was submitted.\n\n"
        "ATTACHED CHART IMAGE:\n"
        f"- Filename: {png_file.name}\n\n"
        "ATTACHED EXCEL WORKBOOK:\n"
        f"- Filename: {text_file.name}\n\n"
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
        {
            "type": "input_text",
            "text": instruction_text,
        },
        {
            "type": "input_image",
            "file_id": uploaded_image_id,
            "detail": "high",
        },
        {
            "type": "input_file",
            "file_id": uploaded_text_id,
        },
    ]

    if uploaded_example_id is not None:
        content.append(
            {
                "type": "input_file",
                "file_id": uploaded_example_id,
            }
        )

    return content


def save_error(error: Exception | str, error_file: Path) -> None:
    """
    Save an exception or model failure response to the error log.
    """
    if isinstance(error, Exception):
        error_text = f"{type(error).__name__}: {error}"
    else:
        error_text = error

    error_file.write_text(
        error_text,
        encoding="utf-8",
    )


# ================================================================
# MAIN
# ================================================================

def generate_chart(chart_stem: str) -> Path | None:
    """Generate an R script for one chart and return its output path."""
    png_file = chart_dir / f"{chart_stem}.png"
    excel_file = chart_dir / f"{chart_stem}.xlsx"
    output_file = output_dir / f"{chart_stem}.R"
    error_file = output_dir / f"{chart_stem}_error.txt"

    print(f"Output R script: {output_file}")
    print(f"Error log:       {error_file}")
    print(f"Example R file:  {example_file}" if example_file else "No example R file provided.")
    print(f"Excel file:       {excel_file}")

    validate_inputs(chart_stem, png_file, excel_file)

    print(f"Chart directory: {chart_dir}")
    print(f"Processing:      {png_file.name}")
    print(f"Metadata:        {excel_file.name}")

    try:
        # ------------------------------------------------------------
        # 1. Upload the PNG image.
        # ------------------------------------------------------------
        uploaded_image_id = upload_file(png_file)

        print(f"Uploaded image:   {uploaded_image_id}")

        # ------------------------------------------------------------
        # 2. Upload the chart-link Excel file.
        # ------------------------------------------------------------
        uploaded_excel_id = upload_file(excel_file)

        print(f"Uploaded excel file: {uploaded_excel_id}")

        # ------------------------------------------------------------
        # 3. Optionally upload the example R file.
        # ------------------------------------------------------------
        uploaded_example_id: str | None = None

        if example_file is not None:
            uploaded_example_id = upload_file(example_file)

            print(f"Uploaded example: {uploaded_example_id}")

        # ------------------------------------------------------------
        # 4. Build the request using only uploaded file IDs.
        # ------------------------------------------------------------
        content = build_request_content(
            chart_stem=chart_stem,
            png_file=png_file,
            text_file=excel_file,
            uploaded_image_id=uploaded_image_id,
            uploaded_text_id=uploaded_excel_id,
            uploaded_example_id=uploaded_example_id,
        )

        print("Submitting request using uploaded file IDs...")

        # ------------------------------------------------------------
        # 5. Submit the prompt after all files have been uploaded.
        # ------------------------------------------------------------
        response = client.responses.create(
            model=model,
            max_output_tokens=16000,
            input=[
                {
                    "role": "user",
                    "content": content,
                }
            ],
        )

        # ------------------------------------------------------------
        # 6. Extract and validate the generated R code.
        # ------------------------------------------------------------
        r_code = remove_markdown_fences(
            response.output_text
        )

        if response_is_bad(r_code):
            save_error(
                r_code or "(empty response)",
                error_file,
            )

            print("Generation failed.")
            print(f"Saved response to: {error_file}")
            return None

        # ------------------------------------------------------------
        # 7. Save the generated R script.
        # ------------------------------------------------------------
        output_file.write_text(
            r_code.rstrip() + "\n",
            encoding="utf-8",
        )

        print(f"Saved R code to: {output_file}")
        return output_file

    except Exception as error:
        save_error(error, error_file)

        print(f"Failed: {png_file.name}")
        print(f"Saved error log to: {error_file}")

        raise


if __name__ == "__main__":
    selected_chart_stem = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "fig-9-1-corr"
    )
    generate_chart(selected_chart_stem)