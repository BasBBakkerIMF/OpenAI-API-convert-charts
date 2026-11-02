"""
Run every chart script (fig-*.py) in this folder and list any that failed,
like r_code/runall.R does for the R versions.
"""
import subprocess
import sys
from pathlib import Path

PYTHON_DIR = Path(__file__).resolve().parent


def chart_order(path: Path):
    """Sort fig-2-3 before fig-10-1 (by figure number, not alphabetically)."""
    return [int(part) for part in path.stem.split("-")[1:]]


failed = []
scripts = sorted(PYTHON_DIR.glob("fig-*.py"), key=chart_order)

for script in scripts:
    result = subprocess.run(
        [sys.executable, script.name],
        cwd=PYTHON_DIR,
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        print(result.stdout.strip())
    else:
        error = result.stderr.strip().splitlines()[-1]
        print(f"ERROR in {script.name}: {error}")
        failed.append((script.name, error))

print()
print("=" * 28)
print("FILES WITH ERRORS")
print("=" * 28)
if failed:
    for name, error in failed:
        print(f"{name} -- {error}")
else:
    print("None")
print(f"\n{len(scripts) - len(failed)} of {len(scripts)} charts created.")
