import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';

abstract class WalletRepository {
  Future<List<TokenBalance>> getBalances();
}
