import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/core/constants/api_constant.dart';

class SocialController extends GetxController {
  var branches = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // First time → show loader
    fetchBranches(showLoader: true);

    // Poll every 10s silently → no loader, no blinking
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchBranches(showLoader: false);
    });
  }

  Future<void> fetchBranches({bool showLoader = false}) async {
    try {
      if (showLoader) isLoading.value = true;

      final response = await http.get(
        Uri.parse(ApiConstants.getProjectUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded["StatusCode"] == "200") {
          final List branchList = decoded["obj"]["Branchlist"];

          // Skip the first item (code "000000" which is "All")
          final updatedBranches = branchList.skip(1).map<Map<String, dynamic>>((b) {
            return {
              'brn_code': b['brn_code'],
              'brn_name': b['brn_name'],
              'add_1': b['add_1'],
              'add_2': b['add_2'],
              'add_3': b['add_3'],
              'add_4': b['add_4'],
              'email_address': b['email_address'],
              'phone_no': b['phone_no'],
              'latitude': b['latitude'],
              'longitude': b['longitude'],
              'image_url': "${ApiConstants.baseUrl}${(b['image_url'] ?? '').toString().replaceAll("\\", "/")}"
            };
          }).toList();

          // ✅ Only update if data changed
          if (branches.toString() != updatedBranches.toString()) {
            branches.assignAll(updatedBranches);
          }
        }
      }
    } catch (e) {
      print("Error fetching branches: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}