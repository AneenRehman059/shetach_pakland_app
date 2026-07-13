import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/models/bill_receipt_model.dart';
import '../constants/api_constant.dart';

class BillReceiptController extends GetxController {
  final String registrationNo;
  final String brnCode;

  final isLoading = true.obs;
  final receiptList = <BillReceipt>[].obs;

  BillReceiptController({
    required this.registrationNo,
    required this.brnCode,
  });

  @override
  void onInit() {
    super.onInit();
    fetchAccountStatement();
  }

  Future<void> fetchAccountStatement() async {
    try {
      isLoading(true);

      print('=== FETCHING RECEIPTS ===');
      print('Registration No: $registrationNo');
      print('BRN Code: $brnCode');

      // FIXED: Using correct parameter order from the curl example
      // brn_code first, then registration_no
      final url = Uri.parse(
        "${ApiConstants.getStatementUrl}?brn_code=$brnCode&regitration_no=$registrationNo",
      );

      print('API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response body: $data');

        print('StatusCode: ${data['StatusCode']}');
        print('Message: ${data['Message']}');

        // Check if response is successful
        if (data['StatusCode'] == '200' || data['StatusCode'] == 200) {
          // Check the structure of 'obj'
          if (data['obj'] != null) {
            print('obj type: ${data['obj'].runtimeType}');
            print('obj value: ${data['obj']}');

            // Try to parse the response
            try {
              final receiptResponse = BillReceiptResponse.fromJson(data);

              if (receiptResponse.receipts.isNotEmpty) {
                receiptList.assignAll(receiptResponse.receipts);
                print('Found ${receiptList.length} receipts');

                // Debug: Print first receipt details
                if (receiptList.isNotEmpty) {
                  final first = receiptList.first;
                  print('First receipt: No=${first.receiptNo}, Amount=${first.receivedAmt}, Mode=${first.paymentMode}');
                }
              } else {
                receiptList.clear();
                showErrorSnackBar('No receipt data available');
                print('Receipt list is empty after parsing');
              }
            } catch (e) {
              receiptList.clear();
              showErrorSnackBar('Error parsing response: $e');
              print('Parsing error: $e');
              print('Problematic data: $data');
            }
          } else {
            receiptList.clear();
            showErrorSnackBar('No data found in response');
            print('obj is null in response');
          }
        } else {
          receiptList.clear();
          showErrorSnackBar('API Error: ${data['Message']}');
        }
      } else {
        receiptList.clear();
        showErrorSnackBar('Failed to load receipts: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Full URL that failed: $url');
      }
    } catch (e) {
      receiptList.clear();
      showErrorSnackBar('Failed to load receipts: ${e.toString()}');
      print('Error: $e');
    } finally {
      isLoading(false);
      print('Loading completed. isLoading: ${isLoading.value}');
      print('Receipts count: ${receiptList.length}');
    }
  }

  void showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
    );
  }
}