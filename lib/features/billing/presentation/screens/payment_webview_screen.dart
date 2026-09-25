import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/billing/presentation/screens/payment_plan_detail_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String brnCode;
  final String brnName;

  const PaymentWebViewScreen({super.key,
    required this.paymentUrl,
    required this.brnCode,
    required this.brnName
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  double progress = 0;
  bool hasReloadedFinalPage = false;

  InAppWebViewController? webController;
  void _handleBackNavigation() {
    Get.offAll(
          () => PayOnlineScreen(
        brnCode: widget.brnCode,
        brnName: widget.brnName,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Payment Portal",style: TextStyle(color: Colors.white),),
        centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
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
              onProgressChanged: (controller, progressValue) {
                setState(() => progress = progressValue / 100);
              },
              onLoadStart: (controller, url) async {
                debugPrint("Loading URL: $url");

                if (url != null &&
                    url.toString().contains(
                      "paklandhousing.shesoft.com.pk/Privacy/PaymentProceed",
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
              onReceivedServerTrustAuthRequest:
                  (controller, challenge) async {
                debugPrint("SSL challenge: ${challenge.protectionSpace.host}");
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              onReceivedError: (controller, request, error) {
                debugPrint("Web error: ${error.description}");
              },
            ),
            if (progress < 1)
              LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}