import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constant.dart';
import '../controllers/media_uploads_controller.dart';
import '../models/comments_model.dart';
import '../models/ticket_models.dart';
import '../models/timeLine_model.dart';
import '../services/httpMassageMapper.dart';

class TicketRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final MediaController _mediaController = MediaController();

  Future<String?> _getUserId() async {
    try {
      return await _storage.read(key: 'user_id');
    } catch (_) {
      return null;
    }
  }

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

  Future<List<Map<String, dynamic>>> getDepartmentByUID(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.getDepartmentByUID}/$userId"),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          final List departments = decoded["obj"];
          return List<Map<String, dynamic>>.from(departments);
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get department by UID error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDepartment() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getDepartment),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          final List departments = decoded["obj"];
          return List<Map<String, dynamic>>.from(departments);
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get department error: $e');
      rethrow;
    }
  }

  Future<Iterable<Map<String, dynamic>>> getBranchesALL(String userId,String brnCode) async {
    try {
      final uri = Uri.parse(ApiConstants.getCustomerPortalUrl).replace(
        queryParameters: {
          "username": userId,
          "brn_code": brnCode,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          final List Branches =  decoded["obj"]["Clientdetaillist"];
          //final List Branches =  decoded["obj"];
          return List<Map<String, dynamic>>.from(Branches);
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get Branches error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBranchesForSOS(String userId, String brnCode) async {
    try {
      final uri = Uri.parse(ApiConstants.getCustomerPortalUrl).replace(
        queryParameters: {
          "username": userId,
          "brn_code": brnCode,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          final List rawList = decoded["obj"]["Clientdetaillist"] ?? [];

          // ✅ Deduplicate by brn_code, skip entries with null/empty brn_code
          final Map<String, Map<String, dynamic>> uniqueBranches = {};
          for (final item in rawList) {
            final map = Map<String, dynamic>.from(item);
            final code = map['brn_code']?.toString().trim() ?? '';
            if (code.isNotEmpty && !uniqueBranches.containsKey(code)) {
              uniqueBranches[code] = map;
            }
          }

          return uniqueBranches.values.toList();
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get Branches error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBranches(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.getBranchesByUserId}/$userId"),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          //final List Branches =  decoded["obj"]["Branchlist"];
          final List Branches =  decoded["obj"];
          return List<Map<String, dynamic>>.from(Branches);
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get Branches error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDeparmentsbycode(String brnCode, String userId) async {
    try {
      final url = "${ApiConstants.getDeptsbyBrnCode}/$brnCode/$userId";

      print('Constructed URL: $url');
      final response = await http.get(
        //Uri.parse(url),
        Uri.parse(url).replace(
          queryParameters: {
            "alowAll": "Yes",
          },
        ),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },

      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          final List depts = decoded["obj"];
          return List<Map<String, dynamic>>.from(depts);
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get department operations error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDeptOpration(String deptId, String brnCode) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.getDeptOpration}/$deptId/$brnCode"),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded["StatusCode"] == "200") {
          final List deptOperations = decoded["obj"];
          return List<Map<String, dynamic>>.from(deptOperations);
        } else {
          throw Exception(decoded["Message"] ?? HttpMessageMapper.getMessage(response.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(response.statusCode));
      }
    } catch (e) {
      print('Get department operations error: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getTickets() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.getAllTicketsUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print('🔍 GetTickets response: $body');
        final list = _extractList(body);
        print('🔍 Extracted list: $list');
        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get tickets error: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getTicketsByStatus(String status) async {
    try {
      final encodedStatus = Uri.encodeComponent(status);
      final url = Uri.parse('${ApiConstants.getTicketsByStatusUrl}/$encodedStatus');

      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get tickets by status error: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getTicketsByUserId(String userId) async {
    try {
      final encoded = Uri.encodeComponent(userId);
      final res = await http.get(
        Uri.parse('${ApiConstants.getTicketsByUserIdUrl}/$encoded'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get tickets by user ID error: $e');
      rethrow;
    }
  }
  Future<List<TicketModel>> getTicketsByAdminId(String adminId) async {
    try {
      final encoded = Uri.encodeComponent(adminId);
      final res = await http.get(
        Uri.parse('${ApiConstants.getTicketsByAminIdUrl}/$encoded'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get tickets by user ID error: $e');
      rethrow;
    }
  }
  Future<List<TicketModel>> getActiveSOSEmergencies() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.getActiveSOSEmergenciesUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        var list = _extractList(body['obj']);

        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get active SOS emergencies error: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getTicketsByDepartment(String department) async {
    try {
      final encoded = Uri.encodeComponent(department);
      final res = await http.get(
        Uri.parse('${ApiConstants.getTicketsByDepartmentUrl}/$encoded'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get tickets by department error: $e');
      rethrow;
    }
  }

  Future<List<TicketModel>> getMyAssignedTickets(String userId) async {
    try {
      final encoded = Uri.encodeComponent(userId);
      final res = await http.get(
        Uri.parse('${ApiConstants.getMyAssignedTicketsUrl}/$encoded'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TicketModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get my assigned tickets error: $e');
      rethrow;
    }
  }

  Future<TicketModel?> getTicket(String id) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.getTicketUrl}/$id'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        print('🔍 GetTicket response: $body');
        final map = _extractMap(body);
        print('🔍 Extracted map: $map');
        if (map != null) return TicketModel.fromJson(map);
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
      return null;
    } catch (e) {
      print('Get ticket error: $e');
      rethrow;
    }
  }

  Future<bool> updateStatusAndPriority({
    required String ticketId,
    required String status,
    required String priority,
    required String remarks,
    required String userId,
  }) async {
    try {
      final res = await http.put(
        Uri.parse(ApiConstants.updateTicketStatusUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
        body: jsonEncode({
          'Id': ticketId,
          'Status': status,
          'Remarks': remarks,
          'Priority': priority,
          'UserId': userId,
        }),
      );

      final responseBody = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }

      return res.statusCode == 200 && responseBody['StatusCode'] == '200';
    } catch (e) {
      print('Update status+priority error: $e');
      rethrow;
    }
  }

  Future<dynamic> createTicket(CreateTicketRequest req) async {
    try {
      print('🎫 Creating ticket with data: ${req.toJson()}');

      final res = await http.post(
        Uri.parse(ApiConstants.createTicketUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-API-KEY": ApiConstants.apiKey,
        },
        body: jsonEncode(req.toJson()),
      );

      print('🎫 Create ticket response: ${res.statusCode} - ${res.body}');

      if (res.statusCode != 200) {
        return {
          "StatusCode": res.statusCode.toString(),
          "Message": HttpMessageMapper.getMessage(res.statusCode),
          "obj": null,
        };
      }

      final body = jsonDecode(res.body);

      if (body is! Map<String, dynamic>) {
        print('❌ Unexpected API structure: ${res.body}');
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      final status = body["StatusCode"]?.toString();
      final message = body["Message"]?.toString() ?? "Unknown error";

      if (status == "200") {
        print('✅ Ticket created successfully.');
        return body;
      } else if (status == "500") {
        print('❌ API returned error 500: $message');
        return body;
      } else {
        print('⚠️ Unexpected status: $status');
        return {
          "StatusCode": status ?? "500",
          "Message": message.isNotEmpty ? message : HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }
    } catch (e, st) {
      print('❌ Create ticket exception: $e\n$st');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  Future<bool> deleteTicket(String id, String userId) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConstants.deleteTicketUrl}/$id/$userId'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      final responseBody = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }

      return res.statusCode == 200 && responseBody['StatusCode'] == '200';
    } catch (e) {
      print('Delete ticket error: $e');
      rethrow;
    }
  }

  Future<bool> addCommentText({
    required String ticketId,
    required String text,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return false;

      final res = await http.post(
        Uri.parse(ApiConstants.addCommentUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
        body: jsonEncode({
          'TicketId': ticketId,
          'UserId': userId,
          'Text': text,
          'CommentType': 'Text',
        }),
      );

      final responseBody = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }

      return res.statusCode == 200 && responseBody['StatusCode'] == '200';
    } catch (e) {
      print('Add comment text error: $e');
      rethrow;
    }
  }
  // core
  // Future<bool> addCommentFile({
  //   required String ticketId,
  //   required File file,
  //   required String commentType,
  //   required int commentId,
  //   required String purposeName,
  //   void Function(int sent, int total)? onProgress,
  // }) async {
  //   try {
  //     final userId = await _getUserId();
  //     if (userId == null) return false;
  //
  //     if (!_mediaController.validateFileSize(file)) {
  //       print('❌ File size exceeds limit (10MB)');
  //       return false;
  //     }
  //
  //     if (!_mediaController.isAllowedExtension(file.path)) {
  //       print('❌ File type not allowed');
  //       return false;
  //     }
  //
  //     final uploadResult = await _mediaController.uploadSingleFile(
  //       file,
  //       userId,
  //       ticketId.toString(),
  //       module: 'tickets',
  //       moduleItemId: ticketId,
  //       commentId: commentId,
  //       purposeName: purposeName,
  //       fileType: _mediaController.getFileExtension(file.path).replaceFirst('.', ''),
  //       onProgress: onProgress,
  //     );
  //
  //     if (uploadResult == null || uploadResult['id'] == null) {
  //       print('❌ File upload failed');
  //       return false;
  //     }
  //
  //     final res = await http.post(
  //       Uri.parse(ApiConstants.addCommentUrl),
  //       headers: {"Content-Type": "application/json",
  //         "X-API-KEY":"${ApiConstants.apiKey}"
  //       },
  //       body: jsonEncode({
  //         'TicketId': ticketId,
  //         'UserId': userId,
  //         'Text': 'File attachment',
  //         'MediaId': uploadResult['id'],
  //         'CommentType': commentType,
  //         'FilePath': uploadResult['path'],
  //       }),
  //     );
  //
  //     final responseBody = jsonDecode(res.body);
  //
  //     if (res.statusCode != 200) {
  //       throw Exception(HttpMessageMapper.getMessage(res.statusCode));
  //     }
  //
  //     return res.statusCode == 200 && responseBody['StatusCode'] == '200';
  //   } catch (e) {
  //     print('Add comment file error: $e');
  //     rethrow;
  //   }
  // }
  //mvc
  Future<bool> addCommentFile({
    required String ticketId,
    required File file,
    required String commentType,
    required int commentId,
    required String purposeName,
    void Function(int sent, int total)? onProgress,
  }) async {try {
    final userId = await _getUserId();
    final username = await _storage.read(key: "user_name") ?? "Unknown";

    if (userId == null) return false;

    // ------------------ File Validation ------------------
    if (!_mediaController.validateFileSize(file)) return false;
    if (!_mediaController.isAllowedExtension(file.path)) return false;

    // ------------------ Upload File ----------------------
    final uploadResult = await _mediaController.uploadSingleFile(
      file,
      userId,
      ticketId,
      module: 'tickets',
      moduleItemId: ticketId,
      commentId: commentId,
      purposeName: purposeName,
      fileType: _mediaController.getFileExtension(file.path).replaceFirst('.', ''),
      onProgress: onProgress,
    );

    print("Upload result: $uploadResult");

    // 🟢 FIX: Extract correct Media ID
    final mediaObj = uploadResult?["id"];
    var mediaId = mediaObj?["<DTO>k__BackingField"];
    //mediaId=mediaObj;
    if (mediaId == null) {
      mediaId=mediaObj;

      print("❌ Failed to extract mediaId from upload response");
      return true;
    }

    final mediaPath = uploadResult?["path"];

    // ------------------ Build Comment Request ------------
    final commentRequest = {
      "Id": 0,
      "TicketId": ticketId,
      "UserId": userId,
      "Text": "File attachment",
      "MediaId": mediaId,            // FIXED
      "MediaPath": mediaPath,        // FIXED
      "CommentType": commentType,
      "CreatedAt": DateTime.now().toIso8601String(),
      "Username": username,
    };

    print("📤 COMMENT REQUEST SENT → $commentRequest");

    // ------------------ API Call --------------------------
    final res = await http.post(
      Uri.parse(ApiConstants.addCommentUrl),
      headers: {
        "Content-Type": "application/json",
        "X-API-KEY": ApiConstants.apiKey,
      },
      body: jsonEncode(commentRequest),
    );

    final responseBody = jsonDecode(res.body);

    print("📩 API RESPONSE → $responseBody");

    return responseBody["StatusCode"] == "200";
  } catch (e) {
    print("❌ Add comment file error: $e");
    return false;
  }
  }


  Future<List<CommentsModel>> getComments(String ticketId) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.getCommentsUrl}/$ticketId'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => CommentsModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get comments error: $e');
      rethrow;
    }
  }

  Future<List<TimeLineModel>> getTicketTimeline(String ticketId) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.getAuditLogsByModuleUrl}/Ticket/$ticketId'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TimeLineModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get ticket timeline error: $e');
      rethrow;
    }
  }

  Future<List<TimeLineModel>> getModuleTimeline(String module, String moduleItemId) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.getAuditLogsByModuleUrl}/$module/$moduleItemId'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _extractList(body);
        return list.map((e) => TimeLineModel.fromJson(e)).toList();
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get module timeline error: $e');
      rethrow;
    }
  }

  Future<dynamic> createTicketWithAttachments(
      CreateTicketRequest req,
      List<File> attachments, {
        void Function(int sent, int total)? onUploadProgress,
        void Function(int fileIndex, int sent, int total)? onFileProgress,
      }) async {
    try {
      print('🎫 Creating ticket with ${attachments.length} attachments');

      final response = await createTicket(req);
      final status = response["StatusCode"]?.toString();

      if (status == "500") {
        print('❌ Failed to create ticket (server error): ${response["Message"]}');
        return response;
      }

      final ticket = response["obj"];
      if (status != "200" || ticket == null) {
        print('❌ Ticket creation failed or empty ticket object.');
        return response;
      }

      final ticketId = ticket["TicketId"]?.toString();
      if (ticketId == null) {
        print('❌ TicketId missing in response.');
        return {
          "StatusCode": "500",
          "Message": HttpMessageMapper.getMessage(500),
          "obj": null,
        };
      }

      print('✅ Ticket created successfully with ID: $ticketId');

      if (attachments.isEmpty) {
        print('ℹ️ No attachments to upload');
        return response;
      }

      print('📎 Uploading ${attachments.length} attachments');
      int uploadedCount = 0;

      for (int i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        print('📎 Uploading file ${i + 1}: ${file.path}');

        if (!_mediaController.validateFileSize(file)) {
          print('❌ Skipping file (too large): ${file.path}');
          continue;
        }

        if (!_mediaController.isAllowedExtension(file.path)) {
          print('❌ Skipping file (invalid type): ${file.path}');
          continue;
        }

        try {
          final uploadResult = await _mediaController.uploadSingleFile(
            file,
            req.userId,
            ticketId,
            module: 'tickets',
            moduleItemId: ticketId,
            purposeName: 'TicketAttachment',
            fileType: _mediaController.getFileExtension(file.path).replaceFirst('.', ''),
            onProgress: (sent, total) {
              final individualProgress = total == 0 ? 0 : (sent / total);
              final overallProgress = (uploadedCount + individualProgress) / attachments.length;
              onUploadProgress?.call((overallProgress * 100).round(), 100);
              onFileProgress?.call(i, sent, total);
            },
          );

          if (uploadResult != null) {
            uploadedCount++;
            print('✅ File ${i + 1} uploaded successfully');
          } else {
            print('❌ Failed to upload file ${i + 1}');
          }
        } catch (e) {
          print('❌ Error uploading file ${i + 1}: $e');
        }
      }

      print('✅ Uploaded $uploadedCount/${attachments.length} attachments');

      return {
        "StatusCode": "200",
        "Message": response["Message"] ?? "Ticket created successfully",
        "obj": ticket,
      };
    } catch (e, stackTrace) {
      print('❌ createTicketWithAttachments error: $e');
      print('Stack trace: $stackTrace');
      return {
        "StatusCode": "500",
        "Message": HttpMessageMapper.getMessage(500),
        "obj": null,
      };
    }
  }

  Future<bool> addTicketAttachments({
    required String ticketId,
    required String userId,
    required List<File> attachments,
    void Function(int sent, int total)? onProgress,
    void Function(int fileIndex, int sent, int total)? onFileProgress,
  }) async {
    try {
      if (attachments.isEmpty) return true;

      int successCount = 0;

      for (int i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        if (!_mediaController.validateFileSize(file)) {
          print('❌ Skipping file ${file.path} - size exceeds limit');
          continue;
        }

        if (!_mediaController.isAllowedExtension(file.path)) {
          print('❌ Skipping file ${file.path} - type not allowed');
          continue;
        }

        final uploadResult = await _mediaController.uploadSingleFile(
          file,
          userId,
          ticketId.toString(),
          module: 'tickets',
          moduleItemId: ticketId,
          purposeName: 'TicketAttachment',
          fileType: _mediaController.getFileExtension(file.path).replaceFirst('.', ''),
          onProgress: (sent, total) {
            if (onProgress != null) onProgress(sent, total);
            if (onFileProgress != null) onFileProgress(i, sent, total);
          },
        );

        if (uploadResult != null) {
          successCount++;
        }
      }

      return successCount > 0;
    } catch (e) {
      print('Add ticket attachments error: $e');
      rethrow;
    }
  }

  Future<bool> submitTicketFeedback({
    required String ticketId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.submitFeedbackUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
        body: jsonEncode({
          'TicketId': ticketId,
          'UserId': userId,
          'Rating': rating,
          'Comment': comment,
        }),
      );

      final responseBody = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }

      return res.statusCode == 200 && responseBody['StatusCode'] == '200';
    } catch (e) {
      print('Submit feedback error: $e');
      rethrow;
    }
  }

  Future<bool> checkBackendHealth() async {
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.getAllTicketsUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": "${ApiConstants.apiKey}"
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }

  Future<AssignTicketResponse?> assignTicket(AssignTicketRequest request) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.assignTicketUrl),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": ApiConstants.apiKey,
        },
        body: jsonEncode(request.toJson()),
      );

      print('🎫 Assign ticket response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['StatusCode'] == '200') {
          final responseData = body['obj'];
          if (responseData is Map<String, dynamic>) {
            return AssignTicketResponse.fromJson(responseData);
          }
        } else {
          throw Exception(body['Message'] ?? HttpMessageMapper.getMessage(res.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
      return null;
    } catch (e) {
      print('Assign ticket error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByDepartment(String deptId) async {
    try {
      final encodedDeptId = Uri.encodeComponent(deptId);
      final res = await http.get(
        Uri.parse('${ApiConstants.getUsersByDeptUrl}/$encodedDeptId'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": ApiConstants.apiKey,
        },
      );

      print('👥 Get users by dept response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['StatusCode'] == '200') {
          final list = _extractList(body);
          return List<Map<String, dynamic>>.from(list);
        } else if (body['StatusCode'] == '404') {
          return [];
        } else {
          throw Exception(body['Message'] ?? HttpMessageMapper.getMessage(res.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get users by department error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStaffUsers() async {
    try {

      final res = await http.get(
        Uri.parse('${ApiConstants.getGetStaffUsersUrl}'),
        headers: {
          "Content-Type": "application/json",
          "X-API-KEY": ApiConstants.apiKey,
        },
      );

      print('👥 Get users by dept response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['StatusCode'] == '200') {
          final list = _extractList(body);
          return List<Map<String, dynamic>>.from(list);
        } else if (body['StatusCode'] == '404') {
          return [];
        } else {
          throw Exception(body['Message'] ?? HttpMessageMapper.getMessage(res.statusCode));
        }
      } else {
        throw Exception(HttpMessageMapper.getMessage(res.statusCode));
      }
    } catch (e) {
      print('Get users by department error: $e');
      rethrow;
    }
  }
}