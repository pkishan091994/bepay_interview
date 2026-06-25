import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/pin_confirmation/pin_confirmation_bloc.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/review_transaction_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/pin_confirmation_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/transaction_success_screen.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/estimate_fee.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/submit_transaction.dart';
import 'package:bepay_interview/injection_container.dart' as di;

import 'package:go_router/go_router.dart';

class MockEstimateFee extends Mock implements EstimateFee {}

class MockSubmitTransaction extends Mock implements SubmitTransaction {}

// Mock classes for HttpOverrides to prevent NetworkImage exceptions in tests
class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class TestHttpOverrides extends HttpOverrides {
  final HttpClient client;
  TestHttpOverrides(this.client);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return client;
  }
}

// A Fake BLoC implementation extending SendFlowBloc directly to resolve the type assignment error
class FakeSendFlowBloc extends SendFlowBloc {
  final List<SendFlowEvent> addedEvents = [];
  final SendFlowState _customState;

  FakeSendFlowBloc(this._customState) : super(estimateFee: MockEstimateFee());

  @override
  SendFlowState get state => _customState;

  @override
  Stream<SendFlowState> get stream => Stream.value(_customState);

  @override
  void add(SendFlowEvent event) {
    addedEvents.add(event);
  }
}

void main() {
  late FakeSendFlowBloc fakeSendFlowBloc;
  late TokenBalance mockToken;
  late Recipient mockRecipient;
  late SendFlowState mockState;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(const SendFlowState());
    registerFallbackValue(Uri());
    registerFallbackValue(
      const EstimateFeeParams(tokenSymbol: '', network: ''),
    );
    registerFallbackValue(
      const SubmitTransactionParams(
        tokenSymbol: '',
        recipientAddress: '',
        amount: 0.0,
      ),
    );

    // Stub the HttpClient once outside the test run cycle to prevent nested Mocktail stubs
    mockHttpClient = MockHttpClient();
    final request = MockHttpClientRequest();
    final response = MockHttpClientResponse();
    final headers = MockHttpHeaders();

    when(() => mockHttpClient.getUrl(any())).thenAnswer((_) async => request);
    when(() => request.headers).thenReturn(headers);
    when(() => request.close()).thenAnswer((_) async => response);
    final transparentPngBytes = [
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      11,
      73,
      68,
      65,
      84,
      120,
      156,
      99,
      96,
      0,
      0,
      0,
      2,
      0,
      1,
      228,
      47,
      10,
      17,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ];

    when(() => response.statusCode).thenReturn(200);
    when(() => response.contentLength).thenReturn(transparentPngBytes.length);
    when(
      () => response.compressionState,
    ).thenReturn(HttpClientResponseCompressionState.notCompressed);

    when(
      () => response.listen(
        any(),
        cancelOnError: any(named: 'cancelOnError'),
        onDone: any(named: 'onDone'),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((Invocation invocation) {
      final void Function(List<int>)? onData =
          invocation.positionalArguments[0];
      final void Function()? onDone = invocation.namedArguments[#onDone];
      final void Function(Object, StackTrace)? onError =
          invocation.namedArguments[#onError];
      final bool? cancelOnError = invocation.namedArguments[#cancelOnError];

      return Stream<List<int>>.fromIterable([transparentPngBytes]).listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    });

    HttpOverrides.global = TestHttpOverrides(mockHttpClient);

    // Configure test screen dimensions to prevent overflows in testing environment
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      500 * 3,
      844 * 3,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 3.0;
  });

  setUp(() async {
    // Reset/clear sl before registering mock instances
    await di.sl.reset();

    final mockEstimateFee = MockEstimateFee();
    final mockSubmitTransaction = MockSubmitTransaction();

    di.sl.registerLazySingleton<EstimateFee>(() => mockEstimateFee);
    di.sl.registerLazySingleton<SubmitTransaction>(() => mockSubmitTransaction);
    di.sl.registerFactory(
      () => PinConfirmationBloc(submitTransaction: di.sl()),
    );

    when(() => mockEstimateFee(any())).thenAnswer((_) async => 0.02);
    when(() => mockSubmitTransaction(any())).thenAnswer((_) async => true);

    mockToken = const TokenBalance(
      id: 'usdc_polygon',
      name: 'USD Coin',
      symbol: 'USDC',
      balance: 250.50,
      fiatRate: 1.0,
      decimals: 6,
      network: 'Polygon',
    );

    mockRecipient = const Recipient(
      id: 'recipient_nikhil',
      name: 'Nikhil',
      address: 'nikhil@bepay',
      type: RecipientType.bepayId,
      isExternal: false,
    );

    mockState = SendFlowState(
      selectedToken: mockToken,
      recipient: mockRecipient,
      amount: 49.99,
      note: 'Dinner',
      currentStepIndex: 2,
    );

    fakeSendFlowBloc = FakeSendFlowBloc(mockState);
  });

  Widget createTestWidget(Widget child) {
    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(
          path: '/test',
          builder: (context, state) => BlocProvider<PinConfirmationBloc>(
            create: (context) => di.sl<PinConfirmationBloc>(),
            child: child,
          ),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/send/pin',
          builder: (context, state) => BlocProvider<PinConfirmationBloc>(
            create: (context) => di.sl<PinConfirmationBloc>(),
            child: const PinConfirmationScreen(),
          ),
        ),
        GoRoute(
          path: '/send/success',
          builder: (context, state) => const TransactionSuccessScreen(),
        ),
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return BlocProvider<SendFlowBloc>.value(
          value: fakeSendFlowBloc,
          child: MaterialApp.router(routerConfig: router),
        );
      },
    );
  }

  group('ReviewTransactionScreen Widget Tests', () {
    testWidgets('displays correct transaction review details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const ReviewTransactionScreen()),
      );
      await tester.pumpAndSettle();

      // Check amount
      expect(find.text('49.99 USDC'), findsOneWidget);

      // Check recipient address
      expect(find.text('nikhil@bepay'), findsOneWidget);

      // Check network name
      expect(find.text('Polygon'), findsOneWidget);

      // Check Flex Gas message
      expect(find.text('Network fee paid using USDC'), findsOneWidget);

      // Check fees & totals
      expect(find.text('0.02 USDC'), findsOneWidget);
      expect(find.text('50.01 USDC'), findsOneWidget);

      // Check warning banner
      expect(
        find.textContaining('Transactions cannot be reversed'),
        findsOneWidget,
      );

      // Check confirm & edit buttons are rendered
      expect(find.text('Confirm Transaction'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('note text field updates BLoC state when typed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const ReviewTransactionScreen()),
      );
      await tester.pumpAndSettle();

      final textFinder = find.byType(TextField);
      expect(textFinder, findsOneWidget);

      await tester.enterText(textFinder, 'Lunch');
      await tester.pump();

      // Verify event was captured in the Fake BLoC
      expect(fakeSendFlowBloc.addedEvents, contains(const UpdateNote('Lunch')));
    });
  });

  group('PinConfirmationScreen Widget Tests', () {
    testWidgets('renders all keys and verify button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const PinConfirmationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Confirm with PIN'), findsOneWidget);
      expect(find.text('Enter your 4-digit security PIN'), findsOneWidget);

      // Digits 0-9
      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }

      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('incorrect PIN entry shows error feedback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const PinConfirmationScreen()));
      await tester.pumpAndSettle();

      // Type "1111" with widget tree pump cycles between key taps
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Incorrect PIN. Please try again.'), findsOneWidget);
    });

    testWidgets(
      'correct PIN entry shows loading spinner and navigates to success screen',
      (WidgetTester tester) async {
        final mockSubmitTransaction = di.sl<SubmitTransaction>();
        when(() => mockSubmitTransaction(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return true;
        });

        await tester.pumpWidget(
          createTestWidget(const PinConfirmationScreen()),
        );
        await tester.pumpAndSettle();

        // Type correct PIN "1234"
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.tap(find.text('4'));

        // Let it trigger verification and trigger state update
        await tester.pump();

        // Verify that it is in submitting state (shows CircularProgressIndicator)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the submit transaction delay
        await tester.pump(const Duration(milliseconds: 60));
        // Pump and settle to complete navigation transitions
        await tester.pumpAndSettle();

        // Verify success screen is shown
        expect(find.text('Transaction Successful'), findsOneWidget);
        expect(find.text('49.99 USDC sent to nikhil@bepay'), findsOneWidget);
      },
    );
  });

  group('TransactionSuccessScreen Widget Tests', () {
    testWidgets('renders success details and copier icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const TransactionSuccessScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transaction Successful'), findsOneWidget);
      expect(find.text('49.99 USDC sent to nikhil@bepay'), findsOneWidget);
      expect(find.text('Polygon'), findsOneWidget);
      expect(find.text('tx_123456789'), findsOneWidget);
      expect(find.text('0.02 USDC'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });
  });
}
