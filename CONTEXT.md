# CONTEXT — Glossary

Canonical terms for the Research Harness Workflow plugin. This file is a glossary, not a spec.

## Plugin

The installable Claude Code plugin itself: skills, agents, hooks, output-styles, templates, and reference docs. Distributed via marketplace and installed into `~/.claude/plugins/`. The Plugin contains **no research data, no run scripts, and no reports** — it is pure tooling. Its files are addressed at runtime via `${CLAUDE_PLUGIN_ROOT}`.

Not to be confused with a **Project**.

## Project

A researcher's own working directory where actual empirical research happens. Created/scaffolded by the `research-harness-setup` skill. The **canonical project layout** (numbered economist convention) is:

```
study_spec.md          # source-of-truth: the study definition
analysis_plan.md       # source-of-truth: the task plan + evidence paths
CLAUDE.md              # research-governance rules, delivered by setup
0.dofiles/             # R / Stata / Python scripts
  └─ logs/             # run logs (live next to the scripts that produce them)
1.rawdata/             # raw source microdata — OS read-only, never written
2.workdata/            # intermediate cleaned data — regenerable
3.outdata/             # final products
  ├─ data/             # analysis-ready dataset + codebook (the "processed data")
  ├─ figures/          # result figures
  └─ tables/           # result tables
4.reports/             # governance / audit markdown (audit, merge, review, reproducibility)
```

This layout is defined **once** as the canonical layout (in the project `CLAUDE.md` and the setup skill); every skill references these names rather than hardcoding its own. **All research data and run artifacts live here, never in the Plugin.** Data dirs (`1.rawdata/`, `2.workdata/`, `3.outdata/data/`) and `0.dofiles/logs/` are git-ignored; `4.reports/` markdown is safe to commit.

The historical confusion in this repo came from running a real Project *inside* the Plugin repo. The two are now strictly separated.

## Artifact

A concrete output of one specific research run: a dataset-specific cleaning script with hardcoded paths, a report containing real coefficients / sample sizes / variable means, a merged panel CSV. Artifacts belong to a **Project** and must **never** be committed to the Plugin. The author's CHARLS LTCI scripts and reports were Artifacts — they are removed from the Plugin.

## Reference

Reusable, de-identified knowledge *about* a dataset that any researcher cleaning that dataset would need: variable naming conventions across waves, encoding gotchas, module routing rules, ID format quirks. References are public facts about a survey instrument, not the product of one researcher's run. They contain **no real result numbers and no project paths**. References are first-class Plugin content, stored under `docs/references/datasets/`. A de-identified CHARLS Reference is welcome in the Plugin even though the CHARLS **Artifacts** are not.

Distinction in one line: **delete the Artifact, keep the de-identified Reference.**

References come in two kinds, on two different axes:

- **Dataset Reference** (`docs/references/datasets/<name>.md`): cleaning knowledge about one survey instrument — variable naming across waves, encoding gotchas, module routing, ID quirks. Reusable by *every* study that uses that dataset. Organized once, reused forever (e.g. `charls.md`).
- **Replication Reference** (`docs/references/replications/<name>.md`): the *method* for reproducing a published paper's subsample on a dataset — the discover→subsample→codebook script pattern, variable-discovery protocol, codebook-validation thresholds. The generic method is a reusable template (`_TEMPLATE.md`); a paper's *achieved* run numbers are an Artifact and are excluded. A Replication Reference may cite the **published paper's** target statistics (public, citable) but never the author's own achieved values.

New references scale additively: drop a file under the right axis and register one line in `docs/references/index.json`. No skill code changes — skills read the registry to discover whether a Reference exists for the current dataset/paper.

## Replication mode

A standalone capability (skill `research-harness-replicate`), orthogonal to the seven-stage pipeline: given a **published paper** + a raw survey panel, extract an analysis-ready subsample + codebook that matches the paper's sample filter, variable construction, and encoding. It runs the discover-vars → subsample → codebook method, reads/writes the `replications/` Reference layer, and validates constructed variable means against the paper's **published** target statistics. It reads raw metadata directly and does not require the full clean pipeline to run first. This is the operational home of the method content distilled from the author's §10; the headline README feature now has a real skill behind it.

The plugin ships **8 functional skills** — the seven-stage pipeline (setup → audit → clean → plan → work → review → release) plus the standalone `research-harness-replicate` — and a `workflow-guide` navigation skill that routes the researcher to the right stage (9 skill directories in total).

## Guardrail (Harness teeth)

A mechanism that *enforces* a research-integrity rule rather than merely stating it. Two layers (see [ADR-0003](docs/adr/0003-raw-data-protection-mechanism.md)):

1. **OS-level lock (primary teeth):** `research-harness-setup` makes `1.rawdata/` write-denied at the operating-system level (`icacls … /deny … /T` on Windows, `chmod -R a-w` on Unix). This is what actually stops a script from overwriting raw data.
2. **PreToolUse hook (secondary):** a **node** hook (Claude Code ships node; cross-platform) that denies `Write`/`Edit`/`git add` targeting protected paths. Hooks are written in node — **not** bash — because `/bin/bash` is absent on native Windows, where a bash hook would silently no-op.

Guardrails are what make this a Harness (controlled environment) rather than a prompt collection, with no Go-binary dependency. The honest limitation: a `Bash`-invoked script writing to raw data is caught only by the OS lock, not the hook.
