import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/download_contant.dart';
import 'package:pakland/core/widgets/toast_message.dart';

import 'package:pakland/core/services/permission_service.dart';

class PDFViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PDFViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      print(widget.pdfUrl);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to download PDF');
      }

      final bytes = response.bodyBytes;

      if (bytes.isEmpty) {
        throw Exception('Downloaded PDF is empty');
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(bytes);

      if (!await file.exists()) {
        throw Exception('Failed to create local PDF file');
      }

      setState(() {
        localFilePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      // Don't show error message for PDF loading
    }
  }

  Future<void> _downloadPdf() async {
    // Request permission using the system's default dialog
    final hasPermission = await DownloadUtils.requestPermission();

    // If permission is denied, simply return without any message
    if (!hasPermission) {
      return;
    }

    // Get the download path before downloading
    final directory = await DownloadUtils.getDownloadsDirectory();
    final sanitizedFileName = DownloadUtils.sanitizeFileName(widget.title);
    final expectedPath = '${directory?.path}/$sanitizedFileName.pdf';

    // First check if file exists
    final fileExists = await DownloadUtils.checkFileExists(widget.title);

    String downloadedFileName = widget.title;

    if (fileExists) {
      // If file exists, add timestamp to make it unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      downloadedFileName = '${widget.title}_$timestamp';
    }

    final result = await DownloadUtils.downloadFile(widget.pdfUrl, downloadedFileName);

    // Only show success message if download was successful
    if (result) {
      final finalPath = fileExists
          ? '${directory?.path}/${DownloadUtils.sanitizeFileName(downloadedFileName)}.pdf'
          : expectedPath;

      final message = fileExists
          ? "File already existed, downloaded as: $downloadedFileName\nPath: $finalPath"
          : "PDF downloaded successfully!\nPath: $finalPath";

      showTopSnackBar(
        context,
        message,
        Colors.green.withOpacity(0.7),
        icon: Icons.check_circle,
        duration: const Duration(seconds: 5),
      );
    } else {
      showTopSnackBar(
        context,
        "Download failed",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: AppColors.whiteBg),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.whiteBg),
        backgroundColor: AppColors.appColor,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: AppColors.whiteBg),
            onPressed: _downloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(
              color: AppColors.appColor,
              size: 50.0,
            ),
            Text(
              "Loading",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.appColor,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      )
          : localFilePath != null
          ? PDFView(
        filePath: localFilePath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {},
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load PDF'),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Error: $errorMessage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: loadPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),

    );
  }
}