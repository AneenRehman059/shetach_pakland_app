import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pakland/models/view_bill_model.dart';
import 'package:pakland/models/view_bill_receipt_model.dart';
import '../constants/api_constant.dart';
import '../models/account_statement_model.dart';

class ViewBillRepository {

  Future<ViewBillResponse> getViewBill(ViewBillRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getBillUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ViewBillResponse.fromJson(data);
      } else {
        throw Exception('Failed to load account statement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load account statement: $e');
    }
  }

  Future<ViewBillReceiptResponse> getBillReceipt(ViewBillReceiptRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getBillUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ViewBillReceiptResponse.fromJson(data);
      } else {
        throw Exception('Failed to load account statement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load account statement: $e');
    }
  }
}