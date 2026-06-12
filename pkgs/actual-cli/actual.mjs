#!/usr/bin/env node
// Tier-1 CLI over the official Actual Budget API (@actual-app/api) — list accounts,
// categories, payees and transactions, categorize transactions (singly or in batch),
// annotate them, inspect/set budget months, create category groups/categories, and
// trigger bank sync. Targets the self-hosted server at https://actual.marnas.sh
// (override with $ACTUAL_SERVER_URL). Credentials are fetched from the self-hosted
// Infisical at call time (project `claude`, path /actual, secrets ACTUAL_PASSWORD +
// ACTUAL_SYNC_ID, optional ACTUAL_FILE_PASSWORD for e2e-encrypted files) via
// `infisical-secrets` — inherited from PATH (home.packages, see
// home-manager/cli/infisical) — and discarded when this process exits.
//
// API gotchas baked in here so callers don't trip on them:
//   - Amounts are integer MINOR UNITS (-5234 == -52.34); table output divides by 100.
//   - The API is local-first: every invocation syncs the budget into a per-user cache
//     dir ($XDG_CACHE_HOME/actual-cli), runs the verb against the local copy, and —
//     for mutating verbs — pushes the changes back with sync(). First run downloads
//     the whole file; later runs are incremental. No rate limits.
//   - The @actual-app/api version must track the server version (majors must match);
//     bump both together.

import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

import * as api from '@actual-app/api';

// @actual-app/core logs sync breadcrumbs straight to the console ("[Breadcrumb] ...",
// "Syncing since ..."), which would pollute the parseable table output. Silence those
// channels and route the CLI's own output through the saved originals. console.error
// stays live so real library errors still surface.
const print = console.log.bind(console);
for (const m of ['log', 'info', 'debug', 'warn', 'group', 'groupEnd']) console[m] = () => {};

const SERVER_URL = process.env.ACTUAL_SERVER_URL ?? 'https://actual.marnas.sh';

function die(msg, code = 1) {
  console.error(msg);
  process.exit(code);
}

function loadCreds() {
  const r = spawnSync('infisical-secrets', ['/actual'], { encoding: 'utf8' });
  if (r.error) die(`actual: failed to run infisical-secrets: ${r.error.message}`);
  if (r.status !== 0) die(`actual: infisical-secrets failed:\n${r.stderr ?? ''}`);
  const secrets = JSON.parse(r.stdout);
  if (!secrets.ACTUAL_PASSWORD || !secrets.ACTUAL_SYNC_ID) {
    die(
      'actual: missing ACTUAL_PASSWORD / ACTUAL_SYNC_ID in Infisical ' +
        `(project=claude env=${process.env.INFISICAL_ENV ?? 'prod'} path=/actual)`,
    );
  }
  return secrets;
}

// One budget session per invocation: connect, sync down, run the verb, push back if
// it mutated, always shut down (shutdown also releases the local db lock).
async function withBudget(fn, { mutates = false } = {}) {
  const creds = loadCreds();
  const dataDir = path.join(
    process.env.XDG_CACHE_HOME ?? path.join(os.homedir(), '.cache'),
    'actual-cli',
  );
  fs.mkdirSync(dataDir, { recursive: true });
  await api.init({ serverURL: SERVER_URL, password: creds.ACTUAL_PASSWORD, dataDir });
  try {
    await api.downloadBudget(
      creds.ACTUAL_SYNC_ID,
      creds.ACTUAL_FILE_PASSWORD ? { password: creds.ACTUAL_FILE_PASSWORD } : undefined,
    );
    await fn();
    if (mutates) await api.sync();
  } finally {
    await api.shutdown();
  }
}

const units = (n) => (n / 100).toFixed(2);
const row = (...cells) => print(cells.map((c) => c ?? '').join('\t'));

async function readStdin() {
  let data = '';
  for await (const chunk of process.stdin) data += chunk;
  return data;
}

