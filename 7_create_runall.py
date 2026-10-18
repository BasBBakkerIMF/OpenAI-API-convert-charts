import pandas as pd
from pathlib import Path


def create_runall(
    chart_list_file: Path,
    output_directory: Path,
) -> None:

    df = pd.read_excel(chart_list_file)

    chart_stems = (
        df["Picture name in this file"]
        .dropna()
        .astype(str)
        .tolist()
    )

    output_directory.mkdir(
        parents=True,
        exist_ok=True,
    )

    runall_file = output_directory / "runall.R"

    stems_r = ",\n    ".join(
        f'"{stem}"'
        for stem in chart_stems
    )

    r_code = f'''chart_stems <- c(
    {stems_r}
)

failed_files <- character()
error_messages <- character()

for (stem in chart_stems) {{

    file <- paste0("K:/r_code/", stem, ".R")

    tryCatch(
        source(file),
        error = function(e) {{

            message(
                "ERROR in ",
                file,
                ": ",
                e$message
            )

            failed_files <<- c(
                failed_files,
                file
            )

            error_messages <<- c(
                error_messages,
                e$message
            )
        }}
    )
}}

cat("\\n")
cat("============================\\n")
cat("FILES WITH ERRORS\\n")
cat("============================\\n")

if (length(failed_files) == 0) {{

    cat("None\\n")

}} else {{

    for (i in seq_along(failed_files)) {{

        cat(
            failed_files[i],
            " -- ",
            error_messages[i],
            "\\n",
            sep = ""
        )
    }}
}}
'''

    runall_file.write_text(
        r_code,
        encoding="utf-8",
    )

    print(f"Saved: {runall_file}")
    print(f"Number of charts: {len(chart_stems)}")


if __name__ == "__main__":

    create_runall(
        chart_list_file=Path(r"K:\chart-list.xlsx"),
        output_directory=Path(r"K:\r_code"),
    )