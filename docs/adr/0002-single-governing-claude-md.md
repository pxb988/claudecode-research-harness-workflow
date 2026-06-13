# Single governing CLAUDE.md, no AGENTS.md

Status: accepted (2026-06-13)

The research-integrity rules (the former root `CLAUDE.md` §1–§8) are delivered **into the user's Project** by `research-harness-setup`, as a single project-level `CLAUDE.md`. The plugin **root** `CLAUDE.md` is reduced to short contributor instructions (how to work on the plugin itself). **`AGENTS.md` is removed entirely** — the inherited two-doc model was generic dev-harness baggage ("Cursor = PM"), and the root file even referenced a non-existent `AGENTS.md`; role boundaries become a section inside the project `CLAUDE.md`.

This is recorded because a future reader will see a thin root `CLAUDE.md` and wonder where the real rules went, and because Claude Code does **not** auto-inject a plugin's `CLAUDE.md` into user sessions — only the Project's own `CLAUDE.md` (in cwd) is loaded, so the rules *must* be written into the Project to reach the researcher.

Considered and rejected: keeping the two-doc (`CLAUDE.md` + `AGENTS.md`) split — more files to maintain, more surface in every user Project, and no research benefit. See [CONTEXT.md](../../CONTEXT.md).
