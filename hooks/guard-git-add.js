#!/usr/bin/env node
// guard-git-add.js — PreToolUse guard: refuse to stage data files / codebooks.
// Honest limit: `git add .` of ignored files is handled by .gitignore, not here;
// this catches explicit staging of data by name/extension/dir.
const fs = require('fs');

const DATA_EXT = /\.(csv|parquet|dta|sas7bdat|rds|feather)(['"]?)$/i;
const PROT_DIR = /(^|[\/\\])(1\.rawdata|2\.workdata|3\.outdata[\/\\]data)([\/\\]|$)/i;
const IN_EXAMPLES = /(^|[\/\\])examples[\/\\]/i;
const IN_RESULTS = /(^|[\/\\])3\.outdata[\/\\](tables|figures)[\/\\]/i;

function deny(reason) {
  return { hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'deny', permissionDecisionReason: reason } };
}

function decide(input) {
  if (!input || input.tool_name !== 'Bash') return null;
  const cmd = String((input.tool_input || {}).command || '');
  if (!/\bgit\s+add\b/.test(cmd)) return null;
  // Take only what follows `git add`, drop flags, split into path tokens, strip quotes.
  const after = cmd.replace(/^[\s\S]*?\bgit\s+add\b/, '');
  const tokens = after.split(/\s+/)
    .filter(t => t && !t.startsWith('-'))
    .map(t => t.replace(/^['"]|['"]$/g, ''));
  for (const t of tokens) {
    // examples/ ships SYNTHETIC, de-identified fixtures that ARE meant to be committed.
    if (IN_EXAMPLES.test(t)) continue;
    // Canonical microdata dirs (raw / work / analysis-ready data) are never committed.
    if (PROT_DIR.test(t)) {
      return deny('Refusing to stage a path under a canonical data dir (1.rawdata/2.workdata/3.outdata/data). Microdata must never be committed. Commit scripts, 4.reports/ markdown, and 3.outdata/tables|figures/ results only.');
    }
    // codebook (variable-level metadata) is never committed, even under results.
    if (/codebook/i.test(t)) {
      return deny('Refusing to stage a codebook. Variable-level metadata must never be committed (data protection). Commit scripts and 4.reports/ markdown only.');
    }
    // 3.outdata/tables|figures/ hold AGGREGATE results — part of the release package (MAJ-5).
    if (!IN_RESULTS.test(t) && DATA_EXT.test(t)) {
      return deny('Refusing to stage a data file. Derived microdata must never be committed (data protection). Commit scripts, 4.reports/ markdown, and 3.outdata/tables|figures/ results only.');
    }
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
