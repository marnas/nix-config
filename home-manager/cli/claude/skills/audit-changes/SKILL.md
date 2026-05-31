---
description: Review the current uncommitted changes and identify which were trial-and-error vs intentional. Flag candidates for git restore. Use when the user asks to clean up the working tree, review what they've changed, or wants to drop dead experiments before committing.
---

## Current state

- Status: !`git status --short`
- Full diff against HEAD: !`git diff HEAD`
- Recent commits (for direction context): !`git log -10 --oneline`

## Instructions

Walk through every hunk in the diff above. For each hunk, classify as one of:

- **Keep** — clearly aligns with the user's recent direction, finishes something started in an earlier commit, or is part of an obvious feature/fix.
- **Drop** — looks like a half-finished or abandoned trial: leftover debug prints, commented-out blocks, dead code paths, abandoned experiments not referenced by the rest of the change, generated output that shouldn't be committed.
- **Ask** — ambiguous; needs the user's judgement.

For each file, list its hunks under one of those buckets. For every "Drop" entry, give the **exact revert command** the user can run:
- Tracked file: `git restore -p <path>` (interactive) or `git restore <path>` (whole file).
- Untracked file: `rm <path>` or `git clean -i`.

**Do not run any destructive commands yourself.** Produce the list, let the user pick.

End with a one-line summary: `kept: N · drop: N · ask: N`.

If the working tree is clean, say so and stop.
