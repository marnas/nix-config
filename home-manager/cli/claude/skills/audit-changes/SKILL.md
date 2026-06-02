---
description: Audit every change in the current git diff (staged and unstaged) so the user can confidently commit. Walk through each hunk, explain what it does, and flag anything that looks unintentional. Use when the user wants to review the working tree before committing, validate what's staged, or clean up dead experiments.
---

## Current state

- Status: !`git status --short`
- Unstaged diff (working tree vs index): !`git diff`
- Staged diff (index vs HEAD): !`git diff --cached`
- Untracked file list: !`git ls-files --others --exclude-standard`
- Recent commits (for direction context): !`git log -10 --oneline`

## Instructions

Audit **every** change shown above — staged, unstaged, and untracked. The goal is for the user to know exactly what would land if they committed right now, with anything questionable surfaced before it goes in.

Walk through the changes file by file. For each file, cover both its staged and unstaged hunks (call out which is which when it matters — e.g. a file that's partially staged). For each hunk, write a one-line description of what it actually does, then classify it:

- **Keep** — intentional, aligns with the user's recent direction, or finishes something started in an earlier commit. Still describe what it does so the user can confirm.
- **Drop** — looks unintentional: leftover debug prints, commented-out blocks, dead code, abandoned experiments not referenced by the rest of the change, generated/build output that shouldn't be committed, stray whitespace-only edits, accidental reverts of prior work.
- **Ask** — ambiguous or surprising; needs the user's judgement. Anything that touches an unrelated area, changes public API, or doesn't have an obvious motivation goes here.

For untracked files, decide whether they look like intended new files (Keep), build/editor cruft (Drop), or unclear (Ask).

For every **Drop** entry, give the exact command:
- Unstaged change in tracked file: `git restore <path>` (whole file) or `git restore -p <path>` (interactive).
- Staged change: `git restore --staged <path>` to unstage, then `git restore <path>` to discard.
- Untracked file: `rm <path>` or `git clean -i`.

Also flag if anything is **staged but doesn't belong in the next commit's scope** — e.g. the user clearly staged for one logical change but an unrelated hunk slipped in. Suggest `git restore --staged <path>` to pull it back.

**Do not run any destructive commands yourself.** Produce the audit; let the user act.

End with a one-line summary: `staged: N files · unstaged: N files · untracked: N · keep: N · drop: N · ask: N`.

If the working tree is clean and nothing is staged, say so and stop.
