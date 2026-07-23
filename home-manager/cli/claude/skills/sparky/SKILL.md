---
description: Track food, exercise, weight, water, sleep, mood and habits in the user's self-hosted SparkyFitness instance via the `sparky` CLI. Use whenever the user mentions Sparky/SparkyFitness or wants to log or review meals, calories, macros, workouts, weight, water intake, check-ins, health trends or fitness goals ("log my lunch", "how many calories today", "add my weight", "how's my streak").
---

## Tool

Use the `sparky` command (installed on PATH). It speaks JSON-RPC to the SparkyFitness
MCP endpoint at `https://sparky.marnas.sh/mcp`; credentials come from Infisical at call
time via `infisical-secrets`, so no setup. The server owns the tool catalog — always
discover, don't assume:

```
sparky tools                      list available tools (name + one-line summary)
sparky schema <tool>              full description (per-action fields) + JSON input schema
sparky call <tool> ['<json>']     invoke a tool; arguments default to {}
```

Example:

```
sparky call sparky_manage_food '{"action":"log_food","food_name":"banana","quantity":1,"unit":"piece","meal_type":"snacks","entry_date":"2026-07-08"}'
```

## Rules

- **Discovery loop:** `sparky tools` → pick the tool → `sparky schema <tool>` →
  `sparky call <tool> '<json>'`. The `sparky_manage_*` tools are multiplexers driven by
  an `action` field; read the schema before every write, since valid actions and their
  required fields live there, not here.
- **Prefer the purpose-built read tools** (`sparky_get_food_diary`,
  `sparky_get_health_summary`, `sparky_get_daily_report`, …) over reconstructing data
  from `manage_*` list actions — they return ready-made summaries.
- Dates are `YYYY-MM-DD` and mean the user's local day — resolve "today"/"yesterday"
  from the current date. `meal_type` is one of breakfast | lunch | dinner | snacks;
  when the user doesn't say which meal, infer from time of day and say so.
- **Search before logging food:** `search_food` first and log the existing catalog
  entry (by `food_id`) so nutrition data stays consistent; only `create_food` when the
  catalog has no match. Same idea for exercises.
- Results come back as markdown/JSON text — relay the numbers, don't re-derive them.
- **Report back** what was logged (food, quantity, meal, date) or the figures asked
  for; entries sync to the user's Sparky apps automatically.

## If it fails

- HTTP 401/403 — stale or permission-limited `API_KEY` in Infisical (project `claude`,
  path `/sparky`); regenerate it in Sparky's Settings → API keys and update Infisical.
- `infisical-secrets`/`infisical-token` errors — Infisical bootstrap problem, see the
  anytype skill's troubleshooting reference (same mechanism).
- Tool-level errors are printed verbatim (`sparky: <tool> returned an error`) — usually
  bad arguments; re-read `sparky schema <tool>`.
