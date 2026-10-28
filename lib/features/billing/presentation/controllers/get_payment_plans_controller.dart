import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pakland/features/company/data/models/get_branch_model.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/billing/data/repositories/payment_plan_repo.dart';

class PaymentPlanController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final PaymentPlanRepo _repo = PaymentPlanRepo();
  var plansWithNames = <Map<String, String>>[].obs;
  var branchList = <Branch>[].obs;
  var selectedBranchName = "".obs;
  var selectedBranchCode = "".obs;
  var isLoading = true.obs;
  var areImagesLoaded = false.obs;
  int _loadRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    selectedBranchName("All");
    selectedBranchCode("");
    // loadBranches() is called by PaymentPlanScreen.initState; calling it here
    // as well made the first open load the plans twice (duplicate plans).
  }

  Future<void> loadBranches() async {
    isLoading(true);
    try {
      final data = await _repo.fetchBranches();
      final branchListResponse = BranchModel.fromJson(data);

      if (branchListResponse.statusCode == "200") {
        branchList.assignAll(branchListResponse.branchList);

        await loadPaymentPlanImages("All");
      }
    } catch (e) {
      debugPrint("Error loading branches: $e");
    } finally {
      isLoading(false);
    }
  }


  Future<void> loadPaymentPlanImages(String brnCode) async {
    isLoading(true);
    areImagesLoaded(false);
    final int requestId = ++_loadRequestId;
    final List<Map<String, String>> loaded = [];
    plansWithNames.clear();

    try {
      String? storedPlans = await _storage.read(key: "mobile_payment_plan");
      if (storedPlans != null) {
        List<dynamic> plans = jsonDecode(storedPlans);

        final filteredPlans = brnCode == "All"
            ? plans
            : plans.where((plan) => plan["brn_code"]?.toString() == brnCode).toList();

        for (var plan in filteredPlans) {
          String path = plan["image_path"]?.toString() ?? "";
          if (path.isEmpty) continue;

          String url = "${ApiConstants.baseUrl}$path"
              .replaceAll(RegExp(r'/+'), '/')
              .replaceFirst(':/', '://');

          loaded.add({
            "plan_name": plan["plan_name"]?.toString() ?? "",
            "image_url": url,
          });
        }

        // A newer request started meanwhile -> drop this stale result.
        if (requestId != _loadRequestId) return;
        plansWithNames.assignAll(loaded);

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
      if (requestId == _loadRequestId) isLoading(false);
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

