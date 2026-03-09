---
name: pdf-toolkit
description: Use a pypdf-first workflow to inspect, split, merge, rotate, crop, extract text, edit metadata, and encrypt/decrypt PDF files. Trigger when working with PDFs for page-level edits, document assembly, text extraction, metadata cleanup, or quick PDF automation. Prefer this skill for digital PDFs; if a document is scan/image-only, detect that early and switch to OCR instead of forcing pypdf.
---

# PDF Toolkit

Use this skill to handle common PDF tasks with a practical, low-dependency workflow learned from the `py-pdf/pypdf` project.

## Quick triage

Start by classifying the request:

1. **Inspect** — page count, metadata, encryption state, forms, attachments, rough text quality
2. **Assemble** — merge files, split ranges, reorder or duplicate pages
3. **Modify pages** — rotate, crop, scale, overlay, stamp, compose pages
4. **Extract** — text, metadata, selected pages, page geometry
5. **Protect** — decrypt, add password, clean metadata

If the user asks for text extraction, determine whether the PDF is:

- **Digital PDF**: selectable text or structured text objects exist → use pypdf
- **Scanned/image-only PDF**: text extraction is empty or nearly empty → explain that OCR is needed

## Preflight

Before writing code:

1. Preserve the original file; write to a new output path.
2. Check that `python3` exists.
3. Check whether `pypdf` is importable.
4. For large or messy PDFs, expect higher memory use during text extraction.
5. If the task modifies pages repeatedly, prefer page-level methods over ad-hoc byte editing.

Minimal environment check:

```bash
python3 - <<'PY'
import importlib.util
print('pypdf:', bool(importlib.util.find_spec('pypdf')))
PY
```

If `pypdf` is unavailable, ask before installing dependencies or choose another already-available tool.

## Preferred workflow

### 1. Inspect first

Read the document before changing it:

- page count
- metadata
- encryption state
- sample text from the first page or two
- whether extraction looks empty / broken

For common code patterns, read `references/pypdf-recipes.md`.

### 2. Choose the safest operation

Prefer these patterns from pypdf:

- Use `PdfReader` to inspect
- Use `PdfWriter.append()` / `merge()` for document assembly
- Use `page.rotate(90)` for simple 90° rotations
- Use page boxes for cropping, with the caveat that cropping hides content rather than deleting it
- Use `page.extract_text()` for digital PDFs only

### 3. Write to a new file

Never overwrite the only copy unless the user explicitly asks.

### 4. Verify output

After generating a result, re-open the output and verify:

- page count matches expectations
- file opens successfully
- extraction or metadata changed as intended
- no accidental blank pages or broken rotation

## Task playbooks

### Merge / reorder / split

Prefer `PdfWriter.append()` and `PdfWriter.merge()` over manual page insertion unless there is a specific reason not to.

Use cases:

- combine several PDFs into one
- extract a page range
- insert one PDF into another at a specific position
- duplicate a page intentionally

For repeated merges of the same source, watch for object-sharing side effects and reset translation when needed.

### Rotate / crop / transform

For simple orientation fixes, prefer `page.rotate()`.

Important caveats:

- `rotate()` is safer than raw transformation for standard 90° page rotation
- cropping changes the visible box; cropped-away content still exists in the PDF
- when overlaying/merging rotated pages, transfer rotation to content first if needed

### Text extraction

Use `page.extract_text()` for digital PDFs.

When extraction quality matters:

- try plain extraction first
- if layout matters, try layout mode
- if headers/footers pollute output, use a visitor function to filter by coordinates
- if the page is scan-only, stop and recommend OCR instead of pretending pypdf can read pixels

### Metadata / encryption

Use pypdf for:

- reading metadata
- updating metadata
- detecting encryption
- decrypting when credentials are available
- writing password-protected output

## Decision rules

- **Need a quick page-count / metadata answer?** Inspect only; do not rewrite the file.
- **Need page-level document surgery?** Use pypdf.
- **Need OCR from scans?** Do not force pypdf; switch tools or tell the user OCR is required.
- **Need visual fidelity rendering or image extraction as the main task?** Consider a rendering-oriented tool instead of stretching this skill.

## Pitfalls to avoid

- Treating scanned PDFs as extractable text PDFs
- Overwriting the original before validation
- Using crop as if it permanently redacts content
- Using generic transformations when `rotate()` is the correct page-orientation fix
- Ignoring memory usage on huge content streams
- Assuming merged forms with duplicate field names will just work

## References

- Read `references/pypdf-recipes.md` for reusable code patterns and caveats.
- Source methodology: `py-pdf/pypdf` on GitHub.
