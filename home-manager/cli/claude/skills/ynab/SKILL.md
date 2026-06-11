---
description: Manage the user's YNAB budget via the `ynab` CLI — review accounts and categories, categorize/approve imported transactions, create category groups, monthly budget checkups. Use whenever the user mentions YNAB, budgeting, categorizing/approving transactions, or asks about their spending ("categorize my transactions", "how's my budget", "add a category").
---

## Tool

Use the `ynab` command (installed on PATH). It calls the YNAB API v1 and targets the user's
last-used plan (YNAB's name for a budget); the access token is fetched from Infisical at
call time via `infisical-secrets`, so no setup or 1Password prompt.

```
ynab accounts                                     open accounts (id, type, name, balance)
ynab categories [--all] [--json]                  groups + categories; GROUP rows carry the group id
ynab payees                                       payee list (id, name)
ynab txns [--since YYYY-MM-DD] [--uncategorized|--unapproved] [--json]
ynab categorize <txn_id> <category_id>            set one transaction's category
ynab categorize --stdin                           bulk: [{"id":..,"category_id":..},...] on stdin
ynab approve <txn_id>...                          approve transaction(s), one bulk request
ynab add-group <name>                             create a category group
ynab add-category <group_id> <name>               create a category
ynab api <METHOD> <PATH> [BODY]                   raw escape hatch (e.g. GET /plans/last-used/months)
```

Table output starts with the **id** — use it for `categorize`/`approve`/`add-category`.
Amounts in tables are currency units (outflows negative); raw `--json` amounts are
**milliunits** (-52340 == -52.34).

## Rules

- **Budget the rate limit** (200 requests/hour per token): always batch — one
  `categorize --stdin` / one `approve` call for many transactions, never a per-transaction
  loop.
- **The category structure is provisional.** It came from YNAB's standard template, not
  the user's actual spending, so categories may not map 1:1 to what he needs. For every
  transaction, treat fit as a question: if no existing category fits *cleanly*, don't
  force the nearest match — flag it and propose a structure change (new category, rename,
  split). Keep this per-transaction scrutiny until the structure has settled and
  everything maps, then this rule can be relaxed to plain categorization.
- **Categorization loop:** `ynab categories` for valid ids → `ynab txns --uncategorized` →
  infer each category from payee name and amount sign → apply the confident ones in one
  `categorize --stdin` batch → present the ambiguous remainder to the user as a table
  (payee, amount, date, suggested category) and apply their answers in a second batch.
  YNAB auto-learns payee→category from what you set, so future imports improve.
- **Memo the non-obvious.** When a transaction isn't recurring or self-explanatory from
  its payee (one-offs, opaque payees like PayPal, debt repayments, reimbursements), record
  what the user says about it as a memo so the context isn't lost:
  `ynab api PATCH /plans/last-used/transactions '{"transactions":[{"id":"..","memo":".."}]}'`
  — combinable with `category_id` in the same batch.
- **Never auto-approve.** Approval is the user's confirmation that a transaction is real
  and correct — run `approve` only when the user explicitly says so. Categorizing is fine
  without approval.
- **Propose category structure before creating it.** `add-group`/`add-category` are quick
  but deleting/merging is manual in the app — list the intended structure first, create
  after the user agrees.
- Money math: when computing sums from `--json`, divide milliunits by 1000 once at the
  end, not per-row with rounding.
- **Report back** counts and what changed; changes sync to the user's YNAB apps
  automatically.

## If it fails

- `HTTP 401` — token rotated or revoked: check the `YNAB_ACCESS_TOKEN` secret in Infisical
  (project `claude`, path `/ynab`).
- `HTTP 429` — rate limited; the window is rolling per hour, wait before retrying.
- `infisical-secrets`/`infisical-token` errors — Infisical bootstrap problem, see the
  anytype skill's troubleshooting reference (same mechanism).
