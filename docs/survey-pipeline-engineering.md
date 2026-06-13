# Survey Microdata Pipeline — Engineering Rules

> Reusable, dataset-agnostic engineering rules for building survey-microdata
> pipelines. Distilled from real wide-panel survey runs. De-identified: no private
> paths, no achieved result numbers.

## 1. Codebook requirements

- Every codebook CSV must include a `description` column, populated from the source
  data's native variable labels.
- For Stata `.dta` files, read labels via `pyreadstat` metadata: `meta.column_labels`
  (aligned with `meta.column_names`).
- Write a dedicated enrichment step that scans all raw `.dta` files with
  `metadataonly=True` and back-fills descriptions after export.
- Pipeline-derived columns (e.g. `WAVE`, constructed indicators) have no Stata label —
  add manual descriptions in the enrichment step.
- Target coverage ≥ 99%; log how many variables received descriptions and how many
  remain empty. Column order: `variable_name`, `description`, then statistics.

## 2. Memory management for wide DataFrames

Cross-wave stacking routinely yields 10,000–25,000 columns. To avoid OOM:

1. **Indicator joins use key columns only.** Counting matched/unmatched rows must
   operate on `left[keys]`, never the full wide panel:
   ```python
   # WRONG — copies the entire wide panel:
   ind = left.merge(right[keys], on=keys, how="left", indicator=True)
   # CORRECT — copies only key columns:
   ind = left[keys].merge(right[keys].drop_duplicates(), on=keys, how="left", indicator=True)
   ```
2. **Supplement scripts load key columns only.** Load just `[ID, WAVE, HOUSEHOLDID,
   COMMUNITYID]` from the wide parquet, merge supplements against this slim key frame,
   save a separate `*_supplement.parquet`, and let the export step do the final join.
3. **Prefer parquet for intermediate stages** (faster I/O, preserves dtypes). Wrap
   `to_parquet()` with a `clean_dtypes()` call first.
4. **Export very wide panels in row chunks** (`chunksize` / `iter_batches`) to avoid
   loading the full panel into RAM.

## 3. Mixed-type columns (cross-wave Stata stacking)

`pd.concat` over multi-wave `.dta` can give object columns mixing `str` and `float`,
causing `ArrowTypeError` on parquet write. Always `clean_dtypes(df)` before
`to_parquet()`. `clean_dtypes` must:
- Decode `bytes` → `str` (pyreadstat returns bytes for some Stata strings).
- For object columns mixing empty-string (Stata missing sentinel `""`) + numeric:
  coerce the whole column to numeric.
- For mixed str + numeric where strings have content: convert all to `str`.
- Use head+tail sampling (~200 rows each) for type detection, **not** a full-column
  `.apply(type)` scan — the full scan is O(n × cols) and takes tens of minutes on wide
  frames.

## 4. Merge duplicate-column prevention

Merging modules with `suffixes=("", "_right")` makes shared columns (`HOUSEHOLDID`,
`COMMUNITYID`) accumulate `_right` chains.
**Rule:** in the pre-merge drop step, drop ALL non-key columns already in the panel —
including `HOUSEHOLDID`/`COMMUNITYID`. Do not exempt them.
```python
drop = [c for c in module.columns if c in existing and c not in keys]
```
Safety net: `write_parquet()` should also dedupe columns: `df = df.loc[:, ~df.columns.duplicated()]`.

## 5. Cross-wave file-naming differences

Survey waves differ in naming. Use a case-insensitive `find_file()` helper, never
hardcoded names. Module availability and within-module variable availability vary by
wave. Encode wave→filename mappings explicitly (a dict per module) rather than relying
on glob patterns.

## 6. Python environment notes

- Use a **dedicated, project-specific** Python environment (e.g. a named conda env)
  pinned in the project's reproducibility report — never a global interpreter. Record
  the exact interpreter path in the project's `4.reports/reproducibility_report.md`,
  not in shared reference docs.
- Required packages: `pandas`, `pyreadstat`, `pyarrow`. Install binary wheels only
  (`--only-binary :all:`) to avoid source-build failures on Windows.
- On Python 3.9: avoid `X | Y` unions and `list[str]` annotations; use `Optional[X]`
  and `List[str]` from `typing`.
