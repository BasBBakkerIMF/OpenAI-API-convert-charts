import win32com.client as win32

excel_path = r"Figure 1_REAL Panel_June2021.xlsx"
sheet_name = "Panel1"

pdf_path = r"Panel1.pdf"

excel = win32.Dispatch("Excel.Application")
excel.Visible = False

wb = excel.Workbooks.Open(excel_path)

ws = wb.Worksheets(sheet_name)

# Export only the print area
ws.ExportAsFixedFormat(
    Type=0,                      # PDF
    Filename=pdf_path,
    IgnorePrintAreas=False
)

wb.Close(False)
#excel.Quit()

print(f"Saved PDF: {pdf_path}")