# data/raw protection: OS-level lock + node hook, honest about the gap

Status: accepted (2026-06-13)

`1.rawdata/` is protected primarily at the **operating-system level** by `research-harness-setup`, applied **after** the researcher has placed raw data into the folder (locking an empty folder protects nothing):

- Windows: `icacls 1.rawdata /deny "%USERNAME%:(OI)(CI)(WD,AD,DC,DE)" /T` — `(OI)(CI)` makes the deny-ACE inheritable to existing and future files/subdirs, `/T` applies recursively, and `WD,AD,DC,DE` denies write-data, append-data, delete-child, and delete (so existing raw files cannot be edited, appended, deleted, or replaced) **while leaving read intact** — the harness must still read raw data. (On Git Bash, invoke through cmd to avoid `/`-flag mangling: `cmd.exe /c 'icacls 1.rawdata /deny "%USERNAME%:(OI)(CI)(WD,AD,DC,DE)" /T'`. Unlock for maintenance with `icacls 1.rawdata /reset /T`.)
  - **Empirically verified on Windows (2026-06-13):** this exact ACE blocks new-file/append/nested-write/delete yet preserves `cat`. An earlier `(W,D,DC)` form was rejected — dropping the object-level Delete (`DE`) lets `rm` bypass the parent's delete-child (`DC`) and delete the file directly, so `DE` is required.
- Unix: `chmod -R a-w 1.rawdata/`.

Setup then runs a **self-test** that attempts to write/edit/delete (a) the directory, (b) an existing raw file, and (c) a nested file; if any attempt **succeeds**, setup fails loud and refuses to report the data as protected — never silently downgrading the guarantee to convention. The self-test **also confirms that reading an existing raw file still succeeds** — a lock that blocks reads is itself a misconfiguration (the harness must read raw data), and is reported as failure just like a writable lock. A secondary PreToolUse **node** hook denies `Write`/`Edit`/`git add` that target the raw-data path. The documentation states plainly that a `Bash`-invoked script (R/Stata/Python) writing to raw data **cannot be reliably intercepted by a hook** — that gap is closed only by the OS lock, and if the OS lock fails the protection degrades to the convention layer.

Recorded because the obvious-looking choice (a bash PreToolUse hook that "blocks writes to raw data") is the *wrong* one here: it does not fire on native Windows (`/bin/bash` absent) and cannot parse arbitrary Bash to know a script writes raw data. Claiming it as enforcement would be a false guarantee — itself an integrity violation. Hooks are therefore written in **node** (Claude Code ships it, cross-platform), and the real teeth are the OS lock.

Considered and rejected: `attrib +R` on Windows (file-level only, leaves new files unprotected, scripts can clear it); bash hooks (don't run on native Windows). See [CONTEXT.md](../../CONTEXT.md) term **Guardrail**.
