import subprocess


def map_drive(drive: str, target: str) -> None:
    subprocess.run(
        ["subst", drive, "/D"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    subprocess.run(
        ["subst", drive, target],
        check=True,
    )

    print(f"{drive} mapped to {target}")


if __name__ == "__main__":

    drives = {
        "L:": r"Q:\DATA\RS\REO\2026 Fall\Charts",
        "K:": r"C:\Users\bbakker\International Monetary Fund (PRD)\WHD-AI-Core - General\OpenAI-API-convert-charts",
    }

    for drive, target in drives.items():
        map_drive(drive, target)