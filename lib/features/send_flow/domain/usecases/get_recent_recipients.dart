import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:bepay_interview/features/send_flow/domain/repositories/send_repository.dart';

class GetRecentRecipients implements UseCase<List<Recipient>, NoParams> {
  final SendRepository repository;

  GetRecentRecipients({required this.repository});

  @override
  Future<List<Recipient>> call(NoParams params) async {
    return await repository.getRecentRecipients();
  }
}
