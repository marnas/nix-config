---
description: Stage all changes, write a single-line commit, and push to the remote.
disable-model-invocation: true
---

## Context

- Status: !`git status --short`
- Diff against HEAD: !`git diff HEAD`
- Recent commits (for subject style): !`git log -5 --oneline`
- Current branch: !`git branch --show-current`

## Instructions

1. If the working tree is clean, report "nothing to commit" and stop.

2. **Sensitive-file scan.** Before staging, check the change set for anything that looks like a secret or accident: `.env*`, files matching `*password*` / `*credential*` / `*secret*` / `*.pem` / `*.key`, or unexpected binaries (large blobs, build artifacts that aren't normally tracked). If any are found, **stop and surface them to the user** — do not stage until they confirm.

3. **Stage explicitly.** Use `git add <path1> <path2> ...` listing each file by name. Don't use `git add -A` / `git add .` — keep the staged set visible.

4. **Draft the subject line.** Follow the commit style defined in `~/.claude/CLAUDE.md` (conventional commits: `<type>(<scope>): <subject>`, single line, ≤72 chars, no body, no `Co-Authored-By` trailer). Focus on the *why* / the change, not a file list.

5. **Commit** with `git commit -m "<subject>"`. Pass the message via `-m`; don't open an editor.

6. **Push.** Try `git push`. If it fails because the branch has no upstream, fall back to `git push -u origin <current-branch>`.

7. **Report.** Show the resulting commit hash (`git rev-parse --short HEAD`) and the push outcome.

If any step fails, stop and surface the error; do not retry blindly.
