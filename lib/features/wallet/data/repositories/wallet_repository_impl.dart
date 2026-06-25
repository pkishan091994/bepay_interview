import 'package:bepay_interview/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:bepay_interview/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TokenBalance>> getBalances() async {
    try {
      final balances = await localDataSource.getBalances();
      return balances;
    } catch (e) {
      throw Exception('Failed to fetch wallet balances');
    }
  }
}
