"""
Append the complete Python script to the end of each page of the tutorial.

Each chart page (charts/<stem>.qmd) gets python/<stem>.py, chart-style.qmd
gets chart_style.py and run-all.qmd gets run_all.py, under the heading
"The complete script". Everything from that heading to the end of the page is
replaced, so run this again whenever a script changes:

    ..\\.venv\\Scripts\\python.exe add_full_scripts.py
"""
from pathlib import Path

TUTORIAL_DIR = Path(__file__).resolve().parent
PYTHON_DIR = TUTORIAL_DIR.parent / "python"
HEADING = "## The complete script"

pages = {TUTORIAL_DIR / "chart-style.qmd": PYTHON_DIR / "chart_style.py",
         TUTORIAL_DIR / "run-all.qmd": PYTHON_DIR / "run_all.py"}
for page in sorted((TUTORIAL_DIR / "charts").glob("fig-*.qmd")):
    pages[page] = PYTHON_DIR / f"{page.stem}.py"

for page, script in pages.items():
    text = page.read_text(encoding="utf-8")
    text = text.split(f"\n{HEADING}\n")[0].rstrip("\n")
    code = script.read_text(encoding="utf-8").rstrip("\n")
    section = (
        f"\n\n{HEADING}\n\n"
        f"The full `python/{script.name}`, as it runs:\n\n"
        f'```` {{.python filename="python/{script.name}"}}\n{code}\n````\n'
    )
    page.write_text(text + section, encoding="utf-8")
    print(f"Updated {page.relative_to(TUTORIAL_DIR)}")
