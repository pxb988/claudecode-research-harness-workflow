# CLAUDE.md — Contributing to the Research Harness Workflow plugin

This repository **is a pure Claude Code plugin** — it ships skills, agents, hooks, and
templates that drive empirical-research projects. It contains **no research data and no
run artifacts** (ADR-0001). The governance rules that apply *inside a research project*
live in `templates/project/CLAUDE.md` (delivered by `/research-harness-setup`), not here.

This file governs work **on the plugin itself**.

## Repository map
- `skills/` — 8 functional skills: 7-stage pipeline (`setup → audit → clean → plan → work → review → release`) + `research-harness-replicate`; plus a `workflow-guide` navigation skill. Auto-discovered; do not declare them in `plugin.json`.
- `agents/` — `analyst`, `reviewer`. Auto-discovered.
- `hooks/` — node guardrails (`guard-raw-data`, `guard-git-add`, `remind-evidence`) + `hooks.json` + `test/`.
- `templates/` — research report templates + `project/` (governance files delivered to user projects).
- `docs/` — `adr/`, `references/` (datasets + replications knowledge), `survey-pipeline-engineering.md`, `INTEGRITY-RULES.md`, `RESEARCH-WORKFLOW.md`, `入门指南.md` (Chinese hands-on getting-started for non-CS users).
- `examples/` — synthetic, de-identified demo fixtures in canonical layout (see `examples/FIXTURES.json`).
- `output-styles/`, `CONTEXT.md`, `README.md`.

## Canonical project layout (what the plugin generates in a user project)
```
study_spec.md   analysis_plan.md   CLAUDE.md(governance)
0.dofiles/  └─ logs/    1.rawdata/    2.workdata/
3.outdata/  ├─ data/  ├─ figures/  └─ tables/    4.reports/
```
This is defined once (here + `templates/project/CLAUDE.md`); every skill references the
same names. Never hardcode a divergent layout in a skill.

## Contributor rules
- **Paths:** skills reference plugin files via `${CLAUDE_PLUGIN_ROOT}/...`; project
  outputs are project-relative (canonical layout above). Never absolute machine paths.
- **No data, ever:** never commit individual-level data, codebooks, `.dta`/`.parquet`,
  or achieved result numbers — anywhere in the repo. The data safety net in `.gitignore`
  and the node hooks are backstops, not permission.
- **References stay de-identified:** `docs/references/` holds public questionnaire facts
  and published paper numbers only — never a specific run's achieved values or private paths.
- **Hooks are TDD:** change a hook only with a failing test first; run `bash hooks/test/run-all.sh` before committing.
- **Tests for knowledge too:** `node docs/references/test-index-resolve.js` must pass after touching the reference layer.
- **Commits:** Chinese, `<type>(scope): <summary>`; plain enough for a non-engineer to read.

## What not to touch without explicit confirmation
- `plugin.json` / `marketplace.json` component wiring (components are auto-discovered).
- Deleting templates/skills, rewriting git history, pushing, or merging to `main`.

## Release boundary (public distribution)
The plugin is distributed via **marketplace `git clone`**, not `git archive` — so
`.gitattributes` `export-ignore` does **not** filter what users receive. Under `clone`,
only files **absent from the published branch** are excluded. Because `main` and its
history still carry the author's CHARLS artifacts (`scripts/charls_*.py`, result-bearing
reports), the public release is cut as an **orphan snapshot** (no history) that becomes
the public default branch — this is what guarantees both a clean file tree and a clean
`git log`.

**Publish target:** the canonical public home is **`pxb988/claudecode-research-harness-workflow`** — its `main` is the orphan default branch, and install paths in `README.md` / `SECURITY.md` / `templates/project/settings.json` / the plugin manifests all point here. It is a *fork* of `maxwell2732/...`, the original upstream, which still carries the dirty CHARLS history and is **not** the release target. Do not push the release to `maxwell2732` or repoint install URLs back to it.

**Orphan release manifest** — when cutting the public snapshot, include the entire
working tree **except**:
- `docs/superpowers/` — design/implementation scaffolding (decisions already captured in `docs/adr/0001–0003`).
- `scripts-meta/` — one-off dev meta-tooling (Phase① sanitize check, target permanently met).
- `.claude/` — local dev config.

Everything else ships, including contributor-facing docs (`CONTEXT.md`, `SECURITY.md`,
this file), `hooks/test/`, and `docs/adr/` — this is an open-source project, not a
sealed installer. `.gitattributes` `export-ignore` is maintained only for the secondary
Zenodo `git archive` tarball; it is not the clone-channel gate.
