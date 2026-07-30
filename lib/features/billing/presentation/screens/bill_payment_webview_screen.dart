import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';

import 'package:pakland/features/billing/presentation/screens/bill_reg_no_screen.dart';

class BillPaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String brnCode;
  final String brnName;

  const BillPaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.brnCode,
    required this.brnName,
  });

  @override
  State<BillPaymentWebViewScreen> createState() => _BillPaymentWebViewScreenState();
}

class _BillPaymentWebViewScreenState extends State<BillPaymentWebViewScreen> {
  double progress = 0;
  bool hasReloadedFinalPage = false;
  InAppWebViewController? webController;
  bool _isLoading = false;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCanGoBack();
    });
  }

  Future<void> _checkCanGoBack() async {
    if (webController != null) {
      _canGoBack = await webController!.canGoBack();
      setState(() {});
    }
  }

  Future<bool> _onWillPop() async {
    if (_canGoBack) {
      // If webview can go back, go back in webview history
      await webController?.goBack();
      await _checkCanGoBack();
      return false; // Don't pop the route
    } else {
      // If webview cannot go back, navigate to ClientListScreen with refresh
      _navigateBackWithRefresh();
      return false; // We handle navigation ourselves
    }
  }

  void _navigateBackWithRefresh() {
    // Clear selections and refresh ClientListScreen
    Get.offAll(
          () => ClientListScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _handleAppBarBack() {
    // This will trigger the same logic as hardware back button
    _onWillPop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Payment Portal",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleAppBarBack,
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.paymentUrl),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useOnLoadResource: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                webController = controller;
              },
              onProgressChanged: (controller, progressValue) async {
                setState(() => progress = progressValue / 100);
                if (progressValue == 100) {
                  await _checkCanGoBack();
                }
              },
              onLoadStart: (controller, url) async {
                debugPrint("Loading URL: $url");

                if (url != null &&
                    url.toString().contains(
                      "sukheradeveloper.shesoft.com.pk/Privacy/PaymentProceed",
                    ) &&
                    !hasReloadedFinalPage) {
                  hasReloadedFinalPage = true;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Redirecting to confirmation...")),
                  );

                  await controller.loadUrl(
                    urlRequest: URLRequest(url: WebUri(url.toString())),
                  );
                }
              },
              onLoadStop: (controller, url) {
                debugPrint("Finished: $url");
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                debugPrint("SSL challenge: ${challenge.protectionSpace.host}");
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              onReceivedError: (controller, request, error) {
                debugPrint("Web error: ${error.description}");
              },
              onUpdateVisitedHistory: (controller, url, isReload) async {
                await _checkCanGoBack();
              },
            ),
            if (progress < 1)
              LinearProgressIndicator(value: progress),
            if (_isLoading)
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Returning to bills...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: _canGoBack
            ? FloatingActionButton.small(
          backgroundColor: AppColors.appColor,
          onPressed: () {
            webController?.goBack();
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        )
            : null,
      ),
    );
  }
}