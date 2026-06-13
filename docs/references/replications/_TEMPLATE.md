---
kind: replication-reference
paper-id: <author-year e.g. zhang-2026>
dataset: <dataset short-id>
status: template
deidentified: true
---

# Replicating <Paper short title> on <Dataset>

> Method notes for extracting an analysis-ready subsample to replicate a published
> paper. You MAY cite the paper's **published** target means (Table 2 etc.). You MUST
> NOT record your own achieved values here — those belong in the project's
> `4.reports/`, never in this reusable reference.

## 1. Three-script pipeline
Number scripts `<dataset>_10/11/12` (or higher to avoid collision with the main pipeline):

| Script | Role | Output (project-relative) |
|---|---|---|
| `*_10_discover_vars.py` | Read `.dta` metadata (`metadataonly=True`) across waves/modules; log var names + labels; flag keyword matches | `3.outdata/data/*_10_var_list.csv` |
| `*_11_<paper>_subsample.py` | Load only needed columns per wave, apply the paper's sample filter, construct outcome/treatment/control vars | `3.outdata/data/*_subsample.parquet` + `.csv` |
| `*_12_<paper>_codebook.py` | Compute per-variable stats, attach paper definitions + published target means, flag mismatches | `3.outdata/data/*_codebook.csv` |

## 2. Variable discovery protocol
- Always run `*_10` before `*_11`. Never assume variable names from the paper alone —
  names differ across waves/versions.
- `*_10` uses `metadataonly=True` (never loads full data), scans 8–10 modules × 3+ waves,
  logs every var whose name OR label matches the keyword list, exports
  `[wave, module, file, var_name, label, flagged]`.

## 3. Concept → variable map
- One row per analysis concept → the wave-specific source variable(s) + construction rule.
- Record published value codes / thresholds you relied on (cite the paper).

## 4. Codebook validation against the paper
`*_12` must emit a `mean_match` column comparing each constructed mean to the paper's
published descriptive statistics:

| Label | Criterion |
|---|---|
| `CLOSE` | `|our_mean − paper_mean| < 0.02` |
| `MODERATE` | `0.02 ≤ diff < 0.10` |
| `DIFFERS` | `diff ≥ 0.10` |

Any `DIFFERS` variable must carry a documented explanation in the codebook `notes`
column before the subsample is considered regression-ready.

## 5. Known replication limitations
- Routing/coverage gaps that bound achievable closeness — document them; never fudge a
  construction to hit a target.
