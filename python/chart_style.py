"""
Shared layout for the REO charts drawn with matplotlib.

Every chart has the same frame: a bold title and an italic subtitle at the
top left, the sources and notes at the bottom left, and the plot in between.
The figure is 5 x 5 inches and saved at 600 dpi, like the R versions.
"""
from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import pandas as pd

PYTHON_DIR = Path(__file__).resolve().parent
DATA_DIR = PYTHON_DIR.parent / "excel_and_png"
FIGURES_DIR = PYTHON_DIR / "figures"

WIDTH = 5.0   # inches
HEIGHT = 5.0  # inches
DPI = 600
PT = 1 / 72   # one point in inches

TEXT_COLOUR = "#111111"

plt.rcParams.update(
    {
        "font.family": "Arial",
        "font.size": 9,
        "text.color": TEXT_COLOUR,
        "axes.edgecolor": TEXT_COLOUR,
        "axes.linewidth": 0.6,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "xtick.color": TEXT_COLOUR,
        "ytick.color": TEXT_COLOUR,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "xtick.major.width": 0.5,
        "ytick.major.width": 0.5,
        "legend.frameon": False,
        "legend.fontsize": 9,
        "axes.unicode_minus": False,  # "-3" as in Excel, not "−3"
    }
)


def read_chart_data(stem: str, sheet: str = "data") -> pd.DataFrame:
    """Read the data extracted from the Excel chart (step 4 of the pipeline)."""
    return pd.read_excel(DATA_DIR / f"{stem}.xlsx", sheet_name=sheet)


def new_chart(
    title: str,
    subtitle: str | None,
    caption: str,
    *,
    title_size: float = 13,
    subtitle_size: float = 11,
    caption_size: float = 8.5,
    left: float = 0.4,
    right: float = 0.15,
    top_gap: float = 0.12,
    bottom_gap: float = 0.35,
    ncols: int = 1,
    wspace: float = 0.6,
):
    """
    Create a figure with title, subtitle and caption, and return it with the
    plot axes.

    left, right, top_gap and bottom_gap (inches) set the space around the
    plot area: room for the y-axis labels, the x-axis labels, and so on.

    For a figure with several panels side by side, pass ncols; wspace
    (inches) is the gap between panels. A list of axes is then returned.
    """
    fig = plt.figure(figsize=(WIDTH, HEIGHT))

    outer = 0.06
    text_x = 0.1 / WIDTH

    y = HEIGHT - outer
    fig.text(
        text_x, y / HEIGHT, title,
        fontsize=title_size, fontweight="bold",
        ha="left", va="top", linespacing=1.0,
    )
    y -= (title.count("\n") + 1) * title_size * 1.17 * PT

    if subtitle:
        fig.text(
            text_x, y / HEIGHT, subtitle,
            fontsize=subtitle_size, fontstyle="italic",
            ha="left", va="top", linespacing=1.0,
        )
        y -= (subtitle.count("\n") + 1) * subtitle_size * 1.2 * PT

    if caption:
        fig.text(
            text_x, outer / HEIGHT, caption,
            fontsize=caption_size,
            ha="left", va="bottom", linespacing=1.1,
        )
        caption_height = (caption.count("\n") + 1) * caption_size * 1.2 * PT
    else:
        caption_height = 0

    axes_top = y - top_gap
    axes_bottom = outer + caption_height + bottom_gap
    panel_width = (WIDTH - left - right - (ncols - 1) * wspace) / ncols

    axes = [
        fig.add_axes(
            [
                (left + i * (panel_width + wspace)) / WIDTH,
                axes_bottom / HEIGHT,
                panel_width / WIDTH,
                (axes_top - axes_bottom) / HEIGHT,
            ]
        )
        for i in range(ncols)
    ]
    return fig, (axes[0] if ncols == 1 else axes)


def set_y_scale(ax: plt.Axes, low: float, high: float, step: float) -> None:
    """Set the y-axis limits, with a tick every `step` starting at `low`."""
    import numpy as np

    ax.set_ylim(low, high)
    ax.set_yticks(np.arange(low, high + step / 2, step))


def add_right_axis(ax: plt.Axes, ylim, step) -> plt.Axes:
    """Add a right-hand scale to ax, with its own limits and tick spacing."""
    ax_right = ax.twinx()
    set_y_scale(ax_right, ylim[0], ylim[1], step)
    ax_right.spines["right"].set_visible(True)
    ax_right.spines["top"].set_visible(False)
    return ax_right


def smooth_line(x, y, points_per_segment: int = 20):
    """
    Return x and y of a smooth curve through the points, like Excel's
    "smoothed line" option (a Catmull-Rom spline).
    """
    import numpy as np

    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)
    px = np.concatenate([[2 * x[0] - x[1]], x, [2 * x[-1] - x[-2]]])
    py = np.concatenate([[2 * y[0] - y[1]], y, [2 * y[-1] - y[-2]]])

    t = np.linspace(0, 1, points_per_segment, endpoint=False)[:, None]
    t2, t3 = t * t, t * t * t
    out = []
    for p in (px, py):
        p0, p1, p2, p3 = p[:-3], p[1:-2], p[2:-1], p[3:]
        seg = 0.5 * (
            2 * p1
            + (-p0 + p2) * t
            + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
            + (-p0 + 3 * p1 - 3 * p2 + p3) * t3
        )
        out.append(np.concatenate([seg.T.ravel(), p[-2:-1]]))
    return out[0], out[1]


def save_chart(fig: plt.Figure, stem: str) -> Path:
    """Save the chart as python/figures/<stem>.png."""
    import time

    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    output_file = FIGURES_DIR / f"{stem}.png"

    # On Windows, an image that is open in a viewer or being scanned can be
    # briefly locked; try again a few times before giving up.
    for attempt in range(5):
        try:
            fig.savefig(output_file, dpi=DPI, facecolor="white")
            break
        except OSError:
            if attempt == 4:
                raise
            time.sleep(1)
    plt.close(fig)
    print(f"Saved {output_file}")
    return output_file
