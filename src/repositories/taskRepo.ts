import { withDb } from '../db'
import type { Task, TaskPriority } from '../domain/types'
import { createId } from '../utils/id'
import { monthRange } from '../utils/date'

type TaskRow = {
  id: string
  title: string
  category: string
  done: number
  due_at: string | null
  priority: string
  created_at: string
  updated_at: string
}

function normalizePriority(value?: string | null): TaskPriority {
  if (value === 'high' || value === 'low' || value === 'medium') return value
  return 'medium'
}

function mapTask(row: TaskRow): Task {
  return {
    id: row.id,
    title: row.title,
    category: row.category || '',
    done: row.done ? 1 : 0,
    dueAt: row.due_at,
    priority: normalizePriority(row.priority),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

const TASK_COLS =
  'id, title, category, done, due_at, priority, created_at, updated_at'

/** 未完成优先 → 优先级高→低 → 有截止日期靠前 → 截止升序 → 更新倒序 */
const TASK_ORDER = `done ASC,
  CASE priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END,
  CASE WHEN due_at IS NULL THEN 1 ELSE 0 END,
  due_at ASC,
  updated_at DESC`

export const taskRepo = {
  async list() {
    return withDb((db) => {
      const rows = db.all<TaskRow>(
        `SELECT ${TASK_COLS} FROM tasks ORDER BY ${TASK_ORDER}`,
      )
      return rows.map(mapTask)
    })
  },

  async listByDueDate(date: string) {
    return withDb((db) => {
      const rows = db.all<TaskRow>(
        `SELECT ${TASK_COLS} FROM tasks
         WHERE due_at = ?
         ORDER BY ${TASK_ORDER}`,
        [date],
      )
      return rows.map(mapTask)
    })
  },

  async dueMarksByMonth(ym: string) {
    return withDb((db) => {
      const { start, end } = monthRange(ym)
      const rows = db.all<{ day: string; cnt: number }>(
        `SELECT due_at AS day, COUNT(1) AS cnt
         FROM tasks
         WHERE due_at IS NOT NULL AND due_at >= ? AND due_at <= ?
         GROUP BY due_at`,
        [start, end],
      )
      const map: Record<string, number> = {}
      for (const row of rows) {
        map[row.day] = row.cnt
      }
      return map
    })
  },

  async get(id: string) {
    return withDb((db) => {
      const row = db.get<TaskRow>(
        `SELECT ${TASK_COLS} FROM tasks WHERE id = ?`,
        [id],
      )
      return row ? mapTask(row) : undefined
    })
  },

  async save(input: {
    id?: string
    title: string
    category?: string
    done?: number
    dueAt?: string | null
    priority?: TaskPriority
  }) {
    return withDb((db) => {
      // 1. 生成/读取主键，补齐时间戳
      // 2. 已存在则更新字段（未传的保持原值）
      // 3. 新建则写入默认中优先级与可选截止日期
      const now = new Date().toISOString()
      const id = input.id || createId()
      const existing = input.id
        ? db.get<TaskRow>(`SELECT ${TASK_COLS} FROM tasks WHERE id = ?`, [id])
        : undefined

      if (existing) {
        db.run(
          `UPDATE tasks
           SET title = ?, category = ?, done = ?, due_at = ?, priority = ?, updated_at = ?
           WHERE id = ?`,
          [
            input.title,
            input.category ?? existing.category,
            input.done ?? existing.done,
            input.dueAt === undefined ? existing.due_at : input.dueAt,
            input.priority ?? normalizePriority(existing.priority),
            now,
            id,
          ],
        )
      } else {
        db.run(
          `INSERT INTO tasks (id, title, category, done, due_at, priority, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            id,
            input.title,
            input.category || '',
            input.done ?? 0,
            input.dueAt ?? null,
            input.priority ?? 'medium',
            now,
            now,
          ],
        )
      }
      return id
    })
  },

  async toggle(id: string) {
    return withDb((db) => {
      const row = db.get<TaskRow>(
        `SELECT ${TASK_COLS} FROM tasks WHERE id = ?`,
        [id],
      )
      if (!row) return
      const now = new Date().toISOString()
      db.run('UPDATE tasks SET done = ?, updated_at = ? WHERE id = ?', [
        row.done ? 0 : 1,
        now,
        id,
      ])
    })
  },

  async remove(id: string) {
    return withDb((db) => {
      db.run('DELETE FROM tasks WHERE id = ?', [id])
    })
  },

  async clearAll() {
    return withDb((db) => {
      db.run('DELETE FROM tasks')
    })
  },
}
