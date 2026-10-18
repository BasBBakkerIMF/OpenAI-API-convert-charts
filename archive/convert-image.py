from PIL import Image

chart= r"L:\reo-chart-exports\fig-1-1.png"
chartsaved= r"L:\reo-chart-exports\fig-1-1_compressed2.png"

image = Image.open(chart).convert("RGB")

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
    chartsaved,
    optimize=True
)