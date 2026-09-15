import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/repositories/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 预热数据库并写入默认分类种子
  final container = ProviderContainer();
  await container.read(databaseProvider).seedDefaultCategories();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const YuetuApp(),
    ),
  );
}
