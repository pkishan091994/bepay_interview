import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/send_flow/domain/repositories/send_repository.dart';
import 'package:equatable/equatable.dart';

class SubmitTransaction implements UseCase<bool, SubmitTransactionParams> {
  final SendRepository repository;

  SubmitTransaction({required this.repository});

  @override
  Future<bool> call(SubmitTransactionParams params) async {
    return await repository.submitTransaction(
      tokenSymbol: params.tokenSymbol,
      recipientAddress: params.recipientAddress,
      amount: params.amount,
    );
  }
}

class SubmitTransactionParams extends Equatable {
  final String tokenSymbol;
  final String recipientAddress;
  final double amount;

  const SubmitTransactionParams({
    required this.tokenSymbol,
    required this.recipientAddress,
    required this.amount,
  });

  @override
  List<Object?> get props => [tokenSymbol, recipientAddress, amount];
}
