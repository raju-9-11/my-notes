
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:journal_app/main.dart';
import 'package:journal_app/src/services/storage_service.dart';

void main() {
  testWidgets('Journal App Smoke Test - Login Screen', (WidgetTester tester) async {
    // Setup Mock Storage Provider Scope
    // Hive init is skipped or mocked via ProviderScope override if we had a full architecture.
    // Here we rely on the fact that LoginScreen doesn't touch storage.

    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Initial pump might show Loading if MockAuthService is slow or stream is waiting.
    // But MockAuthService uses a StreamController.broadcast which might be empty initially.
    // We expect loading indicator or Login Screen.

    // Pump frames to settle stream builder
    await tester.pump();

    // Verify
    expect(find.text('Sign in with Email'), findsOneWidget);
  });
}
