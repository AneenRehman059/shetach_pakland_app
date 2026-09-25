import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:pakland/core/constants/api_constant.dart';



class MediaController extends GetxController {
  /// Upload one or many media files to CMS API
  Future<List<Map<String, dynamic>>?> uploadMedia(
      List<File> files,
      String userId,
      String TicketId,
      {
        String? module,
        String? moduleItemId,
        int? commentId,
        String? purposeName,
        String? fileType,
        void Function(int sent, int total)? onProgress,
        bool retryAlternateFieldNames = true,
        String? registrationNo,
        String? brnCode,
      }) async {
    try {
      Future<http.Response> _send(List<String> fieldNames) async {
        final uri = Uri.parse(ApiConstants.uploadMediaUrl);
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll({'X-API-KEY': ApiConstants.apiKey});
        request.fields['UserId'] = userId;
        request.fields['TicketId'] = TicketId;
        if (registrationNo != null) request.fields['RegistrationNo'] = registrationNo;
        if (brnCode != null) request.fields['BrnCode'] = brnCode;
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final fileName = p.basename(file.path);
          final fieldName = fieldNames.length > i ? fieldNames[i] : fieldNames.last;
          request.files.add(await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            filename: fileName,
          ));
          // The server reads file.FileName for OriginalFileName; optional hint:
          request.fields['UserId'] = userId; // ensure present
          request.fields['TicketId'] = TicketId; // ensure present
          if (module != null) request.fields['Module'] = module;
          if (moduleItemId != null) request.fields['ModuleItemId'] = moduleItemId.toString();
          if (commentId != null) request.fields['CommentId'] = commentId.toString();
          if (purposeName != null) request.fields['PurposeName'] = purposeName;
        }

        // Send request
        final streamedResponse = await request.send();
        return await http.Response.fromStream(streamedResponse);
      }

