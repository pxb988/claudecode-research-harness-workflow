---
name: workflow-guide
description: "RES: Navigation entry point — explains which research-harness skill to invoke at each stage of an empirical study, from setup to release plus paper replication. Trigger: which skill do I use, where do I start, research workflow help, harness overview. Load this when the user is unsure which stage they are in."
description-en: "RES: Navigation entry point — which research-harness skill to invoke at each stage, setup to release plus replication. Trigger: which skill, where do I start, workflow help, harness overview."
kind: reference
purpose: "Route the researcher to the right skill for their current stage"
trigger: "which skill do I use, where do I start, research workflow help, harness overview, /workflow-guide"
shape: reference
role: navigator
owner: research-harness-core
since: "2026-06-13"
allowed-tools: ["Read"]
user-invocable: true
effort: low
---

# Workflow Guide — which skill, when

Eight skills drive an empirical study. Pick by what you have and what you need next.

## The seven-stage pipeline (full study)

| Stage | Skill | Use it when |
|---|---|---|
| 1 | `/research-harness-setup` | Starting a project — create source-of-truth files, canonical layout, data protection |
| 2 | `/research-harness-audit` | Raw data is in `1.rawdata/` — inspect variables, missingness, IDs, feasibility |
| 3 | `/research-harness-clean` | Audit done — clean, recode, merge into an analysis-ready dataset |
| 4 | `/research-harness-plan` | Data is ready — turn the study spec into a concrete analysis plan |
| 5 | `/research-harness-work` | Plan approved — execute one analysis task (script → log → output) |
| 6 | `/research-harness-review` | Results drafted — verify numbers, identification honesty, data protection |
| 7 | `/research-harness-release` | Review = APPROVE — assemble the replication/evidence package |

Run them in order for a full study. Each writes evidence to `4.reports/` and updates
`analysis_plan.md`.

## The replication shortcut (standalone)

| Skill | Use it when |
|---|---|
| `/research-harness-replicate` | You have a published paper + the raw panel and want just the paper's subsample. Reads raw metadata directly; no full clean needed. Validates your means against the paper's published targets. |

## Knowledge that skills consult automatically
- `docs/references/datasets/<id>.md` — per-dataset file-naming + variable-encoding gotchas.
- `docs/references/replications/<paper>.md` — per-paper concept→variable map + target means.
- `docs/survey-pipeline-engineering.md` — wide-panel memory/dtype engineering rules.

Adding a file + an `index.json` entry extends coverage with no skill change.

## The one rule under all of them
> **No script, no log, no claim.** Every number traces to a script run and a log on disk.
