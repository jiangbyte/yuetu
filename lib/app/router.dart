import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_page.dart';

/// 声明式路由表：空白壳仅挂载首页，后续 feature 在此扩展。
GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

/// 供 Riverpod 注入的路由实例。
final routerProvider = Provider<GoRouter>((ref) => createRouter());
