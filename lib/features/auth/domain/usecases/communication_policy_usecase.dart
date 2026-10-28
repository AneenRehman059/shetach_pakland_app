import 'package:pakland/features/auth/data/models/communication_policy_model.dart';
import 'package:pakland/features/auth/domain/repositories/communication_policy_repository.dart';

class CommunicationPolicyUseCase {
  final ICommunicationPolicyRepository _repository;

  CommunicationPolicyUseCase(this._repository);

  Future<CommunicationPolicyModel> call() {
    return _repository.getCommunicationPolicy();
  }
}
