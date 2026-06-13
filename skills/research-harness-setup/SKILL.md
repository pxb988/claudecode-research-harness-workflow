---
name: research-harness-setup
description: "RES: Initialize research project structure, create study_spec.md and analysis_plan.md, set up data protection rules and folder layout. Trigger: setup research project, initialize study, new research project. Do NOT load for: audit, cleaning, analysis, review, release."
description-en: "RES: Initialize research project structure, create study_spec.md and analysis_plan.md, set up data protection rules and folder layout. Trigger: setup research project, initialize study, new research project. Do NOT load for: audit, cleaning, analysis, review, release."
kind: workflow
purpose: "Initialize the research project with source-of-truth files, controlled folder structure, and data protection rules"
trigger: "setup research project, initialize study, new research project, /research-harness-setup"
shape: workflow
role: generator
pair: research-harness-audit
owner: research-harness-core
since: "2026-05-29"
allowed-tools: ["Read", "Write", "Edit", "Glob", "Bash"]
argument-hint: "[--study-name NAME] [--data-path PATH]"
user-invocable: true
effort: low
---

# Research Harness Setup

Initialize a new empirical research project with source-of-truth files, a controlled folder structure, and data protection rules.

This skill runs once at the start of a project. It does not run analysis, audit data, or claim feasibility.

## Quick Reference

| Input | Action |
|---|---|
| `/research-harness-setup` | Interactive: prompt for study name and data path, then create all files |
| `/research-harness-setup --study-name "X" --data-path "1.rawdata/X.csv"` | Non-interactive: use provided values |

## Procedure

### Step 1 — Collect study context

If arguments are not provided, ask the user for:

1. Study name or working title
2. Path to raw data file(s) (may be `unknown` if data not yet available)
3. Brief description of the research question (one or two sentences; may be `unknown`)

Do not invent answers. If the user says `unknown`, write `unknown` in the spec.

### Step 2 — Create folder structure

Create the following directories if they do not exist. Do not delete or overwrite existing content.

```
0.dofiles/
0.dofiles/logs/
1.rawdata/
2.workdata/
3.outdata/data/
3.outdata/figures/
3.outdata/tables/
4.reports/
```

### Step 3 — Create study_spec.md

Copy `${CLAUDE_PLUGIN_ROOT}/templates/study_spec.md` to `study_spec.md` at the project root.

Fill in:
- Study name from Step 1
- Raw data path from Step 1
- Research question from Step 1

Leave all other fields as `unknown`. The researcher fills in the full spec before Stage 2.

If `study_spec.md` already exists: read it, confirm with the user before overwriting, and preserve existing content unless the user explicitly requests replacement.

### Step 4 — Create analysis_plan.md

Copy `${CLAUDE_PLUGIN_ROOT}/templates/analysis_plan.md` to `analysis_plan.md` at the project root.

Fill in:
- Study spec path: `study_spec.md`
- Date: today's date
- Analyst: Claude Code

Leave all task fields as `cc:todo` with `unknown` paths.

If `analysis_plan.md` already exists: do not overwrite. Notify the user.

### Step 5 — Deliver governance files and lock raw data

1. If `CLAUDE.md` does not exist at project root, copy `${CLAUDE_PLUGIN_ROOT}/templates/project/CLAUDE.md` to `CLAUDE.md`.
2. If `.gitignore` does not exist, copy `${CLAUDE_PLUGIN_ROOT}/templates/project/gitignore.template` to `.gitignore`; if it exists, append any missing data-protection lines.
3. Deliver project-level settings: if `.claude/settings.json` does not exist, copy `${CLAUDE_PLUGIN_ROOT}/templates/project/settings.json` to `.claude/settings.json`; if it exists, merge in (without overwriting the user's other settings): the `permissions` (allow Rscript/stata/python, deny `Write/Edit(1.rawdata/**)` + dangerous commands, ask on push/install), the `sandbox.network.deniedDomains`, and ensure `enabledPlugins` contains `claudecode-research-harness-workflow` and `extraKnownMarketplaces` declares this plugin's source. **This project-level `.claude/settings.json` is the ONLY place where permissions take effect** — a plugin's own bundled `settings.json` is NOT merged for permissions (Claude Code honors only `agent`/`subagentStatusLine` from a plugin's settings). It is also what makes the harness project-scoped and reproducible: a collaborator who clones the project and trusts its settings gets the same enabled plugin + guardrails.
4. Write `1.rawdata/READONLY.md` (the read-only notice).
5. **Apply the OS-level read-only lock to `1.rawdata/` — only after the researcher confirms raw data is in place** (locking an empty folder protects nothing). The ACE denies write+delete but **must preserve read** (the harness still reads raw data):
   - Windows: `icacls 1.rawdata /deny "%USERNAME%:(OI)(CI)(WD,AD,DC,DE)" /T`
     (On Git Bash the `/`-flags get mangled — invoke through cmd: `cmd.exe /c 'icacls 1.rawdata /deny "%USERNAME%:(OI)(CI)(WD,AD,DC,DE)" /T'`. `DE` is required: without the object-level Delete right, `rm` bypasses delete-child and removes files anyway.)
   - Unix: `chmod -R a-w 1.rawdata/`
   - Unlock for maintenance: `icacls 1.rawdata /reset /T` (Windows) / `chmod -R u+w 1.rawdata/` (Unix).
6. **Self-test the lock (fail loud).** Attempt to (a) create a file in `1.rawdata/`, (b) edit an existing raw file, (c) create a nested file, (d) delete an existing raw file — **every write/delete MUST fail**. Then (e) **confirm that reading an existing raw file still SUCCEEDS**. If any write/delete succeeds, OR if a read fails, do NOT report the data as protected — report the lock misconfigured and that protection has degraded to the convention layer (see ADR-0003). Never silently downgrade.

### Step 6 — Confirm and report

Print a setup summary:

```
Research Agent Harness — Setup Complete

Study spec:     study_spec.md         [created / already existed]
Analysis plan:  analysis_plan.md      [created / already existed]
Folders:        0.dofiles, 0.dofiles/logs, 1.rawdata,
                2.workdata, 3.outdata/data, 3.outdata/figures,
                3.outdata/tables, 4.reports
Data protection: 1.rawdata/READONLY.md written, OS lock applied

Next step: Fill in study_spec.md, then run /research-harness-audit
```

## Forbidden Actions

- Do not modify any file under `1.rawdata/`
- Do not invent a research question if the user did not provide one
- Do not claim the data is feasible for the proposed design before an audit is run
- Do not run any analysis or data inspection in this step
- Do not overwrite `study_spec.md` without user confirmation if it already exists

## Completion Criteria

- [ ] `study_spec.md` exists with study name, data path, and research question filled in (or `unknown`)
- [ ] `analysis_plan.md` exists with header fields populated
- [ ] All 8 folders exist: `0.dofiles/`, `0.dofiles/logs/`, `1.rawdata/`, `2.workdata/`, `3.outdata/data/`, `3.outdata/figures/`, `3.outdata/tables/`, `4.reports/`
- [ ] `1.rawdata/READONLY.md` exists
- [ ] OS-level read-only lock applied to `1.rawdata/` and self-test passed
- [ ] No files under `1.rawdata/` were modified

## Handoff to Stage 2

Tell the user:

> Fill in the remaining fields in `study_spec.md` — particularly identification strategy, variables, and sample restrictions — before running `/research-harness-audit`.
> When `study_spec.md` is complete and you have approved it, run `/research-harness-audit`.
