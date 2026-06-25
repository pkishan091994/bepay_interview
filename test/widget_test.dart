import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:bepay_interview/core/theme/theme_notifier.dart';
import 'package:bepay_interview/injection_container.dart' as di;
import 'package:bepay_interview/main.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  setUp(() async {
    await di.sl.reset();
    await di.init();

    // Override real secure storage with mock to prevent platform channel exceptions in tests
    di.sl.unregister<FlutterSecureStorage>();
    di.sl.registerLazySingleton<FlutterSecureStorage>(
      () => MockFlutterSecureStorage(),
    );

    // Configure test screen dimensions with slightly wider bounds to accommodate
    // Flutter test environment fallback fonts, preventing mock text overflows
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      500 * 3,
      844 * 3,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
  });

  testWidgets('Wallet Home Screen displays total balance and assets', (
    WidgetTester tester,
  ) async {
    // Build our app wrapped with ThemeNotifier provider (mirrors main() entry point)
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    );

    // Settle the initial UI loading states
    await tester.pump();

    // Wait for the mock datasource simulated network delay (800ms) to resolve
    await tester.pumpAndSettle(const Duration(milliseconds: 900));

    // Verify total balance label is present
    expect(find.text('TOTAL BALANCE'), findsOneWidget);

    // Verify assets section title is present
    expect(find.text('Assets'), findsOneWidget);

    // Verify tokens USDC, ETH, SOL, BTC, MATIC are displayed
    expect(find.text('USDC'), findsOneWidget);
    expect(find.text('ETH'), findsOneWidget);
    expect(find.text('SOL'), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
    expect(find.text('MATIC'), findsOneWidget);
  });
}
