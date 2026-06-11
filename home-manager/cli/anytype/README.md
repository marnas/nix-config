# Anytype `any` tooling

Declarative client tooling for the **self-hosted Anytype** backend. The CLI talks to a
single **central `anytype-cli serve` bot node running in the home cluster** (see the
`flux-config` repo, `apps/anytype/cli/` + `apps/anytype/SETUP.md`). This module just ships the
`any` wrapper every machine uses to capture/manage objects in the Anytype space.

## What this module provides

- **`any`** — a `writeShellApplication` (`./any.sh`) over the Anytype REST API. Verbs:
  `add | bm | collect | ls | get | set | rm | types | init-priority`. Targets the space whose
  id is in Infisical (`ANYTYPE_SPACE_ID`); `any --space <id> …` overrides per call.

That's the whole module — **no daemon, no `anytype-cli` on the workstation**. The REST API is
served centrally; `any` is just `curl`/`jq` against it.

## Architecture (one central bot node)

Earlier each machine ran its own `anytype-cli serve` (systemd on Linux, launchd on macOS) on
`127.0.0.1:31012` and synced through the backend ("model A"). That's gone — it was high-friction
to set up per machine and the daemons timed out reaching the backend. Now a single node in the
cluster serves the REST API for everyone:

```
   nixos              macOS              … any tailnet device
    │ any               │ any
    └────────┬──────────┘
             ▼  HTTPS — api.anytype.marnas.sh   (tailnet-only Traefik ingress)
   ┌──────────────────────────────┐
   │ anytype-cli serve  :31012     │   cluster pod (apps/anytype/cli)
   │ bot account "claude" (editor) │   member of the space
   └───────────────┬──────────────┘
                   ▼  any-sync, in-cluster (anytype-bundle ClusterIP)
            self-hosted backend bundle  (apps/anytype)
```

`any` → tailnet → ingress → bot node → backend. **Online-only**: there's no local node, so `any`
needs the tailnet reachable. (Desktop/iOS keep their own local-first copies and sync independently,
so they still work offline.)

## Authentication

Two layers, no per-machine identity (full detail in `apps/anytype/SETUP.md`):

1. **Network** — `api.anytype.marnas.sh` resolves only on the tailnet, so tailnet membership is
   the gate; the public Let's Encrypt cert just provides TLS.
2. **API** — a bearer apikey. `any.sh` sends `Authorization: Bearer <ANYTYPE_APIKEY>` (+
   `Anytype-Version`). The key, `ANYTYPE_SPACE_ID`, and `ANYTYPE_API_VERSION` are pulled from
   self-hosted Infisical (project `claude`, path `/anytype`) at call time via a short-lived
   machine-identity token from `infisical-token` (whose creds come from 1Password via the
   platform-wrapped `op`), then discarded. Nothing secret lands on disk and there's no per-call
   1Password prompt.

## Identity & keys (all server-side now)

- **Bot account** — one account named **claude**, a member (editor) of the space. Its account
  key and the in-cluster network config live in 1Password → kubernetes vault → item
  `anytype-cli` (`ACCOUNT_KEY` / `CLIENT_CONFIG`), synced into the cluster as a Secret.
- **API key** — one key minted on the node (`anytype auth apikey create claude`), stored in
  Infisical as `ANYTYPE_APIKEY`. It's the node's key, shared by every machine — not per-host.

To rotate the apikey: `kubectl -n anytype exec deploy/anytype-cli -- anytype auth apikey create
<name>`, then update `ANYTYPE_APIKEY` in Infisical.

## Space model

One shared space is the norm; **Project** objects (the `project` type) are the in-space split,
and Tasks attach to them via the built-in `linked_projects` relation. A separate space only earns
its keep for rarely-needed hard-private material — and the bot is not a member of such a space, so
it stays out of reach by design. `any` targets one space (`ANYTYPE_SPACE_ID`); renaming that space
in the desktop is cosmetic (the id is stable), so the tooling is unaffected.

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
  `properties:[{key:"source",url:"…"}]` (name left empty). The bot node then asynchronously
  fetches the page title (-> name) and description a second or two later. Putting the URL in
  the name leaves `source` empty -> a dead card, no metadata. `any add bookmark <url>` / `any
  bm <url>` handle this.
- **The source relation isn't clickable in the bookmark layout** (the title banner opens the
  link-to-object picker, not the URL; source isn't a featured relation). So `any bm` also writes
  the URL into the **body** as a markdown link `[url](url)` — that's the reliably clickable
  surface. Markdown links in a body render clickable; a bare URL stays plain text.
- **Object create is idempotent on (type + source) for bookmarks.** Re-POSTing an existing
  URL returns the *existing* object id and **ignores the new body** — it does not duplicate
  and does not update. Footgun: a create-then-`rm`-by-returned-id "recreate" will delete the
  original (the returned id == the original). To change a bookmark's body, `rm` first, *then*
  create.
- **REST `create` ignores the type's default template.** The desktop applies a type's
  default template on create (so layout-width and other template defaults carry over); the
  REST `POST /objects` does not — objects come out with the built-in narrow layout. Pass
  `template_id` in the create body to match desktop behaviour. The default template is the
  type's **blank** template (empty `name`) returned by `GET /types/{id}/templates`; that's
  the one whose layout-width slider you edit to set a type-wide width. `any add` auto-resolves
  and applies it; `--template ID` overrides, `--template ""` opts out.
- **Collection membership uses a different endpoint and body shape.** `POST
  /v1/spaces/{sid}/lists/{collection_id}/objects` with body `{"objects":["id",...]}` — a
  *bare* array 400s, and it must be `objects`/`data`-wrapped. Only Collections (manual lists);
  a Set is query-defined. The **GET** list-objects endpoint 404s on this API version, so
  membership can't be read back — verify in the desktop. `any collect <coll> <id>…` and
  `any add … --collection <id>` wrap the POST.
