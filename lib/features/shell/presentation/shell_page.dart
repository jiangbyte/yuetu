import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_dock.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../application/dock_provider.dart';
import '../domain/dock_module.dart';

/// Shell：内容区 + 可配置底栏（各页自带 FAB）。
class ShellPage extends ConsumerWidget {
  const ShellPage({
    super.key,
    required this.module,
    required this.child,
  });

  final DockModule module;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(dockProvider);
    final dockVisible = ref.watch(dockVisibleProvider);

    return AppScaffold(
      padding: EdgeInsets.zero,
      bottomBar: dockVisible
          ? AppDock(
              modules: modules,
              current: module,
              onSelect: (m) => context.go(m.routePath),
            )
          : null,
      body: child,
    );
  }
}
