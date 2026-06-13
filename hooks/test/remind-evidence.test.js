const assert = require('assert');
const { decide } = require('../remind-evidence.js');

// 1) Rscript 无日志重定向 → 提醒
let r = decide({ tool_name: 'Bash', tool_input: { command: 'Rscript 0.dofiles/clean.R' } });
assert.ok(r && r.hookSpecificOutput.additionalContext, 'should remind when Rscript has no log');

// 2) 有 sink( → 不提醒(脚本内已写日志)
r = decide({ tool_name: 'Bash', tool_input: { command: 'Rscript 0.dofiles/clean.R  # uses sink()' } });
assert.strictEqual(r, null, 'should not remind when sink() present');

// 3) 有重定向到 logs/ 文件 → 不提醒
r = decide({ tool_name: 'Bash', tool_input: { command: 'python 0.dofiles/run.py > 0.dofiles/logs/run.log 2>&1' } });
assert.strictEqual(r, null, 'should not remind when redirected to a log file');

// 4) 裸 2>&1 但无文件重定向 → 仍提醒(MAJ-7 负测)
r = decide({ tool_name: 'Bash', tool_input: { command: 'python 0.dofiles/run.py 2>&1' } });
assert.ok(r && r.hookSpecificOutput.additionalContext, 'bare 2>&1 without a file must still remind');

// 5) 非脚本运行命令忽略
r = decide({ tool_name: 'Bash', tool_input: { command: 'ls 0.dofiles/' } });
assert.strictEqual(r, null, 'should ignore non-run command');

// 6) git add 一个 .py 文件名 → 不是运行脚本,绝不提醒(MAJ-1 回归)
r = decide({ tool_name: 'Bash', tool_input: { command: 'git add 0.dofiles/analysis.py' } });
assert.strictEqual(r, null, 'MAJ-1: ".py" filename must not trigger a run reminder');

// 7) py 启动器(Windows)真运行脚本且无日志 → 仍要提醒
r = decide({ tool_name: 'Bash', tool_input: { command: 'py 0.dofiles/run.py' } });
assert.ok(r && r.hookSpecificOutput.additionalContext, 'py launcher running a script must still remind');

// 8) git commit/add 命令里引号内提到 python 等 → 不是运行脚本,不提醒(adversarial review)
r = decide({ tool_name: 'Bash', tool_input: { command: 'git commit -m "ran python clean.R, saved log"' } });
assert.strictEqual(r, null, 'a git command mentioning an interpreter in its message must not remind');

console.log('remind-evidence: all tests passed');
