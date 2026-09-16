import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuetu/app/app.dart';
import 'package:yuetu/core/constants/app_constants.dart';

void main() {
  testWidgets('首页展示品牌名', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: YuetuApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);
    expect(find.text('开始'), findsOneWidget);
  });
}
