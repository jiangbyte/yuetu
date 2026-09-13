import { withDb } from '../db'

export const metaRepo = {
  async getLedgerName() {
    return withDb((db) => {
      const row = db.get<{ value: string }>('SELECT value FROM meta WHERE key = ?', [
        'ledger_name',
      ])
      return row?.value || '月兔账本'
    })
  },

  async setLedgerName(name: string) {
    return withDb((db) => {
      db.run(
        `INSERT INTO meta (key, value) VALUES (?, ?)
         ON CONFLICT(key) DO UPDATE SET value = excluded.value`,
        ['ledger_name', name],
      )
    })
  },
}
