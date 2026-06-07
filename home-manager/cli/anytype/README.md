# Anytype `any` tooling

Declarative client tooling for the **self-hosted Anytype** backend (the any-sync
bundle runs on the home cluster; see `flux-config` repo, `apps/anytype`). This module
gives every machine a CLI to capture/manage objects in your Anytype space, plus the
always-on daemon that backs it.

## What this module provides

- **`any`** — a `writeShellApplication` (`./any.sh`) wrapping the Anytype Local REST API
  (`127.0.0.1:31012`). Verbs: `add | ls | get | set | rm | types`. Targets the space whose
  id is in 1Password (field `space_id`); `any --space <id> …` overrides per call. Reads
  credentials from 1Password at call time; `op` is inherited from PATH (the platform's
  wrapped binary), never bundled.
- **The daemon** — `anytype-cli serve`, run as a `systemd` user service on Linux and a
  `launchd` agent on macOS (same `serveArgs`, platform-guarded). It's the local-first
  node: writes objects locally, pushes them to the backend bundle, serves the REST API.

## Architecture (model A: one daemon per machine)

```
  Linux box                         Mac
  ┌──────────────┐                  ┌──────────────┐
  │ anytype-cli  │                  │ anytype-cli  │
  │  serve :31012│                  │  serve :31012│
  │   ^      |   │                  │   ^      |   │
  │  any     v   │                  │  any     v   │
  └──────────┼───┘                  └──────────┼───┘
             └────────► self-hosted ◄──────────┘
                       backend bundle
                  (always-on, on cluster)
```

Each machine runs its **own** daemon, logged into the **same** bot identity. They never
talk directly — they sync through the always-on backend, so any machine can be offline.
The localhost API is just that machine's on-ramp to its own node.

## Space model

One shared space is the norm; **Project** objects (the `project` type) are the in-space
split, and Tasks attach to them via the built-in `linked_projects` relation. A separate
space only earns its keep for rarely-needed hard-private material — and the bot is not a
member of such a space, so it stays out of reach by design. `any` targets one space
(`space_id` in 1Password); renaming that space in the desktop is cosmetic (the id is
stable), so the tooling is unaffected.

## Identity & keys

- **Bot identity** (one, shared): account key in 1Password → Private → `anytype-cli bot
  account`. Imported per-machine via `anytype-cli auth login`.
- **API key** (per-machine, node-local): stored in the same 1Password item's `API`
  section. `apikey` = Linux box; add `apikey_<host>` for each new machine.
- **Other API fields**: `base_url` (`http://127.0.0.1:31012`), `api_version`
  (`2025-11-08`), `space_id`.

## Self-hosted network config — the critical bit

`anytype-cli` only joins the self-hosted network if it finds the network config in its
config dir. **Without it, a fresh node joins Anytype's production network and never sees
your space.**

- File: `config.yaml` — `networkId` + the bundle's coordinator/sync/file node addresses
  (`anytype.taild03c2.ts.net`). Public (no private keys).
- Source: 1Password → kubernetes vault → `Anytype self-hosted — any-sync-bundle` (same
  content as the Linux box's `~/.config/anytype/config.yaml`).
- Path: Linux `~/.config/anytype/config.yaml`. macOS: **TODO confirm** (likely
  `~/Library/Application Support/anytype/config.yaml`).

## macOS first-run runbook

Prereqs: Mac on the tailnet (backend = `anytype.taild03c2.ts.net`), dotfiles flake applied.

1. **Apply the flake** → installs `anytype-cli`, `any`, and the launchd daemon.
2. **Drop in the network config** (see section above) so the daemon joins the self-hosted
   network.
3. **Restart the daemon** to load it: `launchctl kickstart -k gui/$(id -u)/anytype-cli`.
4. **Log in the bot**: `anytype-cli auth login` (account key from 1Password → Private).
   It connects to the self-hosted net and syncs your space.
5. **Create a Mac key**: `anytype-cli auth apikey create claude-macos` → store as
   `apikey_macos` in the 1Password item's `API` section.
6. **Point `any` at it**: first test whether the existing `apikey` is accepted on the Mac
   node. If yes, keys are shared (one field). If no, teach `any.sh` to pick the apikey
   field by `$(hostname)`.
7. **Verify**: `any add task "hello from mac"` → confirm it appears on the Linux box /
   desktop / iOS (proves sync through the backend).

Troubleshooting: connection refused → daemon down (`launchctl print gui/$(id -u)/anytype-cli`);
`401 invalid api key` → wrong/stale apikey field.

## Known API quirks (learned the hard way)

- **Body is create-only.** `POST /objects` sets the markdown body; `PATCH /objects/{id}`
  silently ignores `body` (only name/properties update). To change a body, recreate the
  object. `any set` therefore has no `--body`.
- **Markdown formatting:** write bodies in plain markdown — `##` headings, `- [ ]`
  checklists, `**bold**`, fenced ```code``` blocks, `>` callouts all import correctly.
  But Anytype's importer mis-aligns **inline `code` spans** when the same line contains
  multibyte chars (it auto-converts `->` to `→` and `...` to `…`, which shifts the byte
  offsets). Keep prose ASCII and put commands in fenced blocks, not inline code.
- **Select properties** (e.g. Task `status`) take the option's **tag id**, not its name —
  resolve via `GET /properties/{id}/tags`. `any set --status` does this case-insensitively.
- **`false` checkboxes are omitted** from search results, so absent `done` == open.
- **Bookmarks: URL goes in the `source` property, not the name.** Create with
  `properties:[{key:"source",url:"…"}]` (name left empty). The daemon then asynchronously
  fetches the page title (-> name) and description a second or two later. Putting the URL in
  the name leaves `source` empty -> a dead card, no metadata. `any add bookmark <url>` / `any
  bm <url>` handle this.
- **The source relation isn't clickable in this daemon's bookmark layout** (the title banner
  opens the link-to-object picker, not the URL; source isn't a featured relation). So `any bm`
  also writes the URL into the **body** as a markdown link `[url](url)` — that's the reliably
  clickable surface. Markdown links in a body render clickable; a bare URL stays plain text.
- **Object create is idempotent on (type + source) for bookmarks.** Re-POSTing an existing
  URL returns the *existing* object id and **ignores the new body** — it does not duplicate
  and does not update. Footgun: a create-then-`rm`-by-returned-id "recreate" will delete the
  original (the returned id == the original). To change a bookmark's body, `rm` first, *then*
  create.
- **Collection membership uses a different endpoint and body shape.** `POST
  /v1/spaces/{sid}/lists/{collection_id}/objects` with body `{"objects":["id",...]}` — a
  *bare* array 400s, and it must be `objects`/`data`-wrapped. Only Collections (manual lists);
  a Set is query-defined. The **GET** list-objects endpoint 404s on this daemon version, so
  membership can't be read back via the API — verify in the desktop. `any collect <coll> <id>…`
  and `any add … --collection <id>` wrap the POST.

## Open TODOs

- [ ] Confirm the macOS anytype-cli config dir path.
- [ ] Confirm whether one API key works across nodes (→ collapse to a single field) or is
      node-local (→ keep `apikey_<host>` + host-switch in `any.sh`).
