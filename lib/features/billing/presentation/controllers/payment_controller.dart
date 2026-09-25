import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/features/billing/presentation/screens/bill_payment_webview_screen.dart';

import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/billing/presentation/screens/payment_webview_screen.dart';
import 'package:pakland/features/billing/data/repositories/pay_now_repo.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repo = PaymentRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String registrationNo,
    required String paymentType,
    required String paymentCode,
    required String memberName,
    required String brnCode,
    required String brnName,
    required String clientId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> body = {
        "Registration": {
          "Currency": "AED",
          "ReturnPath": "",
          "TransactionHint": "CPT:Y;VCC:Y;",
          "OrderID": "3333333344444",
          "OrderName": "3333333344444",
          "Channel": "Web",
          "Amount": amount.toStringAsFixed(2),
          "Customer": "Demo Merchant",
          "Store": "0000",
          "Terminal": "0000",
          "UserName": "Demo_fY9c",
          "Password": "Comtrust@20182018",
          "brn_code": brnCode,
          "registration_no": registrationNo,
          "payment_type": paymentType,
          "CNIC": clientId,
          "deviceInfo": {
            "deviceId": "string",
            "deviceModel": "string",
            "platform": "string",
            "osVersion": "string",
            "latitude": "string",
            "longitude": "string",
            "manufacturer": "string",
            "operatingSystem": "string",
            "webViewVersion": "string"
          }
        }
      };

      final response = await _repo.processPayment(body);

      // Check the response structure based on your API
      print(response["StatusCode"]);
      if (response["StatusCode"] == "0") {
        // Success case - navigate to payment webview
        final String? paymentUrl = response["obj"]["Url"];

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          Get.to(() => PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            brnCode: brnCode,
            brnName: brnName,
          ));

          // showTopSnackBar(
          //     context,
          //     response["Message"] ?? "Payment processed successfully",
          //     Colors.green.withOpacity(0.7),
          //     icon: Icons.check_circle
          // );
          return true;
        } else {
          showTopSnackBar(
              context,
              "Payment URL not found",
              Colors.red.withOpacity(0.7),
              icon: Icons.warning
          );
          return false;
        }
      } else {
        // Error case
        showTopSnackBar(
            context,
            response["Message"] ?? "Payment processing failed",
            Colors.red.withOpacity(0.7),
            icon: Icons.warning
        );
        return false;
      }
    } catch (e) {
      showTopSnackBar(
          context,
          "Payment failed: ${e.toString()}",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> billProcessPayment({
    required BuildContext context,
    required double amount,
    required String registrationNo,
    required String paymentType,
    required String paymentCode,
    required String memberName,
    required String brnCode,
    required String brnName,
    required String clientId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> body = {
        "Registration": {
          "Currency": "AED",
          "ReturnPath": "",
          "TransactionHint": "CPT:Y;VCC:Y;",
          "OrderID": "3333333344444",
          "OrderName": "3333333344444",
          "Channel": "Web",
          "Amount": amount.toStringAsFixed(2),
          "Customer": "Demo Merchant",
          "Store": "0000",
          "Terminal": "0000",
          "UserName": "Demo_fY9c",
          "Password": "Comtrust@20182018",
          "brn_code": brnCode,
          "registration_no": registrationNo,
          "payment_type": paymentType,
          "CNIC": clientId,
          "deviceInfo": {
            "deviceId": "string",
            "deviceModel": "string",
            "platform": "string",
            "osVersion": "string",
            "latitude": "string",
            "longitude": "string",
            "manufacturer": "string",
            "operatingSystem": "string",
            "webViewVersion": "string"
          }
        }
      };

      final response = await _repo.processPayment(body);

      // Check the response structure based on your API
      print(response["StatusCode"]);
      if (response["StatusCode"] == "0") {
        // Success case - navigate to payment webview
        final String? paymentUrl = response["obj"]["Url"];

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          Get.to(() => BillPaymentWebViewScreen(
            paymentUrl: paymentUrl,
            brnCode: brnCode,
            brnName: brnName,
          ));

          // showTopSnackBar(
          //     context,
          //     response["Message"] ?? "Payment processed successfully",
          //     Colors.green.withOpacity(0.7),
          //     icon: Icons.check_circle
          // );
          return true;
        } else {
          showTopSnackBar(
              context,
              "Payment URL not found",
              Colors.red.withOpacity(0.7),
              icon: Icons.warning
          );
          return false;
        }
      } else {
        // Error case
        showTopSnackBar(
            context,
            response["Message"] ?? "Payment processing failed",
            Colors.red.withOpacity(0.7),
            icon: Icons.warning
        );
        return false;
      }
    } catch (e) {
      showTopSnackBar(
          context,
          "Payment failed: ${e.toString()}",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}