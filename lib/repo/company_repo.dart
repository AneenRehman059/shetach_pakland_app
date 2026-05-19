import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';

class CompanyRepository {
  Future<Map<String, dynamic>> fetchCompanyDetails(String compCode) async {
    final uri = Uri.parse("${ApiConstants.getCompanyInfoUrl}?comp=$compCode");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response. body);
    } else {
      throw Exception("Failed to load company details: ${response.body}");
    }
  }
}
