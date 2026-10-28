import 'package:pakland/features/auth/data/models/communication_policy_model.dart';

abstract class ICommunicationPolicyRepository {
  Future<CommunicationPolicyModel> getCommunicationPolicy();
}
