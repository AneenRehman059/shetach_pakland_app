import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/customer_portal/data/repositories/customer_portal_repo.dart';
import 'package:pakland/features/customer_portal/data/models/customer_portal_model.dart';

class CustomerPortalController extends GetxController {
  final _repo = CustomerPortalRepository();
  final _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var customerObj = Rxn<CustomerPortalObj>();

  @override
  void onInit() {
    super.onInit();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData({BuildContext? context}) async {

    await _storage.write(key: "customer_address", value: customerObj.value?.address ?? "");

    try {
      isLoading.value = true;

      String? userId = await _storage.read(key: "user_id");
      if (userId == null || userId.isEmpty) {
        showTopSnackBar(
          context ?? Get.overlayContext!,
          title: "Alert",
          "User ID not found",
          Colors.red.withOpacity(0.7),
        );
        return;
      }

      final data = await _repo.getCustomerPortalData(username: userId);

      if (data.statusCode == "200") {
        customerObj.value = data.obj;
      } else {
        showTopSnackBar(
          context ?? Get.overlayContext!,
          title: "Alert",
          data.message,
          Colors.red.withOpacity(0.7),
        );
      }
    } catch (e) {
      showTopSnackBar(
        context ?? Get.overlayContext!,
        title: "Alert",
        e.toString(),
        Colors.red.withOpacity(0.7),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
