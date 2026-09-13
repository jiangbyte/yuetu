import type { Database } from 'sql.js'
import type { DbClient } from './types'

// file-loader 强制当文件资源发出，避免 webpack 按 wasm 模块解析
// eslint-disable-next-line @typescript-eslint/no-var-requires
const wasmMod = require('!!file-loader?esModule=false&name=static/[name].[ext]!../assets/sql-wasm-browser.wasm')
const wasmUrl: string = typeof wasmMod === 'string' ? wasmMod : String(wasmMod?.default || wasmMod)

const IDB_NAME = 'yuetu'
const IDB_STORE = 'sqlite'
const IDB_KEY = 'main'

function openIdb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(IDB_NAME, 1)
    req.onupgradeneeded = () => {
      const db = req.result
      if (!db.objectStoreNames.contains(IDB_STORE)) {
        db.createObjectStore(IDB_STORE)
      }
    }
    req.onsuccess = () => resolve(req.result)
    req.onerror = () => reject(req.error)
  })
}

async function loadBytes(): Promise<Uint8Array | null> {
  const idb = await openIdb()
  return new Promise((resolve, reject) => {
    const tx = idb.transaction(IDB_STORE, 'readonly')
    const req = tx.objectStore(IDB_STORE).get(IDB_KEY)
    req.onsuccess = () => {
      const val = req.result
      if (!val) {
        resolve(null)
        return
      }
      resolve(val instanceof Uint8Array ? val : new Uint8Array(val))
    }
    req.onerror = () => reject(req.error)
  })
}

async function saveBytes(data: Uint8Array) {
  const idb = await openIdb()
  return new Promise<void>((resolve, reject) => {
    const tx = idb.transaction(IDB_STORE, 'readwrite')
    tx.objectStore(IDB_STORE).put(data, IDB_KEY)
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error)
  })
}

function wrap(db: Database): DbClient {
  return {
    exec(sql) {
      db.run(sql)
    },
    run(sql, params = []) {
      db.run(sql, params as any[])
    },
    get(sql, params = []) {
      const stmt = db.prepare(sql)
      stmt.bind(params as any[])
      if (!stmt.step()) {
        stmt.free()
        return undefined
      }
      const row = stmt.getAsObject()
      stmt.free()
      return row as any
    },
    all(sql, params = []) {
      const stmt = db.prepare(sql)
      stmt.bind(params as any[])
      const rows: any[] = []
      while (stmt.step()) {
        rows.push(stmt.getAsObject())
      }
      stmt.free()
      return rows
    },
    transaction(fn) {
      db.run('BEGIN')
      try {
        fn()
        db.run('COMMIT')
      } catch (e) {
        db.run('ROLLBACK')
        throw e
      }
    },
    async persist() {
      await saveBytes(db.export())
    },
  }
}

/** 创建 H5 sql.js 客户端（browser wasm + IndexedDB 持久化） */
export async function createDbClient(): Promise<DbClient> {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const initSqlJs = require('sql.js/dist/sql-wasm-browser.js')
  const SQL = await (initSqlJs.default || initSqlJs)({
    locateFile: () => {
      const url = typeof wasmUrl === 'string' ? wasmUrl : String(wasmUrl)
      if (url.startsWith('http') || url.startsWith('/')) return url
      return `/${url.replace(/^\.\//, '')}`
    },
  })
  const bytes = await loadBytes()
  const db = bytes ? new SQL.Database(bytes) : new SQL.Database()
  return wrap(db)
}
