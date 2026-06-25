import 'package:bepay_interview/features/send_flow/data/models/recipient_model.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';

abstract class SendLocalDataSource {
  Future<List<RecipientModel>> getRecentRecipients();

  Future<double> estimateFee(String tokenSymbol, String network);

  Future<bool> submitTransaction({
    required String tokenSymbol,
    required String recipientAddress,
    required double amount,
  });
}

class SendLocalDataSourceImpl implements SendLocalDataSource {
  @override
  Future<List<RecipientModel>> getRecentRecipients() async {
    // Simulate simulated latency delay
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockRecipients;
  }

  @override
  Future<double> estimateFee(String tokenSymbol, String network) async {
    // Simulate latency delay
    await Future.delayed(const Duration(milliseconds: 300));
    return 0.02; // Standard gas/transfer fee
  }

  @override
  Future<bool> submitTransaction({
    required String tokenSymbol,
    required String recipientAddress,
    required double amount,
  }) async {
    // Simulate delay representing mock blockchain transaction broadcast
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // Mock transaction success
  }

  static const List<RecipientModel> _mockRecipients = [
    RecipientModel(
      id: 'recent_sarah',
      name: 'Sarah Chen',
      address: 'sarah_c@bepay',
      type: RecipientType.bepayId,
      isExternal: false,
      badge: 'LAST USED',
      timestamp: '2h ago',
    ),
    RecipientModel(
      id: 'recent_jordan',
      name: 'Jordan Doe',
      address: 'jordan_pay@bepay',
      type: RecipientType.bepayId,
      isExternal: false,
      timestamp: 'Yesterday',
    ),
    RecipientModel(
      id: 'recent_marcus',
      name: 'Marcus Wu',
      address: 'mwu_finance@bepay',
      type: RecipientType.bepayId,
      isExternal: false,
      timestamp: '3 days ago',
    ),
  ];
}
