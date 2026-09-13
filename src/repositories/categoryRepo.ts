import {
  DEFAULT_CATEGORY_COLORS,
  type Category,
  type CategoryKind,
} from '../domain/types'
import { withDb } from '../db'
import { createId } from '../utils/id'

type CategoryRow = {
  id: string
  type: string
  name: string
  color: string
  sort_order: number
  created_at: string
  updated_at: string
}

function mapRow(row: CategoryRow): Category {
  return {
    id: row.id,
    type: row.type as CategoryKind,
    name: row.name,
    color: row.color,
    sortOrder: row.sort_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

export const categoryRepo = {
  async listByType(type: CategoryKind): Promise<Category[]> {
    return withDb((db) => {
      // 手写 SQL：本地 SQLite 无 ORM
      const rows = db.all<CategoryRow>(
        `SELECT id, type, name, color, sort_order, created_at, updated_at
         FROM categories
         WHERE type = ?
         ORDER BY sort_order ASC, created_at ASC`,
        [type],
      )
      return rows.map(mapRow)
    })
  },

  /** 名称 → 颜色映射，供流水列表着色 */
  async colorMap(type?: CategoryKind): Promise<Record<string, string>> {
    return withDb((db) => {
      const rows = type
        ? db.all<{ name: string; color: string }>(
            'SELECT name, color FROM categories WHERE type = ?',
            [type],
          )
        : db.all<{ name: string; color: string }>(
            'SELECT name, color FROM categories',
          )
      const map: Record<string, string> = {}
      for (const row of rows) {
        map[row.name] = row.color
      }
      return map
    })
  },

  async create(input: { type: CategoryKind; name: string; color?: string }) {
    const name = input.name.trim()
    if (!name) throw new Error('分类名称不能为空')

    return withDb((db) => {
      const exists = db.get<{ id: string }>(
        'SELECT id FROM categories WHERE type = ? AND name = ?',
        [input.type, name],
      )
      if (exists) throw new Error('同类型下已有该分类')

      const max = db.get<{ m: number }>(
        'SELECT COALESCE(MAX(sort_order), -1) AS m FROM categories WHERE type = ?',
        [input.type],
      )
      const now = new Date().toISOString()
      const id = createId()
      const color =
        input.color ||
        DEFAULT_CATEGORY_COLORS[name] ||
        DEFAULT_CATEGORY_COLORS.__default
      db.run(
        `INSERT INTO categories (id, type, name, color, sort_order, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [id, input.type, name, color, (max?.m ?? -1) + 1, now, now],
      )
      return id
    })
  },

  /** 写入时确保分类进入历史；已存在则直接返回名称 */
  async ensure(type: CategoryKind, name: string) {
    const trimmed = name.trim()
    if (!trimmed) return ''
    return withDb((db) => {
      const exists = db.get<{ id: string }>(
        'SELECT id FROM categories WHERE type = ? AND name = ?',
        [type, trimmed],
      )
      if (exists) return trimmed

      const max = db.get<{ m: number }>(
        'SELECT COALESCE(MAX(sort_order), -1) AS m FROM categories WHERE type = ?',
        [type],
      )
      const now = new Date().toISOString()
      const color =
        DEFAULT_CATEGORY_COLORS[trimmed] || DEFAULT_CATEGORY_COLORS.__default
      db.run(
        `INSERT INTO categories (id, type, name, color, sort_order, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [createId(), type, trimmed, color, (max?.m ?? -1) + 1, now, now],
      )
      return trimmed
    })
  },

  async update(input: { id: string; name: string; color: string }) {
    const name = input.name.trim()
    if (!name) throw new Error('分类名称不能为空')

    return withDb((db) => {
      const row = db.get<CategoryRow>(
        `SELECT id, type, name, color, sort_order, created_at, updated_at
         FROM categories WHERE id = ?`,
        [input.id],
      )
      if (!row) throw new Error('分类不存在')

      const clash = db.get<{ id: string }>(
        `SELECT id FROM categories
         WHERE type = ? AND name = ? AND id != ?`,
        [row.type, name, input.id],
      )
      if (clash) throw new Error('同类型下已有该分类')

      const now = new Date().toISOString()
      db.run(
        `UPDATE categories
         SET name = ?, color = ?, updated_at = ?
         WHERE id = ?`,
        [name, input.color, now, input.id],
      )

      if (name !== row.name) {
        if (row.type === 'expense' || row.type === 'income') {
          db.run(
            `UPDATE transactions
             SET category = ?, updated_at = ?
             WHERE type = ? AND category = ?`,
            [name, now, row.type, row.name],
          )
        } else if (row.type === 'note') {
          db.run(
            `UPDATE notes SET category = ?, updated_at = ? WHERE category = ?`,
            [name, now, row.name],
          )
        } else if (row.type === 'task') {
          db.run(
            `UPDATE tasks SET category = ?, updated_at = ? WHERE category = ?`,
            [name, now, row.name],
          )
        }
      }
    })
  },

  async remove(id: string) {
    return withDb((db) => {
      const row = db.get<{ type: string; name: string }>(
        'SELECT type, name FROM categories WHERE id = ?',
        [id],
      )
      if (!row) throw new Error('分类不存在')

      const left = db.get<{ c: number }>(
        'SELECT COUNT(1) AS c FROM categories WHERE type = ?',
        [row.type],
      )
      if ((left?.c || 0) <= 1) {
        throw new Error('至少保留一个分类')
      }

      if (row.type === 'expense' || row.type === 'income') {
        const used = db.get<{ c: number }>(
          `SELECT COUNT(1) AS c FROM transactions
           WHERE type = ? AND category = ?`,
          [row.type, row.name],
        )
        if ((used?.c || 0) > 0) {
          throw new Error(`仍有 ${used!.c} 笔流水使用该分类，请先修改流水后再删`)
        }
      } else if (row.type === 'note') {
        const used = db.get<{ c: number }>(
          'SELECT COUNT(1) AS c FROM notes WHERE category = ?',
          [row.name],
        )
        if ((used?.c || 0) > 0) {
          throw new Error(`仍有 ${used!.c} 篇笔记使用该分类`)
        }
      } else if (row.type === 'task') {
        const used = db.get<{ c: number }>(
          'SELECT COUNT(1) AS c FROM tasks WHERE category = ?',
          [row.name],
        )
        if ((used?.c || 0) > 0) {
          throw new Error(`仍有 ${used!.c} 个任务使用该分类`)
        }
      }

      db.run('DELETE FROM categories WHERE id = ?', [id])
    })
  },
}
