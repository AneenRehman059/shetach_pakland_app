// sos_repo.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/sos/data/models/sos_models.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/core/services/httpMassageMapper.dart';

class SOSRepository {
  final String baseUrl = ApiConstants.cmsBase;

  // ✅ Update FCM Token
  Future<dynamic> updateFCMToken(FCMTokenUpdateRequest request) async {
    try {
      print('🔄 Updating FCM token: ${request.toJson()}');

      final response = await http.put(
        Uri.parse(ApiConstants.updateFCMTokenUrl),
        headers: {
          'Content-Type': 'application/json',
          "X-API-KEY": ApiConstants.apiKey
        },
        body: jsonEncode(request.toJson()),
      );

      print('🎫 Update FCM token response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        return {
          "StatusCode": response.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(response.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ FCM token updated successfully');
        return body;
      } else {
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error updating FCM token: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  // ✅ Get All SOS Users
  Future<dynamic> getAllSOSUsers() async {
    try {
      print('🔄 Fetching all SOS users');

      final response = await http.get(
        Uri.parse(ApiConstants.getAllSOSUsersUrl),
        headers: {
          'Content-Type': 'application/json',
          "X-API-KEY": ApiConstants.apiKey
        },
      );

      if (response.statusCode != 200) {
        return {
          "StatusCode": response.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(response.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ SOS users fetched successfully');
        return body;
      } else {
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching SOS users: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  // ✅ Send SOS Notification to Admins and Staff
  Future<dynamic> sendSOSNotification(SOSNotificationRequest request) async {
    try {
      print('📤 Sending SOS notification request to: ${ApiConstants.sendSOSNotificationUrl}');
      print('📤 Request data: ${request.toJson()}');

      final response = await http.post(
        Uri.parse(ApiConstants.sendSOSNotificationUrl),
        headers: {
          'Content-Type': 'application/json',
          "X-API-KEY":"${ApiConstants.apiKey}"
        },
        body: jsonEncode(request.toJson()),
      );

      print('📥 SOS Response Status: ${response.statusCode}');
      print('📥 SOS Response Body: ${response.body}');

      if (response.statusCode != 200) {
        return {
          "StatusCode": response.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(response.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ SOS notification sent successfully');
        return body;
      } else {
        print('❌ SOS notification failed with status: $status');
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error in sendSOSNotification: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  // ✅ Stop SOS Alarm
  Future<dynamic> stopSOSAlarm({
    required String ticketId,
    required String userId,
    String? remarks,
  }) async {
    try {
      print('🔄 Stopping SOS alarm for ticket: $ticketId');

      final response = await http.post(
        Uri.parse(ApiConstants.stopSOSAlarmUrl),
        headers: {
          'Content-Type': 'application/json',
          "X-API-KEY": ApiConstants.apiKey
        },
        body: jsonEncode({
          'TicketId': ticketId,
          'UserId': userId,
          'Remarks': remarks ?? 'SOS alarm stopped by staff',
        }),
      );

      print('🎫 Stop SOS alarm response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        return {
          "StatusCode": response.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(response.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ SOS alarm stopped successfully');
        return body;
      } else {
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error stopping SOS alarm: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  // ✅ Respond to SOS (Go & Respond)
  Future<dynamic> respondToSOS({
    required String ticketId,
    required String responderUserId,
    required String responderName,
    String? remarks,
  }) async {
    try {
      print('🔄 Responding to SOS for ticket: $ticketId');

      final response = await http.post(
        Uri.parse(ApiConstants.respondToSOSUrl),
        headers: {
          'Content-Type': 'application/json',
          "X-API-KEY": ApiConstants.apiKey
        },
        body: jsonEncode({
          'TicketId': ticketId,
          'ResponderUserId': responderUserId,
          'ResponderName': responderName,
          'Remarks': remarks ?? 'Team responding to SOS',
        }),
      );

      print('🎫 Respond to SOS response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        return {
          "StatusCode": response.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(response.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ SOS response recorded successfully');
        return body;
      } else {
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error responding to SOS: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  // ✅ Get Active SOS Emergencies
  Future<dynamic> getActiveSOSEmergencies() async {
    try {
      print('🔄 Fetching active SOS emergencies');

      final response = await http.get(
        Uri.parse(ApiConstants.getActiveSOSEmergenciesUrl),
        headers: {
          'Content-Type': 'application/json',
          "X-API-KEY": ApiConstants.apiKey
        },
      );

      if (response.statusCode != 200) {
        return {
          "StatusCode": response.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(response.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ Active SOS emergencies fetched successfully');
        return body;
      } else {
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching active SOS emergencies: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  // Helper method to extract list from response (TicketRepository style)
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      if (body['obj'] is Map && body['obj']['data'] is List) {
        return body['obj']['data'] as List;
      }
      if (body['obj'] is List) return body['obj'] as List;
      if (body['data'] is List) return body['data'] as List;
      if (body['Tickets'] is List) return body['Tickets'] as List;
    }
    return [];
  }

  // Helper method to extract map from response (TicketRepository style)
  Map<String, dynamic>? _extractMap(dynamic body) {
    if (body is Map) {
      if (body['obj'] is Map) return body['obj'] as Map<String, dynamic>;
      if (body['data'] is Map) return body['data'] as Map<String, dynamic>;
      if (body['Ticket'] is Map) return body['Ticket'] as Map<String, dynamic>;
      if (body['obj'] != null && body['obj'] is! List) {
        return body['obj'] as Map<String, dynamic>;
      }
      return body as Map<String, dynamic>;
    }
    return null;
  }
}