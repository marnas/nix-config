---
description: Manage tasks, notes, bookmarks, projects, and pages in the user's self-hosted Anytype space. Use whenever the user wants to capture, list, look up, update, complete, or delete a task / todo / note / reminder / bookmark ("add a task…", "note that…", "remind me to…", "save/bookmark this link", "what's in Anytype", "mark X done", "what are my open tasks").
---

## Tool

Use the `any` command (installed on PATH). It wraps the local Anytype REST API and
targets the user's default space; credentials come from 1Password automatically.

```
any add <type> "<name>" ["<body>"] [--collection ID]   create (type: task | note | page | project | bookmark)
any bm <url> ["<name>"] [--collection ID]          capture a link as a bookmark (url -> source; title/desc auto-fetched)
any collect <collection-id> <object-id>...         add existing object(s) to a collection
any ls [-t TYPE] [-q "text"] [--open|--done] [--json]   list / search
any get <id> [--json]                              full object (properties + markdown body)
any set <id> [--name N] [--done|--undone] [--due YYYY-MM-DD] [--status S]   # body is create-only
any set <id> [--project <project-id> ...] [--unlink-projects]   # link/clear Linked Projects
any rm <id>                                         delete
any types                                           list available type keys
any --space <id> <verb> ...                         operate on a different space
```

`ls`/`get` print tab-separated rows starting with the object **id** — use that id for
`get`/`set`/`rm`. `--status` accepts To Do / In Progress / Done (case-insensitive).
Add `--json` when you need to parse fields precisely.

## How to use it

- **Capture:** pick a type (`task` for actionable todos/reminders, `note` for free-form,
  `page` for longer docs, `project` to group related work) and a concise name; put extra
  detail in the body. e.g. `any add task "Renew passport" "expires end of July"`.
- **Always file it under a project.** Anything you add should belong to a project so the
  space stays organised. Before creating, run `any ls -t project` and pick the project the
  item clearly belongs to (e.g. cluster/Flux work → Homelab; NixOS/macOS dotfiles work →
  Dotfiles). `add` can't link at create time, so link right after:
  `any set <new-id> --project <project-id>`. If nothing fits, ask the user whether to use an
  existing project or create a new one (`any add project "<Name>" "<one-line scope>"`) rather
  than leaving it unfiled. Items can carry more than one project — repeat `--project`.
- **Links are bookmarks, never tasks.** A bare URL to read/triage later is NOT a todo —
  capturing it as a `task` ("Check https://…") clutters the open-task list with non-actions.
  Use `any bm <url>` instead: the URL goes in the `source` property (daemon asynchronously
  fetches the page title + description — name is empty for a moment, then fills in) and also
  into the body as a clickable `[url](url)` link (the source relation itself isn't clickable
  in the current bookmark layout, so the body link is how you actually open the page).
  File bookmarks in the **Bookmarks collection** (a Collection, not a project):
  `any bm <url> --collection <bookmarks-collection-id>`. Resolve the id once with
  `any ls -t collection -q Bookmarks`. Only make it a task if there's a real action ("read X
  and decide whether to adopt it"), and even then link the bookmark for the source.
- **Find before you modify:** to act on an existing item, first `any ls -t task -q "passport"`
  (or `--open`) to get its id, then `any set <id> --done`.
- **Keep status in sync while working a task.** If you pick up a task from here and start
  acting on it, immediately mark it `any set <id> --status "In Progress"`. When you finish the
  work, close it out with `any set <id> --done` (and report what you did). Never leave a task
  you've worked silently To Do or In Progress — the status must reflect reality so the user
  isn't misled about what's still outstanding. If you only partially complete it, leave it
  In Progress and say so.
- **Writing bodies — favor structure over prose.** Don't write walls of text; lean on
  Anytype's formatting so a body stays scannable at a glance: `##` headings to chunk it,
  `- [ ]` checklists for steps/criteria (in a `task` these double as a runbook — prefer them
  over paragraphs), `**bold**` for key terms, fenced ```code``` blocks for commands / specs /
  aligned key–value, `>` callouts for the one thing that must not be missed (a blocker, status,
  warning). Keep prose to a sentence or two per section. Keep text ASCII and put commands in
  fenced blocks — inline `code` spans mis-align on lines with auto-converted arrows (`->`→`→`),
  so don't mix inline code and arrows on the same line.
- **Editing a body:** it's set only at create time. To change it, recreate the object — create
  the replacement (with the improved body), relink its project, then `rm` the old id.
- **Report back** the object name and what changed; entries sync to the user's desktop and
  phone automatically (no need to keep the GUI open).

## If it fails

- Connection refused / no response → the daemon is down. Check `systemctl --user status anytype-cli`
  and restart with `systemctl --user restart anytype-cli`.
- `401 invalid api key` → the API key in 1Password ("anytype-cli bot account" → API) is stale;
  regenerate with `anytype-cli auth apikey create <name>` and update the item.
