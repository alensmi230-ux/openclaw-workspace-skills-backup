# pypdf Recipes

These patterns are distilled from the `py-pdf/pypdf` repository and docs. Use them as defaults when the environment has `python3` and `pypdf` available.

## 1. Inspect a PDF

```python
from pypdf import PdfReader

reader = PdfReader('input.pdf')
print('pages:', len(reader.pages))
print('encrypted:', reader.is_encrypted)
print('metadata:', reader.metadata)

sample = reader.pages[0].extract_text() or ''
print('sample:', sample[:500])
```

Use this first for most tasks.

Interpretation:

- text looks normal → digital PDF, proceed with extraction/manipulation
- text is empty / nearly empty but the page clearly has content → likely scanned PDF, OCR needed

## 2. Merge PDFs

Prefer `append()` for simple concatenation.

```python
from pypdf import PdfWriter

writer = PdfWriter()
for path in ['a.pdf', 'b.pdf', 'c.pdf']:
    writer.append(path)

with open('merged.pdf', 'wb') as f:
    writer.write(f)
```

Insert one document into another at a position:

```python
from pypdf import PdfWriter

writer = PdfWriter()
writer.append('base.pdf', pages=(0, 2))
writer.merge(position=2, fileobj='insert.pdf', pages=(0, 1))
writer.append('base.pdf', pages=(2, 5))

with open('out.pdf', 'wb') as f:
    writer.write(f)
```

### Merge caveats

- For large PDFs, recursion depth can matter.
- If you copy the same source content repeatedly, object reuse can create surprising side effects. Use `writer.reset_translation(reader)` when needed.
- For merged forms with duplicate field names, namespace the fields first.

## 3. Split / extract page ranges

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader('input.pdf')
writer = PdfWriter()

for i in range(2, 5):
    writer.add_page(reader.pages[i])

with open('pages-3-to-5.pdf', 'wb') as f:
    writer.write(f)
```

## 4. Rotate pages

Prefer `rotate()` for standard orientation fixes.

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader('input.pdf')
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

writer.pages[0].rotate(90)

with open('rotated.pdf', 'wb') as f:
    writer.write(f)
```

Why this is preferred:

- `rotate()` updates orientation in a page-safe way
- raw transformations are more appropriate for layout composition than simple orientation repair

## 5. Crop pages

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader('input.pdf')
writer = PdfWriter()

page = reader.pages[0]
writer.add_page(page)

page0 = writer.pages[0]
page0.mediabox.upper_right = (
    page0.mediabox.right / 2,
    page0.mediabox.top / 2,
)

with open('cropped.pdf', 'wb') as f:
    writer.write(f)
```

Important:

- Cropping changes visibility, not existence.
- Do not describe crop as secure removal or redaction.

## 6. Extract text

Basic extraction:

```python
from pypdf import PdfReader

reader = PdfReader('input.pdf')
for page in reader.pages:
    text = page.extract_text() or ''
    print(text)
```

Layout-aware extraction:

```python
text = page.extract_text(extraction_mode='layout')
```

If headers/footers should be filtered, use a visitor function:

```python
from pypdf import PdfReader

reader = PdfReader('input.pdf')
page = reader.pages[0]
parts = []

def visitor_body(text, cm, tm, font_dict, font_size):
    y = tm[5]
    if 50 < y < 720 or y == 0:
        parts.append(text)

page.extract_text(visitor_text=visitor_body)
body = ''.join(parts)
print(body)
```

### Extraction caveats

- PDF text extraction has ambiguous goals: paragraphs, tables, headers, footers, captions, ligatures
- Very large uncompressed content streams can use a lot of memory
- Scan-only pages need OCR; pypdf does not read text from pixels

## 7. Overlay / merge transformed pages

```python
from pypdf import PdfReader, PdfWriter, Transformation

base_reader = PdfReader('base.pdf')
overlay_reader = PdfReader('overlay.pdf')

writer = PdfWriter()
page = writer.add_page(base_reader.pages[0])

op = Transformation().rotate(45).translate(tx=50)
page.merge_transformed_page(overlay_reader.pages[0], op, expand=True)

with open('composed.pdf', 'wb') as f:
    writer.write(f)
```

If pages already carry rotation metadata, normalize first before visual merging.

## 8. Metadata and protection

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader('input.pdf')
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)

writer.add_metadata({
    '/Title': 'Clean Copy',
    '/Author': 'OpenClaw',
})
writer.encrypt('secret-password')

with open('protected.pdf', 'wb') as f:
    writer.write(f)
```

## 9. When not to use pypdf

Choose another path when the task is primarily:

- OCR from scans
- high-fidelity rendering to images
- complex table extraction from messy scanned docs
- GUI editing or pixel-perfect layout authoring

In those cases, say so clearly and switch tools instead of forcing this workflow.
