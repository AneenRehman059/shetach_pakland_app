import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/recent_activity/data/models/recent_activity_model.dart';

class RecentActivityRepository {
  Future<List<RecentActivityModel>> fetchActivity(String userId, String fromDate, String toDate) async {
    final url = Uri.parse("${ApiConstants.recentActivityUrl}?user_id=$userId&from_date=$fromDate&to_date=$toDate");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["StatusCode"] == "200") {
        List list = data["obj"];
        return list.map((e) => RecentActivityModel.fromJson(e)).toList();
      } else {
        throw Exception(data["Message"] ?? "Failed to load activity");
      }
    } else {
      throw Exception(
          "Failed (code: ${response.statusCode}) - ${response.body}");
    }
  }
}
