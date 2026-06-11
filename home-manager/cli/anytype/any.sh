# Tier-1 CLI over the self-hosted Anytype REST API, served by the central `anytype-cli
# serve` bot node in the cluster and reached over the tailnet at api.anytype.marnas.sh
# (no per-machine daemon). Operates on your default space (id from Infisical,
# secret `ANYTYPE_SPACE_ID`); override per-call with `any --space <id> <verb> ...`.
# Credentials/config are fetched from the self-hosted Infisical at call time (project
# `claude`, path /anytype) via `infisical-secrets`, then DISCARDED when this process
# exits — nothing secret on disk and (unlike the old `op item get`) no per-call 1Password
# prompt. shebang + `set -euo pipefail` are injected by writeShellApplication, so this
# file starts at the functions. `infisical-secrets` is inherited from PATH
# (home.packages, see ../infisical), same as `op`.

load_creds() {
  local secrets
  secrets="$(infisical-secrets /anytype)"
  APIKEY="$(jq -r '.ANYTYPE_APIKEY // empty' <<<"$secrets")"
  VER="$(jq -r '.ANYTYPE_API_VERSION // empty' <<<"$secrets")"
  if [ -n "${SPACE_OVERRIDE:-}" ]; then
    SID="$SPACE_OVERRIDE"
  else
    SID="$(jq -r '.ANYTYPE_SPACE_ID // empty' <<<"$secrets")"
  fi
  if [ -z "$APIKEY" ] || [ -z "$VER" ] || [ -z "$SID" ]; then
    echo "any: missing ANYTYPE_APIKEY/ANYTYPE_API_VERSION/ANYTYPE_SPACE_ID in Infisical" \
         "(project=claude env=${INFISICAL_ENV:-prod} path=/anytype)" >&2
    exit 1
  fi
  BASE="https://api.anytype.marnas.sh"
}

api() { # api METHOD PATH [BODY]
  local method="$1" path="$2" body="${3:-}"
  # No -f: we capture the status ourselves so a 4xx/5xx body (the API's error message)
  # is surfaced instead of swallowed. `-w` appends the HTTP code on its own trailing line.
  local args=(-sS -X "$method"
    -H "Anytype-Version: $VER"
    -H "Content-Type: application/json"
    -w '\n%{http_code}'
    --config -)
  [ -n "$body" ] && args+=(-d "$body")
  # The bearer apikey goes via a --config stream on stdin, never argv (the request body in
  # -d is user content, not secret, so it can stay on the command line).
  local out code
  out="$(printf 'header = "Authorization: Bearer %s"\n' "$APIKEY" | curl "${args[@]}" "$BASE$path")"
  code="${out##*$'\n'}"; out="${out%$'\n'*}"
  if [ "$code" -lt 200 ] || [ "$code" -ge 300 ]; then
    echo "any: $method $path → HTTP $code" >&2
    [ -n "$out" ] && echo "$out" >&2
    exit 1
  fi
  printf '%s' "$out"
}

