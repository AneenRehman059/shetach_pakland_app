import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/booking/data/repositories/booking_repo.dart';

class BookingController extends GetxController {
  final _repo = BookingRepository();

  var branches = <Map<String, dynamic>>[].obs;
  var blocks = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;

  var selectedBranchName = "".obs;
  var selectedBranchCode = "".obs;

  var selectedBlockName = "".obs;
  var selectedBlockCode = "".obs;

  var plotSizes = <Map<String, dynamic>>[].obs;
  var plotNatures = <Map<String, dynamic>>[].obs;
  var plotTypes = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
    fetchPlotNatures();
    fetchPlotTypes();
  }
  Future<void> fetchPlotNatures({BuildContext? context}) async {
    try {
      isLoading.value = true;
      final data = await _repo.fetchPlotNatures();
      plotNatures.assignAll(data);
    } catch (e) {
      showTopSnackBar( context ?? Get.overlayContext!, title: "Alert",e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchPlotTypes({BuildContext? context}) async {
    try {
      isLoading.value = true;
      final data = await _repo.fetchPlotTypes();
      plotTypes.assignAll(data);
    } catch (e) {
      showTopSnackBar(context ?? Get.overlayContext!, title: "Alert",e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBranches({BuildContext? context}) async {
    try {
      isLoading.value = true;
      final data = await _repo.getBranches();
      branches.assignAll(data);
    } catch (e) {
      showTopSnackBar(context ?? Get.overlayContext!, title: "Alert",e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectBranch(String name) async {
    selectedBranchName.value = name;
    final branch = branches.firstWhere(
          (b) => b["brn_name"]?.trim() == name.trim(),
      orElse: () => {},
    );
    selectedBranchCode.value = branch["brn_code"] ?? "";

    if (selectedBranchCode.value.isNotEmpty) {
      await fetchBlocks(selectedBranchCode.value);
    }
  }

  Future<void> fetchBlocks(String branchCode,{BuildContext? context}) async {
    try {
      isLoading.value = true;
      final data = await _repo.fetchBlocks(branchCode);
      blocks.assignAll(data);
    } catch (e) {
      showTopSnackBar(context ?? Get.overlayContext!, title: "Alert",e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlotSizes(String branchCode, String blockNo,{BuildContext? context}) async {
    try {
      isLoading.value = true;
      final data = await _repo.fetchPlotSizes(branchCode, blockNo);
      plotSizes.assignAll(data);
    } catch (e) {
      showTopSnackBar(context ?? Get.overlayContext!, title: "Alert",e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitBooking({
    required String brnCode,
    // required String idNo,
    required String contactName,
    required String contactNo,
    required String plotSizeCode,
    required String plotNo,
    required String blockNo,
    required String email,
    required String plotType,
    required String plotNature,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final payload = {
        "brn_code": brnCode,
        // "id_no": idNo,
        "contact_name": contactName,
        "contact_no": contactNo,
        "token_remarks": "",
        "token_amt": "",
        "expirey_date": DateTime.now().toIso8601String(),
        "plot_category_desc": "",
        "net_price": 0,
        "plot_size_code": plotSizeCode,
        "plot_no": plotNo,
        "block_no": blockNo,
        "plot_type": plotType,
        "plot_nature_code": plotNature,
        "postby": "",
        "email": email,
        "status": "",
      };

      final success = await _repo.createBooking(payload);

      if (success) {

        showTopSnackBar(context,"Your request submitted successfully.", Colors.green.withOpacity(0.7),icon: Icons.check_circle);

        Get.offAll(() => MainWrapper());
      }
    } catch (e) {

      showTopSnackBar(context, title: "Alert",e.toString(), Colors.red.withOpacity(0.7),icon: Icons.warning);
    } finally {
      isLoading.value = false;
    }
  }


  void selectBlock(String name) async {
    selectedBlockName.value = name;
    final block = blocks.firstWhere(
          (b) => b["block_name"]?.trim() == name.trim(),
      orElse: () => {},
    );
    selectedBlockCode.value = block["block_no"] ?? "";

    if (selectedBranchCode.value.isNotEmpty && selectedBlockCode.value.isNotEmpty) {
      await fetchPlotSizes(selectedBranchCode.value, selectedBlockCode.value);
    }
  }
}
