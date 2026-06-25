import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/recipient_entry/recipient_entry_bloc.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/get_recent_recipients.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:bepay_interview/core/usecases/usecase.dart';

class MockGetRecentRecipients extends Mock implements GetRecentRecipients {}

void main() {
  group('RecipientEntryBloc Tests', () {
    late RecipientEntryBloc recipientEntryBloc;
    late MockGetRecentRecipients mockGetRecentRecipients;

    setUpAll(() {
      registerFallbackValue(NoParams());
    });

    setUp(() {
      mockGetRecentRecipients = MockGetRecentRecipients();
      when(() => mockGetRecentRecipients(any())).thenAnswer((_) async => []);
      recipientEntryBloc =
          RecipientEntryBloc(getRecentRecipients: mockGetRecentRecipients);
    });

    tearDown(() {
      recipientEntryBloc.close();
    });

    test('initial state is correct', () {
      expect(recipientEntryBloc.state.inputString, '');
      expect(recipientEntryBloc.state.recipient, isNull);
      expect(recipientEntryBloc.state.isValid, false);
      expect(recipientEntryBloc.state.errorMessage, isNull);
      expect(recipientEntryBloc.state.selectedTab, 0);
    });

    blocTest<RecipientEntryBloc, RecipientEntryState>(
      'validates nikhil@bepay successfully in Bepay ID tab',
      build: () => recipientEntryBloc,
      act: (bloc) => bloc.add(const RecipientInputChanged('nikhil@bepay')),
      expect: () => [
        isA<RecipientEntryState>()
            .having((s) => s.inputString, 'inputString', 'nikhil@bepay')
            .having((s) => s.isValid, 'isValid', true)
            .having(
              (s) => s.recipient?.type,
              'recipient.type',
              RecipientType.bepayId,
            )
            .having((s) => s.recipient?.isExternal, 'recipient.isExternal', false),
      ],
    );

    blocTest<RecipientEntryBloc, RecipientEntryState>(
      'validates mixed case evm address successfully in Wallet Address tab',
      build: () => recipientEntryBloc,
      act: (bloc) => bloc
        ..add(const RecipientTabChanged(1))
        ..add(
          const RecipientInputChanged(
            '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
          ),
        ),
      expect: () => [
        // Tab changed state
        const RecipientEntryState(
          selectedTab: 1,
          inputString: '',
          recipient: null,
          isValid: false,
          errorMessage: null,
          recentRecipients: [],
        ),
        // Input changed state
        isA<RecipientEntryState>()
            .having(
              (s) => s.inputString,
              'inputString',
              '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
            )
            .having((s) => s.isValid, 'isValid', true)
            .having(
              (s) => s.recipient?.type,
              'recipient.type',
              RecipientType.address,
            )
            .having((s) => s.recipient?.isExternal, 'recipient.isExternal', true),
      ],
    );

    blocTest<RecipientEntryBloc, RecipientEntryState>(
      'validates user@example.com email successfully in Bepay ID tab',
      build: () => recipientEntryBloc,
      act: (bloc) => bloc.add(const RecipientInputChanged('user@example.com')),
      expect: () => [
        isA<RecipientEntryState>()
            .having((s) => s.inputString, 'inputString', 'user@example.com')
            .having((s) => s.isValid, 'isValid', true)
            .having(
              (s) => s.recipient?.type,
              'recipient.type',
              RecipientType.email,
            )
            .having((s) => s.recipient?.isExternal, 'recipient.isExternal', false),
      ],
    );

    blocTest<RecipientEntryBloc, RecipientEntryState>(
      'validates +919999999999 phone successfully in Bepay ID tab',
      build: () => recipientEntryBloc,
      act: (bloc) => bloc.add(const RecipientInputChanged('+919999999999')),
      expect: () => [
        isA<RecipientEntryState>()
            .having((s) => s.inputString, 'inputString', '+919999999999')
            .having((s) => s.isValid, 'isValid', true)
            .having(
              (s) => s.recipient?.type,
              'recipient.type',
              RecipientType.phone,
            )
            .having((s) => s.recipient?.isExternal, 'recipient.isExternal', false),
      ],
    );

    blocTest<RecipientEntryBloc, RecipientEntryState>(
      'shows tab switch warning when EVM address is typed in Bepay ID tab',
      build: () => recipientEntryBloc,
      act: (bloc) => bloc.add(
        const RecipientInputChanged(
          '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        ),
      ),
      expect: () => [
        const RecipientEntryState(
          inputString: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
          recipient: null,
          isValid: false,
          errorMessage:
              'This is a wallet address. Please switch to the Wallet Address tab.',
          recentRecipients: [],
        ),
      ],
    );
  });
}
