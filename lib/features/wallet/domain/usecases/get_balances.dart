import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:bepay_interview/features/wallet/domain/repositories/wallet_repository.dart';

class GetBalances implements UseCase<List<TokenBalance>, NoParams> {
  final WalletRepository repository;

  GetBalances({required this.repository});

  @override
  Future<List<TokenBalance>> call(NoParams params) async {
    return await repository.getBalances();
  }
}
