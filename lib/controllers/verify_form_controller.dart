import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../customs/toast_message.dart';
import '../repo/verify_form_repo.dart';

class VerifyFormController extends GetxController {
  final VerifyFormRepository _repo = VerifyFormRepository();

  var isLoading = false.obs;
  var message = "".obs;
  var isSuccess = false.obs;
  var branchName = "".obs;
  var formNumber = "".obs;
  var formStatus = "".obs;
  var formCurrency = "".obs;

  void reset() {
    isLoading.value = false;
    message.value = "";
    isSuccess.value = false;
    branchName.value = "";
    formNumber.value = "";
    formStatus.value = "";
    formCurrency.value = "";
  }

  String get statusText {
    switch (formStatus.value.toUpperCase()) {
      case 'I':
        return "Normal - Ready for buying and selling";
      case 'R':
        return "Normal - Not ready for buying and selling";
      case 'C':
        return "Cancelled - This form has been cancelled";
      case 'A':
        return "Adjusted - Not ready for buying and selling";
      default:
        return "Status code not recognized";
    }
  }

  String get statusTitle {
    switch (formStatus.value.toUpperCase()) {
      case 'I':
        return "Normal / Ready";
      case 'R':
        return "Active / Not Ready";
      case 'C':
        return "Cancelled";
      case 'A':
        return "Adjusted";
      default:
        return "Unknown Status";
    }
  }

  Color get statusColor {
    switch (formStatus.value.toUpperCase()) {
      case 'I':
        return Colors.green; // bg-success-custom
      case 'R':
        return Colors.orange; // bg-warning-custom
      case 'C':
        return Colors.red; // bg-danger-custom
      case 'A':
        return Colors.blue; // bg-info-custom
      default:
        return Colors.grey; // bg-secondary
    }
  }

  Future<void> verifyForm({
    required BuildContext context,
    required String formNo,
  }) async {
    try {
      reset();
      isLoading.value = true;

      final data = await _repo.verifyForm(formNo);

      if (data["StatusCode"] == "200") {
        isSuccess.value = true;
        message.value = "Form number is Valid";

        branchName.value = data["obj"]["BranchName"] ?? "";
        formNumber.value = data["obj"]["FormNo"] ?? "";
        formStatus.value = data["obj"]["Form_status"] ?? "";
        formCurrency.value = data["obj"]["Currency_note"] ?? "";

        showTopSnackBar(context, "Form number is Valid", Colors.green);
      } else {
        isSuccess.value = false;
        showTopSnackBar(context, "Form number is Invalid", Colors.red);
      }
    } catch (e) {
      isSuccess.value = false;
      message.value = "Something went wrong";

      showTopSnackBar(context, "Something went wrong", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}