// Open on-budget accounts only by default (closed/off-budget ones still satisfy old
// transactions but are noise for budgeting); --all includes everything.
async function cmdAccounts(args) {
  const all = args.includes('--all');
  await withBudget(async () => {
    const accounts = await api.getAccounts();
    for (const a of accounts) {
      if (!all && (a.closed || a.offbudget)) continue;
      const balance = await api.getAccountBalance(a.id);
      row(a.id, a.offbudget ? 'offbudget' : 'onbudget', a.name, units(balance));
    }
  });
}

// Rows: <id> <TAB> <GROUP|''> <TAB> <name>. Group header rows carry the group id and
// name (needed for add-category); category rows are indented under them. Amounts live
// in `budget`, not here — Actual categories have no standalone balance field.
async function cmdCategories(args) {
  const json = args.includes('--json');
  const all = args.includes('--all');
  await withBudget(async () => {
    const groups = await api.getCategoryGroups();
    if (json) {
      print(JSON.stringify(groups, null, 2));
      return;
    }
    for (const g of groups) {
      if (!all && g.hidden) continue;
      row(g.id, 'GROUP', g.name);
      for (const c of g.categories ?? []) {
        if (!all && c.hidden) continue;
        row(c.id, '', c.name);
      }
    }
  });
}

async function cmdPayees() {
  await withBudget(async () => {
    for (const p of await api.getPayees()) {
      if (p.transfer_acct) continue; // transfer payees mirror accounts — noise here
      row(p.id, p.name);
    }
  });
}

// ActualQL across all accounts (getTransactions is per-account). Default splits mode
// is 'inline': split children appear individually (each categorizable), parents are
// hidden. --uncategorized excludes transfers (their category is legitimately null).
async function cmdTxns(args) {
  let since = null;
  let account = null;
  let uncategorized = false;
  let json = false;
  while (args.length > 0) {
    const a = args.shift();
    if (a === '--since') since = args.shift();
    else if (a === '--account') account = args.shift();
    else if (a === '--uncategorized') uncategorized = true;
    else if (a === '--json') json = true;
    else die(`txns: unknown arg ${a}`, 2);
  }
  await withBudget(async () => {
    let query = api.q('transactions');
    if (since) query = query.filter({ date: { $gte: since } });
    if (account) query = query.filter({ account });
    if (uncategorized) query = query.filter({ category: null, transfer_id: null });
    query = query
      .select(['id', 'date', 'amount', 'payee.name', 'category.name', 'account.name', 'notes', 'cleared'])
      .orderBy({ date: 'desc' });
    const { data } = await api.aqlQuery(query);
    if (json) {
      print(JSON.stringify(data, null, 2));
      return;
    }
    for (const t of data) {
      row(
        t.id,
        t.date,
        units(t.amount),
        t['payee.name'] ?? '—',
        t['category.name'] ?? '(uncategorized)',
        t['account.name'],
        t.cleared ? 'cleared' : 'uncleared',
        t.notes ?? '',
      );
    }
  });
}

// Both forms apply locally then push ONE sync:
//   actual categorize <txn_id> <category_id>     single
//   actual categorize --stdin                    JSON array [{"id":..,"category":..,"notes"?:..},...]
async function cmdCategorize(args) {
  let items;
  if (args[0] === '--stdin') {
    items = JSON.parse(await readStdin());
    if (!Array.isArray(items)) die('categorize --stdin: expected a JSON array', 2);
  } else if (args.length === 2) {
    items = [{ id: args[0], category: args[1] }];
  } else {
    die('usage: actual categorize <txn_id> <category_id> | actual categorize --stdin', 2);
  }
  await withBudget(
    async () => {
      for (const t of items) {
        const fields = {};
        if (t.category !== undefined) fields.category = t.category;
        if (t.notes !== undefined) fields.notes = t.notes;
        await api.updateTransaction(t.id, fields);
      }
      print(`Categorized ${items.length} transaction(s)`);
    },
    { mutates: true },
  );
}

async function cmdNote(args) {
  if (args.length !== 2) die('usage: actual note <txn_id> <text>', 2);
  await withBudget(
    async () => {
      await api.updateTransaction(args[0], { notes: args[1] });
      print('Noted');
    },
    { mutates: true },
  );
}

async function cmdMonths() {
  await withBudget(async () => {
    for (const m of await api.getBudgetMonths()) print(m);
  });
}

