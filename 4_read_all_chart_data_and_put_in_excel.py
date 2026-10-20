import pandas as pd
from pathlib import Path

from helper_for_4_read_data_from_excel_chart_and_export import read_chart_data


def process_charts(
    chart_list_file: Path,
    output_directory: Path,
    figure_column: str,
) -> None:
    """
    Read the chart list and export the underlying Excel data
    for each chart.
    """

    df = pd.read_excel(
        chart_list_file
    )

    output_directory.mkdir(
        parents=True,
        exist_ok=True
    )

    for _, row in df.iterrows():

        figure_number = row[figure_column]
        picture_name = row["Picture name in this file"]

        # Use the supplied picture name when available.
        # Otherwise construct one from the REO figure number.
        if pd.isna(picture_name):
            figure_name = (
                f"fig-{str(figure_number).replace('.', '-')}"
            )
        else:
            figure_name = str(picture_name)

        second_chart = (
            None
            if pd.isna(row["Second chart"])
            else str(row["Second chart"])
        )

        print()
        print("=" * 70)
        print(f"Processing: {figure_name}")
        print(f"Source file: {row['File Location']}")
        print(f"Sheet: {row['Sheet']}")
        print(f"Chart: {row['Chart name in sheet']}")

        if second_chart:
            print(f"Second chart: {second_chart}")

        try:
            read_chart_data(
                filename=row["File Location"],
                sheet_name=row["Sheet"],
                chart_name=row["Chart name in sheet"],
                chart_name_right=second_chart,
                out_dir=str(output_directory),
                output_name=figure_name,
                verbose=True,
            )

        except Exception as error:
            print()
            print("ERROR")
            print(f"Figure: {figure_name}")
            print(f"File: {row['File Location']}")
            print(f"Sheet: {row['Sheet']}")
            print(f"Chart: {row['Chart name in sheet']}")
            print(f"Second chart: {second_chart}")
            print(f"Error: {error}")

    print()
    print("=" * 70)
    print("Finished.")


if __name__ == "__main__":

    process_charts(
        chart_list_file=Path(
            r"K:\chart-list.xlsx"
        ),
        output_directory=Path(
            r"K:\excel_and_png"
        ),
        figure_column="October 2026 REO Figure",
    )