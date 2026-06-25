import 'package:flutter_test/flutter_test.dart';
import 'package:bepay_interview/features/send_flow/data/datasources/send_local_data_source.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';

void main() {
  late SendLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = SendLocalDataSourceImpl();
  });

  group('getRecentRecipients', () {
    test('should return list of mock recipients', () async {
      final result = await dataSource.getRecentRecipients();
      expect(result, isNotEmpty);
      expect(result.first.name, 'Sarah Chen');
      expect(result.first.type, RecipientType.bepayId);
    });
  });

  group('estimateFee', () {
    test('should return standard fee', () async {
      final result = await dataSource.estimateFee('USDC', 'Polygon');
      expect(result, 0.02);
    });
  });

  group('submitTransaction', () {
    test('should return true representing mock success', () async {
      final result = await dataSource.submitTransaction(
        tokenSymbol: 'USDC',
        recipientAddress: 'sarah_c@bepay',
        amount: 100.0,
      );
      expect(result, true);
    });
  });
}
