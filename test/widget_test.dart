import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuetu/app/app.dart';

void main() {
  testWidgets('启动后进入任务收集箱', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: YuetuApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('收集箱'), findsOneWidget);
    expect(find.text('任务'), findsWidgets);
  });
}
