#!/usr/bin/env node
// Validate docs/references/index.json structure and that every registered file exists.
const fs = require('fs');
const path = require('path');
const assert = require('assert');

const here = __dirname;
const idx = JSON.parse(fs.readFileSync(path.join(here, 'index.json'), 'utf8'));

assert.ok(idx.datasets && typeof idx.datasets === 'object', 'index.json must have a datasets map');
assert.ok(idx.replications && typeof idx.replications === 'object', 'index.json must have a replications map');

// charls must be discoverable (Stage B3 shipped it)
assert.ok(idx.datasets.charls, 'charls must be registered in datasets');

function checkEntries(map, kind) {
  for (const [id, entry] of Object.entries(map)) {
    assert.ok(entry.file, `${kind}.${id} must have a file`);
    const p = path.join(here, entry.file);
    assert.ok(fs.existsSync(p), `${kind}.${id} -> ${entry.file} must exist on disk`);
    if (kind === 'replications') {
      assert.ok(entry.dataset, `replications.${id} must name its dataset`);
    }
  }
}
checkEntries(idx.datasets, 'datasets');
checkEntries(idx.replications, 'replications');

// Resolution helper that skills rely on
function resolveDataset(shortId) {
  const e = idx.datasets[shortId];
  return e ? path.join(here, e.file) : null;
}
assert.ok(resolveDataset('charls') && fs.existsSync(resolveDataset('charls')), 'resolveDataset(charls) must point to an existing file');
assert.strictEqual(resolveDataset('nonexistent'), null, 'unknown dataset resolves to null');

console.log('index-resolve: all tests passed');
