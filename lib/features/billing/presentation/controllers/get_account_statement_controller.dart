import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/features/billing/data/models/get_statement_model.dart';

import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/billing/data/models/account_statement_model.dart';
import 'package:pakland/features/billing/data/repositories/account_statment_repo.dart';

class AccountStatementController extends GetxController {
  final AccountStatementRepository _repository = AccountStatementRepository();

  final Rx<AccountStatementResponse?> accountStatement = Rx<AccountStatementResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxString receiptImageUrl = ''.obs;
  final RxBool isReceiptImageLoading = false.obs;
  final RxString receiptImageError = ''.obs;

  Future<void> fetchAccountStatement({
    required String brnCode,
    required String registrationNo,
    required String idNo,
    required String userName,
    required int reportId,
    required String receiptNo,
    required List<String> copies,

  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final request = AccountStatementRequest(
        brnCode: brnCode,
        registrationNo: registrationNo,
        idNo: idNo,
        userName: userName,
        reportId: reportId,
        receiptNo: receiptNo,
        copies: copies,
      );

      final response = await _repository.getAccountStatement(request);
      accountStatement.value = response;

      if (!response.success) {
        throw Exception('Failed to generate statement');
      }
    } catch (e) {
      error.value = e.toString();
      // Get.snackbar(
      //   'Error',
      //   e.toString(),
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReceiptImage({
    required String brnCode,
    required String receiptNo,
  }) async {
    try {
      isReceiptImageLoading.value = true;
      receiptImageError.value = '';
      receiptImageUrl.value = '';

      final url = await _repository.getReceiptImageUrl(
        brnCode: brnCode,
        receiptNo: receiptNo,
      );

      receiptImageUrl.value = url;
    } catch (e) {
      receiptImageError.value = e.toString();
    } finally {
      isReceiptImageLoading.value = false;
    }
  }

  void clearData() {
    accountStatement.value = null;
    error.value = '';
  }
}
