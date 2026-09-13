import { withDb } from '../db'
import type { Note } from '../domain/types'
import { createId } from '../utils/id'

type NoteRow = {
  id: string
  title: string
  content: string
  category: string
  created_at: string
  updated_at: string
}

function mapNote(row: NoteRow): Note {
  return {
    id: row.id,
    title: row.title,
    content: row.content || '',
    category: row.category || '',
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

export const noteRepo = {
  async list() {
    return withDb((db) => {
      const rows = db.all<NoteRow>(
        `SELECT id, title, content, category, created_at, updated_at
         FROM notes ORDER BY updated_at DESC`,
      )
      return rows.map(mapNote)
    })
  },

  async get(id: string) {
    return withDb((db) => {
      const row = db.get<NoteRow>(
        `SELECT id, title, content, category, created_at, updated_at
         FROM notes WHERE id = ?`,
        [id],
      )
      return row ? mapNote(row) : undefined
    })
  },

  async save(input: {
    id?: string
    title: string
    content: string
    category?: string
  }) {
    return withDb((db) => {
      const now = new Date().toISOString()
      const id = input.id || createId()
      const category = input.category || ''
      const existing = input.id
        ? db.get<{ id: string }>('SELECT id FROM notes WHERE id = ?', [id])
        : undefined

      if (existing) {
        db.run(
          `UPDATE notes
           SET title = ?, content = ?, category = ?, updated_at = ?
           WHERE id = ?`,
          [input.title, input.content, category, now, id],
        )
      } else {
        db.run(
          `INSERT INTO notes (id, title, content, category, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [id, input.title, input.content, category, now, now],
        )
      }
      return id
    })
  },

  async remove(id: string) {
    return withDb((db) => {
      db.run('DELETE FROM notes WHERE id = ?', [id])
    })
  },

  async clearAll() {
    return withDb((db) => {
      db.run('DELETE FROM notes')
    })
  },
}
