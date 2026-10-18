import zipfile
import os
import xml.etree.ElementTree as ET
from io import BytesIO
from PIL import Image


#=================

NS = {
    "xdr": "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing",
    "a":   "http://schemas.openxmlformats.org/drawingml/2006/main",
    "r":   "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "rel": "http://schemas.openxmlformats.org/package/2006/relationships",
    "s":   "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
}


def _rels(z, part):
    """Read the .rels file for a part, return {rId: target path}."""
    folder, name = part.rsplit("/", 1)
    rels_path = f"{folder}/_rels/{name}.rels"
    out = {}
    for rel in ET.fromstring(z.read(rels_path)).findall("rel:Relationship", NS):
        target = rel.get("Target")
        if target.startswith("../"):
            target = "xl/" + target[3:]
        elif not target.startswith("/"):
            target = f"{folder}/{target}"
        out[rel.get("Id")] = target.lstrip("/")
    return out


def save_flattened(img_bytes, out_path):
    """Save as PNG, compositing any transparency onto a white background."""
    img = Image.open(BytesIO(img_bytes))
    if img.mode in ("RGBA", "LA", "P"):
        img = img.convert("RGBA")
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[-1])   # alpha channel as mask
        img = bg
    else:
        img = img.convert("RGB")
    img.save(out_path, "PNG")


def export_pictures(filename, sheet_name, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    exported = []

    with zipfile.ZipFile(filename) as z:
        # sheet name -> sheet part
        wbxml = ET.fromstring(z.read("xl/workbook.xml"))
        wb_rels = _rels(z, "xl/workbook.xml")
        sheet_part = None
        for sh in wbxml.find("s:sheets", NS):
            if sh.get("name") == sheet_name:
                sheet_part = wb_rels[sh.get(f"{{{NS['r']}}}id")]
        if sheet_part is None:
            raise ValueError(f"No sheet named '{sheet_name}'")

        # sheet -> drawing part (the real drawing XML, not vmlDrawing parts)
        sheet_rels = _rels(z, sheet_part)
        drawing_part = next((t for t in sheet_rels.values()
                             if "drawings/drawing" in t and t.endswith(".xml")),
                            None)
        if drawing_part is None:
            print("Sheet has no drawing layer — no pictures.")
            return exported
        drawing_rels = _rels(z, drawing_part)

        # walk the pictures
        root = ET.fromstring(z.read(drawing_part))
        seen = {}
        for pic in root.iter(f"{{{NS['xdr']}}}pic"):
            cnvpr = pic.find(".//xdr:cNvPr", NS)
            name = cnvpr.get("name") or f"picture_{cnvpr.get('id')}"

            blip = pic.find(".//a:blip", NS)
            if blip is None:
                continue
            media_part = drawing_rels[blip.get(f"{{{NS['r']}}}embed")]
            img_bytes = z.read(media_part)

            # sanitize the name and dedupe duplicates
            safe = "".join(ch for ch in name if ch not in '\\/:*?"<>|').strip()
            if safe in seen:
                seen[safe] += 1
                safe = f"{safe} ({seen[safe]})"
            else:
                seen[safe] = 1
            out_path = os.path.join(out_dir, safe + ".png")

            try:
                save_flattened(img_bytes, out_path)
            except Exception as e:
                # e.g. EMF/WMF sources that Pillow can't decode
                raw_path = os.path.join(out_dir,
                                        safe + os.path.splitext(media_part)[1])
                with open(raw_path, "wb") as fh:
                    fh.write(img_bytes)
                print(f"{name}: could not convert ({e}); "
                      f"saved raw as {raw_path}")
                exported.append(raw_path)
                continue

            exported.append(out_path)
            print(f"{name} -> {out_path}  (source: {media_part})")

    return exported


if __name__ == "__main__":
    export_pictures(r"L:\WHD REO File Locator (October 2026).xlsx", 
                    out_dir=r"K:\excel_and_png",
                    sheet_name=    "October 2026")