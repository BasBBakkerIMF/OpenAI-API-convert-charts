import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile(r"L:\Copy of WHD REO File Locator (October 2026).xlsx")as z:
    drawings = [n for n in z.namelist() if n.startswith("xl/drawings/drawing")
                and n.endswith(".xml")]
    for d in drawings:
        print(f"--- {d}")
        root = ET.fromstring(z.read(d))
        for el in root.iter():
            if el.tag.endswith("}cNvPr"):
                print(f"  name={el.get('name')!r}  descr={el.get('descr')!r}")

from openpyxl import load_workbook

wb = load_workbook(r"L:\Copy of WHD REO File Locator (October 2026).xlsx")
for ws in wb.worksheets:
    if ws.defined_names:
        print(f"--- sheet: {ws.title}")
        for name, dn in ws.defined_names.items():
            print("  ", name, "->", list(dn.destinations))