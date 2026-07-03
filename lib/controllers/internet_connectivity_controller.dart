import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import '../customs/toast_message.dart';
import '../no_nerwork_screen.dart';

class InternetConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  RxBool isConnected = true.obs;
  bool isCheckingConnection = false;

  // NEW: track whether we're the ones who pushed OfflineScreen
  bool _isOfflineScreenShown = false;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
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
      final results = await _connectivity.checkConnectivity();
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
        _showOfflineScreen();
      }
    } else {
      if (!isConnected.value) {
        isConnected.value = true;
        _returnToLastScreen();
      }
    }
  }

  void _showOfflineScreen() {
    if (!_isOfflineScreenShown) {
      _isOfflineScreenShown = true;
      Get.to(() => const OfflineScreen());
    }
  }

  void _returnToLastScreen() {
    if (_isOfflineScreenShown) {
      _isOfflineScreenShown = false;
      // Pop OfflineScreen off the stack -> reveals the exact previous screen
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      } else {
        // Fallback only if there's genuinely nothing to go back to
        // (e.g. app was launched while offline)
        Get.offAll(() => MainWrapper(initialIndex: 0));
      }
    }
  }

  Future<void> checkAndRetrieveData(BuildContext context) async {
    if (isCheckingConnection) return;
    isCheckingConnection = true;

    try {
      await Future.delayed(Duration(milliseconds: 500));
      final results = await _connectivity.checkConnectivity();

      if (!results.contains(ConnectivityResult.none)) {
        isConnected.value = true;
        update();
        _returnToLastScreen(); // uses the same pop logic now

        showTopSnackBar(
          context,
          title: "Connection Restored",
          "Your internet Connection restored",
          Colors.green.withOpacity(0.7),
          icon: Icons.check_circle,
        );
      } else {
        showTopSnackBar(
          context,
          title: "Alert",
          "No Internet Connection Found",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning,
        );
      }
    } finally {
      Future.delayed(Duration(milliseconds: 1000), () {
        isCheckingConnection = false;
      });
    }
  }
}