
import ast
import sys
from pathlib import Path
from importlib import metadata

# Folders to exclude
EXCLUDE = {
    ".venv",
    "venv",
    "env",
    "__pycache__",
    ".git",
    "archive",
}

# Project root (location of this script)
ROOT = Path(__file__).resolve().parent


def find_imports():
    """Find imported modules in all project Python files."""
    imports = set()

    for file in ROOT.rglob("*.py"):
        if any(part in EXCLUDE for part in file.relative_to(ROOT).parts):
            continue

        try:
            source = file.read_text(encoding="utf-8-sig")
            tree = ast.parse(source, filename=str(file))

            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        imports.add(alias.name.split(".")[0])

                elif isinstance(node, ast.ImportFrom):
                    if node.level == 0 and node.module:
                        imports.add(node.module.split(".")[0])

        except (SyntaxError, UnicodeError) as e:
            print(f"Skipping {file.name}: {e}")

    return imports


def generate_requirements():
    imports = find_imports()

    # Standard Python library modules
    stdlib = sys.stdlib_module_names

    # Map imported module names to installed packages
    package_map = metadata.packages_distributions()

    requirements = set()
    unresolved = set()

    for module in sorted(imports):
        if module in stdlib:
            continue

        distributions = package_map.get(module)

        if not distributions:
            unresolved.add(module)
            continue

        for distribution in distributions:
            try:
                version = metadata.version(distribution)
                requirements.add(f"{distribution}=={version}")
            except metadata.PackageNotFoundError:
                unresolved.add(module)

    output = ROOT / "requirements.txt"
    output.write_text(
        "\n".join(sorted(requirements, key=str.lower)) + "\n",
        encoding="utf-8",
    )

    print(f"Created {output.name}")
    print(f"Found {len(requirements)} dependencies")

    if unresolved:
        print("\nUnresolved imports (possibly local modules):")
        for module in sorted(unresolved):
            print(f"  {module}")


if __name__ == "__main__":
    generate_requirements()
