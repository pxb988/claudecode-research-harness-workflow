const assert = require('assert');
const { decide } = require('../guard-raw-data.js');

// 1) 拦截写入 1.rawdata
let r = decide({ tool_name: 'Write', tool_input: { file_path: 'proj/1.rawdata/households.csv' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny Write to 1.rawdata');

// 2) 放行写入 2.workdata
r = decide({ tool_name: 'Write', tool_input: { file_path: '2.workdata/clean.csv' } });
assert.strictEqual(r, null, 'should allow Write to 2.workdata');

// 3) Windows 反斜杠路径也拦
r = decide({ tool_name: 'Edit', tool_input: { file_path: 'C:\\proj\\1.rawdata\\x.dta' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny windows backslash path');

// 4) 非写工具忽略
r = decide({ tool_name: 'Read', tool_input: { file_path: '1.rawdata/x.csv' } });
assert.strictEqual(r, null, 'should ignore Read');

// 5) 兼容旧布局 data/raw/ 也拦(过渡期)
r = decide({ tool_name: 'Write', tool_input: { file_path: 'data/raw/x.csv' } });
assert.ok(r && r.hookSpecificOutput.permissionDecision === 'deny', 'should deny legacy data/raw too');

// 6) examples 下的合成 fixture 可写(MIN-5:与 guard-git-add 豁免对称)
r = decide({ tool_name: 'Write', tool_input: { file_path: 'examples/basic-data-cleaning/1.rawdata/households.csv' } });
assert.strictEqual(r, null, 'MIN-5: writing example synthetic fixtures must be allowed');

// 7) examples 旧布局 data/raw 也豁免(迁移过渡期)
r = decide({ tool_name: 'Edit', tool_input: { file_path: 'examples/econometrics-replication/data/raw/panel.csv' } });
assert.strictEqual(r, null, 'MIN-5: legacy example data/raw also exempt');

// 8) deny 文案自包含,不引用用户项目里不存在的文件路径(MIN-1)
r = decide({ tool_name: 'Write', tool_input: { file_path: '1.rawdata/x.csv' } });
assert.ok(r && !/docs\/INTEGRITY-RULES\.md/.test(r.hookSpecificOutput.permissionDecisionReason), 'MIN-1: deny reason must be self-contained');

console.log('guard-raw-data: all tests passed');
