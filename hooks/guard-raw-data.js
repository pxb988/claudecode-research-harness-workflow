#!/usr/bin/env node
// guard-raw-data.js — PreToolUse secondary guard: deny Write/Edit into the raw-data dir.
// Primary protection is the OS read-only lock applied by research-harness-setup (ADR-0003).
const fs = require('fs');

// matches a path segment "1.rawdata" or legacy "data/raw"
const PROTECTED = /(^|[\/\\])(1\.rawdata|data[\/\\]raw)([\/\\]|$)/i;

function decide(input) {
  const tool = (input && input.tool_name) || '';
  if (!/^(Write|Edit|MultiEdit)$/.test(tool)) return null;
  const ti = (input && input.tool_input) || {};
  const p = String(ti.file_path || ti.path || '');
  // examples/ ships SYNTHETIC fixtures that researchers regenerate — exempt, to
  // stay symmetric with guard-git-add's examples exemption (MIN-5).
  if (/(^|[\/\\])examples[\/\\]/i.test(p)) return null;
  if (p && PROTECTED.test(p)) {
    return {
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason:
          '1.rawdata/ holds read-only raw microdata and must never be modified (research-integrity rule 1). Write outputs to 2.workdata/ (intermediate) or 3.outdata/ (analysis-ready / results) instead.'
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
