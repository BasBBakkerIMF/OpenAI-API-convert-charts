import pandas as pd
from pathlib import Path


def create_chart_list(
    locator_file: Path,
    locator_sheet: str,
    output_file: Path,
    figure_column: str,
) -> pd.DataFrame:
    """
    Read the REO file locator, clean the chart information,
    and save the resulting chart list to an Excel file.
    """

    df = pd.read_excel(
        locator_file,
        sheet_name=locator_sheet,
        header=1,
        usecols="B,C,E:H",
    )

    # Keep only rows that identify a figure and source sheet.
    df = df.dropna(
        subset=[
            figure_column,
            "Sheet",
        ]
    )

    df = df.reset_index(drop=True)

    # Convert missing second-chart entries to None.
    df["Second chart"] = (
        df["Second chart"]
        .astype(object)
        .where(
            df["Second chart"].notna(),
            None,
        )
    )

    # Make sure the output directory exists.
    output_file.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    # Save cleaned dataframe.
    df.to_excel(
        output_file,
        index=False,
    )

    print(df)
    print()
    print(f"Saved chart list to:")
    print(output_file)

    return df


if __name__ == "__main__":

    create_chart_list(
        locator_file=Path(
            r"L:\WHD REO File Locator (October 2026).xlsx"
        ),
        locator_sheet="October 2026",
        output_file=Path(
            r"K:\chart-list.xlsx"
        ),
        figure_column="October 2026 REO Figure",
    )