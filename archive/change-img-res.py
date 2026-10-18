from PIL import Image


# The actual SharePoint/OneDrive folder may contain a non-breaking
# space after "(WHD)". The function below checks both versions.
chart_dir_normal_space = Path(
    r"C:\Users\bbakker\International Monetary Fund (PRD)"
    r"\(WHD) Regional Studies - General"
    r"\REO\October 2026 REO"
    r"\Conjunctural"
    r"\REO materials from Bas"
    r"\reo-chart-exports"
)

chart_dir_nonbreaking_space = Path(
    "C:\\Users\\bbakker\\International Monetary Fund (PRD)"
    "\\(WHD)\u00a0Regional Studies - General"
    "\\REO\\October 2026 REO"
    "\\Conjunctural"
    "\\REO materials from Bas"
    "\\reo-chart-exports"
)

# Change this to the chart you want to process.
chart_stem = "fig-9-1"

# Optional example R file showing the preferred chart style.
# Leave as None when no example is needed.
example_file: Path | None = None

# Example:
# example_file = Path(r"C:\path\to\example_chart.R")


# ================================================================
# FIND THE CORRECT CHART DIRECTORY
# ================================================================

def resolve_chart_directory() -> Path:
    """
    Find the chart directory, checking both an ordinary space and a
    non-breaking space after '(WHD)'.
    """
    possible_directories = [
        chart_dir_nonbreaking_space,
        chart_dir_normal_space,
    ]

    for directory in possible_directories:
        if directory.exists():
            return directory

    attempted_paths = "\n".join(
        f"- {directory}"
        for directory in possible_directories
    )

    raise FileNotFoundError(
        "The chart directory was not found.\n\n"
        "Checked these locations:\n"
        f"{attempted_paths}"
    )


chart_dir = resolve_chart_directory()

png_file = chart_dir / f"{chart_stem}.png"

image = Image.open(png_file).convert("RGB")

# Resize only if it is wider than 900 pixels
if image.width > 900:
    new_height = round(image.height * 900 / image.width)
    image = image.resize(
        (900, new_height),
        Image.Resampling.LANCZOS
    )

# Reduce to 128 colors
image = image.quantize(
    colors=128,
    method=Image.Quantize.MEDIANCUT
)

image.save(
    "fig1_compressed.png",
    optimize=True
)