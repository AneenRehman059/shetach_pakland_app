import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/billing/data/pdf_statment_service.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/features/billing/presentation/controllers/get_account_statement_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/billing/data/models/get_statement_model.dart';

class AccountStatementScreen extends StatefulWidget {
  final String registrationNo;
  final String brnCode;
  final String plotType;
  final String idNo;

  const AccountStatementScreen({
    super.key,
    required this.registrationNo,
    required this.brnCode,
    required this.plotType,
    required this.idNo,
  });

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  final AccountStatementController controller = Get.put(AccountStatementController());

  double progress = 0;
  InAppWebViewController? webController;
  bool _isLoading = true;
  bool _isDisposing = false;
  bool _isSaving = false;
  final List<String> copies = ["Client", "Office", "Account"];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAccountStatement(
        brnCode: widget.brnCode,
        registrationNo: widget.registrationNo,
        idNo: widget.idNo,
        userName: widget.idNo,
        reportId: 100201,
        receiptNo: '',
        copies: copies,
      );
    });
  }

  @override
  void dispose() {
    webController?.stopLoading();
    webController = null;
    Get.delete<AccountStatementController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() => _isDisposing = true);
        await Future.delayed(const Duration(milliseconds: 150));
        webController?.stopLoading();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appColor,
          title: const Text(
            "Account Statement",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              setState(() => _isDisposing = true);
              await Future.delayed(const Duration(milliseconds: 150));
              webController?.stopLoading();
              Get.back();
            },
          ),
          actions: [
            _isSaving
                ? const Padding(
              padding: EdgeInsets.all(14.0),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            )
                : IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _launchPrintUrl,
              tooltip: 'Save as PDF',
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
                    'Loading Statement Data...',
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
                    'No statement data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (controller.accountStatement.value!.success)
                Expanded(
                  child: Stack(
                    children: [
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
                            transparentBackground: false,
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
                            debugPrint("Account Statement Loading URL: $url");
                            setState(() {
                              _isLoading = true;
                            });
                          },
                          onLoadStop: (controller, url) async {
                            debugPrint("Account Statement Loaded: $url");
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
                          // onReceivedError: (controller, request, error) {
                          //   debugPrint("WebView Error: ${error.description}");
                          //   setState(() {
                          //     _isLoading = false;
                          //   });
                          //
                          //   showTopSnackBar(
                          //     context,
                          //     "Failed to load content: ${error.description}",
                          //     Colors.orange.withOpacity(0.7),
                          //     icon: Icons.warning,
                          //   );
                          // },
                          onConsoleMessage: (controller, consoleMessage) {
                            debugPrint("WebView Console: ${consoleMessage.message}");
                          },
                        ),

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
                                  'Loading Account Statement...',
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
// Replace _launchPrintUrl and add these methods to _AccountStatementScreenState

  Future<void> _launchPrintUrl() async {
    final reportUrl = controller.accountStatement.value?.reportUrl ?? '';

    if (reportUrl.isEmpty) {
      showTopSnackBar(
        context,
        "No statement available to print",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
      return;
    }

    // ✅ Directly trigger PDF save — no new screen needed
    await _saveAsPdf(reportUrl);
  }

  Future<void> _saveAsPdf(String reportUrl) async {
    if (webController == null) {
      showTopSnackBar(
        context,
        "Please wait for the statement to finish loading",
        Colors.orange.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Step 1: Get raw HTML from webview
      String html = await _getPageHtml();

      // Step 2: Remove <noscript> blocks
      html = _removeNoscriptTags(html);

      // Step 3: Embed all images as base64
      html = await _embedImagesAsBase64(html, reportUrl);

      setState(() => _isSaving = false);

      // Step 4: Open print/save dialog
      await Printing.layoutPdf(
        onLayout: (format) async {
          return await Printing.convertHtml(
            format: format,
            html: html,
          );
        },
        name: 'Account_Statement.pdf',
      );
    } catch (e) {
      debugPrint("PDF Save Error: $e");
      if (mounted) {
        setState(() => _isSaving = false);
        showTopSnackBar(
          context,
          "Failed to save PDF. Please try again.",
          Colors.red.withOpacity(0.7),
          icon: Icons.error,
        );
      }
    }
  }

  Future<String> _getPageHtml() async {
    if (webController == null) return '<html><body>No content</body></html>';
    try {
      final result = await webController!.callAsyncJavaScript(
        functionBody: '''
        await Promise.all(
          Array.from(document.images).map(img => {
            if (img.complete) return Promise.resolve();
            return new Promise(resolve => {
              img.onload = resolve;
              img.onerror = resolve;
            });
          })
        );

        await Promise.all(
          Array.from(document.images).map(img => {
            return new Promise(resolve => {
              if (!img.src || img.src.startsWith('data:')) {
                resolve();
                return;
              }
              fetch(img.src)
                .then(r => r.blob())
                .then(blob => new Promise((res, rej) => {
                  const reader = new FileReader();
                  reader.onloadend = () => {
                    img.src = reader.result;
                    res();
                  };
                  reader.onerror = rej;
                  reader.readAsDataURL(blob);
                }))
                .then(resolve)
                .catch(() => resolve());
            });
          })
        );

        if (!document.querySelector("base")) {
          var base = document.createElement("base");
          base.href = window.location.href;
          document.head.prepend(base);
        }

        return document.documentElement.outerHTML;
      ''',
      );
      return result?.value?.toString() ?? '<html><body>No content</body></html>';
    } catch (e) {
      debugPrint("HTML fetch error: $e");
      return '<html><body>No content</body></html>';
    }
  }

  String _removeNoscriptTags(String html) {
    return html.replaceAll(
      RegExp(r'<noscript[^>]*>[\s\S]*?</noscript>', caseSensitive: false),
      '',
    );
  }

  Future<String> _embedImagesAsBase64(String html, String baseUrl) async {
    final RegExp imgRegex = RegExp(
      r'''<img\s[^>]*src=["']([^"']+)["'][^>]*>''',
      caseSensitive: false,
    );

    final matches = imgRegex.allMatches(html).toList();
    final Map<String, String> replacements = {};

    await Future.wait(matches.map((match) async {
      final originalSrc = match.group(1)!;
      if (replacements.containsKey(originalSrc)) return;
      if (originalSrc.startsWith('data:')) return;

      try {
        final absoluteUrl = _makeAbsolute(originalSrc, baseUrl);
        final response = await http
            .get(Uri.parse(absoluteUrl))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final mimeType = response.headers['content-type'] ?? 'image/png';
          final base64Str = base64Encode(response.bodyBytes);
          replacements[originalSrc] = 'data:$mimeType;base64,$base64Str';
        }
      } catch (e) {
        debugPrint("Image embed error for $originalSrc: $e");
      }
    }));

    String result = html;
    replacements.forEach((original, base64Uri) {
      result = result.replaceAll(
        RegExp('src=["\']${RegExp.escape(original)}["\']', caseSensitive: false),
        'src="$base64Uri"',
      );
    });

    return result;
  }

  String _makeAbsolute(String src, String baseUrl) {
    if (src.startsWith('http://') || src.startsWith('https://')) return src;
    final uri = Uri.parse(baseUrl);
    if (src.startsWith('/')) return '${uri.scheme}://${uri.host}$src';
    final basePath = baseUrl.substring(0, baseUrl.lastIndexOf('/') + 1);
    return '$basePath$src';
  }
}