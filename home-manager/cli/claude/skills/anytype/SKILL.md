---
description: Manage tasks, notes, bookmarks, projects, and pages in the user's self-hosted Anytype space. Use whenever the user wants to capture, list, look up, update, complete, or delete a task / todo / note / reminder / bookmark ("add a task…", "note that…", "remind me to…", "save/bookmark this link", "what's in Anytype", "mark X done", "what are my open tasks").
---

## Tool

Use the `any` command (installed on PATH). It calls the self-hosted Anytype REST API — served
by one central `anytype-cli serve` bot node in the cluster, reached over the tailnet at
`https://api.anytype.marnas.sh` (no per-machine daemon) — and targets the user's default space.
It fetches the API key (+ space id / api version) from the self-hosted Infisical at call time
via `infisical-token`, so there's no per-call 1Password prompt.

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
`get`/`set`/`rm`. `--status` accepts To Do / In Progress / Done and `--priority` accepts
High / Medium / Low (both case-insensitive, both single-select on the Task type).
Add `--json` when you need to parse fields precisely. **`--done` and `--status` are separate
fields, and a closed task needs both** — `--status` sets the select shown on the task (To Do /
In Progress / Done); `--done` ticks the checkbox that `ls`/list views render as `[x]`. Close a
task with both in one call (`any set <id> --status "Done" --done`): `--status "Done"` alone
leaves the list checkbox `[ ]`, so the task still reads as open at a glance.

## How to use it

- **Capture:** pick a type (`task` for actionable todos/reminders, `page` for any free-form
  or longer document, `bookmark` for links, `project` to group related work). **The name is a
  short, scannable headline — not the whole item.** Keep it to a few words that read cleanly in
  a list (`Renew passport`), and push *all* the detail — context, steps, deadlines, links,
  acceptance criteria — into the **body** (formatting + the task template:
  [reference/task-bodies.md](reference/task-bodies.md)). Don't bolt context onto the name; even
  a single line of it belongs in the body:
  `any add task "Renew passport" "Expires end of July. Need old passport + 2 photos."` **Use
  `page`, not `note`,
  for free-form content** — the `note` type is title-less (its API `name` is ignored and gets
  mangled into the body's first line), so it's hostile to CLI capture; `page` has a real name +
  body. Reserve `note` for nothing here.
- **Always file it under a project.** Anything you add should belong to a project so the
  space stays organised. Before creating, run `any ls -t project` and pick the project the
  item clearly belongs to (e.g. cluster/Flux work → Homelab; NixOS/macOS dotfiles work →
  Dotfiles). `add` can't link at create time, so link right after:
  `any set <new-id> --project <project-id>`. If nothing fits, ask the user whether to use an
  existing project or create a new one (`any add project "<Name>" "<one-line scope>"`) rather
  than leaving it unfiled. Items can carry more than one project — repeat `--project`.
- **Styling — every project gets an emoji icon; tracking lives *in* the project.** Give each
  project a relevant icon with `any set <id> --icon 🖥️` so the list reads at a glance and new
  projects match the set (current: Homelab 🖥️ · Dotfiles ❄️ · Home 🏡 · Personal 🌱). When you
  create a project, icon it in the same breath. **Don't** icon individual tasks — they inherit
  the Task **type**'s icon, which is the consistent baseline; a per-task emoji just breaks the
  uniform look. There is no separate tracking board or collection: to see a project's work, open
  the project and read its linked tasks (the `linked_projects` backlinks) — keep it that simple.
- **Links are bookmarks, never tasks.** A bare URL to read/triage later is NOT a todo —
  capturing it as a `task` ("Check https://…") clutters the open-task list with non-actions.
  Use `any bm <url>` instead: the URL goes in the `source` property (the bot node asynchronously
  fetches the page title + description — name is empty for a moment, then fills in) and also
  into the body as a clickable `[url](url)` link (the source relation isn't clickable in the
  current desktop bookmark layout, so the body link is how you open the page on desktop;
  mobile opens the source directly). No collection needed — the auto-generated Bookmark
  **type view** already lists every bookmark with zero upkeep; only use `--collection` for a
  hand-curated subset. Only make it a task if there's a real action ("read X and decide
  whether to adopt it"), and even then link the bookmark for the source.
- **Find before you modify:** to act on an existing item, first `any ls -t task -q "passport"`
  (or `--open`) to get its id, then `any set <id> --status "Done"`.
- **Keep status in sync while working a task.** New tasks are created as **To Do**
  automatically (`any add` sets it), so a task never sits blank/statusless. If you pick up a
  task from here and start acting on it, immediately mark it `any set <id> --status "In Progress"`. When you finish the
  work, close it out with **both fields** — `any set <id> --status "Done" --done` (see the Tool
  note above for why both are needed) — and report what you did. Never leave a
  task you've worked silently To Do or In Progress — the status must reflect reality so the
  user isn't misled about what's still outstanding. If you only partially complete it, leave it
  In Progress and say so.
- **Set a priority on every task.** Pass `--priority High|Medium|Low` when you `add` a task.
  If the user states a level, use it; otherwise **infer it from the task's content** — weigh
  impact (what breaks / who's blocked if it slips) and urgency (deadline, security exposure):
  e.g. a leaked-secret rotation or a hard deadline is High, routine cleanup/nice-to-have is Low,
  the rest Medium. Don't ask just to set it — make the call and say which you chose. Revise later
  with `any set <id> --priority <level>` when the picture changes.
- **Writing bodies — read [reference/task-bodies.md](reference/task-bodies.md)** before
  composing any non-trivial body. It covers the formatting rules (`##` headings with emoji
  anchors, `- [ ]` checklists, the ASCII/arrow caveat), the Goal/Steps/Done-when task template,
  and the global Definition of Done. Bodies are **create-only** — to change one, recreate the
  object (new body, relink its project, then `rm` the old id).
- **Report back** the object name and what changed; entries sync to the user's desktop and
  phone automatically (no need to keep the GUI open).

## If it fails

- Connection refused / no response / DNS failure → the central bot node is unreachable. The API
  is tailnet-only at `api.anytype.marnas.sh`, so first confirm this machine is on the tailnet;
  then check the cluster node: `kubectl -n anytype get pods -l app=anytype-cli` and its logs.
- `401 invalid api key` → the API key is stale; regenerate with `anytype-cli auth apikey create
  <name>` and update the `ANYTYPE_APIKEY` secret in Infisical (project `claude`, path `/anytype`).
- Infisical/auth errors (e.g. `Project ID is required`, empty token) → the bootstrap is off:
  check the `infisical-claude` 1Password item has `client_id` / `client_secret` / `project_id`,
  then `infisical-token --refresh`.
- `task type has no 'priority' property` → the Priority field isn't on the space yet (e.g. a
  fresh space). Run the one-time `any init-priority` to create it (High/Medium/Low) and attach
  it to the Task type; it's idempotent.
