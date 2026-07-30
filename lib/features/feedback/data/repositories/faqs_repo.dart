import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/feedback/data/models/faqs_model.dart';

class FaqRepository {
  Future<List<FaqModel>> fetchFaqs() async {
    final url = Uri.parse(ApiConstants.getFaqsUrl);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      List list = jsonData["obj"];

      return list.map((e) => FaqModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load FAQs");
    }
  }
}
