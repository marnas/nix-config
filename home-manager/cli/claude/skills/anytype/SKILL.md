---
description: Manage tasks, notes, projects, and pages in the user's self-hosted Anytype space. Use whenever the user wants to capture, list, look up, update, complete, or delete a task / todo / note / reminder ("add a task…", "note that…", "remind me to…", "what's in Anytype", "mark X done", "what are my open tasks").
---

## Tool

Use the `any` command (installed on PATH). It wraps the local Anytype REST API and
targets the user's default space; credentials come from 1Password automatically.

```
any add <type> "<name>" ["<body>"]                 create (type: task | note | page | project | bookmark)
any ls [-t TYPE] [-q "text"] [--open|--done] [--json]   list / search
any get <id> [--json]                              full object (properties + markdown body)
any set <id> [--name N] [--done|--undone] [--due YYYY-MM-DD] [--status S]   # body is create-only
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
- **Find before you modify:** to act on an existing item, first `any ls -t task -q "passport"`
  (or `--open`) to get its id, then `any set <id> --done`.
- **Writing bodies:** plain markdown imports well (`##` headings, `- [ ]` checklists,
  `**bold**`, fenced ```code``` blocks, `>` callouts). Keep prose ASCII and put commands in
  fenced blocks — inline `code` spans mis-align on lines with auto-converted arrows (`->`→`→`).
  Body is set only at create time; to change a body, recreate the object.
- **Report back** the object name and what changed; entries sync to the user's desktop and
  phone automatically (no need to keep the GUI open).

## If it fails

- Connection refused / no response → the daemon is down. Check `systemctl --user status anytype-cli`
  and restart with `systemctl --user restart anytype-cli`.
- `401 invalid api key` → the API key in 1Password ("anytype-cli bot account" → API) is stale;
  regenerate with `anytype-cli auth apikey create <name>` and update the item.
