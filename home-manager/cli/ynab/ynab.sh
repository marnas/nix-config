# Tier-1 CLI over the YNAB API v1 (https://api.ynab.com/v1) — list accounts, categories
# and transactions, categorize/approve transactions (singly or in batch), and create
# category groups/categories. Targets the account's default plan (YNAB renamed "budgets"
# to "plans" in the API, 2026-03); override per-call with `ynab --plan <id> <verb> ...`.
# The access token is fetched from the self-hosted Infisical at call time (project
# `claude`, path /ynab, secret YNAB_ACCESS_TOKEN) via `infisical-secrets` — inherited
# from PATH (home.packages, see ../infisical) — and discarded when this process exits.
# shebang + `set -euo pipefail` are injected by writeShellApplication.
#
# API gotchas baked in here so callers don't trip on them:
#   - Amounts are MILLIUNITS (-52340 == -52.34); table output divides by 1000.
#   - Rate limit: 200 requests/hour per token -> batch verbs PATCH many transactions in
#     one request; prefer them over per-transaction loops.
#   - `plans/last-used` is accepted in lieu of a plan id, so most calls need no plan
#     lookup. (The documented `plans/default` alias 404s unless the account has a default
#     plan explicitly set — `data.default_plan` is null here — so we default to last-used,
#     which always resolves.)

load_creds() {
  TOKEN="$(infisical-secrets /ynab | jq -r '.YNAB_ACCESS_TOKEN // empty')"
  if [ -z "$TOKEN" ]; then
    echo "ynab: missing YNAB_ACCESS_TOKEN in Infisical (project=claude env=${INFISICAL_ENV:-prod} path=/ynab)" >&2
    exit 1
  fi
  BASE="https://api.ynab.com/v1"
}

api() { # api METHOD PATH [BODY]
  local method="$1" path="$2" body="${3:-}"
  # No -f: we capture the status ourselves so a 4xx/5xx body (the API's error message)
  # is surfaced instead of swallowed. `-w` appends the HTTP code on its own trailing line.
  local args=(-sS -X "$method"
    -H "Content-Type: application/json"
    -w '\n%{http_code}'
    --config -)
  [ -n "$body" ] && args+=(-d "$body")
  # The bearer token goes via a --config stream on stdin, never argv (the request body in
  # -d is user content, not secret, so it can stay on the command line).
  local out code
  out="$(printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" | curl "${args[@]}" "$BASE$path")"
  code="${out##*$'\n'}"; out="${out%$'\n'*}"
  if [ "$code" -lt 200 ] || [ "$code" -ge 300 ]; then
    echo "ynab: $method $path → HTTP $code" >&2
    [ "$code" = 429 ] && echo "ynab: rate limited (200 requests/hour per token) — wait for the hour window to roll" >&2
    [ -n "$out" ] && echo "$out" >&2
    exit 1
  fi
  printf '%s' "$out"
}

cmd_plans() {
  api GET "/plans" | jq -r '.data.plans[] | [.id, .name, .last_modified_on] | @tsv'
}

# Open accounts only by default (closed ones still satisfy old transactions but are
# noise for budgeting); --all includes closed/deleted.
cmd_accounts() {
  local all=0
  [ "${1:-}" = "--all" ] && all=1
  api GET "/plans/$PLAN/accounts" \
    | jq -r --argjson all "$all" '.data.accounts[]
        | select($all == 1 or ((.closed or .deleted) | not))
        | [.id, .type, .name, (.balance/1000)] | @tsv'
}

# Rows: <id> <TAB> <group|''> <TAB> <name> <TAB> <available>. Group header rows carry the
# group id and name (needed for add-category); category rows are indented under them.
cmd_categories() {
  local json=0 all=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --json) json=1; shift ;;
      --all) all=1; shift ;;
      *) echo "categories: unknown arg $1" >&2; exit 2 ;;
    esac
  done
  local r; r="$(api GET "/plans/$PLAN/categories")"
  if [ "$json" = 1 ]; then echo "$r"; return; fi
  jq -r --argjson all "$all" '
    .data.category_groups[]
    | select($all == 1 or ((.hidden or .deleted) | not))
    | "\(.id)\tGROUP\t\(.name)",
      (.categories[]
       | select($all == 1 or ((.hidden or .deleted) | not))
       | "\(.id)\t\t\(.name)\t\(.balance/1000)")' <<<"$r"
}

cmd_payees() {
  api GET "/plans/$PLAN/payees" \
    | jq -r '.data.payees[] | select(.deleted|not) | [.id, .name] | @tsv'
}

