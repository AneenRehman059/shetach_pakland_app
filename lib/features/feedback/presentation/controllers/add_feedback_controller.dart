import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/feedback/data/repositories/add_feedback_repo.dart';

class FeedbackController extends GetxController {
  final FeedbackRepository _repo = FeedbackRepository();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;

  Future<bool> sendFeedback({
    required BuildContext context,
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    try {
      isLoading.value = true;

      String? cnic = await _storage.read(key: "user_id");
      if (cnic == null || cnic.isEmpty) {
        return false;
      }

      final body = {
        "Id": 0,
        "cnic": cnic,
        "name": name.trim(),
        "email": email.trim(),
        "phone": phone.trim(),
        "message": message.trim(),
        "deviceId": "string",
        "deviceModel": "string",
      };

      final response = await _repo.sendFeedback(body);

      if (response["StatusCode"] == "200") {
        showTopSnackBar(context, response["Message"] ?? "Feedback submitted successfully", Colors.green.withOpacity(0.7),icon: Icons.check_circle);
        return true;
      } else {
        showTopSnackBar(context, title: "Alert", "Some technical fault occured! Try again later." ?? "Something went wrong",Colors.red.withOpacity(0.7),icon: Icons.warning);
        return false;
      }
    } catch (e) {
      showTopSnackBar(context, title: "Alert", e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
