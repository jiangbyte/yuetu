import { withDb } from '../db'
import type {
  CategoryAgg,
  DayTrend,
  MonthSummary,
  Transaction,
  TxType,
} from '../domain/types'
import { DEFAULT_PAYMENT_METHOD } from '../domain/types'
import { createId } from '../utils/id'
import { monthRange } from '../utils/date'

type TxRow = {
  id: string
  type: string
  amount: number
  category: string
  note: string
  payment_method?: string
  occurred_at: string
  created_at: string
  updated_at: string
}

function mapTx(row: TxRow): Transaction {
  return {
    id: row.id,
    type: row.type as TxType,
    amount: row.amount,
    category: row.category,
    note: row.note || '',
    paymentMethod: row.payment_method || DEFAULT_PAYMENT_METHOD,
    occurredAt: row.occurred_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

const TX_COLS =
  'id, type, amount, category, note, payment_method, occurred_at, created_at, updated_at'

export const transactionRepo = {
  async listByMonth(ym: string) {
    return withDb((db) => {
      const { start, end } = monthRange(ym)
      const rows = db.all<TxRow>(
        `SELECT ${TX_COLS} FROM transactions
         WHERE occurred_at >= ? AND occurred_at <= ?
         ORDER BY occurred_at DESC, created_at DESC`,
        [start, end],
      )
      return rows.map(mapTx)
    })
  },

  async listByDate(date: string) {
    return withDb((db) => {
      const rows = db.all<TxRow>(
        `SELECT ${TX_COLS} FROM transactions
         WHERE occurred_at = ?
         ORDER BY created_at DESC`,
        [date],
      )
      return rows.map(mapTx)
    })
  },

  /** 某月每天是否有流水（日历圆点） */
  async dayMarksByMonth(ym: string) {
    return withDb((db) => {
      const { start, end } = monthRange(ym)
      const rows = db.all<{
        day: string
        income: number
        expense: number
        cnt: number
      }>(
        `SELECT
           occurred_at AS day,
           COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
           COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense,
           COUNT(1) AS cnt
         FROM transactions
         WHERE occurred_at >= ? AND occurred_at <= ?
         GROUP BY occurred_at`,
        [start, end],
      )
      const map: Record<
        string,
        { income: number; expense: number; count: number }
      > = {}
      for (const row of rows) {
        map[row.day] = {
          income: row.income,
          expense: row.expense,
          count: row.cnt,
        }
      }
      return map
    })
  },

  async get(id: string) {
    return withDb((db) => {
      const row = db.get<TxRow>(
        `SELECT ${TX_COLS} FROM transactions WHERE id = ?`,
        [id],
      )
      return row ? mapTx(row) : undefined
    })
  },

  async save(input: {
    id?: string
    type: TxType
    amount: number
    category: string
    note?: string
    paymentMethod?: string
    occurredAt: string
  }) {
    return withDb((db) => {
      // 1. 生成/读取主键
      // 2. 更新时保留未传入字段；新建写入默认支付方式
      const now = new Date().toISOString()
      const id = input.id || createId()
      const existing = input.id
        ? db.get<TxRow>(`SELECT ${TX_COLS} FROM transactions WHERE id = ?`, [id])
        : undefined
      const paymentMethod =
        input.paymentMethod ||
        existing?.payment_method ||
        DEFAULT_PAYMENT_METHOD

      if (existing) {
        db.run(
          `UPDATE transactions
           SET type = ?, amount = ?, category = ?, note = ?, payment_method = ?,
               occurred_at = ?, updated_at = ?
           WHERE id = ?`,
          [
            input.type,
            input.amount,
            input.category,
            input.note || '',
            paymentMethod,
            input.occurredAt,
            now,
            id,
          ],
        )
      } else {
        db.run(
          `INSERT INTO transactions
           (id, type, amount, category, note, payment_method, occurred_at, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            id,
            input.type,
            input.amount,
            input.category,
            input.note || '',
            paymentMethod,
            input.occurredAt,
            now,
            now,
          ],
        )
      }
      return id
    })
  },

  async remove(id: string) {
    return withDb((db) => {
      db.run('DELETE FROM transactions WHERE id = ?', [id])
    })
  },

  async monthSummary(ym: string): Promise<MonthSummary> {
    return withDb((db) => {
      const { start, end } = monthRange(ym)
      const row = db.get<{ income: number; expense: number }>(
        `SELECT
           COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
           COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense
         FROM transactions
         WHERE occurred_at >= ? AND occurred_at <= ?`,
        [start, end],
      )
      const income = row?.income || 0
      const expense = row?.expense || 0
      return { income, expense, balance: income - expense }
    })
  },

  async categoryAgg(ym: string, type: TxType = 'expense'): Promise<CategoryAgg[]> {
    return withDb((db) => {
      const { start, end } = monthRange(ym)
      return db.all<CategoryAgg>(
        `SELECT category, COALESCE(SUM(amount), 0) AS total
         FROM transactions
         WHERE type = ? AND occurred_at >= ? AND occurred_at <= ?
         GROUP BY category
         ORDER BY total DESC`,
        [type, start, end],
      )
    })
  },

  async dayTrend(ym: string): Promise<DayTrend[]> {
    return withDb((db) => {
      const { start, end } = monthRange(ym)
      return db.all<DayTrend>(
        `SELECT
           occurred_at AS day,
           COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
           COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense
         FROM transactions
         WHERE occurred_at >= ? AND occurred_at <= ?
         GROUP BY occurred_at
         ORDER BY occurred_at ASC`,
        [start, end],
      )
    })
  },

  async clearAll() {
    return withDb((db) => {
      db.run('DELETE FROM transactions')
    })
  },
}

export function groupByDay(list: Transaction[]) {
  const map = new Map<string, Transaction[]>()
  list.forEach((item) => {
    const arr = map.get(item.occurredAt) || []
    arr.push(item)
    map.set(item.occurredAt, arr)
  })
  return Array.from(map.entries()).map(([date, items]) => ({ date, items }))
}
