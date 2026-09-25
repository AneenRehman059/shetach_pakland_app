import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/constants/download_contant.dart';
import 'package:pakland/features/billing/data/services/pdf_statment_service.dart';
import 'package:pakland/features/billing/presentation/controllers/view_bill_controller.dart';

class ViewBillScreen extends StatefulWidget {
  final String registrationNo;
  final String brnCode;
  final String plotType;
  final String idNo;
  final int billNo;

  const ViewBillScreen({
    super.key,
    required this.registrationNo,
    required this.brnCode,
    required this.plotType,
    required this.idNo,
    required this.billNo
  });

  @override
  State<ViewBillScreen> createState() => _ViewBillScreenState();
}

class _ViewBillScreenState extends State<ViewBillScreen> {
  final ViewBillController controller = Get.put(ViewBillController());

  double progress = 0;
  InAppWebViewController? webController;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _isDisposing = false;  // Add this flag

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBill(
        brnCode: widget.brnCode,
        registrationNo: widget.registrationNo,
        idNo: widget.idNo,
        userName: widget.idNo,
        billNo: widget.billNo.toString(),
      );
    });
  }

  @override
  void dispose() {
    // Clean up WebView resources
    _cleanupWebView();
    Get.delete<ViewBillController>();
    super.dispose();
  }

  Future<void> _cleanupWebView() async {
    setState(() => _isDisposing = true);
    if (webController != null) {
      await webController?.stopLoading();
      // Small delay to ensure stopLoading completes
      await Future.delayed(const Duration(milliseconds: 150));
    }
    webController = null;
  }

  Future<void> _downloadBill() async {
    if (_isDownloading) return;

    final reportUrl = controller.accountStatement.value?.reportUrl ?? '';

    if (reportUrl.isEmpty) {
      showTopSnackBar(
        context,
        "No bill available to download",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      // Check if we need to use JavaScript to print
      if (webController != null && !_isDisposing) {
        // Try to trigger browser's print dialog
        await webController?.evaluateJavascript(
          source: "window.print();",
        );

        showTopSnackBar(
          context,
          "Print dialog opened. Select 'Save as PDF' in the print dialog.",
          Colors.blue.withOpacity(0.7),
          icon: Icons.print,
          duration: const Duration(seconds: 5),
        );
      } else {
        showTopSnackBar(
          context,
          "Cannot print at this time",
          Colors.orange.withOpacity(0.7),
          icon: Icons.warning,
        );
      }
    } catch (e) {
      debugPrint("Print error: $e");
      showTopSnackBar(
        context,
        "Failed to open print dialog",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(  // Add WillPopScope
      onWillPop: () async {
        await _cleanupWebView();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appColor,
          title: const Text(
            "Bill",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              await _cleanupWebView();
              Get.back();
            },
          ),
          actions: [
            _isDownloading
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
                : IconButton(
              icon: Icon(Icons.download, color: Colors.white),
              onPressed: _downloadBill,
              tooltip: 'Download Bill as PDF',
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(color: AppColors.appColor, size: 50.0),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Bill...',
                    style: TextStyle(
                      color: AppColors.appColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final reportUrl = controller.accountStatement.value?.reportUrl ?? '';

          if (reportUrl.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No bill available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final isSuccess = controller.accountStatement.value?.success ?? false;

          if (!isSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bill',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please check your connection and try again',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.fetchBill(
                        brnCode: widget.brnCode,
                        registrationNo: widget.registrationNo,
                        idNo: widget.idNo,
                        userName: widget.idNo,
                        billNo: widget.billNo.toString(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appColor,
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Only show WebView if not disposing
                    if (!_isDisposing)
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(reportUrl),
                        ),
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          useOnLoadResource: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowFileAccessFromFileURLs: true,
                          allowsInlineMediaPlayback: true,
                          transparentBackground: true,
                          supportZoom: true,
                          disableVerticalScroll: false,
                          disableHorizontalScroll: false,
                        ),
                        onWebViewCreated: (controller) {
                          webController = controller;
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        onProgressChanged: (controller, progressValue) {
                          setState(() => progress = progressValue / 100);
                        },
                        onLoadStart: (controller, url) async {
                          debugPrint("Bill Loading URL: $url");
                          setState(() {
                            _isLoading = true;
                          });
                        },
                        onLoadStop: (controller, url) async {
                          debugPrint("Bill Loaded: $url");
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        onReceivedServerTrustAuthRequest: (controller, challenge) async {
                          debugPrint("SSL Bypass for: ${challenge.protectionSpace.host}");
                          return ServerTrustAuthResponse(
                            action: ServerTrustAuthResponseAction.PROCEED,
                          );
                        },
                        onReceivedHttpAuthRequest: (controller, challenge) async {
                          debugPrint("HTTP Auth required: ${challenge.protectionSpace.host}");
                          return HttpAuthResponse(
                            action: HttpAuthResponseAction.PROCEED,
                          );
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          debugPrint("WebView Console: ${consoleMessage.message}");
                        },
                      ),

                    // Loading indicator
                    if (_isLoading || progress < 1.0)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: progress < 1.0 ? progress : null,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.appColor),
                        ),
                      ),

                    // Full screen loading for initial load
                    if (_isLoading && progress == 0)
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitWave(color: AppColors.appColor, size: 40.0),
                              const SizedBox(height: 16),
                              Text(
                                'Loading Bill...',
                                style: TextStyle(
                                  color: AppColors.appColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}