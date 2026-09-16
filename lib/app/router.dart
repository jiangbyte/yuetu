import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tokens.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/checkin/presentation/checkin_page.dart';
import '../features/checkin/presentation/habit_create_page.dart';
import '../features/checkin/presentation/habit_done_page.dart';
import '../features/checkin/presentation/habit_library_page.dart';
import '../features/checkin/presentation/habit_slide_page.dart';
import '../features/memorial/domain/memorial_item.dart';
import '../features/memorial/presentation/memorial_detail_page.dart';
import '../features/memorial/presentation/memorial_edit_page.dart';
import '../features/memorial/presentation/memorial_page.dart';
import '../features/focus/presentation/focus_page.dart';
import '../features/ledger/presentation/ledger_budget_page.dart';
import '../features/ledger/presentation/ledger_edit_page.dart';
import '../features/ledger/presentation/ledger_page.dart';
import '../features/mine/presentation/about_page.dart';
import '../features/mine/presentation/dock_settings_page.dart';
import '../features/mine/presentation/more_page.dart';
import '../features/notes/presentation/note_edit_page.dart';
import '../features/notes/presentation/notes_page.dart';
import '../features/shell/domain/dock_module.dart';
import '../features/shell/presentation/shell_page.dart';
import '../features/tasks/presentation/tasks_page.dart';

/// 根据路径解析当前底栏模块。
DockModule moduleFromPath(String path) {
  if (path.startsWith('/tasks')) return DockModule.tasks;
  if (path.startsWith('/calendar')) return DockModule.calendar;
  if (path.startsWith('/ledger')) return DockModule.ledger;
  if (path.startsWith('/notes')) return DockModule.notes;
  if (path.startsWith('/focus')) return DockModule.focus;
  if (path.startsWith('/checkin')) return DockModule.checkin;
  if (path.startsWith('/memorial')) return DockModule.memorial;
  return DockModule.more;
}

/// 底栏页无过渡，避免切换时白屏闪一下。
CustomTransitionPage<void> _shellPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

/// 应用路由表。
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/tasks',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ShellPage(
            module: moduleFromPath(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) =>
                _shellPage(state, const TasksPage()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) =>
                _shellPage(state, const CalendarPage()),
          ),
          GoRoute(
            path: '/ledger',
            pageBuilder: (context, state) =>
                _shellPage(state, const LedgerPage()),
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) =>
                _shellPage(state, const NotesPage()),
          ),
          GoRoute(
            path: '/focus',
            pageBuilder: (context, state) =>
                _shellPage(state, const FocusPage()),
          ),
          GoRoute(
            path: '/checkin',
            pageBuilder: (context, state) =>
                _shellPage(state, const CheckInPage()),
          ),
          GoRoute(
            path: '/memorial',
            pageBuilder: (context, state) =>
                _shellPage(state, const MemorialPage()),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) =>
                _shellPage(state, const MorePage()),
          ),
        ],
      ),
      GoRoute(
        path: '/memorial/edit',
        builder: (context, state) {
          final typeName = state.uri.queryParameters['type'];
          MemorialType? type;
          if (typeName != null) {
            for (final t in MemorialType.values) {
              if (t.name == typeName) {
                type = t;
                break;
              }
            }
          }
          return MemorialEditPage(type: type);
        },
      ),
      GoRoute(
        path: '/memorial/:id',
        builder: (context, state) => MemorialDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/checkin/library',
        builder: (context, state) => const HabitLibraryPage(),
      ),
      GoRoute(
        path: '/checkin/create',
        builder: (context, state) => const HabitCreatePage(),
      ),
      GoRoute(
        path: '/checkin/slide/:id',
        builder: (context, state) => HabitSlidePage(
          habitId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/checkin/done/:id',
        builder: (context, state) => HabitDonePage(
          habitId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ledger/edit',
        pageBuilder: (context, state) => _shellPage(
          state,
          const LedgerEditPage(),
        ),
      ),
      GoRoute(
        path: '/ledger/budget',
        builder: (context, state) {
          final year = int.tryParse(state.uri.queryParameters['year'] ?? '') ??
              DateTime.now().year;
          final month =
              int.tryParse(state.uri.queryParameters['month'] ?? '') ??
                  DateTime.now().month;
          return LedgerBudgetPage(month: DateTime(year, month));
        },
      ),
      GoRoute(
        path: '/notes/edit/:id',
        pageBuilder: (context, state) => _shellPage(
          state,
          NoteEditPage(noteId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/more/dock',
        pageBuilder: (context, state) => _shellPage(
          state,
          const Material(
            color: AppColors.canvas,
            child: SafeArea(child: DockSettingsPage()),
          ),
        ),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _shellPage(
          state,
          const Material(
            color: AppColors.canvas,
            child: SafeArea(child: AboutPage()),
          ),
        ),
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => createRouter());
