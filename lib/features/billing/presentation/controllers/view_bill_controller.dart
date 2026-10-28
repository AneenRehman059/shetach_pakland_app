import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/features/billing/data/models/get_statement_model.dart';
import 'package:pakland/features/billing/data/models/view_bill_model.dart';
import 'package:pakland/features/billing/data/models/view_bill_receipt_model.dart';
import 'package:pakland/features/billing/data/repositories/view_bill_repo.dart';

import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/billing/data/models/account_statement_model.dart';
import 'package:pakland/features/billing/data/repositories/account_statement_repo.dart';

class ViewBillController extends GetxController {
  final ViewBillRepository _repository = ViewBillRepository();

  final Rx<ViewBillResponse?> accountStatement = Rx<ViewBillResponse?>(null);
  final Rx<ViewBillReceiptResponse?> receiptStatement = Rx<ViewBillReceiptResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchBill({
    required String brnCode,
    required String registrationNo,
    required String idNo,
    required String userName,
    required String billNo,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final request = ViewBillRequest(
        brnCode: brnCode,
        registrationNo: registrationNo,
        idNo: idNo,
        userName: userName,
        billNo: billNo
      );

      final response = await _repository.getViewBill(request);
      accountStatement.value = response;

      if (!response.success) {
        throw Exception('Failed to fetch bill');
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBillReceipt({
    required String brnCode,
    required String registrationNo,
    required String idNo,
    required String userName,
    required String billNo,
    required String receiptNo,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final request = ViewBillReceiptRequest(
          brnCode: brnCode,
          registrationNo: registrationNo,
          idNo: idNo,
          userName: userName,
          billNo: billNo,
        receiptNo: receiptNo
      );

      final response = await _repository.getBillReceipt(request);
      receiptStatement.value = response;

      if (!response.success) {
        throw Exception('Failed to fetch bill');
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    receiptStatement.value = null;
    error.value = '';
  }
}