      // Attempt 1: use repeated 'File'
      http.Response response = await _send(List.filled(files.length, 'File'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('📎 Upload response: $responseData');

        if (responseData is Map<String, dynamic>) {
          if (responseData['StatusCode'] == '200') {
            final obj = responseData['obj'];
            print('📎 Upload obj: $obj');

            // Handle response format from your backend
            if (obj is List) {
              if (obj.isEmpty) {
                print('❌ Upload failed: Empty result list');
                return null;
              }
              return obj.map<Map<String, dynamic>>((result) {
                // Handle different response formats from backend
                return {
                  'id': result['id'] ?? result['Id'],
                  'path': result['path'] ?? result['FilePath'],
                  'url': result['url'] ?? result['publicUrl'] ?? getMediaUrl(result['path'] ?? result['FilePath']),
                  'originalName': result['originalName'] ?? result['OriginalFileName'],
                  'fileSize': result['fileSize'] ?? result['ContentLength'],
                };
              }).toList();
            } else if (obj is Map<String, dynamic>) {
              // Single file returned
              return [
                {
                  'id': obj['id'] ?? obj['Id'],
                  'path': obj['path'] ?? obj['FilePath'],
                  'url': obj['url'] ?? obj['publicUrl'] ?? getMediaUrl(obj['path'] ?? obj['FilePath']),
                  'originalName': obj['originalName'] ?? obj['OriginalFileName'],
                  'fileSize': obj['fileSize'] ?? obj['ContentLength'],
                }
              ];
            } else {
              print('❌ Upload failed: Unexpected obj type: ${obj.runtimeType}');
              return null;
            }
          } else {
            print('❌ Upload failed: ${responseData['Message']}');
            Get.snackbar('Upload Failed', responseData['Message'] ?? 'Unknown error');
            return null;
          }
        } else {
          print('❌ Upload failed: Unexpected response format: ${responseData.runtimeType}');
          return null;
        }
      } else {
        print('❌ Upload failed: HTTP ${response.statusCode} - ${response.body}');
        // If first attempt failed and retry enabled, try indexed field names
        if (retryAlternateFieldNames) {
          final altFields = List<String>.generate(files.length, (i) => 'File[$i]');
          final altResponse = await _send(altFields);
          if (altResponse.statusCode == 200) {
            final responseData = jsonDecode(altResponse.body);
            if (responseData is Map<String, dynamic> && responseData['StatusCode'] == '200') {
              final obj = responseData['obj'];
              if (obj is List) {
                return obj.map<Map<String, dynamic>>((result) => {
                  'id': result['id'] ?? result['Id'],
                  'path': result['path'] ?? result['FilePath'],
                  'url': result['url'] ?? result['publicUrl'] ?? getMediaUrl(result['path'] ?? result['FilePath']),
                  'originalName': result['originalName'] ?? result['OriginalFileName'],
                  'fileSize': result['fileSize'] ?? result['ContentLength'],
                }).toList();
              } else if (obj is Map<String, dynamic>) {
                return [
                  {
                    'id': obj['id'] ?? obj['Id'],
                    'path': obj['path'] ?? obj['FilePath'],
                    'url': obj['url'] ?? obj['publicUrl'] ?? getMediaUrl(obj['path'] ?? obj['FilePath']),
                    'originalName': obj['originalName'] ?? obj['OriginalFileName'],
                    'fileSize': obj['fileSize'] ?? obj['ContentLength'],
                  }
                ];
              }
            }
          }
        }
        return null;
      }
    } catch (e) {
      print('❌ Upload failed: $e');
      Get.snackbar('Upload Failed', 'Network error: $e');
      return null;
    }
  }

  /// Wrapper: Upload single file
  Future<Map<String, dynamic>?> uploadSingleFile(
      File file,
      String userId,
      String TicketId,
      {
        String? module,
        String? moduleItemId,
        int? commentId,
        String? purposeName,
        String? fileType,
        void Function(int sent, int total)? onProgress,
      }) async {
    final result = await uploadMedia(
      [file],
      userId,
      TicketId,
      module: module,
      moduleItemId: moduleItemId,
      commentId: commentId,
      purposeName: purposeName,
      fileType: fileType,
      onProgress: onProgress,
    );

    // Safe access to first element
    if (result != null && result.isNotEmpty) {
      return result.first;
    } else {
      print('❌ Upload failed: No result returned from uploadMedia');
      return null;
    }
  }

  /// Wrapper: Upload multiple files
  Future<List<Map<String, dynamic>>?> uploadMultipleFiles(
      List<File> files,
      String userId,
      String TicketId,
      {
        String? module,
        String? moduleItemId,
        String? purposeName,
        void Function(int sent, int total)? onProgress,
      }) async {
    return await uploadMedia(
      files,
      userId,
      TicketId,
      module: module,
      moduleItemId: moduleItemId,
      purposeName: purposeName,
      onProgress: onProgress,
    );
  }

  /// Deletes a media file by its ID
  Future<bool> deleteMedia(int mediaId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.getMediaUrl}/$mediaId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData is Map<String, dynamic> && responseData['StatusCode'] == '200';
      }

      print('❌ Delete failed: ${response.statusCode} - ${response.body}');
      Get.snackbar('Delete Failed', 'Server returned ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Delete failed: $e');
      Get.snackbar('Delete Failed', 'Network error: $e');
      return false;
    }
  }

  /// Retrieves media info by ID
  Future<Map<String, dynamic>?> getMedia(int mediaId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getMediaUrl}/$mediaId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> && responseData['StatusCode'] == '200') {
          return responseData['obj'] ?? responseData;
        }
        print('❌ Get media failed: ${responseData['Message']}');
      }
      return null;
    } catch (e) {
      print('❌ Get media failed: $e');
      return null;
    }
  }

  /// Updates media metadata
  Future<bool> updateMedia(int mediaId, String fileType, String originalFileName) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.getMediaUrl}/$mediaId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'FileType': fileType,
          'OriginalFileName': originalFileName,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData is Map<String, dynamic> && responseData['StatusCode'] == '200';
      }

      print('❌ Update failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('❌ Update failed: $e');
      return false;
    }
  }

  /// Build media URL
  String getMediaUrl(String filePath) {
    if (filePath.startsWith('http')) return filePath;
    final baseUrl = ApiConstants.baseUrl;
    return filePath.startsWith('/') ? '$baseUrl$filePath' : '$baseUrl/$filePath';
  }

  /// File type helpers
  bool isImageFile(String fileName) =>
      ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(p.extension(fileName).toLowerCase());

  bool isDocumentFile(String fileName) =>
      ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.ppt', '.pptx'].contains(p.extension(fileName).toLowerCase());

  bool isAudioFile(String fileName) =>
      ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.amr'].contains(p.extension(fileName).toLowerCase());

  bool isVideoFile(String fileName) =>
      ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.webm'].contains(p.extension(fileName).toLowerCase());

  /// Validate file size (10MB limit as per your backend)
  bool validateFileSize(File file, [int maxSizeMB = 10]) {
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeMB;
  }

  /// Get file extension from path
  String getFileExtension(String fileName) {
    return p.extension(fileName).toLowerCase();
  }

  /// Check if file extension is allowed
  bool isAllowedExtension(String fileName) {
    return isImageFile(fileName) ||
        isDocumentFile(fileName) ||
        isAudioFile(fileName) ||
        isVideoFile(fileName);
  }
}