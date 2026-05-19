import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';

class PaymentPlanRepo {

  Future<Map<String, dynamic>> fetchBranches() async {
    final url =  Uri.parse(ApiConstants.getBranchUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch branches");
    }
  }
}
