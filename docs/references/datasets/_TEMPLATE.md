---
kind: dataset-reference
dataset: <SHORT-ID e.g. charls>
status: template
deidentified: true
---

# <Dataset full name> — Engineering Reference

> De-identified, reusable facts about this survey dataset. Public questionnaire /
> documentation knowledge only. No achieved result numbers, no private paths.

## 1. File naming across waves
- Conventions (case, CamelCase vs lowercase), module renames per wave.
- Always resolve filenames with a case-insensitive finder; never hardcode one name.

## 2. Key columns & merge keys
- ID / household / community / wave key columns and any cross-wave format change.

## 3. Variable encoding gotchas
- Per-concept value codes, thresholds, multi-select null-vs-zero conventions,
  questionnaire routing that hides respondents from a variable.

## 4. Memory / dtype pitfalls
- Wide-panel column counts, mixed-type stacking, parquet vs csv, key-only joins.

## 5. Known limitations
- Cross-wave crosswalk gaps, coverage holes — document, never silently assume fixed.