# Compact one-line summary used by ls: "<id>  [x]  task  Name  (due 2026-06-30)".
# Anytype omits false checkboxes from search results, so absent `done` == open.
fmt_table() {
  jq -r '.data[] |
    (.properties // []) as $p |
    ( [ $p[]|select(.key=="done")|.checkbox ] | first // false ) as $done |
    ( [ $p[]|select(.key=="due_date")|.date ] | first ) as $due |
    ( if .type.key=="task" then (if $done then "[x]" else "[ ]" end) else "   " end ) as $mark |
    [ .id, $mark, .type.key, .name,
      (if $due then "(due " + ($due|split("T")[0]) + ")" else "" end)
    ] | @tsv'
}

# Bookmarks are special: the URL must go in the `source` property (NOT the name),
# because the daemon watches that property and asynchronously fetches the page
# title + description for you. Passing the URL as the name (the old footgun) leaves
# `source` empty -> a dead card with no metadata. So `add bookmark` takes the url
# positionally and an optional explicit name (leave empty to let the fetch fill it).
# We ALSO write the URL into the body as a markdown link, because this daemon's
# bookmark layout doesn't surface the (unfeatured) source relation as a clickable
# element -- the body link is the only reliably clickable way to open the page.
# Note: object create is idempotent on (type+source) for bookmarks -- re-creating an
# existing URL returns the existing id and ignores the new body, so to change a
# bookmark's body you must `rm` it first, then create.
# Resolve a type's DEFAULT template id from its type key, or empty if none. The REST
# `create` endpoint ignores a type's default template — objects come out with the built-in
# narrow layout, unlike the desktop, which applies the default template (so layout-width
# and other template defaults are lost). We replicate the desktop by passing template_id on
# create. Anytype's default is the type's BLANK template (the one with an empty name — and
# the one whose layout-width slider the user edits to set a type-wide width); we pick that.
# Best-effort: any failure (network, no templates, unknown type) yields empty -> plain
# create, the prior behaviour, so this never blocks object creation.
resolve_default_template() { # resolve_default_template TYPE_KEY -> template id | empty
  local tid
  tid="$(api GET "/v1/spaces/$SID/types?limit=200" | jq -r --arg k "$1" '.data[]|select(.key==$k)|.id')" || return 0
  [ -n "$tid" ] || return 0
  api GET "/v1/spaces/$SID/types/$tid/templates?limit=100" \
    | jq -r '[.data[]|select(.name=="")][0].id // empty' || return 0
}

# `--collection ID` (any type) drops the new object into a collection after create.
# `--template ID` overrides the auto-resolved default template (use `--template ""` to opt
# out and create a bare object).
cmd_add() {
  local coll="" prio="" tpl="" tpl_set=0 pos=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --collection) coll="$2"; shift 2 ;;
      --priority) prio="$2"; shift 2 ;;
      --template) tpl="$2"; tpl_set=1; shift 2 ;;
      *) pos+=("$1"); shift ;;
    esac
  done
  set -- ${pos[@]+"${pos[@]}"}
  [ "$#" -ge 1 ] || { echo "usage: any add <type> <name> [body]   (bookmark: any add bookmark <url> [name])" >&2; exit 2; }
  local type="$1"; shift
  local payload r id label
  if [ "$type" = "bookmark" ]; then
    [ "$#" -ge 1 ] || { echo "usage: any add bookmark <url> [name]" >&2; exit 2; }
    local url="$1" name="${2:-}"
    payload="$(jq -n --arg n "$name" --arg u "$url" '{type_key:"bookmark",name:$n,body:("[\($u)](\($u))"),properties:[{key:"source",url:$u}]}')"
    label="$url"
  else
    [ "$#" -ge 1 ] || { echo "usage: any add <type> <name> [body]" >&2; exit 2; }
    local name="$1" body="${2:-}"
    # Apply the type's default (blank) template so layout-width and other template defaults
    # match desktop-created objects. Explicit --template (incl. --template "" to opt out)
    # wins; otherwise auto-resolve. tpl="" => no template_id in the payload.
    [ "$tpl_set" = 1 ] || tpl="$(resolve_default_template "$type" || true)"
    if [ "$type" = "task" ]; then
      # New tasks default to "To Do" so they never land statusless (blank) — they show up
      # in the To-Do/open views immediately. Override later with `any set --status`.
      local sttag; sttag="$(resolve_status "To Do")" || exit 2
      local props; props="$(jq -nc --arg s "$sttag" '[{key:"status",select:$s}]')"
      # Priority is optional at create — the caller infers it from the task's content and
      # passes --priority; left blank if omitted (no hardcoded default).
      if [ -n "$prio" ]; then
        local pr; pr="$(resolve_priority "$prio")" || exit 2
        props="$(jq -c --arg k "${pr%%$'\t'*}" --arg p "${pr##*$'\t'}" '. + [{key:$k,select:$p}]' <<<"$props")"
      fi
      payload="$(jq -n --arg t "$type" --arg n "$name" --arg b "$body" --argjson pr "$props" --arg tpl "$tpl" \
        '{type_key:$t,name:$n,body:$b,properties:$pr} + (if $tpl=="" then {} else {template_id:$tpl} end)')"
    else
      [ -n "$prio" ] && { echo "add: --priority only applies to tasks" >&2; exit 2; }
      payload="$(jq -n --arg t "$type" --arg n "$name" --arg b "$body" --arg tpl "$tpl" \
        '{type_key:$t,name:$n,body:$b} + (if $tpl=="" then {} else {template_id:$tpl} end)')"
    fi
    label="$name"
  fi
  r="$(api POST "/v1/spaces/$SID/objects" "$payload")"
  id="$(jq -r '.object.id' <<<"$r")"
  echo "Created $type \"$label\" → $id"
  if [ -n "$coll" ]; then
    api POST "/v1/spaces/$SID/lists/$coll/objects" "$(jq -nc --arg i "$id" '{objects:[$i]}')" >/dev/null
    echo "  added to collection $coll"
  fi
}

