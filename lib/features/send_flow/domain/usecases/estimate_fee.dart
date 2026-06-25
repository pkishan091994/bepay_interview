import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/send_flow/domain/repositories/send_repository.dart';
import 'package:equatable/equatable.dart';

class EstimateFee implements UseCase<double, EstimateFeeParams> {
  final SendRepository repository;

  EstimateFee({required this.repository});

  @override
  Future<double> call(EstimateFeeParams params) async {
    return await repository.estimateFee(params.tokenSymbol, params.network);
  }
}

class EstimateFeeParams extends Equatable {
  final String tokenSymbol;
  final String network;

  const EstimateFeeParams({required this.tokenSymbol, required this.network});

  @override
  List<Object?> get props => [tokenSymbol, network];
}
