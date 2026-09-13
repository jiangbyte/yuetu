import { withDb } from '../db'

/**
 * 汇总本机业务数据，供导出与清空入口使用。
 */
export const dataRepo = {
  /**
   * 导出流水、笔记、任务、分类与元信息为可序列化对象。
   */
  async exportBundle() {
    return withDb((db) => {
      // 1. 按表拉取全量，避免导出遗漏
      // 2. 附带导出时间，便于文件命名与回溯
      const transactions = db.all('SELECT * FROM transactions ORDER BY occurred_at DESC')
      const notes = db.all('SELECT * FROM notes ORDER BY updated_at DESC')
      const tasks = db.all('SELECT * FROM tasks ORDER BY updated_at DESC')
      const categories = db.all('SELECT * FROM categories ORDER BY type, sort_order')
      const meta = db.all('SELECT * FROM meta')
      return {
        app: 'yuetu',
        version: 1,
        exportedAt: new Date().toISOString(),
        transactions,
        notes,
        tasks,
        categories,
        meta,
      }
    })
  },

  /**
   * 清空流水、笔记、任务（分类与元信息保留）。
   */
  async clearUserContent() {
    return withDb(async (db) => {
      // 1. 事务内删除三类内容表，保证要么全清要么全保留
      // 2. 分类与 meta 不动，避免用户预设结构丢失
      db.transaction(() => {
        db.run('DELETE FROM transactions')
        db.run('DELETE FROM notes')
        db.run('DELETE FROM tasks')
      })
      if (db.persist) await db.persist()
    })
  },
}
