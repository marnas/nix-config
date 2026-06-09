---
description: Manage tasks, notes, bookmarks, projects, and pages in the user's self-hosted Anytype space. Use whenever the user wants to capture, list, look up, update, complete, or delete a task / todo / note / reminder / bookmark ("add a task…", "note that…", "remind me to…", "save/bookmark this link", "what's in Anytype", "mark X done", "what are my open tasks").
---

## Tool

Use the `any` command (installed on PATH). It calls the self-hosted Anytype REST API — one
central bot node, reached over the tailnet at `https://api.anytype.marnas.sh` — and targets the
user's default space. Credentials come from the self-hosted Infisical at call time via
`infisical-token`, so there's no per-call 1Password prompt.

```
any add <type> "<name>" ["<body>"] [--collection ID] [--priority P]   create (type: task | note | page | project | bookmark)
any bm <url> ["<name>"] [--collection ID]          capture a link as a bookmark (url -> source; title/desc auto-fetched)
any collect <collection-id> <object-id>...         add existing object(s) to a collection
any ls [-t TYPE] [-q "text"] [--open|--done] [--json]   list / search
any get <id> [--json]                              full object (properties + markdown body)
any set <id> [--name N] [--icon EMOJI] [--done|--undone] [--due YYYY-MM-DD] [--status S] [--priority P]   # body is create-only
any set <id> [--project <project-id> ...] [--unlink-projects]   # link/clear Linked Projects
any rm <id>                                         delete
any types                                           list available type keys
any --space <id> <verb> ...                         operate on a different space
```

`ls`/`get` print tab-separated rows starting with the object **id** — use that id for
`get`/`set`/`rm`; add `--json` to parse fields precisely. `--status` accepts To Do / In
Progress / Done and `--priority` accepts High / Medium / Low (both case-insensitive).

## Rules

- **Names are headlines.** A few scannable words (`Renew passport`); *all* detail — context,
  steps, deadlines, links — goes in the **body**. Use `page`, never `note`, for free-form
  content (the `note` type is title-less and mangles the name into the body — hostile to CLI
  capture).
- **Always file it under a project.** Before creating, `any ls -t project` and pick the fit
  (cluster/Flux → Homelab; dotfiles → Dotfiles). `add` can't link at create time, so link right
  after: `any set <new-id> --project <project-id>` (repeat `--project` for several). If nothing
  fits, ask the user rather than leaving it unfiled.
- **Links are bookmarks, never tasks** — capture with `any bm <url>`. When a task is warranted
  anyway, plus project icon/styling rules and how to infer priorities, see
  [reference/conventions.md](reference/conventions.md).
- **Find before you modify:** `any ls -t task -q "passport"` (or `--open`) to get the id, then
  `any set <id> …`.
- **Keep status real.** `add` creates tasks as To Do. Pick one up → `any set <id> --status
  "In Progress"` immediately. Finished → close with **both fields in one call**:
  `any set <id> --status "Done" --done` (`--status` sets the select; `--done` ticks the
  checkbox list views render — one without the other reads wrong). Partially done → leave In
  Progress and say so. Never leave a task you worked on silently stale.
- **Set a priority on every task** at `add` time (`--priority High|Medium|Low`): the user's
  word if given, else infer per [reference/conventions.md](reference/conventions.md) and say
  which you chose.
- **Bodies:** read [reference/task-bodies.md](reference/task-bodies.md) before composing any
  non-trivial body — formatting rules, the Goal/Steps/Done-when template, and the Definition of
  Done. Bodies are **create-only**: to change one, recreate the object (new body, relink its
  project, then `rm` the old id).
- **Report back** the object name and what changed; entries sync to desktop and phone
  automatically.

## If it fails

See [reference/troubleshooting.md](reference/troubleshooting.md) — unreachable bot node, stale
API key (401), Infisical bootstrap errors, missing Priority property.
