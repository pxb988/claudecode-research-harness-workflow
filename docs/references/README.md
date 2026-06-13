# References — Accumulable Research Knowledge

This layer holds **reusable, de-identified** knowledge that research skills consult
automatically. It has two axes:

- `datasets/` — per-dataset engineering facts: file-naming conventions, variable
  encoding gotchas, memory/dtype pitfalls. Public, de-identified. **No achieved
  result numbers, no private paths, no individual-level data.**
- `replications/` — per-paper replication method notes: which variables map to which
  concepts, sample filters, validation thresholds. May cite a paper's **published**
  target means; **never** the author's own achieved values.

`index.json` is a machine-readable registry. Skills (`research-harness-clean`,
`research-harness-replicate`) read it to auto-discover the right reference by
dataset name or paper id — adding a file + an index entry extends coverage with
**no skill edit**.

## How to add a reference

1. Copy the matching `_TEMPLATE.md` into `datasets/<name>.md` or `replications/<paper-id>.md`.
2. Fill it in. Keep it de-identified: public questionnaire facts only; cite published
   numbers, never your own runs' achieved values; use relative path *shapes*, never
   absolute machine paths.
3. Register it in `index.json` (see the schema there).
4. Run `node docs/references/test-index-resolve.js` — it must pass.

## What must never enter this layer

- Achieved sample sizes / means / coefficients from a specific run
- Absolute machine paths (`C:\Users\...`), conda env names, private file trees
- Any individual-level data or data-file attachment
