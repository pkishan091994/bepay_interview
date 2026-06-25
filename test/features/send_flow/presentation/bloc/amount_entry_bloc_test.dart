import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/amount_entry/amount_entry_bloc.dart';

void main() {
  group('AmountEntryBloc Tests', () {
    late AmountEntryBloc amountEntryBloc;

    setUp(() {
      // Mocking token with balance 250.50 and 2 decimals (e.g., mock USDC/USDT precision)
      amountEntryBloc = AmountEntryBloc(maxBalance: 250.50, decimals: 2);
    });

    tearDown(() {
      amountEntryBloc.close();
    });

    test('initial state is correct', () {
      expect(amountEntryBloc.state.amountString, '0');
      expect(amountEntryBloc.state.amount, 0.0);
      expect(amountEntryBloc.state.isValid, false);
      expect(amountEntryBloc.state.errorMessage, isNull);
    });

    blocTest<AmountEntryBloc, AmountEntryState>(
      'emits correct state when typing digits',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('4'))
        ..add(const AmountKeyTyped('9')),
      expect: () => [
        const AmountEntryState(
          amountString: '4',
          amount: 4.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '49',
          amount: 49.0,
          isValid: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'ignores redundant leading zeros',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('0'))
        ..add(const AmountKeyTyped('0'))
        ..add(const AmountKeyTyped('5')),
      expect: () => [
        // The first '0' is already '0', so typing another '0' is ignored (no state emit)
        const AmountEntryState(
          amountString: '5',
          amount: 5.0,
          isValid: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'handles decimal point insertion correctly',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('.'))
        ..add(const AmountKeyTyped('5')),
      expect: () => [
        const AmountEntryState(
          amountString: '0.',
          amount: 0.0,
          isValid: false,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '0.5',
          amount: 0.5,
          isValid: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'ignores duplicate decimal points',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('1'))
        ..add(const AmountKeyTyped('.'))
        ..add(const AmountKeyTyped('.'))
        ..add(const AmountKeyTyped('2')),
      expect: () => [
        const AmountEntryState(
          amountString: '1',
          amount: 1.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '1.',
          amount: 1.0,
          isValid: true,
          errorMessage: null,
        ),
        // Duplicate '.' is ignored (no state change)
        const AmountEntryState(
          amountString: '1.2',
          amount: 1.2,
          isValid: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'restricts precision to token decimal limit',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('1'))
        ..add(const AmountKeyTyped('.'))
        ..add(const AmountKeyTyped('2'))
        ..add(const AmountKeyTyped('5'))
        ..add(
          const AmountKeyTyped('9'),
        ), // Decimals is 2, so '9' should be ignored
      expect: () => [
        const AmountEntryState(
          amountString: '1',
          amount: 1.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '1.',
          amount: 1.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '1.2',
          amount: 1.2,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '1.25',
          amount: 1.25,
          isValid: true,
          errorMessage: null,
        ),
        // '9' is ignored, so no new state is emitted
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'handles backspace correctly',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('1'))
        ..add(const AmountKeyTyped('2'))
        ..add(AmountBackspacePressed())
        ..add(AmountBackspacePressed()),
      expect: () => [
        const AmountEntryState(
          amountString: '1',
          amount: 1.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '12',
          amount: 12.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '1',
          amount: 1.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '0',
          amount: 0.0,
          isValid: false,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'sets amount to max balance when MAX event is sent',
      build: () => amountEntryBloc,
      act: (bloc) => bloc.add(AmountMaxPressed()),
      expect: () => [
        const AmountEntryState(
          amountString: '250.5',
          amount: 250.50,
          isValid: true,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'emits error when amount exceeds max balance limit',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('3'))
        ..add(const AmountKeyTyped('0'))
        ..add(const AmountKeyTyped('0')),
      expect: () => [
        const AmountEntryState(
          amountString: '3',
          amount: 3.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '30',
          amount: 30.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '300',
          amount: 300.0,
          isValid: false,
          errorMessage: 'Insufficient balance',
        ),
      ],
    );

    blocTest<AmountEntryBloc, AmountEntryState>(
      'resets state and updates maxBalance & decimals when AmountUpdateToken is received',
      build: () => amountEntryBloc,
      act: (bloc) => bloc
        ..add(const AmountKeyTyped('5'))
        ..add(const AmountUpdateToken(maxBalance: 10.0, decimals: 1)),
      expect: () => [
        const AmountEntryState(
          amountString: '5',
          amount: 5.0,
          isValid: true,
          errorMessage: null,
        ),
        const AmountEntryState(
          amountString: '0',
          amount: 0.0,
          isValid: false,
          errorMessage: null,
        ),
      ],
      verify: (bloc) {
        expect(bloc.maxBalance, 10.0);
        expect(bloc.decimals, 1);
      },
    );
  });
}