// Header lines with the month totals, then per-group/category rows:
// <category_id> <TAB> <group|''> <TAB> <name> <TAB> budgeted <TAB> spent <TAB> balance
async function cmdBudget(args) {
  const month = args[0] ?? new Date().toISOString().slice(0, 7);
  await withBudget(async () => {
    const b = await api.getBudgetMonth(month);
    print(`month\t${b.month}`);
    print(`toBudget\t${units(b.toBudget)}`);
    print(`totalIncome\t${units(b.totalIncome)}`);
    print(`totalBudgeted\t${units(b.totalBudgeted)}`);
    print(`totalSpent\t${units(b.totalSpent)}`);
    print(`totalBalance\t${units(b.totalBalance)}`);
    for (const g of b.categoryGroups) {
      if (g.hidden) continue;
      row(g.id, 'GROUP', g.name);
      for (const c of g.categories ?? []) {
        if (c.hidden) continue;
        row(c.id, '', c.name, units(c.budgeted ?? 0), units(c.spent ?? 0), units(c.balance ?? 0));
      }
    }
  });
}

// Amount is in currency units here (the one place the CLI takes money input).
async function cmdSetBudget(args) {
  if (args.length !== 3) die('usage: actual set-budget <YYYY-MM> <category_id> <amount>', 2);
  const [month, categoryId, amount] = args;
  await withBudget(
    async () => {
      await api.setBudgetAmount(month, categoryId, Math.round(Number(amount) * 100));
      print(`Budgeted ${amount} for ${categoryId} in ${month}`);
    },
    { mutates: true },
  );
}

async function cmdAddGroup(args) {
  if (args.length !== 1) die('usage: actual add-group <name>', 2);
  await withBudget(
    async () => {
      const id = await api.createCategoryGroup({ name: args[0] });
      print(`Created group "${args[0]}" → ${id}`);
    },
    { mutates: true },
  );
}

async function cmdAddCategory(args) {
  if (args.length !== 2) die('usage: actual add-category <group_id> <name>', 2);
  await withBudget(
    async () => {
      const id = await api.createCategory({ name: args[1], group_id: args[0] });
      print(`Created category "${args[1]}" → ${id}`);
    },
    { mutates: true },
  );
}

// Link two separately-imported legs of the same transfer (e.g. a credit-card payment
// imported on both accounts). The duplicate leg is deleted first, then the kept leg's
// payee is set to the other account's transfer payee — core reacts by creating the
// linked mirror transaction, so the pair shows as one transfer in Actual.
async function cmdLinkTransfer(args) {
  if (args.length !== 2) die('usage: actual link-transfer <keep_txn_id> <dupe_txn_id>', 2);
  const [keepId, dupeId] = args;
  await withBudget(
    async () => {
      const { data } = await api.aqlQuery(
        api
          .q('transactions')
          .filter({ id: { $oneof: [keepId, dupeId] } })
          .select(['id', 'account', 'amount']),
      );
      const keep = data.find((t) => t.id === keepId);
      const dupe = data.find((t) => t.id === dupeId);
      if (!keep || !dupe) die('link-transfer: transaction(s) not found');
      if (keep.account === dupe.account) die('link-transfer: both legs are in the same account');
      if (keep.amount !== -dupe.amount) die('link-transfer: amounts are not equal-and-opposite');
      const transferPayee = (await api.getPayees()).find((p) => p.transfer_acct === dupe.account);
      if (!transferPayee) die('link-transfer: no transfer payee found for the other account');
      await api.deleteTransaction(dupeId);
      await api.updateTransaction(keepId, { payee: transferPayee.id, category: null });
      print(`Linked ${keepId} as a transfer to "${transferPayee.name}"; deleted duplicate ${dupeId}`);
    },
    { mutates: true },
  );
}

async function cmdRenameCategory(args) {
  if (args.length !== 2) die('usage: actual rename-category <category_id> <name>', 2);
  await withBudget(
    async () => {
      await api.updateCategory(args[0], { name: args[1] });
      print(`Renamed category ${args[0]} → "${args[1]}"`);
    },
    { mutates: true },
  );
}