# Add existing object(s) to a collection (Anytype "list"). Collections only — a Set
# is query-defined and has no manual membership.
cmd_collect() {
  [ "$#" -ge 2 ] || { echo "usage: any collect <collection_id> <object_id>..." >&2; exit 2; }
  local coll="$1"; shift
  local ids; ids="$(printf '%s\n' "$@" | jq -R . | jq -cs '{objects:.}')"
  api POST "/v1/spaces/$SID/lists/$coll/objects" "$ids" >/dev/null
  echo "Added $# object(s) to collection $coll"
}

cmd_ls() {
  local type="" query="" want="" limit=50 json=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t|--type) type="$2"; shift 2 ;;
      -q|--query) query="$2"; shift 2 ;;
      --open) want="open"; shift ;;
      --done) want="done"; shift ;;
      -n|--limit) limit="$2"; shift 2 ;;
      --json) json=1; shift ;;
      *) echo "ls: unknown arg $1" >&2; exit 2 ;;
    esac
  done
  local body r
  if [ -n "$type" ]; then
    body="$(jq -n --arg q "$query" --arg t "$type" '{query:$q,types:[$t]}')"
  else
    body="$(jq -n --arg q "$query" '{query:$q}')"
  fi
  r="$(api POST "/v1/spaces/$SID/search?limit=$limit" "$body")"
  # client-side done filter (avoids unverified server filter syntax)
  if [ "$want" = "open" ]; then
    r="$(jq '.data |= map(select(([ (.properties//[])[]|select(.key=="done")|.checkbox ]|first // false) != true))' <<<"$r")"
  elif [ "$want" = "done" ]; then
    r="$(jq '.data |= map(select(([ (.properties//[])[]|select(.key=="done")|.checkbox ]|first // false) == true))' <<<"$r")"
  fi
  if [ "$json" = 1 ]; then echo "$r"; else fmt_table <<<"$r"; fi
}

