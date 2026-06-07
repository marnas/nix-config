# Tier-1 CLI over the self-hosted Anytype Local REST API (served by `anytype-cli
# serve` on 127.0.0.1:31012). Operates on your default space (id from 1Password,
# field `space_id`); override per-call with `any --space <id> <verb> ...`.
# Credentials are read from 1Password at call time (item "anytype-cli bot account",
# Private vault) — nothing secret on disk. shebang + `set -euo pipefail` are injected
# by writeShellApplication, so this file starts straight at the functions.

load_creds() {
  local j
  j="$(op item get "anytype-cli bot account" --vault Private --format json)"
  APIKEY="$(jq -r '.fields[]|select(.label=="apikey")|.value' <<<"$j")"
  BASE="$(jq -r '.fields[]|select(.label=="base_url")|.value' <<<"$j")"
  VER="$(jq -r '.fields[]|select(.label=="api_version")|.value' <<<"$j")"
  if [ -n "${SPACE_OVERRIDE:-}" ]; then
    SID="$SPACE_OVERRIDE"
  else
    SID="$(jq -r '.fields[]|select(.label=="space_id")|.value' <<<"$j")"
  fi
}

api() { # api METHOD PATH [BODY]
  local method="$1" path="$2" body="${3:-}"
  local args=(-fsS -X "$method"
    -H "Authorization: Bearer $APIKEY"
    -H "Anytype-Version: $VER"
    -H "Content-Type: application/json")
  [ -n "$body" ] && args+=(-d "$body")
  curl "${args[@]}" "$BASE$path"
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
# `--collection ID` (any type) drops the new object into a collection after create.
cmd_add() {
  local coll="" pos=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --collection) coll="$2"; shift 2 ;;
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
    [ "$#" -ge 2 ] || { echo "usage: any add <type> <name> [body]" >&2; exit 2; }
    local name="$2" body="${3:-}"
    payload="$(jq -n --arg t "$type" --arg n "$name" --arg b "$body" '{type_key:$t,name:$n,body:$b}')"
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

# Resolve a Task status option name (case-insensitive) to its tag id, which is
# what the select property expects.
resolve_status() {
  local want="$1" pid tags id
  pid="$(api GET "/v1/spaces/$SID/types?limit=100" \
    | jq -r '.data[]|select(.key=="task").properties[]|select(.key=="status").id')"
  tags="$(api GET "/v1/spaces/$SID/properties/$pid/tags")"
  id="$(jq -r --arg w "$want" '.data[]|select((.name|ascii_downcase)==($w|ascii_downcase))|.id' <<<"$tags" | head -n1)"
  if [ -z "$id" ]; then
    echo "set: invalid status '$want'. valid: $(jq -r '[.data[].name]|join(", ")' <<<"$tags")" >&2
    exit 2
  fi
  printf '%s' "$id"
}

cmd_set() {
  [ "$#" -ge 1 ] || { echo "usage: any set <id> [--name N] [--done|--undone] [--due DATE] [--status S] [--project ID ...|--unlink-projects]" >&2; exit 2; }
  local id="$1"; shift
  local name="" set_name=0
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
      --done) add_prop '{"key":"done","checkbox":true}'; shift ;;
      --undone) add_prop '{"key":"done","checkbox":false}'; shift ;;
      --due) add_prop "$(jq -nc --arg d "$2" '{key:"due_date",date:$d}')"; shift 2 ;;
      --status)
        local tag; tag="$(resolve_status "$2")" || exit 2
        add_prop "$(jq -nc --arg s "$tag" '{key:"status",select:$s}')"; shift 2 ;;
      --project) projects="$(jq -c --arg p "$2" '. + [$p]' <<<"$projects")"; set_projects=1; shift 2 ;;
      --unlink-projects) projects="[]"; set_projects=1; shift ;;
      *) echo "set: unknown arg $1" >&2; exit 2 ;;
    esac
  done
  [ "$set_projects" = 1 ] && add_prop "$(jq -nc --argjson o "$projects" '{key:"linked_projects",objects:$o}')"
  local payload
  payload="$(jq -nc \
    --argjson sn "$set_name" --arg n "$name" \
    --argjson props "$props" '
    ( if $sn==1 then {name:$n} else {} end )
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
    help|-h|--help)
      cat >&2 <<'EOF'
any — manage objects in your self-hosted Anytype space
  any [--space ID] <verb> ...                      target a different space (default: your space_id)

  add <type> <name> [body] [--collection ID]       create an object (type: task|note|page|project|bookmark)
  add bookmark <url> [name] [--collection ID]      create a bookmark (url -> source; title/desc auto-fetched)
  bm <url> [name] [--collection ID]                shortcut for `add bookmark`
  collect <collection_id> <object_id>...           add existing object(s) to a collection
  ls [-t TYPE] [-q TEXT] [--open|--done] [--json]   list/search objects
  get <id> [--json]                                show one object (props + markdown)
  set <id> [--name N] [--done|--undone] [--due YYYY-MM-DD] [--status S]   (body is create-only)
           [--project ID ...]                      link to project(s) (repeat to add; replaces existing)
           [--unlink-projects]                     clear all linked projects
  rm <id>                                          delete an object
  types                                            list type keys in the space
EOF
      ;;
    *) echo "any: unknown verb '$verb' (try: any help)" >&2; exit 2 ;;
  esac
}
main "$@"
