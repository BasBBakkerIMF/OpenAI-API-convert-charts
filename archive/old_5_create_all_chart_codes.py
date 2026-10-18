from old_helper_for_4_generate_r_code_one_chart import generate_chart
import pandas as pd


def main():

    df = pd.read_excel(r"K:\chart-list.xlsx")

    chart_stems = (
        df["Picture name in this file"]
        .dropna()
        .astype(str)
        .tolist()
    )

    print(chart_stems)
    # chart_stems =  [
    
    # "fig-5-1",
    # ]


    # chart_stems = ["fig-7-1"]

    failed: list[tuple[str, str]] = []

    for chart_stem in chart_stems:
        try:
            result = generate_chart(chart_stem)
            if result is None:
                failed.append((chart_stem, "model returned # FAILED"))
        except Exception as error:
            failed.append((chart_stem, f"{type(error).__name__}: {error}"))
            print(f"Error on {chart_stem}, continuing.")

    print(f"\nProcessed {len(chart_stems)} charts, {len(failed)} failed.")
    for chart_stem, reason in failed:
        print(f"  {chart_stem}: {reason}")


if __name__ == "__main__":
    main()