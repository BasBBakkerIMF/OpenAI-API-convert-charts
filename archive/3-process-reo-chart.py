
from __future__ import annotations

import re
import time
from pathlib import Path
from typing import Any

import win32com.client as win32


# ================================================================
# SETTINGS
# ================================================================

WORKBOOK_PATH = Path(
    r"L:/WHD REO File Locator (October 2026).xlsx"
)

OUTPUT_DIRECTORY = Path("K:")

# Name of the worksheet to process
WORKSHEET_NAME = "October 2026"

# Excel often needs to be visible for CopyPicture to work reliably.
SHOW_EXCEL = True


# ================================================================
# EXCEL / OFFICE NUMERIC CONSTANTS
#
# Numeric constants are used because win32com.constants may not
# contain Excel constants when using late binding.
# ================================================================

XL_SCREEN = 1
XL_BITMAP = 2
XL_PICTURE = -4147

MSO_CHART = 3
MSO_LINKED_PICTURE = 11
MSO_PICTURE = 13


# ================================================================
# GENERAL HELPERS
# ================================================================

def safe_filename(name: str) -> str:
    """Convert a worksheet name to a valid Windows filename."""

    result = re.sub(r'[<>:"/\\|?*]', "_", name)
    result = result.strip().rstrip(".")

    return result or "Sheet"


def cell_is_nonblank(value: Any, formula: Any) -> bool:
    """Return True when a cell has a value or formula."""

    if formula not in (None, ""):
        return True

    if value is None:
        return False

    if isinstance(value, str):
        return value.strip() != ""

    return True


def normalize_com_array(value: Any) -> tuple[tuple[Any, ...], ...]:
    """
    Normalize a COM range result to a two-dimensional tuple.

    Excel returns a scalar for one cell and tuples for larger ranges.
    """

    if isinstance(value, tuple):
        if value and isinstance(value[0], tuple):
            return value

        return (value,)

    return ((value,),)


# ================================================================
# TEXT RANGE EXPORT
# ================================================================

def find_nonblank_cell_bounds(worksheet):
    """
    Find the smallest rectangle containing cells with values or formulas.

    This does not rely on Excel's Find method and therefore does not
    require xlFormulas or other COM constants.
    """

    used = worksheet.UsedRange

    start_row = int(used.Row)
    start_column = int(used.Column)
    row_count = int(used.Rows.Count)
    column_count = int(used.Columns.Count)

    values = normalize_com_array(used.Value2)
    formulas = normalize_com_array(used.Formula)

    first_row = None
    last_row = None
    first_column = None
    last_column = None

    for row_offset in range(row_count):
        for column_offset in range(column_count):

            try:
                value = values[row_offset][column_offset]
            except IndexError:
                value = None

            try:
                formula = formulas[row_offset][column_offset]
            except IndexError:
                formula = None

            if not cell_is_nonblank(value, formula):
                continue

            actual_row = start_row + row_offset
            actual_column = start_column + column_offset

            if first_row is None or actual_row < first_row:
                first_row = actual_row

            if last_row is None or actual_row > last_row:
                last_row = actual_row

            if first_column is None or actual_column < first_column:
                first_column = actual_column

            if last_column is None or actual_column > last_column:
                last_column = actual_column

    if first_row is None:
        return None

    return first_row, first_column, last_row, last_column


def displayed_cell_text(cell) -> str:
    """
    Get the displayed text of an Excel cell.

    This preserves displayed dates, percentages, and number formats.
    """

    try:
        result = cell.Text
    except Exception:
        result = cell.Value2

    if result is None:
        return ""

    return (
        str(result)
        .replace("\r\n", " ")
        .replace("\r", " ")
        .replace("\n", " ")
    )