cmd_get() {
  [ "$#" -ge 1 ] || { echo "usage: any get <id> [--json]" >&2; exit 2; }
  local id="$1" json=0
  [ "${2:-}" = "--json" ] && json=1
  local r; r="$(api GET "/v1/spaces/$SID/objects/$id")"
  if [ "$json" = 1 ]; then echo "$r"; return; fi
  jq -r '
    ["created_date","last_modified_date","last_modified_by","creator","backlinks","links","added_date"] as $sys |
    .object |
    "id:    \(.id)",
    "type:  \(.type.key)",
    "name:  \(.name)",
    ((.properties//[])[]
      | .key as $k | select(($sys|index($k))|not)
      | (.checkbox // .date // .select.name // .number // (.text|select(.!=""))
         // ([.objects[]? | if type=="object" then .name else . end]|select(length>0)|join(", "))
         // ([.multi_select[]?.name]|select(length>0)|join(", "))) as $v
      | select($v != null)
      | "prop:  \(.key) = \($v)"),
    "---",
    (.markdown // "")' <<<"$r"
}

# Resolve a select option name (case-insensitive) to its tag id — what a select
# property value expects. Generic over the task-type property key (status, priority).
resolve_tag() { # resolve_tag PROPKEY WANTED
  local propkey="$1" want="$2" pid tags id
  pid="$(api GET "/v1/spaces/$SID/types?limit=100" \
    | jq -r --arg pk "$propkey" '.data[]|select(.key=="task").properties[]|select(.key==$pk)|.id')"
  if [ -z "$pid" ]; then
    echo "set: task type has no '$propkey' property (run \`any init-priority\` to add it)" >&2
    exit 2
  fi
  tags="$(api GET "/v1/spaces/$SID/properties/$pid/tags")"
  id="$(jq -r --arg w "$want" '.data[]|select((.name|ascii_downcase)==($w|ascii_downcase))|.id' <<<"$tags" | head -n1)"
  if [ -z "$id" ]; then
    echo "set: invalid $propkey '$want'. valid: $(jq -r '[.data[].name]|join(", ")' <<<"$tags")" >&2
    exit 2
  fi
  printf '%s' "$id"
}
resolve_status() { resolve_tag status "$1"; }

# Resolve the task type's Priority (select) relation for a level name. Echoes
# "<property_key>\t<tag_id>". The relation is user-created so its key is a hash — we
# locate it by name on the task type, not a fixed key (unlike status).
resolve_priority() { # resolve_priority LEVEL
  local want="$1" prow pid pkey tags id
  prow="$(api GET "/v1/spaces/$SID/types?limit=100" \
    | jq -c '[.data[]|select(.key=="task").properties[]|select((.name|ascii_downcase)=="priority" and .format=="select")][0] // empty')"
  if [ -z "$prow" ]; then
    echo "set: task type has no Priority (select) relation — run \`any init-priority\`" >&2
    exit 2
  fi
  pid="$(jq -r '.id' <<<"$prow")"; pkey="$(jq -r '.key' <<<"$prow")"
  tags="$(api GET "/v1/spaces/$SID/properties/$pid/tags")"
  id="$(jq -r --arg w "$want" '.data[]|select((.name|ascii_downcase)==($w|ascii_downcase))|.id' <<<"$tags" | head -n1)"
  if [ -z "$id" ]; then
    echo "set: invalid priority '$want'. valid: $(jq -r '[.data[].name]|join(", ")' <<<"$tags")" >&2
    exit 2
  fi
  printf '%s\t%s' "$pkey" "$id"
}

cmd_set() {
  [ "$#" -ge 1 ] || { echo "usage: any set <id> [--name N] [--icon EMOJI] [--done|--undone] [--due DATE] [--status S] [--priority P] [--project ID ...|--unlink-projects]" >&2; exit 2; }
  local id="$1"; shift
  local name="" set_name=0
  local icon="" set_icon=0
  local props="[]"
  # linked_projects is an object relation: PATCH replaces the whole array, so we
  # collect every --project into one list and send it once. set_projects=1 even
  # when empty (--unlink-projects) so the cleared list is still emitted.
  local projects="[]" set_projects=0
  add_prop() { props="$(jq -c --argjson p "$1" '. + [$p]' <<<"$props")"; }
  # NOTE: the API only sets the markdown body at create time; PATCH ignores `body`,
  # so there is intentionally no --body here. To change a body, recreate the object.
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --name) name="$2"; set_name=1; shift 2 ;;
      --icon) icon="$2"; set_icon=1; shift 2 ;;
      --done) add_prop '{"key":"done","checkbox":true}'; shift ;;
      --undone) add_prop '{"key":"done","checkbox":false}'; shift ;;
      --due) add_prop "$(jq -nc --arg d "$2" '{key:"due_date",date:$d}')"; shift 2 ;;
      --status)
        local tag; tag="$(resolve_status "$2")" || exit 2
        add_prop "$(jq -nc --arg s "$tag" '{key:"status",select:$s}')"; shift 2 ;;
      --priority)
        local pr; pr="$(resolve_priority "$2")" || exit 2
        add_prop "$(jq -nc --arg k "${pr%%$'\t'*}" --arg s "${pr##*$'\t'}" '{key:$k,select:$s}')"; shift 2 ;;
      --project) projects="$(jq -c --arg p "$2" '. + [$p]' <<<"$projects")"; set_projects=1; shift 2 ;;
      --unlink-projects) projects="[]"; set_projects=1; shift ;;
      *) echo "set: unknown arg $1" >&2; exit 2 ;;
    esac
  done
  [ "$set_projects" = 1 ] && add_prop "$(jq -nc --argjson o "$projects" '{key:"linked_projects",objects:$o}')"
  local payload
  payload="$(jq -nc \
    --argjson sn "$set_name" --arg n "$name" \
    --argjson si "$set_icon" --arg ic "$icon" \
    --argjson props "$props" '
    ( if $sn==1 then {name:$n} else {} end )
    + ( if $si==1 then {icon:{format:"emoji",emoji:$ic}} else {} end )
    + ( if ($props|length)>0 then {properties:$props} else {} end )')"
  local r; r="$(api PATCH "/v1/spaces/$SID/objects/$id" "$payload")"
  echo "Updated $(jq -r '.object.id' <<<"$r")  →  $(jq -r '.object.name' <<<"$r")"
}

cmd_rm() {
  [ "$#" -ge 1 ] || { echo "usage: any rm <id>" >&2; exit 2; }
  api DELETE "/v1/spaces/$SID/objects/$1" >/dev/null
  echo "Deleted $1"
}

cmd_types() {
  api GET "/v1/spaces/$SID/types?limit=100" | jq -r '.data[] | "\(.key)\t\(.name)"'
}

