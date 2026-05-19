import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/models/get_statement_model.dart';

import '../constants/api_constant.dart';
import '../models/account_statement_model.dart';
import '../repo/account_statment_repo.dart';

class AccountStatementController extends GetxController {
  final AccountStatementRepository _repository = AccountStatementRepository();

  final Rx<AccountStatementResponse?> accountStatement = Rx<AccountStatementResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

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

  Future<void> fetchReceiptStatement({
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

  void clearData() {
    accountStatement.value = null;
    error.value = '';
  }
}
