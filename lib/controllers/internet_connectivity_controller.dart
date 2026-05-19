import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/dashboard/main_screen.dart';
import '../customs/toast_message.dart';
import '../no_nerwork_screen.dart';

class InternetConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  RxBool isConnected = true.obs;
  bool isCheckingConnection = false; // Add this flag

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results,
        ) {
      _updateConnectionStatus(
        results.contains(ConnectivityResult.none)
            ? ConnectivityResult.none
            : results.first,
      );
    });

    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    try {
      final List<ConnectivityResult> results =
      await _connectivity.checkConnectivity();
      _updateConnectionStatus(
        results.contains(ConnectivityResult.none)
            ? ConnectivityResult.none
            : results.first,
      );
    } catch (e) {
      print("Error checking connection: $e");
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      if (isConnected.value) {
        isConnected.value = false;
        Get.off(() => OfflineScreen());
      }
    } else {
      if (!isConnected.value) {
        isConnected.value = true;
        _returnToLastScreen();
      }
    }
  }

  void _returnToLastScreen() {
    Get.offAll(() => MainWrapper(initialIndex: 0));
  }

  Future<void> checkAndRetrieveData(BuildContext context) async {
    // Prevent multiple simultaneous checks
    if (isCheckingConnection) return;

    isCheckingConnection = true;

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final List<ConnectivityResult> results =
      await _connectivity.checkConnectivity();

      if (!results.contains(ConnectivityResult.none)) {
        isConnected.value = true;
        update();
        _returnToLastScreen();

        showTopSnackBar(
            context,
            title: "Connection Restored",
            "Your internet Connection restored ️",
            Colors.green.withOpacity(0.7),
            icon: Icons.check_circle
        );

      } else {
        showTopSnackBar(
            context,
            title:"Alert",
            "No Internet Connection Found",
            Colors.red.withOpacity(0.7),
            icon: Icons.warning
        );
      }
    } finally {
      // Reset the flag after a short delay to prevent rapid successive calls
      Future.delayed(Duration(milliseconds: 1000), () {
        isCheckingConnection = false;
      });
    }
  }
}