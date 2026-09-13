export type SqlParams = Array<string | number | null>

export type DbClient = {
  exec: (sql: string) => void
  run: (sql: string, params?: SqlParams) => void
  get: <T = Record<string, any>>(sql: string, params?: SqlParams) => T | undefined
  all: <T = Record<string, any>>(sql: string, params?: SqlParams) => T[]
  transaction: (fn: () => void) => void
  persist?: () => Promise<void>
}
