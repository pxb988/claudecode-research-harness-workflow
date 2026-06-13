const assert = require('assert');
const { decide } = require('../guard-git-add.js');

// 1) 拦 git add 的 csv
let r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 2.workdata/clean.csv' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny add csv');

// 2) 拦 .dta / .parquet
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add panel.dta' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny add dta');

// 3) 拦 protected dir
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 1.rawdata/' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny add 1.rawdata dir');

// 4) 拦 codebook
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 3.outdata/data/codebook.txt' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny add codebook');

// 5) 放行 add 脚本/报告
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 0.dofiles/clean.R 4.reports/audit.md' } });
assert.strictEqual(r, null, 'should allow add script + report');

// 6) 非 git add 忽略
r = decide({ tool_name: 'Bash', tool_input: { command: 'ls data.csv' } });
assert.strictEqual(r, null, 'should ignore non git-add');

// 7) 放行 examples 合成 fixture
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add examples/basic-data-cleaning/data/raw/households.csv' } });
assert.strictEqual(r, null, 'should allow committing synthetic examples fixture');

// 8) examples 路径若混入 canonical 数据目录,仍整体拦截
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add examples/x.md 1.rawdata/secret.csv' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'canonical data dir always wins');

// 9) 放行结果表 3.outdata/tables/*.csv(MAJ-5:release 复现包需要)
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 3.outdata/tables/table1.csv' } });
assert.strictEqual(r, null, 'MAJ-5: result tables under 3.outdata/tables/ must be allowed');

// 10) 放行图 3.outdata/figures/
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 3.outdata/figures/fig1.csv' } });
assert.strictEqual(r, null, 'figures dir csv must be allowed');

// 11) 但分析就绪数据 3.outdata/data/ 仍强拦
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 3.outdata/data/analysis_ready.csv' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', '3.outdata/data must still be denied');

// 12) codebook 即使落在 tables/ 也拦(变量级元数据不外泄)
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 3.outdata/tables/codebook.csv' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'codebook always denied');

// 13) examples 迁 canonical 后,其合成 fixture 在 1.rawdata/ 下也必须可提交(BLK-A2)
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add examples/basic-data-cleaning/1.rawdata/households.csv' } });
assert.strictEqual(r, null, 'BLK-A2: example fixture under examples/.../1.rawdata/ must be committable');

console.log('guard-git-add: all tests passed');
