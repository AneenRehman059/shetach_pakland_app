import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/get_events_model.dart';

class EventsRepository {
  Future<EventsResponse> getEventsData({required String comp}) async {
    final url = Uri.parse(
        "${ApiConstants.getEventsUrl}?comp=$comp"
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return EventsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch events data: ${response.body}");
    }
  }
}