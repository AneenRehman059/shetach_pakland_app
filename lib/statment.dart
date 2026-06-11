import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:printing/printing.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'colors.dart';

class PrintWebViewScreen extends StatefulWidget {
  final String url;
  const PrintWebViewScreen({super.key, required this.url});

  @override
  State<PrintWebViewScreen> createState() => _PrintWebViewScreenState();
}

class _PrintWebViewScreenState extends State<PrintWebViewScreen> {
  InAppWebViewController? _webController;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appColor,
        title: const Text("Receipt", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(14.0),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            ),
          )
              : IconButton(
            icon: Icon(Icons.file_download, color: Colors.white),
            tooltip: 'Save as PDF',
            onPressed: _saveAsPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              supportZoom: true,
              transparentBackground: false,
            ),
            onWebViewCreated: (controller) => _webController = controller,
            onLoadStart: (controller, url) =>
                setState(() => _isLoading = true),
            onLoadStop: (controller, url) =>
                setState(() => _isLoading = false),
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitWave(color: AppColors.appColor, size: 40.0),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Receipt...',
                      style: TextStyle(
                          color: AppColors.appColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveAsPdf() async {
    if (_webController == null) return;
    setState(() => _isSaving = true);

    try {
      // Step 1: Get raw HTML from webview
      String html = await _getPageHtml();

      // Step 2: Remove <noscript> blocks (fixes "browser does not support scripts" message)
      html = _removeNoscriptTags(html);

      // Step 3: Embed all images as base64 (fixes missing images in PDF)
      html = await _embedImagesAsBase64(html);

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save PDF. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Fetch the full HTML from the webview — wait for all images to load first
  Future<String> _getPageHtml() async {
    if (_webController == null) return '<html><body>No content</body></html>';
    try {
      final result = await _webController!.callAsyncJavaScript(
        functionBody: '''
        // Wait for all images to be loaded
        await Promise.all(
          Array.from(document.images).map(img => {
            if (img.complete) return Promise.resolve();
            return new Promise(resolve => {
              img.onload = resolve;
              img.onerror = resolve;
            });
          })
        );

        // Convert all images to base64 inline
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

        // Inject base tag
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

  /// Remove <noscript>...</noscript> blocks from HTML
  /// This prevents the "browser does not support scripts" message
  String _removeNoscriptTags(String html) {
    return html.replaceAll(
      RegExp(r'<noscript[^>]*>[\s\S]*?</noscript>', caseSensitive: false),
      '',
    );
  }

  /// Find all <img src="..."> tags, download each image,
  /// and replace src with a base64 data URI so the PDF renderer can show them
  Future<String> _embedImagesAsBase64(String html) async {
    final RegExp imgRegex = RegExp(
      r'''<img\s[^>]*src=["']([^"']+)["'][^>]*>''',
      caseSensitive: false,
    );

    // Collect all unique image URLs first
    final matches = imgRegex.allMatches(html).toList();
    final Map<String, String> replacements = {}; // original src -> base64 URI

    await Future.wait(matches.map((match) async {
      final originalSrc = match.group(1)!;
      if (replacements.containsKey(originalSrc)) return; // already processed
      if (originalSrc.startsWith('data:')) return; // already base64

      try {
        // Make URL absolute if it's relative
        final absoluteUrl = _makeAbsolute(originalSrc);
        final response = await http
            .get(Uri.parse(absoluteUrl))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final mimeType =
              response.headers['content-type'] ?? 'image/png';
          final base64Str = base64Encode(response.bodyBytes);
          replacements[originalSrc] = 'data:$mimeType;base64,$base64Str';
        }
      } catch (e) {
        debugPrint("Image embed error for $originalSrc: $e");
      }
    }));

    // Replace all src values with base64 URIs
    String result = html;
    replacements.forEach((original, base64Uri) {
      result = result.replaceAll(
        RegExp('src=["\']${RegExp.escape(original)}["\']',
            caseSensitive: false),
        'src="$base64Uri"',
      );
    });

    return result;
  }

  /// Convert relative URL to absolute using the webview's current URL
  String _makeAbsolute(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return src;
    }
    final base = widget.url;
    final uri = Uri.parse(base);
    if (src.startsWith('/')) {
      return '${uri.scheme}://${uri.host}$src';
    }
    // Relative path — resolve against base URL directory
    final basePath = base.substring(0, base.lastIndexOf('/') + 1);
    return '$basePath$src';
  }
}