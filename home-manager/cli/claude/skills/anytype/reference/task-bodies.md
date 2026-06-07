# Writing task/object bodies

How to write a `body` so it stays scannable in the Anytype UI. The `name` is a short
headline; everything else lives here. Body is **create-only** — to change it, recreate the
object (new body, relink project, `rm` the old id).

## Formatting — structure over prose

Don't write walls of text; lean on Anytype's formatting:

- `##` headings to chunk it; lead each heading with one relevant emoji as an eye anchor
  (`## 📋 Steps`, `## ⚠️ Blocker`, `## 🔗 Links`, `## 📅 Deadline`, `## ✅ Done when`) —
  one icon per heading, not sprinkled through prose.
- `- [ ]` checklists for steps/criteria (in a `task` these double as a runbook — prefer them
  over paragraphs).
- `**bold**` for key terms; `>` callouts for the one thing that must not be missed.
- Fenced ```code``` blocks for commands / specs / aligned key–value.
- Keep prose to a sentence or two per section.

Keep text otherwise ASCII and put commands in fenced blocks — inline `code` spans mis-align on
lines with auto-converted arrows (`->` → `→`), and never put emoji inside a fenced block; so
don't mix inline code and arrows on the same line.

## Task body template — Goal / Steps / Done-when

Default shape for a non-trivial `task` (drop any section that doesn't earn its place — a
one-line task needs none of it):

- `## 🎯 Goal` — the outcome **and why**, 1–2 sentences. The only always-on section.
- `## 📋 Steps` — the runbook: `- [ ]` actions you perform (the *how*).
- `## ✅ Done when` — acceptance criteria: `- [ ]` **verifiable, observable** conditions that
  prove it worked (the *proof*). One condition per line, active voice, outcome not
  implementation, no "and/or". This is what lets you close with `--status "Done"` honestly.
- Optional, only when real: `## 🧭 Decisions` (the why-not trail), `## ⚠️ Blocker`,
  `## 🔗 Links` / depends-on.

**Steps ≠ Done-when:** steps are actions to take; Done-when are conditions to verify — all steps
ticked does not mean the goal is met. Goal and Done-when overlap only for trivial tasks (then
keep just the Goal); don't restate one as the other.

## Definition of Done — applies to every task, never repeated in a body

A task is only Done when, as relevant: changes committed + pushed; cluster synced /
`home-manager` switched; no plaintext secrets (1Password / Infisical only); `CLAUDE.md` or docs
updated if behaviour or a convention changed; and it's closed with `--status "Done"` reflecting
reality.
