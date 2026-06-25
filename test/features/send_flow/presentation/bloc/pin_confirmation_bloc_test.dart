import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/pin_confirmation/pin_confirmation_bloc.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/submit_transaction.dart';

class MockSubmitTransaction extends Mock implements SubmitTransaction {}

void main() {
  group('PinConfirmationBloc Tests', () {
    late PinConfirmationBloc pinConfirmationBloc;
    late MockSubmitTransaction mockSubmitTransaction;

    setUpAll(() {
      registerFallbackValue(const SubmitTransactionParams(
        tokenSymbol: 'USDC',
        recipientAddress: '0x123',
        amount: 10.0,
      ));
    });

    setUp(() {
      mockSubmitTransaction = MockSubmitTransaction();
      pinConfirmationBloc = PinConfirmationBloc(submitTransaction: mockSubmitTransaction);
    });

    tearDown(() {
      pinConfirmationBloc.close();
    });

    test('initial state is correct', () {
      expect(pinConfirmationBloc.state.pin, '');
      expect(pinConfirmationBloc.state.errorMessage, isNull);
      expect(pinConfirmationBloc.state.isSubmitting, false);
      expect(pinConfirmationBloc.state.isSuccess, false);
      expect(pinConfirmationBloc.state.incorrectAttempts, 0);
      expect(pinConfirmationBloc.state.isLocked, false);
    });

    blocTest<PinConfirmationBloc, PinConfirmationState>(
      'submits transaction successfully with correct pin',
      setUp: () {
        when(() => mockSubmitTransaction(any())).thenAnswer((_) async => true);
      },
      build: () => pinConfirmationBloc,
      act: (bloc) => bloc
        ..add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0))
        ..add(const PinDigitEntered(digit: '2', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0))
        ..add(const PinDigitEntered(digit: '3', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0))
        ..add(const PinDigitEntered(digit: '4', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0)),
      expect: () => [
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '12'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '123'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1234'),
        isA<PinConfirmationState>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<PinConfirmationState>().having((s) => s.isSuccess, 'isSuccess', true),
      ],
    );

    blocTest<PinConfirmationBloc, PinConfirmationState>(
      'increments incorrect attempts and locks after 3 failures',
      build: () => pinConfirmationBloc,
      act: (bloc) async {
        // Attempt 1: 1111
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        await Future.delayed(const Duration(milliseconds: 15));

        // Attempt 2: 1111
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        await Future.delayed(const Duration(milliseconds: 15));

        // Attempt 3: 1111 -> Lockout
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
        bloc.add(const PinDigitEntered(digit: '1', tokenSymbol: 'USDC', recipientAddress: '0x123', amount: 10.0));
      },
      expect: () => [
        // Attempts 1
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '11'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '111'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1111'),
        isA<PinConfirmationState>().having((s) => s.incorrectAttempts, 'incorrectAttempts', 1),
        // Attempts 2
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '11'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '111'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1111'),
        isA<PinConfirmationState>().having((s) => s.incorrectAttempts, 'incorrectAttempts', 2),
        // Attempts 3 -> Lock
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '11'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '111'),
        isA<PinConfirmationState>().having((s) => s.pin, 'pin', '1111'),
        isA<PinConfirmationState>()
            .having((s) => s.incorrectAttempts, 'incorrectAttempts', 3)
            .having((s) => s.isLocked, 'isLocked', true),
      ],
    );
  });
}
