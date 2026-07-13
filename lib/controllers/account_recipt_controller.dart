import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../customs/toast_message.dart';
import '../models/recipt_model.dart';

class AccountReciptController extends GetxController {
  final String registrationNo;
  final String brnCode;

  final isLoading = true.obs;
  final receiptList = <Receipt>[].obs;

  AccountReciptController({
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

      print('Fetching receipts for: $registrationNo, $brnCode');

      final url = Uri.parse(
        "${ApiConstants.getReciptUrl}?regeration_no=$registrationNo&brncode=$brnCode",
      );

      print('API URL: $url');

      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if data structure is correct
        if (data['obj'] != null && data['obj']['Receiptlist'] != null) {
          final receiptData = data['obj']['Receiptlist'] as List;
          print('Found ${receiptData.length} receipts');

          final List<Receipt> parsedReceipts = [];

          for (var item in receiptData) {
            try {
              final receipt = Receipt.fromJson(item);
              parsedReceipts.add(receipt);
            } catch (e) {
              print('Error parsing receipt item: $e');
              print('Problematic item: $item');
            }
          }

          receiptList.assignAll(parsedReceipts);

          if (parsedReceipts.isEmpty) {
            _showSnackBar('No valid receipt data found', Colors.red.withOpacity(0.7));
          }
        } else {
          receiptList.clear();
          _showSnackBar('No receipt data available in response',Colors.red.withOpacity(0.7));
          print('Unexpected response structure: $data');
        }
      } else {
        receiptList.clear();
        _showSnackBar('Failed to load receipts: ${response.statusCode}', Colors.red.withOpacity(0.7));
      }
    } catch (e) {
      receiptList.clear();
      _showSnackBar('Failed to load receipts: ${e.toString()}', Colors.red.withOpacity(0.7));
      print('Error: $e');
    } finally {
      isLoading(false);
      print('Loading completed. isLoading: ${isLoading.value}');
      print('Receipts count: ${receiptList.length}');
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    // Use Get.context to get the current context for showing the snackbar
    final context = Get.context;
    if (context != null) {
      showTopSnackBar(
        context,
        message,
        backgroundColor,
        title: backgroundColor == Colors.red ? 'Error' : 'Warning',
        icon: backgroundColor == Colors.red ? Icons.error : Icons.warning,
      );
    } else {
      // Fallback to regular Get.snackbar if context is not available
      Get.snackbar(
        backgroundColor == Colors.red ? 'Error' : 'Warning',
        message,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}