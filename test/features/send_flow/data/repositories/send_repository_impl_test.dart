import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bepay_interview/features/send_flow/data/datasources/send_local_data_source.dart';
import 'package:bepay_interview/features/send_flow/data/models/recipient_model.dart';
import 'package:bepay_interview/features/send_flow/data/repositories/send_repository_impl.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';

class MockSendLocalDataSource extends Mock implements SendLocalDataSource {}

void main() {
  late MockSendLocalDataSource mockLocalDataSource;
  late SendRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockSendLocalDataSource();
    repository = SendRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('getRecentRecipients', () {
    const tRecipients = [
      RecipientModel(
        id: '1',
        name: 'Sarah Chen',
        address: 'sarah_c@bepay',
        type: RecipientType.bepayId,
        isExternal: false,
      ),
    ];

    test(
      'should return recent recipients when the call to local data source is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.getRecentRecipients(),
        ).thenAnswer((_) async => tRecipients);
        // act
        final result = await repository.getRecentRecipients();
        // assert
        expect(result, tRecipients);
        verify(() => mockLocalDataSource.getRecentRecipients()).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      },
    );
  });

  group('estimateFee', () {
    const tTokenSymbol = 'USDC';
    const tNetwork = 'Polygon';
    const tFee = 0.02;

    test('should return estimated fee from the local data source', () async {
      // arrange
      when(
        () => mockLocalDataSource.estimateFee(any(), any()),
      ).thenAnswer((_) async => tFee);
      // act
      final result = await repository.estimateFee(tTokenSymbol, tNetwork);
      // assert
      expect(result, tFee);
      verify(
        () => mockLocalDataSource.estimateFee(tTokenSymbol, tNetwork),
      ).called(1);
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('submitTransaction', () {
    const tTokenSymbol = 'USDC';
    const tRecipientAddress = 'sarah_c@bepay';
    const tAmount = 100.0;

    test(
      'should submit transaction to local data source and return result',
      () async {
        // arrange
        when(
          () => mockLocalDataSource.submitTransaction(
            tokenSymbol: any(named: 'tokenSymbol'),
            recipientAddress: any(named: 'recipientAddress'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => true);
        // act
        final result = await repository.submitTransaction(
          tokenSymbol: tTokenSymbol,
          recipientAddress: tRecipientAddress,
          amount: tAmount,
        );
        // assert
        expect(result, true);
        verify(
          () => mockLocalDataSource.submitTransaction(
            tokenSymbol: tTokenSymbol,
            recipientAddress: tRecipientAddress,
            amount: tAmount,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      },
    );
  });
}
