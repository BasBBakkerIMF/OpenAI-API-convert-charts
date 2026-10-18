import pandas as pd
from read_data_from_excel_chart_and_export import read_chart_data

df = pd.read_excel(
    r"L:\WHD REO File Locator (October 2026).xlsx",
    sheet_name="October 2026",
    header=1,
    usecols="B,C,E:H",
)

df = df.dropna(subset=["October 2026 REO Figure", "Sheet"])
df = df.reset_index(drop=True)

df["Second chart"] = df["Second chart"].astype(object).where(
    df["Second chart"].notna(),
    None
)

print(df)

for _, row in df.iterrows():
    figure_name = str(row["Picture name in this file"])

    second_chart = (
        None
        if pd.isna(row["Second chart"])
        else row["Second chart"]
    )

    print(figure_name)
    
    try:
        read_chart_data(
            row["File Location"],
            row["Sheet"],
            row["Chart name in sheet"],
            chart_name_right=second_chart,
            out_dir=r"K:\excel_and_png",
            output_name=figure_name,
            verbose=True
        )

    except Exception as error:
        print("\n" + "=" * 70)
        print(f"ERROR EXPORTING: {figure_name}")
        print(f"File: {row['File Location']}")
        print(f"Sheet: {row['Sheet']}")
        print(f"Chart: {row['Chart name in sheet']}")
        print(f"Second chart: {row['Second chart']}")
        print(f"Error: {error}")
        print("=" * 70 + "\n")