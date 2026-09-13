import { createDbClient } from './client'
import { migrate } from './migrations'
import type { DbClient } from './types'

let ready: Promise<DbClient> | null = null
let instance: DbClient | null = null

/** 启动时初始化 SQLite 并跑迁移 */
export function initDb() {
  if (!ready) {
    ready = (async () => {
      const db = await createDbClient()
      migrate(db)
      await db.persist?.()
      instance = db
      return db
    })()
  }
  return ready
}

export function getDb() {
  if (!instance) {
    throw new Error('数据库尚未初始化')
  }
  return instance
}

export async function withDb<T>(fn: (db: DbClient) => T | Promise<T>) {
  const db = await initDb()
  // 每次访问再跑一遍幂等迁移，避免 HMR / 版本号已升但缺列
  migrate(db)
  const result = await fn(db)
  await db.persist?.()
  return result
}
