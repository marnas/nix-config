# Conventions: icons, bookmarks, priorities

## Project icons & styling

Every project gets a relevant emoji icon (`any set <id> --icon 🖥️`) so the list reads at a
glance and new projects match the set (current: Homelab 🖥️ · Dotfiles ❄️ · Home 🏡 ·
Personal 🌱). When you create a project, icon it in the same breath. **Don't** icon individual
tasks — they inherit the Task **type**'s icon, which is the consistent baseline; a per-task
emoji just breaks the uniform look. There is no separate tracking board or collection: to see
a project's work, open the project and read its linked tasks (the `linked_projects`
backlinks) — keep it that simple.

## Bookmarks vs tasks

A bare URL to read/triage later is NOT a todo — capturing it as a `task` ("Check https://…")
clutters the open-task list with non-actions. `any bm <url>` puts the URL in the `source`
property (the bot node asynchronously fetches the page title + description — name is empty for
a moment, then fills in) and also into the body as a clickable `[url](url)` link (the source
relation isn't clickable in the current desktop bookmark layout, so the body link is how you
open the page on desktop; mobile opens the source directly). No collection needed — the
auto-generated Bookmark **type view** already lists every bookmark with zero upkeep; only use
`--collection` for a hand-curated subset. Only make it a task if there's a real action ("read
X and decide whether to adopt it"), and even then link the bookmark for the source.

## Inferring priority

If the user states a level, use it; otherwise infer it from the task's content — weigh impact
(what breaks / who's blocked if it slips) and urgency (deadline, security exposure): e.g. a
leaked-secret rotation or a hard deadline is High, routine cleanup/nice-to-have is Low, the
rest Medium. Don't ask just to set it — make the call and say which you chose. Revise later
with `any set <id> --priority <level>` when the picture changes.
