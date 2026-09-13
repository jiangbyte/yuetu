import type { DbClient } from './types'
import { createId } from '../utils/id'
import {
  DEFAULT_CATEGORY_COLORS,
  EXPENSE_CATEGORIES,
  INCOME_CATEGORIES,
  NOTE_CATEGORIES,
  TASK_CATEGORIES,
} from '../domain/types'

export const SCHEMA_VERSION = 5

/** 执行建表与版本迁移 */
export function migrate(db: DbClient) {
  // 1. 基础表（幂等）
  db.exec(`
    CREATE TABLE IF NOT EXISTS meta (
      key TEXT PRIMARY KEY NOT NULL,
      value TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS transactions (
      id TEXT PRIMARY KEY NOT NULL,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      category TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      payment_method TEXT NOT NULL DEFAULT '微信',
      occurred_at TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS notes (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      due_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_tx_occurred ON transactions(occurred_at);
    CREATE INDEX IF NOT EXISTS idx_tx_type ON transactions(type);
    CREATE INDEX IF NOT EXISTS idx_tasks_done ON tasks(done);
  `)

  // 2. 读取当前 schema 版本
  let version = 0
  const versionRow = db.get<{ value: string }>(
    'SELECT value FROM meta WHERE key = ?',
    ['schema_version'],
  )
  if (versionRow) {
    version = Number(versionRow.value) || 0
  } else {
    db.run('INSERT INTO meta (key, value) VALUES (?, ?)', [
      'schema_version',
      '0',
    ])
  }

  const ledgerName = db.get<{ value: string }>(
    'SELECT value FROM meta WHERE key = ?',
    ['ledger_name'],
  )
  if (!ledgerName) {
    db.run('INSERT INTO meta (key, value) VALUES (?, ?)', [
      'ledger_name',
      '月兔账本',
    ])
  }

  // 3. v2：分类表 + 默认收支种子
  if (version < 2) {
    migrateToV2(db)
    version = 2
  }

  // 4. v3：笔记/任务分类字段与种子
  if (version < 3) {
    migrateToV3(db)
    version = 3
  }

  // 5. v4：任务优先级
  if (version < 4) {
    migrateToV4(db)
    version = 4
  }

  // 6. v5：流水支付方式
  if (version < 5) {
    migrateToV5(db)
    version = 5
  }

  // 7. 列级兜底：避免版本号已升但 ALTER 未生效导致缺列
  ensureColumn(
    db,
    'transactions',
    'payment_method',
    `ALTER TABLE transactions ADD COLUMN payment_method TEXT NOT NULL DEFAULT '微信'`,
  )
  ensureColumn(
    db,
    'tasks',
    'priority',
    `ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT 'medium'`,
  )
  ensureColumn(
    db,
    'tasks',
    'category',
    `ALTER TABLE tasks ADD COLUMN category TEXT NOT NULL DEFAULT ''`,
  )
  ensureColumn(
    db,
    'notes',
    'category',
    `ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT ''`,
  )

  // 支付方式空值回填（幂等）
  if (hasColumn(db, 'transactions', 'payment_method')) {
    db.run(
      `UPDATE transactions
       SET payment_method = '微信'
       WHERE payment_method IS NULL OR payment_method = ''`,
    )
  }

  // 8. 写回版本号
  db.run(
    `INSERT INTO meta (key, value) VALUES (?, ?)
     ON CONFLICT(key) DO UPDATE SET value = excluded.value`,
    ['schema_version', String(SCHEMA_VERSION)],
  )
}

function hasColumn(db: DbClient, table: string, column: string) {
  // 1. 优先 PRAGMA；2. 再试 SELECT，避免 sql.js 下 PRAGMA 结果异常漏检
  try {
    const rows = db.all<Record<string, unknown>>(`PRAGMA table_info(${table})`)
    if (rows.some((r) => String(r.name) === column)) return true
  } catch {
    // ignore
  }
  try {
    db.get(`SELECT ${column} FROM ${table} LIMIT 1`)
    return true
  } catch {
    return false
  }
}

/** 缺列时执行 ALTER；已存在则跳过 */
function ensureColumn(
  db: DbClient,
  table: string,
  column: string,
  alterSql: string,
) {
  if (hasColumn(db, table, column)) return
  db.run(alterSql)
}

function seedCategories(
  db: DbClient,
  type: string,
  names: string[],
) {
  const now = new Date().toISOString()
  let order = 0
  for (const name of names) {
    const exists = db.get<{ id: string }>(
      'SELECT id FROM categories WHERE type = ? AND name = ?',
      [type, name],
    )
    if (exists) continue
    const color =
      DEFAULT_CATEGORY_COLORS[name] || DEFAULT_CATEGORY_COLORS.__default
    db.run(
      `INSERT INTO categories (id, type, name, color, sort_order, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [createId(), type, name, color, order++, now, now],
    )
  }
}

/** 新增 categories 表并写入默认收支分类 */
function migrateToV2(db: DbClient) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY NOT NULL,
      type TEXT NOT NULL,
      name TEXT NOT NULL,
      color TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE UNIQUE INDEX IF NOT EXISTS idx_cat_type_name ON categories(type, name);
    CREATE INDEX IF NOT EXISTS idx_cat_type_sort ON categories(type, sort_order);
  `)

  const count = db.get<{ c: number }>('SELECT COUNT(1) AS c FROM categories')
  if ((count?.c || 0) > 0) return

  seedCategories(db, 'expense', EXPENSE_CATEGORIES)
  seedCategories(db, 'income', INCOME_CATEGORIES)
}

/** 笔记/任务增加 category，并写入默认分类 */
function migrateToV3(db: DbClient) {
  db.exec(`
    CREATE TABLE IF NOT EXISTS categories (
      id TEXT PRIMARY KEY NOT NULL,
      type TEXT NOT NULL,
      name TEXT NOT NULL,
      color TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE UNIQUE INDEX IF NOT EXISTS idx_cat_type_name ON categories(type, name);
    CREATE INDEX IF NOT EXISTS idx_cat_type_sort ON categories(type, sort_order);
  `)

  if (!hasColumn(db, 'notes', 'category')) {
    db.exec(`ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT ''`)
  }
  if (!hasColumn(db, 'tasks', 'category')) {
    db.exec(`ALTER TABLE tasks ADD COLUMN category TEXT NOT NULL DEFAULT ''`)
  }

  seedCategories(db, 'note', NOTE_CATEGORIES)
  seedCategories(db, 'task', TASK_CATEGORIES)
}

/** 任务增加 priority，默认中；无截止日期的补创建日便于展示 */
function migrateToV4(db: DbClient) {
  if (!hasColumn(db, 'tasks', 'priority')) {
    db.exec(
      `ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT 'medium'`,
    )
  }
  db.run(
    `UPDATE tasks
     SET due_at = substr(created_at, 1, 10)
     WHERE due_at IS NULL OR due_at = ''`,
  )
}

/** 流水增加支付方式，默认微信 */
function migrateToV5(db: DbClient) {
  ensureColumn(
    db,
    'transactions',
    'payment_method',
    `ALTER TABLE transactions ADD COLUMN payment_method TEXT NOT NULL DEFAULT '微信'`,
  )
  db.run(
    `UPDATE transactions
     SET payment_method = '微信'
     WHERE payment_method IS NULL OR payment_method = ''`,
  )
}
