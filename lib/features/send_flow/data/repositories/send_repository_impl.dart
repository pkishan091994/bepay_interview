import 'package:bepay_interview/features/send_flow/data/datasources/send_local_data_source.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:bepay_interview/features/send_flow/domain/repositories/send_repository.dart';

class SendRepositoryImpl implements SendRepository {
  final SendLocalDataSource localDataSource;

  SendRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Recipient>> getRecentRecipients() async {
    return await localDataSource.getRecentRecipients();
  }

  @override
  Future<double> estimateFee(String tokenSymbol, String network) async {
    return await localDataSource.estimateFee(tokenSymbol, network);
  }

  @override
  Future<bool> submitTransaction({
    required String tokenSymbol,
    required String recipientAddress,
    required double amount,
  }) async {
    return await localDataSource.submitTransaction(
      tokenSymbol: tokenSymbol,
      recipientAddress: recipientAddress,
      amount: amount,
    );
  }
}
