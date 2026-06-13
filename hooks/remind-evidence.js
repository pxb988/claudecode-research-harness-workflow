#!/usr/bin/env node
// remind-evidence.js — PostToolUse soft reminder: a research script ran without a
// visible log redirection. Non-blocking; injects a context note, never denies.
const fs = require('fs');

// Interpreter must appear at COMMAND position (line start or after a shell
// separator), and be followed by a script arg — so a ".py" FILENAME inside
// `git add analysis.py` no longer false-triggers (MAJ-1). Longest tokens first.
const RUN = /(?:^|[\s;&|(])(Rscript|stata-mp|stata-se|stata|python3|python|py)(?=\s|$)/;
// A log counts only if output is redirected to a FILE (`> file` / `>> file`) or a
// log construct is present. Bare `2>&1` (no file) must NOT count — it's `>` then `&`,
// excluded by the negative lookahead — otherwise a logless run reads as logged (MAJ-7).
const HAS_LOG = /(log\s+using|sink\s*\(|logging\.|>>?\s*(?!&)\S+|\btee\b)/i;

function decide(input) {
  if (!input || input.tool_name !== 'Bash') return null;
  const cmd = String((input.tool_input || {}).command || '');
  if (/^\s*git\b/.test(cmd)) return null;  // git subcommands are not script runs
  if (RUN.test(cmd) && !HAS_LOG.test(cmd)) {
    return {
      hookSpecificOutput: {
        hookEventName: 'PostToolUse',
        additionalContext:
          'Reminder: a research script ran but no log redirection was detected. Per research-integrity rules, every run must write a log under 0.dofiles/logs/. Verify a log exists before marking the task done.'
      }
    };
  }
  return null;
}

function main() {
  let input = {};
  try { input = JSON.parse(fs.readFileSync(0, 'utf8') || '{}'); } catch (e) { process.exit(0); }
  const out = decide(input);
  if (out) process.stdout.write(JSON.stringify(out));
  process.exit(0);
}

if (require.main === module) main();
module.exports = { decide };
