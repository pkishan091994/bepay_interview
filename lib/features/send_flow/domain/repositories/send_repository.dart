import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';

abstract class SendRepository {
  Future<List<Recipient>> getRecentRecipients();

  Future<double> estimateFee(String tokenSymbol, String network);

  Future<bool> submitTransaction({
    required String tokenSymbol,
    required String recipientAddress,
    required double amount,
  });
}
