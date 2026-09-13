export type TxType = 'income' | 'expense'

/** 分类所属业务域 */
export type CategoryKind = TxType | 'note' | 'task'

export type Transaction = {
  id: string
  type: TxType
  amount: number
  category: string
  note: string
  /** 支付/到账方式 */
  paymentMethod: string
  occurredAt: string
  createdAt: string
  updatedAt: string
}

/** 流水默认支付方式 */
export const PAYMENT_METHODS = [
  '微信',
  '支付宝',
  '现金',
  '银行卡',
  '信用卡',
  '其他',
] as const

export const DEFAULT_PAYMENT_METHOD = '微信'

export type Note = {
  id: string
  title: string
  content: string
  category: string
  createdAt: string
  updatedAt: string
}

/** 任务优先级 */
export type TaskPriority = 'high' | 'medium' | 'low'

export type Task = {
  id: string
  title: string
  category: string
  done: number
  dueAt: string | null
  priority: TaskPriority
  createdAt: string
  updatedAt: string
}

export const TASK_PRIORITIES: Array<{
  key: TaskPriority
  label: string
}> = [
  { key: 'high', label: '高' },
  { key: 'medium', label: '中' },
  { key: 'low', label: '低' },
]

export function taskPriorityLabel(priority: TaskPriority) {
  return TASK_PRIORITIES.find((p) => p.key === priority)?.label || '中'
}

export type MonthSummary = {
  income: number
  expense: number
  balance: number
}

export type CategoryAgg = {
  category: string
  total: number
}

export type DayTrend = {
  day: string
  income: number
  expense: number
}

export type Category = {
  id: string
  type: CategoryKind
  name: string
  color: string
  sortOrder: number
  createdAt: string
  updatedAt: string
}

/** 默认种子名（迁移用）；运行时以 categories 表为准 */
export const EXPENSE_CATEGORIES = [
  '餐饮',
  '交通',
  '购物',
  '居住',
  '娱乐',
  '医疗',
  '其他支出',
]

export const INCOME_CATEGORIES = ['工资', '奖金', '理财', '其他收入']

export const NOTE_CATEGORIES = ['灵感', '工作', '生活', '学习', '其他']

export const TASK_CATEGORIES = ['工作', '生活', '购物', '健康', '其他']

export const DEFAULT_CATEGORY_COLORS: Record<string, string> = {
  餐饮: '#e07a5f',
  交通: '#4a9fd8',
  购物: '#8e6bb8',
  居住: '#5a9e6f',
  娱乐: '#c6b04a',
  医疗: '#d96b6b',
  其他支出: '#7a8694',
  工资: '#1b9a82',
  奖金: '#4caf7a',
  理财: '#4a90c8',
  其他收入: '#6b7c8a',
  灵感: '#7a92a8',
  工作: '#5b8fd4',
  生活: '#4fad9f',
  学习: '#8e6bb8',
  健康: '#e07070',
  其他: '#7a8694',
  __default: '#7a8694',
}

/** 分类管理页可选色板（含玉兔冷色与分类语义色） */
export const CATEGORY_COLOR_PALETTE = [
  '#e07a5f',
  '#4a9fd8',
  '#8e6bb8',
  '#5a9e6f',
  '#c6b04a',
  '#d96b6b',
  '#7a8694',
  '#4fad9f',
  '#3a8f83',
  '#5b8fd4',
  '#7a92a8',
  '#1a1a1a',
]
