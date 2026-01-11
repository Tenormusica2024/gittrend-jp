// Basic smoke test for GitTrend JP app
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gittrend_jp/app.dart';

void main() {
  testWidgets('App smoke test - app should build without errors',
      (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: GitTrendApp(),
      ),
    );

    // Verify the app builds and shows something
    expect(find.byType(GitTrendApp), findsOneWidget);
  });
}
