import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:bepay_interview/features/send_flow/domain/repositories/send_repository.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/estimate_fee.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/get_recent_recipients.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/submit_transaction.dart';

class MockSendRepository extends Mock implements SendRepository {}

void main() {
  late MockSendRepository mockRepository;
  late GetRecentRecipients getRecentRecipients;
  late EstimateFee estimateFee;
  late SubmitTransaction submitTransaction;

  setUp(() {
    mockRepository = MockSendRepository();
    getRecentRecipients = GetRecentRecipients(repository: mockRepository);
    estimateFee = EstimateFee(repository: mockRepository);
    submitTransaction = SubmitTransaction(repository: mockRepository);
  });

  group('GetRecentRecipients Usecase', () {
    const tRecipients = [
      Recipient(
        id: '1',
        name: 'Sarah Chen',
        address: 'sarah_c@bepay',
        type: RecipientType.bepayId,
        isExternal: false,
      ),
    ];

    test('should get recent recipients from the repository', () async {
      // arrange
      when(
        () => mockRepository.getRecentRecipients(),
      ).thenAnswer((_) async => tRecipients);
      // act
      final result = await getRecentRecipients(NoParams());
      // assert
      expect(result, tRecipients);
      verify(() => mockRepository.getRecentRecipients()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('EstimateFee Usecase', () {
    const tTokenSymbol = 'USDC';
    const tNetwork = 'Polygon';
    const tFee = 0.02;

    test('should estimate fee from the repository', () async {
      // arrange
      when(
        () => mockRepository.estimateFee(any(), any()),
      ).thenAnswer((_) async => tFee);
      // act
      final result = await estimateFee(
        const EstimateFeeParams(tokenSymbol: tTokenSymbol, network: tNetwork),
      );
      // assert
      expect(result, tFee);
      verify(
        () => mockRepository.estimateFee(tTokenSymbol, tNetwork),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('SubmitTransaction Usecase', () {
    const tTokenSymbol = 'USDC';
    const tRecipientAddress = 'sarah_c@bepay';
    const tAmount = 100.0;

    test('should submit transaction to the repository', () async {
      // arrange
      when(
        () => mockRepository.submitTransaction(
          tokenSymbol: any(named: 'tokenSymbol'),
          recipientAddress: any(named: 'recipientAddress'),
          amount: any(named: 'amount'),
        ),
      ).thenAnswer((_) async => true);
      // act
      final result = await submitTransaction(
        const SubmitTransactionParams(
          tokenSymbol: tTokenSymbol,
          recipientAddress: tRecipientAddress,
          amount: tAmount,
        ),
      );
      // assert
      expect(result, true);
      verify(
        () => mockRepository.submitTransaction(
          tokenSymbol: tTokenSymbol,
          recipientAddress: tRecipientAddress,
          amount: tAmount,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
