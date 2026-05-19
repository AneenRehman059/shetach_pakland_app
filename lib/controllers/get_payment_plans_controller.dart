import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pakland/models/get_branch_model.dart';
import '../constants/api_constant.dart';
import '../repo/payment_plan_repo.dart';

class PaymentPlanController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final PaymentPlanRepo _repo = PaymentPlanRepo();
  var plansWithNames = <Map<String, String>>[].obs;
  var branchList = <Branch>[].obs;
  var selectedBranchName = "".obs;
  var selectedBranchCode = "".obs;
  var isLoading = true.obs;
  var areImagesLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedBranchName("All");
    selectedBranchCode("");
    loadBranches();
  }

  Future<void> loadBranches() async {
    isLoading(true);
    try {
      final data = await _repo.fetchBranches();
      final branchListResponse = BranchModel.fromJson(data);

      if (branchListResponse.statusCode == "200") {
        branchList.assignAll(branchListResponse.branchList);

        // ✅ Do NOT override "All"
        // Always load all plans on first open
        await loadPaymentPlanImages("All");
      }
    } catch (e) {
      debugPrint("Error loading branches: $e");
    } finally {
      isLoading(false);
    }
  }


  Future<void> loadPaymentPlanImages(String brnCode) async {
    isLoading(true); // only while fetching data
    areImagesLoaded(false);
    plansWithNames.clear();

    try {
      String? storedPlans = await _storage.read(key: "mobile_payment_plan");
      if (storedPlans != null) {
        List<dynamic> plans = jsonDecode(storedPlans);

        final filteredPlans = brnCode == "All"
            ? plans
            : plans.where((plan) => plan["brn_code"]?.toString() == brnCode).toList();

        // build list without blocking on precache
        for (var plan in filteredPlans) {
          String path = plan["image_path"]?.toString() ?? "";
          if (path.isEmpty) continue;

          String url = "${ApiConstants.baseUrl}$path"
              .replaceAll(RegExp(r'/+'), '/')
              .replaceFirst(':/', '://');

          plansWithNames.add({
            "plan_name": plan["plan_name"]?.toString() ?? "",
            "image_url": url,
          });
        }

        // precache images in background (don’t block UI)
        Future.wait(plansWithNames.map((plan) async {
          try {
            await precacheImage(NetworkImage(plan["image_url"]!), Get.context!);
          } catch (_) {}
        })).whenComplete(() {
          areImagesLoaded(true);
        });
      }
    } catch (e) {
      debugPrint("Error loading payment plans: $e");
    } finally {
      isLoading(false);
    }
  }


  void changeBranch(String branchName) {
    selectedBranchName(branchName);

    if (branchName == "All") {
      selectedBranchCode("");
      loadPaymentPlanImages("All");
    } else {
      final branch = branchList.firstWhere(
            (b) => b.brnName == branchName,
        orElse: () => Branch(brnCode: '', brnName: ''),
      );
      selectedBranchCode(branch.brnCode);
      loadPaymentPlanImages(selectedBranchCode.value);
    }
  }

}

