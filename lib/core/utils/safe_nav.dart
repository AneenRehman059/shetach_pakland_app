import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Get.back() ke bajaye use karein.
///
/// Get.back() navigate karne se pehle closeCurrentSnackbar() chalata hai.
/// Agar koi Get.snackbar queue mein atak jaye (uska _controller initialize
/// na hua ho) to wo LateInitializationError deta hai aur back kabhi nahi
/// hota. SafeNav.back() seedha Navigator pop karta hai, is liye snackbar
/// ki state se bilkul independent hai. Dialogs / bottom sheets bhi routes
/// hain, is liye unke result bhi isi se wapas milte hain.
class SafeNav {
  SafeNav._();

  static void back<T extends Object?>({T? result}) {
    final nav = Get.key.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop<T>(result);
    }
  }
}
