/// 领域常量：支付方式、默认分类与色板。
library;

const paymentMethods = ['微信', '支付宝', '现金', '银行卡', '信用卡', '其他'];

const defaultPaymentMethod = '微信';

const expenseCategories = [
  '餐饮',
  '交通',
  '购物',
  '居住',
  '娱乐',
  '医疗',
  '其他支出',
];

const incomeCategories = ['工资', '奖金', '理财', '其他收入'];

const noteCategories = ['灵感', '工作', '生活', '学习', '其他'];

const taskCategories = ['工作', '生活', '购物', '健康', '其他'];

const defaultCategoryColors = <String, String>{
  '餐饮': '#e07a5f',
  '交通': '#4a9fd8',
  '购物': '#8e6bb8',
  '居住': '#5a9e6f',
  '娱乐': '#c6b04a',
  '医疗': '#d96b6b',
  '其他支出': '#7a8694',
  '工资': '#1b9a82',
  '奖金': '#4caf7a',
  '理财': '#4a90c8',
  '其他收入': '#6b7c8a',
  '灵感': '#7a92a8',
  '工作': '#5b8fd4',
  '生活': '#4fad9f',
  '学习': '#8e6bb8',
  '健康': '#e07070',
  '其他': '#7a8694',
  '__default': '#7a8694',
};

const categoryColorPalette = [
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
];

String colorForCategory(String name) =>
    defaultCategoryColors[name] ?? defaultCategoryColors['__default']!;
