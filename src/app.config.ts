export default defineAppConfig({
  pages: [
    'pages/ledger/index',
    'pages/calendar/index',
    'pages/tasks/index',
    'pages/mine/index',
    'pages/notes/index',
    'pages/reports/index',
    'pages/ledger/edit',
    'pages/notes/edit',
    'pages/tasks/edit',
    'pages/categories/index',
    'pages/mine/data',
    'pages/mine/about',
  ],
  window: {
    backgroundTextStyle: 'light',
    backgroundColor: '#f7f7f7',
    navigationBarBackgroundColor: '#ffffff',
    navigationBarTitleText: '月兔',
    navigationBarTextStyle: 'black',
    // H5 / Capacitor 用自定义顶栏，避免系统栏缺失导致无法返回
    navigationStyle: 'custom',
  },
  tabBar: {
    color: '#8c8c8c',
    selectedColor: '#1a1a1a',
    backgroundColor: '#ffffff',
    borderStyle: 'white',
    list: [
      {
        pagePath: 'pages/ledger/index',
        text: '流水',
        iconPath: 'assets/tab/ledger.png',
        selectedIconPath: 'assets/tab/ledger-active.png',
      },
      {
        pagePath: 'pages/calendar/index',
        text: '日历',
        iconPath: 'assets/tab/calendar.png',
        selectedIconPath: 'assets/tab/calendar-active.png',
      },
      {
        pagePath: 'pages/tasks/index',
        text: '事项',
        iconPath: 'assets/tab/tasks.png',
        selectedIconPath: 'assets/tab/tasks-active.png',
      },
      {
        pagePath: 'pages/mine/index',
        text: '我的',
        iconPath: 'assets/tab/mine.png',
        selectedIconPath: 'assets/tab/mine-active.png',
      },
    ],
  },
})
