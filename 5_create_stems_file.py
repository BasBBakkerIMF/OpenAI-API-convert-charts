import pandas as pd
from pathlib import Path


def main():
    chart_list_file = Path(r"K:\chart-list.xlsx")
    stems_file = Path(r"K:\stems.txt")

    df = pd.read_excel(chart_list_file)

    chart_stems = (
        df["Picture name in this file"]
        .dropna()
        .astype(str)
        .str.strip()
        .loc[lambda x: x != ""]
        .tolist()
    )

    stems_file.write_text(
        "\n".join(chart_stems) + "\n",
        encoding="utf-8",
    )

    print(f"Created {stems_file}")
    print(f"Number of stems: {len(chart_stems)}")

    for stem in chart_stems:
        print(stem)


if __name__ == "__main__":
    main()