def write_text_file(worksheet, output_path: Path) -> bool:
    """
    Find all nonblank cells and write their bounding range as a
    tab-delimited UTF-8 text file.
    """

    bounds = find_nonblank_cell_bounds(worksheet)

    if bounds is None:
        return False

    first_row, first_column, last_row, last_column = bounds

    lines: list[str] = []

    for row in range(first_row, last_row + 1):

        fields: list[str] = []

        for column in range(first_column, last_column + 1):
            cell = worksheet.Cells(row, column)
            fields.append(displayed_cell_text(cell))

        # Remove trailing blank fields from each row.
        while fields and fields[-1] == "":
            fields.pop()

        lines.append("\t".join(fields))

    # Remove empty lines at the bottom.
    while lines and not lines[-1].strip():
        lines.pop()

    output_path.write_text(
        "\n".join(lines),
        encoding="utf-8-sig"
    )

    return True


# ================================================================
# PICTURE IDENTIFICATION
# ================================================================

def is_picture_shape(shape) -> bool:
    """Determine whether an Excel shape is a picture."""

    try:
        shape_type = int(shape.Type)
    except Exception:
        return False

    return shape_type in {
        MSO_PICTURE,
        MSO_LINKED_PICTURE
    }


def is_chart_shape(shape) -> bool:
    """Determine whether a shape contains an Excel chart."""

    try:
        return bool(shape.HasChart)
    except Exception:
        pass

    try:
        return int(shape.Type) == MSO_CHART
    except Exception:
        return False


def find_largest_exportable_shape(worksheet):
    """
    Find the largest picture or chart on a worksheet.

    The largest object is normally the pasted chart image rather than
    a small logo, icon, or decorative object.
    """

    candidates = []

    for index in range(1, worksheet.Shapes.Count + 1):

        shape = worksheet.Shapes.Item(index)

        if not is_picture_shape(shape) and not is_chart_shape(shape):
            continue

        try:
            area = float(shape.Width) * float(shape.Height)
        except Exception:
            area = 0.0

        candidates.append((area, shape))

    if not candidates:
        return None

    candidates.sort(
        key=lambda item: item[0],
        reverse=True
    )

    return candidates[0][1]


# ================================================================
# PICTURE EXPORT
# ================================================================

def delete_existing_file(path: Path) -> None:
    """Delete a previous output file if it exists."""

    if path.exists():
        path.unlink()


def export_real_chart(shape, output_path: Path) -> bool:
    """Export a genuine Excel chart directly."""

    try:
        if not bool(shape.HasChart):
            return False

        result = shape.Chart.Export(
            Filename=str(output_path),
            FilterName="PNG"
        )

        return bool(result) and output_path.exists()

    except Exception:
        return False


def export_picture_through_temporary_chart(
    excel,
    worksheet,
    shape,
    output_path: Path
) -> bool:
    """
    Export a pasted picture by copying it into a temporary Excel chart
    and exporting that chart as PNG.
    """

    temporary_chart_object = None

    try:
        # Clipboard operations are much more reliable when the relevant
        # workbook and worksheet are active and Excel is visible.
        excel.Visible = True
        worksheet.Parent.Activate()
        worksheet.Activate()

        shape.Select()
        time.sleep(0.3)

        copied = False

        # First try copying as a bitmap.
        try:
            shape.CopyPicture(
                Appearance=XL_SCREEN,
                Format=XL_BITMAP
            )
            copied = True
        except Exception:
            pass

        # Try copying as a vector picture.
        if not copied:
            try:
                shape.CopyPicture(
                    Appearance=XL_SCREEN,
                    Format=XL_PICTURE
                )
                copied = True
            except Exception:
                pass

        # Last fallback: ordinary copy.
        if not copied:
            shape.Copy()
            copied = True

        time.sleep(0.5)

        width = max(float(shape.Width), 20.0)
        height = max(float(shape.Height), 20.0)

        temporary_chart_object = worksheet.ChartObjects().Add(
            Left=float(shape.Left),
            Top=float(shape.Top),
            Width=width,
            Height=height
        )

        temporary_chart_object.Activate()
        time.sleep(0.2)

        temporary_chart = temporary_chart_object.Chart

        # Paste the clipboard image into the temporary chart.
        temporary_chart.Paste()
        time.sleep(0.5)

        result = temporary_chart.Export(
            Filename=str(output_path),
            FilterName="PNG"
        )

        time.sleep(0.2)

        return bool(result) and output_path.exists()

    finally:
        if temporary_chart_object is not None:
            try:
                temporary_chart_object.Delete()
            except Exception:
                pass


