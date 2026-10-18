from pathlib import Path
from PIL import Image

chart_dir = Path(r"L:\reo-chart-exports")
backup_dir = chart_dir / "backups"

backup_dir.mkdir(parents=True, exist_ok=True)

for chart_path in sorted(chart_dir.glob("*.png")):
    backup_path = backup_dir / chart_path.name

    print(f"Processing: {chart_path.name}")

    # Do not overwrite an existing backup.
    if not backup_path.exists():
        backup_path.write_bytes(chart_path.read_bytes())
        print(f"  Backup created: {backup_path}")
    else:
        print(f"  Backup already exists: {backup_path}")

    try:
        with Image.open(chart_path) as source_image:
            image = source_image.convert("RGB")

            # Resize only if wider than 900 pixels.
            if image.width > 900:
                new_height = round(image.height * 900 / image.width)

                image = image.resize(
                    (900, new_height),
                    Image.Resampling.LANCZOS,
                )

            # Reduce to 128 colors.
            image = image.quantize(
                colors=128,
                method=Image.Quantize.MEDIANCUT,
            )

            # Overwrite the original while preserving its filename.
            image.save(
                chart_path,
                format="PNG",
                optimize=True,
            )

        print(f"  Saved: {chart_path}")

    except Exception as error:
        print(f"  Failed: {error}")

print("Finished.")