async function cmdRenameGroup(args) {
  if (args.length !== 2) die('usage: actual rename-group <group_id> <name>', 2);
  await withBudget(
    async () => {
      await api.updateCategoryGroup(args[0], { name: args[1] });
      print(`Renamed group ${args[0]} → "${args[1]}"`);
    },
    { mutates: true },
  );
}

// Without a transfer category, transactions of the deleted category/group become
// uncategorized (deletion itself never touches transactions).
async function cmdRmCategory(args) {
  if (args.length < 1 || args.length > 2) {
    die('usage: actual rm-category <category_id> [transfer_category_id]', 2);
  }
  await withBudget(
    async () => {
      await api.deleteCategory(args[0], args[1]);
      print(`Deleted category ${args[0]}`);
    },
    { mutates: true },
  );
}

async function cmdRmGroup(args) {
  if (args.length < 1 || args.length > 2) {
    die('usage: actual rm-group <group_id> [transfer_category_id]', 2);
  }
  await withBudget(
    async () => {
      await api.deleteCategoryGroup(args[0], args[1]);
      print(`Deleted group ${args[0]} and its categories`);
    },
    { mutates: true },
  );
}

// Pulls new transactions from the bank-sync provider configured on the server
// (GoCardless/SimpleFIN) into the budget, for one account or all linked accounts.
async function cmdSync(args) {
  let account = null;
  if (args[0] === '--account') account = args[1];
  await withBudget(
    async () => {
      await api.runBankSync(account ? { accountId: account } : undefined);
      print('Bank sync complete');
    },
    { mutates: true },
  );
}

const HELP = `actual — manage your Actual Budget via the official API
  accounts [--all]                                open on-budget accounts (id, kind, name, balance)
  categories [--all] [--json]                     groups + categories (GROUP rows carry the group id)
  payees                                          payee list (id, name)
  txns [--since YYYY-MM-DD] [--account ID] [--uncategorized] [--json]   list transactions
  categorize <txn_id> <category_id>               set a transaction's category
  categorize --stdin                              bulk: [{"id":..,"category":..,"notes"?:..},...] on stdin
  note <txn_id> <text>                            set a transaction's notes
  link-transfer <keep_txn_id> <dupe_txn_id>       merge two imported legs of one transfer (deletes the dupe)
  months                                          list budget months (YYYY-MM)
  budget [YYYY-MM]                                month totals + per-category budgeted/spent/balance
  set-budget <YYYY-MM> <category_id> <amount>     budget an amount (currency units) for a category
  add-group <name>                                create a category group
  add-category <group_id> <name>                  create a category in a group
  rename-category <category_id> <name>            rename a category
  rename-group <group_id> <name>                  rename a category group
  rm-category <category_id> [transfer_cat_id]     delete a category (txns move to transfer_cat_id, else uncategorized)
  rm-group <group_id> [transfer_cat_id]           delete a group and all its categories
  sync [--account ID]                             run bank sync (all linked accounts or one)

  Amounts are integer minor units in raw JSON (-5234 == -52.34); table output is already in units.
  Server: ${SERVER_URL} (override with $ACTUAL_SERVER_URL)`;

const verbs = {
  accounts: cmdAccounts,
  categories: cmdCategories,
  payees: cmdPayees,
  txns: cmdTxns,
  categorize: cmdCategorize,
  note: cmdNote,
  'link-transfer': cmdLinkTransfer,
  months: cmdMonths,
  budget: cmdBudget,
  'set-budget': cmdSetBudget,
  'add-group': cmdAddGroup,
  'add-category': cmdAddCategory,
  'rename-category': cmdRenameCategory,
  'rename-group': cmdRenameGroup,
  'rm-category': cmdRmCategory,
  'rm-group': cmdRmGroup,
  sync: cmdSync,
};

const [verb, ...rest] = process.argv.slice(2);
if (!verb || verb === 'help' || verb === '-h' || verb === '--help') {
  console.error(HELP);
  process.exit(verb ? 0 : 2);
}
if (!verbs[verb]) die(`actual: unknown verb '${verb}' (try: actual help)`, 2);
try {
  await verbs[verb](rest);
} catch (e) {
  die(`actual: ${e.message ?? e}`);
}
