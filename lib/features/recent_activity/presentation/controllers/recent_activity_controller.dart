import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import 'package:pakland/features/recent_activity/data/repositories/recent_activity_repo.dart';
import 'package:pakland/features/recent_activity/data/models/recent_activity_model.dart';

class RecentActivityController extends GetxController {
  final RecentActivityRepository _repo = RecentActivityRepository();
  final _storage = const FlutterSecureStorage();

  RxBool isLoading = false.obs;
  RxList<RecentActivityModel> activityList = <RecentActivityModel>[].obs;

  // For date filtering
  Rx<DateTime> fromDate = DateTime.now().obs;
  Rx<DateTime> toDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivity();
  }

  Future<void> fetchActivity() async {
    try {
      isLoading.value = true;

      String? userId = await _storage.read(key: "user_id");
      if (userId == null || userId.isEmpty) return;

      String from = DateFormat("yyyy/MM/dd").format(fromDate.value);
      String to = DateFormat("yyyy/MM/dd").format(toDate.value);

      final list = await _repo.fetchActivity(userId, from, to);
      activityList.value = list;

    } catch (e) {
      print("ERROR: $e");
      activityList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String fullDate) => fullDate.split("T")[0].replaceAll("-", "/");
  String formatTime(String fullDate) => fullDate.split("T")[1].substring(0, 8);
}
