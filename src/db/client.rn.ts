import { open } from '@op-engineering/op-sqlite'
import type { DbClient, SqlParams } from './types'

/** 创建 RN 原生 SQLite 客户端 */
export async function createDbClient(): Promise<DbClient> {
  const db = open({ name: 'yuetu.db' })

  const client: DbClient = {
    exec(sql) {
      db.executeSync(sql)
    },
    run(sql, params = []) {
      db.executeSync(sql, params as any[])
    },
    get(sql, params = []) {
      const res = db.executeSync(sql, params as any[])
      const rows = res.rows ?? []
      return rows[0] as any
    },
    all(sql, params = []) {
      const res = db.executeSync(sql, params as any[])
      return (res.rows ?? []) as any[]
    },
    transaction(fn) {
      db.executeSync('BEGIN')
      try {
        fn()
        db.executeSync('COMMIT')
      } catch (e) {
        db.executeSync('ROLLBACK')
        throw e
      }
    },
  }

  return client
}

export type { SqlParams }
