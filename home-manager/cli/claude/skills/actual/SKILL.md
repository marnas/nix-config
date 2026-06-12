---
description: Manage the user's Actual Budget via the `actual` CLI — review accounts, categories and budget months, categorize imported transactions, run bank sync, create category groups. Use whenever the user mentions Actual Budget, budgeting, categorizing transactions, or asks about their spending ("categorize my transactions", "how's my budget", "add a category").
---

## Tool

Use the `actual` command (installed on PATH). It drives the official Actual Budget API
against the self-hosted server at actual.marnas.sh; credentials come from Infisical at
call time via `infisical-secrets`, so no setup. The API is local-first: each call syncs
the budget into a local cache, so the first call in a while is slow — that's normal.

```
actual accounts [--all]                                open on-budget accounts (id, kind, name, balance)
actual categories [--all] [--json]                     groups + categories; GROUP rows carry the group id
actual payees                                          payee list (id, name)
actual txns [--since YYYY-MM-DD] [--account ID] [--uncategorized] [--json]
actual categorize <txn_id> <category_id>               set one transaction's category
actual categorize --stdin                              bulk: [{"id":..,"category":..,"notes"?:..},...] on stdin
actual note <txn_id> <text>                            set a transaction's notes
actual link-transfer <keep_txn_id> <dupe_txn_id>       merge two imported legs of one transfer (deletes the dupe)
actual add-txn <account_id> <date> <amount> [--payee NAME] [--category ID] [--notes TEXT] [--cleared]
actual months                                          list budget months (YYYY-MM)
actual budget [YYYY-MM]                                 month totals + per-category budgeted/spent/balance
actual set-budget <YYYY-MM> <category_id> <amount>     budget an amount (currency units)
actual add-group <name>                                create a category group
actual add-category <group_id> <name>                  create a category
actual rename-category <category_id> <name>            rename a category
actual rename-group <group_id> <name>                  rename a category group
actual rm-category <category_id> [transfer_cat_id]     delete a category (txns move to transfer_cat_id, else uncategorized)
actual rm-group <group_id> [transfer_cat_id]           delete a group and all its categories
actual sync [--account ID]                             pull new transactions from the bank (server-side GoCardless)
```

Table output starts with the **id** — use it for `categorize`/`note`/`add-category`.
Amounts in tables are currency units (outflows negative); raw `--json` amounts are
**minor units** (-5234 == -52.34) — divide by 100 once at the end of any sum.

## Rules

- **Fetch the working context first.** Private budget context that Actual itself can't
  tell you — current life situation, pending obligations, payee decoder, conventions —
  lives in the Anytype page **"Actual Budget — Claude working context"**. Read it (via
  the anytype skill) at the start of a budget session, and update it when a session
  changes that context (obligation settled, new convention).
- **Precedent before inference.** Before inferring a payee's category, check how the
  same payee was categorized in past transactions (`txns --json`, filter by payee) —
  Actual doesn't auto-learn, but history is the user's own ruling.
- **The category structure is provisional.** It was migrated from YNAB, not grown from
  the user's actual spending, so categories may not map 1:1 to what he needs. For every
  transaction, treat fit as a question: if no existing category fits *cleanly*, don't
  force the nearest match — flag it and propose a structure change (new category,
  rename, split). Relax to plain categorization once the structure has settled.
- **Categorization loop:** `actual categories` for valid ids → `actual txns
  --uncategorized` → infer each category from payee name and amount sign → apply the
  confident ones in one `categorize --stdin` batch → present the ambiguous remainder to
  the user as a table (payee, amount, date, suggested category) and apply their answers
  in a second batch. Unlike YNAB, Actual does **not** auto-learn payee→category from
  API edits — for a recurring payee, suggest the user add a rule in the Actual app.
- **Note the non-obvious.** When a transaction isn't recurring or self-explanatory from
  its payee (one-offs, opaque payees like PayPal, reimbursements), record what the user
  says about it: `notes` in the `categorize --stdin` batch, or `actual note <id> <text>`.
- **Leave transfers and split parents alone.** `txns` already inlines split children
  (categorize each child); transfers legitimately have no category. When both legs of
  one transfer were imported separately (typical for credit-card payments: equal and
  opposite amounts in two accounts), merge them with `link-transfer`, keeping the
  bank-account leg.
- **Propose structure changes before applying them.** List the intended
  groups/categories first, `add-*`/`rm-*` after the user agrees. The `rm-*` verbs are
  destructive (no undo); when deleting a category that has transactions, pass a
  transfer category id so they don't fall back to uncategorized.
- **Bank import is `actual sync`**, run it when the user asks to refresh/import
  transactions, then continue with the categorization loop.
- **Reconciling:** compare `accounts` against the real-world balance the user reports;
  book the difference with `add-txn --cleared` — payee `Starting Balance`, category
  `Starting Balances` when it represents history predating the import window, otherwise
  a categorized adjustment the user agrees to.
- **Report back** counts and what changed; the server sync at the end of each mutating
  call propagates to the user's Actual apps automatically.

## If it fails

- `missing ACTUAL_PASSWORD / ACTUAL_SYNC_ID` — seed Infisical (project `claude`, path
  `/actual`); optional `ACTUAL_FILE_PASSWORD` for an e2e-encrypted file.
- Version/out-of-sync errors — the pinned `@actual-app/api` must track the server:
  compare `curl https://actual.marnas.sh/info` with `pkgs/actual-cli` in `~/.dotfiles`
  and bump version, lockfile and `npmDepsHash` together.
- Corrupt/stale local cache — delete `~/.cache/actual-cli` (it re-downloads in full).
- `infisical-secrets`/`infisical-token` errors — Infisical bootstrap problem, see the
  anytype skill's troubleshooting reference (same mechanism).