def export_shape_to_png(
    excel,
    worksheet,
    shape,
    output_path: Path
) -> bool:
    """Export either a chart or a pasted picture."""

    output_path = output_path.resolve()
    delete_existing_file(output_path)

    if is_chart_shape(shape):
        if export_real_chart(shape, output_path):
            return True

    return export_picture_through_temporary_chart(
        excel=excel,
        worksheet=worksheet,
        shape=shape,
        output_path=output_path
    )


# ================================================================
# MAIN WORKBOOK PROCESSING
# ================================================================

def export_workbook(
    workbook_path: Path,
    output_directory: Path,
    worksheet_name: str
) -> None:

    workbook_path = workbook_path.resolve()
    output_directory.mkdir(
        parents=True,
        exist_ok=True
    )

    if not workbook_path.exists():
        raise FileNotFoundError(
            f"Workbook not found:\n{workbook_path}"
        )

    excel = None
    workbook = None

    try:
        excel = win32.DispatchEx(
            "Excel.Application"
        )

        excel.Visible = SHOW_EXCEL
        excel.DisplayAlerts = False
        excel.ScreenUpdating = True
        excel.EnableEvents = False

        workbook = excel.Workbooks.Open(
            str(workbook_path),
            UpdateLinks=0,
            ReadOnly=True
        )

        print(f"Workbook: {workbook.Name}")
        print(f"Worksheet: {worksheet_name}")
        print(f"Output: {output_directory}")
        print()

        # --------------------------------------------------------
        # Get the requested worksheet
        # --------------------------------------------------------

        try:
            worksheet = workbook.Worksheets(
                worksheet_name
            )
        except Exception as error:
            available_sheets = [
                str(
                    workbook.Worksheets.Item(i).Name
                )
                for i in range(
                    1,
                    workbook.Worksheets.Count + 1
                )
            ]

            raise ValueError(
                f"Worksheet not found: {worksheet_name}\n\n"
                f"Available worksheets:\n"
                + "\n".join(available_sheets)
            ) from error

        sheet_name = str(worksheet.Name)
        stem = safe_filename(sheet_name)

        text_path = (
            output_directory /
            f"{stem}.txt"
        )

        image_path = (
            output_directory /
            f"{stem}.png"
        )

        print(f"Processing: {sheet_name}")

        # --------------------------------------------------------
        # Export worksheet text
        # --------------------------------------------------------

        try:
            if write_text_file(
                worksheet,
                text_path
            ):
                print(
                    f"  Text:  {text_path.name}"
                )
            else:
                print(
                    "  Text:  no nonblank cells found"
                )

        except Exception as error:
            print(
                f"  Text export failed: {error}"
            )

        # --------------------------------------------------------
        # Export picture or chart
        # --------------------------------------------------------

        try:
            shape = (
                find_largest_exportable_shape(
                    worksheet
                )
            )

            if shape is None:
                print(
                    "  Image: no picture or chart found"
                )

            else:
                print(
                    f"  Shape: {shape.Name} "
                    f"(type {shape.Type}, "
                    f"{round(shape.Width)} x "
                    f"{round(shape.Height)})"
                )

                if export_shape_to_png(
                    excel=excel,
                    worksheet=worksheet,
                    shape=shape,
                    output_path=image_path
                ):
                    print(
                        f"  Image: {image_path.name}"
                    )
                else:
                    print(
                        "  Image export failed"
                    )

        except Exception as error:
            print(
                f"  Image export failed: {error}"
            )

        print()

    finally:
        if workbook is not None:
            try:
                workbook.Close(
                    SaveChanges=False
                )
            except Exception:
                pass

        if excel is not None:
            try:
                excel.CutCopyMode = False
                excel.EnableEvents = True
                excel.Quit()
            except Exception:
                pass


# ================================================================
# RUN
# ================================================================

if __name__ == "__main__":

    export_workbook(
        workbook_path=WORKBOOK_PATH,
        output_directory=OUTPUT_DIRECTORY,
        worksheet_name=WORKSHEET_NAME
    )
