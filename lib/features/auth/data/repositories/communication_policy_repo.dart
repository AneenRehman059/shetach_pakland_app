import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/auth/data/models/communication_policy_model.dart';

class CommunicationPolicyRepository {
  Future<CommunicationPolicyModel> getCommunicationPolicy() async {
    final uri = Uri.parse(ApiConstants.getCommunicationPolicyUrl);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["error"] == false && data["obj"] != null) {
        return CommunicationPolicyModel.fromJson(data["obj"]);
      } else {
        throw Exception(data["Message"] ?? "Failed to load communication policy");
      }
    } else {
      throw Exception(
          "Failed (code: ${response.statusCode}) - ${response.body}");
    }
  }
}