cmd_txns() {
  local params=() json=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --since) params+=("since_date=$2"); shift 2 ;;
      --uncategorized) params+=("type=uncategorized"); shift ;;
      --unapproved) params+=("type=unapproved"); shift ;;
      --json) json=1; shift ;;
      *) echo "txns: unknown arg $1" >&2; exit 2 ;;
    esac
  done
  local qs="" p
  for p in ${params[@]+"${params[@]}"}; do qs="$qs${qs:+&}$p"; done
  local r; r="$(api GET "/plans/$PLAN/transactions${qs:+?$qs}")"
  if [ "$json" = 1 ]; then echo "$r"; return; fi
  jq -r '.data.transactions[] | select(.deleted|not) |
    [.id, .date, (.amount/1000), (.payee_name // "—"), (.category_name // "(uncategorized)"),
     (if .approved then "approved" else "NEW" end)] | @tsv' <<<"$r"
}

# Both forms send ONE bulk PATCH (rate-limit friendly):
#   ynab categorize <txn_id> <category_id>      single
#   ynab categorize --stdin                     JSON array [{"id":..,"category_id":..},...]
cmd_categorize() {
  local body
  if [ "${1:-}" = "--stdin" ]; then
    body="$(jq -c '{transactions: map({id, category_id})}')"
  else
    [ "$#" -eq 2 ] || { echo "usage: ynab categorize <txn_id> <category_id> | ynab categorize --stdin" >&2; exit 2; }
    body="$(jq -nc --arg i "$1" --arg c "$2" '{transactions:[{id:$i,category_id:$c}]}')"
  fi
  local r; r="$(api PATCH "/plans/$PLAN/transactions" "$body")"
  echo "Categorized $(jq -r '.data.transactions | length' <<<"$r") transaction(s)"
}

cmd_approve() {
  [ "$#" -ge 1 ] || { echo "usage: ynab approve <txn_id>..." >&2; exit 2; }
  local body
  body="$(printf '%s\n' "$@" | jq -R . | jq -cs '{transactions: map({id:., approved:true})}')"
  local r; r="$(api PATCH "/plans/$PLAN/transactions" "$body")"
  echo "Approved $(jq -r '.data.transactions | length' <<<"$r") transaction(s)"
}

cmd_add_group() {
  [ "$#" -eq 1 ] || { echo "usage: ynab add-group <name>" >&2; exit 2; }
  local r; r="$(api POST "/plans/$PLAN/category_groups" "$(jq -nc --arg n "$1" '{category_group:{name:$n}}')")"
  echo "Created group \"$1\" → $(jq -r '.data.category_group.id' <<<"$r")"
}

cmd_add_category() {
  [ "$#" -eq 2 ] || { echo "usage: ynab add-category <group_id> <name>" >&2; exit 2; }
  local r; r="$(api POST "/plans/$PLAN/categories" \
    "$(jq -nc --arg g "$1" --arg n "$2" '{category:{name:$n,category_group_id:$g}}')")"
  echo "Created category \"$2\" → $(jq -r '.data.category.id' <<<"$r")"
}

main() {
  PLAN="last-used"
  if [ "${1:-}" = "--plan" ]; then PLAN="$2"; shift 2; fi
  local verb="${1:-help}"; shift || true
  case "$verb" in
    plans) load_creds; cmd_plans "$@" ;;
    accounts) load_creds; cmd_accounts "$@" ;;
    categories) load_creds; cmd_categories "$@" ;;
    payees) load_creds; cmd_payees "$@" ;;
    txns) load_creds; cmd_txns "$@" ;;
    categorize) load_creds; cmd_categorize "$@" ;;
    approve) load_creds; cmd_approve "$@" ;;
    add-group) load_creds; cmd_add_group "$@" ;;
    add-category) load_creds; cmd_add_category "$@" ;;
    api) load_creds; api "$@"; echo ;;
    help|-h|--help)
      cat >&2 <<'EOF'
ynab — manage your YNAB plan (budget) via the YNAB API
  ynab [--plan ID] <verb> ...                     target a specific plan (default: last-used)

  plans                                           list plans (id, name, last modified)
  accounts [--all]                                list open accounts (id, type, name, balance)
  categories [--all] [--json]                     list category groups + categories (ids first; amounts in units)
  payees                                          list payees (id, name)
  txns [--since YYYY-MM-DD] [--uncategorized|--unapproved] [--json]   list transactions
  categorize <txn_id> <category_id>               set a transaction's category
  categorize --stdin                              bulk: JSON array [{"id":..,"category_id":..},...] on stdin
  approve <txn_id>...                             approve transaction(s) (one bulk request)
  add-group <name>                                create a category group
  add-category <group_id> <name>                  create a category in a group
  api <METHOD> <PATH> [BODY]                      raw API escape hatch (PATH under /v1, e.g. /plans/last-used/months)

  Amounts are milliunits in raw JSON (-52340 == -52.34); table output is already in units.
  Rate limit: 200 requests/hour — prefer the bulk verbs.
EOF
      ;;
    *) echo "ynab: unknown verb '$verb' (try: ynab help)" >&2; exit 2 ;;
  esac
}
main "$@"
