import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/app_dock.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/ledger/presentation/ledger_edit_page.dart';
import '../features/ledger/presentation/ledger_page.dart';
import '../features/mine/presentation/about_page.dart';
import '../features/mine/presentation/data_page.dart';
import '../features/mine/presentation/mine_page.dart';
import '../features/notes/presentation/note_edit_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/tasks/presentation/task_edit_page.dart';
import '../features/tasks/presentation/tasks_page.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// 应用路由：Shell 四 Tab + 全屏二级页。
GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/ledger',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ledger',
                builder: (context, state) => const LedgerPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mine',
                builder: (context, state) => const MinePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/ledger/edit',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final date = state.uri.queryParameters['date'];
          return LedgerEditPage(id: id, initialDate: date);
        },
      ),
      GoRoute(
        path: '/tasks/edit',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final date = state.uri.queryParameters['date'];
          return TaskEditPage(id: id, initialDue: date);
        },
      ),
      GoRoute(
        path: '/notes/edit',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return NoteEditPage(id: id);
        },
      ),
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final ym = state.uri.queryParameters['ym'];
          return ReportsPage(initialYm: ym);
        },
      ),
      GoRoute(
        path: '/categories',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/mine/data',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const DataPage(),
      ),
      GoRoute(
        path: '/mine/about',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
}

/// Shell：内容区 + 自定义 Dock。
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: navigationShell,
      bottomNavigationBar: AppDock(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        onQuickLedger: () => context.push('/ledger/edit'),
        onQuickTask: () => context.push('/tasks/edit'),
        onQuickNote: () => context.push('/notes/edit'),
      ),
    );
  }
}