# One-time bootstrap: create the single-select "Priority" property (High/Medium/Low)
# and attach it to the Task type. Idempotent — re-running is a no-op once present.
# Schema lives in the Anytype app's runtime state (not a declarative source), so this
# verb is how we (re)create it reproducibly on a fresh space.
cmd_init_priority() {
  local types ttid props prow pid pkey
  types="$(api GET "/v1/spaces/$SID/types?limit=100")"
  ttid="$(jq -r '.data[]|select(.key=="task").id' <<<"$types")"
  [ -n "$ttid" ] || { echo "init-priority: task type not found" >&2; exit 1; }
  # Reuse a select property named "Priority" if one exists; else create a fresh one. We
  # key a new one 'task_priority' to dodge the bundled number relation 'priority'.
  props="$(api GET "/v1/spaces/$SID/properties?limit=200")"
  prow="$(jq -c '[.data[]|select((.name|ascii_downcase)=="priority" and .format=="select")][0] // empty' <<<"$props")"
  if [ -n "$prow" ]; then
    pid="$(jq -r '.id' <<<"$prow")"; pkey="$(jq -r '.key' <<<"$prow")"
  else
    local r; r="$(api POST "/v1/spaces/$SID/properties" '{"key":"task_priority","name":"Priority","format":"select"}')"
    pid="$(jq -r '.property.id' <<<"$r")"; pkey="$(jq -r '.property.key' <<<"$r")"
  fi
  # Ensure exactly the High/Medium/Low options exist (create any missing, with colors).
  local have; have="$(api GET "/v1/spaces/$SID/properties/$pid/tags" | jq -c '[.data[].name|ascii_downcase]')"
  local nc n c
  for nc in High:red Medium:yellow Low:lime; do
    n="${nc%%:*}"; c="${nc##*:}"
    if ! jq -e --arg n "$(printf '%s' "$n" | tr '[:upper:]' '[:lower:]')" 'index($n)' <<<"$have" >/dev/null; then
      api POST "/v1/spaces/$SID/properties/$pid/tags" "$(jq -nc --arg n "$n" --arg c "$c" '{name:$n,color:$c}')" >/dev/null
    fi
  done
  # Attach to the Task type if not already present (PATCH replaces the whole list).
  if jq -e --arg k "$pkey" '.data[]|select(.key=="task").properties[]|select(.key==$k)' <<<"$types" >/dev/null; then
    echo "Priority already on the Task type (options ensured)."
  else
    local newprops
    newprops="$(jq -c --arg k "$pkey" '[.data[]|select(.key=="task").properties[]|{key,name,format}] + [{key:$k,name:"Priority",format:"select"}]' <<<"$types")"
    api PATCH "/v1/spaces/$SID/types/$ttid" "$(jq -nc --argjson p "$newprops" '{properties:$p}')" >/dev/null
    echo "Attached Priority (High / Medium / Low) to the Task type."
  fi
}

main() {
  SPACE_OVERRIDE=""
  if [ "${1:-}" = "--space" ]; then SPACE_OVERRIDE="$2"; shift 2; fi
  local verb="${1:-help}"; shift || true
  case "$verb" in
    add) load_creds; cmd_add "$@" ;;
    bm) load_creds; cmd_add bookmark "$@" ;;
    collect) load_creds; cmd_collect "$@" ;;
    ls|list) load_creds; cmd_ls "$@" ;;
    get) load_creds; cmd_get "$@" ;;
    set) load_creds; cmd_set "$@" ;;
    rm|del) load_creds; cmd_rm "$@" ;;
    types) load_creds; cmd_types "$@" ;;
    init-priority) load_creds; cmd_init_priority "$@" ;;
    help|-h|--help)
      cat >&2 <<'EOF'
any — manage objects in your self-hosted Anytype space
  any [--space ID] <verb> ...                      target a different space (default: your space_id)

  add <type> <name> [body] [--collection ID] [--priority P] [--template ID]   create an object (type: task|note|page|project|bookmark)
           (auto-applies the type's default/blank template so layout width matches desktop; --template "" opts out)
  add bookmark <url> [name] [--collection ID]      create a bookmark (url -> source; title/desc auto-fetched)
  bm <url> [name] [--collection ID]                shortcut for `add bookmark`
  collect <collection_id> <object_id>...           add existing object(s) to a collection
  ls [-t TYPE] [-q TEXT] [--open|--done] [--json]   list/search objects
  get <id> [--json]                                show one object (props + markdown)
  set <id> [--name N] [--icon EMOJI] [--done|--undone] [--due YYYY-MM-DD] [--status S] [--priority P]   (body is create-only)
           [--project ID ...]                      link to project(s) (repeat to add; replaces existing)
           [--unlink-projects]                     clear all linked projects
  rm <id>                                          delete an object
  types                                            list type keys in the space
  init-priority                                    one-time: add the Priority field (High/Medium/Low) to the Task type
EOF
      ;;
    *) echo "any: unknown verb '$verb' (try: any help)" >&2; exit 2 ;;
  esac
}
main "$@"
