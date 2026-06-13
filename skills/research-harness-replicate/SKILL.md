---
name: research-harness-replicate
description: "RES: Extract an analysis-ready subsample from raw survey panels to replicate a published paper. Runs discover-vars -> subsample -> codebook, validates constructed means against the paper's published targets (CLOSE/MODERATE/DIFFERS). Reads raw metadata directly; does not require a full clean first. Trigger: replicate a paper, extract subsample, reproduce Table 2, paper replication. Do NOT load for: full cleaning, setup, audit, review, release."
description-en: "RES: Extract an analysis-ready subsample from raw survey panels to replicate a published paper. Runs discover-vars -> subsample -> codebook, validates constructed means against the paper's published targets. Trigger: replicate a paper, extract subsample, reproduce Table 2. Do NOT load for: full cleaning, setup, audit, review, release."
kind: workflow
purpose: "Extract and validate a paper-replication subsample from raw survey microdata"
trigger: "replicate a paper, extract subsample, reproduce Table 2, paper replication, /research-harness-replicate"
shape: workflow
role: generator
pair: research-harness-review
owner: research-harness-core
since: "2026-06-13"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
argument-hint: "[--paper <id>] [--dataset <id>]"
user-invocable: true
effort: medium
---

# Research Harness Replicate

Extract an analysis-ready subsample from raw survey panels to replicate a published
paper, and validate the constructed variable means against the paper's **published**
descriptive statistics. This skill reads raw `.dta`/`.csv` **metadata directly** and
does not require a full `/research-harness-clean` run first.

## When to use
- You have a published paper + the raw survey panel, and you want the exact subsample.
- You are NOT doing a full study clean — just a targeted, paper-faithful extraction.

For a full study pipeline use the seven-stage flow instead (see `/workflow-guide`).

## Quick Reference

| Input | Action |
|---|---|
| `/research-harness-replicate` | Interactive: ask for paper id + dataset id, then run the three stages |
| `/research-harness-replicate --paper <paper-id> --dataset <dataset-id>` | Non-interactive |

## Auto-discovery of reference knowledge

1. Read `docs/references/index.json`.
2. Resolve `--dataset <id>` → `datasets/<id>.md` for file-naming + variable-encoding
   gotchas. If the dataset is not registered, tell the user and offer to create one
   from `datasets/_TEMPLATE.md`.
3. Resolve `--paper <id>` → `replications/<id>.md` for the concept→variable map and the
   published target means. If absent, create it from `replications/_TEMPLATE.md` and
   ask the user for the paper's Table-2 published values.

Never invent variable names or target means. Variable names come from the dataset
reference (or a discover-vars run); target means come from the paper.

## Procedure

### Step 1 — Discover variables (metadata only)
Copy `${CLAUDE_PLUGIN_ROOT}/skills/research-harness-replicate/reference/discover_vars.py`
into `0.dofiles/<dataset>_10_discover_vars.py`, set the keyword list from the paper's
concepts, and run it. It scans raw `.dta` **metadata only** (`metadataonly=True`) and
writes a flagged variable list to `3.outdata/data/_10_var_list.csv`. Log the run under
`0.dofiles/logs/`.

**Never load full data for discovery.** Confirm actual variable names per wave from the
output before constructing anything — names differ across waves (see the dataset
reference).

### Step 2 — Build the subsample
Copy `reference/build_subsample.py` into `0.dofiles/<dataset>_11_<paper>_subsample.py`.
Load only the confirmed columns per wave, apply the paper's sample filter, and construct
each variable using the documented encodings from `datasets/<id>.md` + the paper. Save
to `3.outdata/data/` as both `.parquet` and `.csv`. **Log every dropped observation
with its reason and count** (integrity rule 4) under `0.dofiles/logs/`.

### Step 3 — Build the codebook and validate against the paper
Copy `reference/build_codebook.py` into `0.dofiles/<dataset>_12_<paper>_codebook.py`.
Fill `PAPER_TARGETS` with the paper's **published** Table-2 values (never your own
achieved values). Run it to emit `3.outdata/data/_12_codebook.csv` with a `mean_match`
column:

| Label | Criterion |
|---|---|
| `CLOSE` | `|our_mean − paper_mean| < 0.02` |
| `MODERATE` | `0.02 ≤ diff < 0.10` |
| `DIFFERS` | `diff ≥ 0.10` |

Any `DIFFERS` variable must get a documented explanation in the codebook `notes` column
before the subsample is treated as regression-ready.

### Step 4 — Report
Write a Chinese task-completion report to `4.reports/report_replicate-<paper>_<YYYYMMDD>.md`
(per project CLAUDE.md §6): evidence chain (script → log → output) for each number, the
mean_match summary, and any DIFFERS explanations. **All numbers must come from the
codebook/log — never from memory.**

## Forbidden Actions
- Do not write to `1.rawdata/`.
- Do not load full data during discovery (metadata only).
- Do not record your own achieved means in `docs/references/` — those go to `4.reports/`.
- Do not fabricate variable names or paper target means.
- Do not silently drop observations — log every filter.

## Completion Criteria
- [ ] `_10_var_list.csv` produced from a metadata-only scan, with a log
- [ ] `_11_subsample.{parquet,csv}` produced, all drops logged
- [ ] `_12_codebook.csv` produced with a `mean_match` column vs the paper's published means
- [ ] Every `DIFFERS` variable has a documented explanation
- [ ] Chinese completion report written to `4.reports/` with a full evidence chain
