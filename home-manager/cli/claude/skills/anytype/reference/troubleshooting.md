# Troubleshooting `any` failures

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
