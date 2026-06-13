# Pure-plugin / Project separation, public release via fresh history

Status: accepted (2026-06-13)

The repository is the installable Claude Code **Plugin** only — skills, agents, hooks, output-styles, templates, reference docs. It contains **no research data, no run scripts, and no reports**. A researcher installs it via marketplace and runs `research-harness-setup` inside their own **Project** directory, which is where all data and run artifacts live (git-ignored). Plugin files are addressed at runtime via `${CLAUDE_PLUGIN_ROOT}`, never by paths relative to the user's working directory.

We chose this over the "clone-and-work-inside-the-repo" template model because conflating the Plugin with a working Project is exactly what polluted this repo (the author ran a real CHARLS study inside it). The public release is cut from a **fresh orphan commit** (single "initial public release") so the prior history — which contains the author's run artifacts and real numbers derived from licensed microdata — never ships.

Consequences: every skill that copies a template must resolve its source via `${CLAUDE_PLUGIN_ROOT}/templates/...`; the repo's own `.gitignore` no longer needs to protect data dirs (there are none), while the *Project* `.gitignore` delivered by setup does. See [CONTEXT.md](../../CONTEXT.md) terms **Plugin**, **Project**, **Artifact**.
