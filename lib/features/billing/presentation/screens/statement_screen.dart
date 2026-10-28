import 'package:pakland/core/widgets/loader.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

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
      appBar: AppHeaderBar(
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
              child: AppLoader(),
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
                    AppLoader(size: 80),
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
      String html = await _getPageHtml();

      html = _removeNoscriptTags(html);

      html = await _embedImagesAsBase64(html);

      setState(() => _isSaving = false);

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

  String _removeNoscriptTags(String html) {
    return html.replaceAll(
      RegExp(r'<noscript[^>]*>[\s\S]*?</noscript>', caseSensitive: false),
      '',
    );
  }

  Future<String> _embedImagesAsBase64(String html) async {
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

  String _makeAbsolute(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return src;
    }
    final base = widget.url;
    final uri = Uri.parse(base);
    if (src.startsWith('/')) {
      return '${uri.scheme}://${uri.host}$src';
    }
    final basePath = base.substring(0, base.lastIndexOf('/') + 1);
    return '$basePath$src';
  }
}