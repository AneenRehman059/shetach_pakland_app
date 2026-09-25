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
import 'package:pakland/core/widgets/custom_messages.dart'; // ← your messages file

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
  bool _isDownloading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Failed to download PDF');
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) throw Exception('Downloaded PDF is empty');

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      if (!await file.exists()) throw Exception('Failed to create local PDF file');

      setState(() {
        localFilePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) return;

    // ── 1. Permission check ──────────────────────────────────────────
    final hasPermission = await DownloadUtils.requestPermission();
    if (!hasPermission) {
      // Check if permanently denied → guide to settings
      final isPermanentlyDenied =
          await Permission.storage.isPermanentlyDenied ||
              await Permission.photos.isPermanentlyDenied;

      if (mounted) {
        if (isPermanentlyDenied) {
          _showSettingsDialog();
        } else {
          showTopSnackBar(
            context,
            DownloadMessages.permissionDeniedMessage,
            Colors.red.shade800,
            title: DownloadMessages.permissionDeniedTitle,
            icon: Icons.lock,
          );
        }
      }
      return;
    }

    // ── 2. Storage space check ───────────────────────────────────────
    try {
      final hasSpace = await _hasEnoughStorage();
      if (!hasSpace) {
        if (mounted) {
          showTopSnackBar(
            context,
            DownloadMessages.insufficientStorageMessage,
            Colors.orange.shade800,
            title: DownloadMessages.insufficientStorageTitle,
            icon: Icons.storage_rounded,
          );
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        showTopSnackBar(
          context,
          DownloadMessages.storageCheckFailedMessage,
          Colors.orange.shade800,
          title: DownloadMessages.insufficientStorageTitle,
          icon: Icons.storage_rounded,
        );
      }
      return;
    }

    setState(() => _isDownloading = true);

    try {
      // ── 3. Duplicate file check ────────────────────────────────────
      final directory   = await DownloadUtils.getDownloadsDirectory();
      final fileExists  = await DownloadUtils.checkFileExists(widget.title);
      final timestamp   = DateTime.now().millisecondsSinceEpoch;

      final downloadedFileName = fileExists
          ? '${widget.title}_$timestamp'
          : widget.title;

      // ── 4. Download ────────────────────────────────────────────────
      final result = await DownloadUtils.downloadFile(
        widget.pdfUrl,
        downloadedFileName,
      );

      if (!mounted) return;

      if (result) {
        final sanitized = DownloadUtils.sanitizeFileName(downloadedFileName);
        final finalPath = '${directory?.path}/$sanitized.pdf';

        final message = fileExists
            ? '${DownloadMessages.duplicateFileMessage} $downloadedFileName\n${DownloadMessages.savedPathLabel} $finalPath'
            : DownloadMessages.downloadSuccessMessage;

        showTopSnackBar(
          context,
          message,
          Colors.green.shade800,
          title: DownloadMessages.downloadSuccessTitle,
          icon: Icons.check_circle,
          duration: const Duration(seconds: 5),
        );
      } else {
        showTopSnackBar(
          context,
          DownloadMessages.downloadFailedMessage,
          Colors.red.shade800,
          title: DownloadMessages.downloadFailedTitle,
          icon: Icons.error,
        );
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(
          context,
          DownloadMessages.downloadFailedMessage,
          Colors.red.shade800,
          title: DownloadMessages.downloadFailedTitle,
          icon: Icons.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // ── Settings dialog (permanently denied) ──────────────────────────
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              DownloadMessages.permissionSettingsTitle,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          DownloadMessages.permissionSettingsMessage,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              DownloadMessages.cancel,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.settings, color: Colors.white, size: 18),
            label: Text(
              DownloadMessages.openSettings,
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  // ── Storage check ──────────────────────────────────────────────────
  Future<bool> _hasEnoughStorage({int minRequiredMB = 50}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final result  = await Process.run('df', [tempDir.path]);

      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        if (lines.length >= 2) {
          final parts       = lines[1].trim().split(RegExp(r'\s+'));
          final availableKB = int.tryParse(parts[3]) ?? 0;
          return (availableKB / 1024) >= minRequiredMB;
        }
      }
      return await _probeStorageWrite(tempDir.path);
    } catch (_) {
      return await _probeStorageWrite(
          (await getTemporaryDirectory()).path);
    }
  }

  Future<bool> _probeStorageWrite(String dirPath) async {
    final probe = File('$dirPath/probe_${DateTime.now().millisecondsSinceEpoch}.tmp');
    try {
      await probe.writeAsBytes(List.filled(1024, 0));
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: AppColors.whiteBg)),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.whiteBg),
        backgroundColor: AppColors.appColor,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: AppColors.whiteBg),
            onPressed: _isDownloading ? null : _downloadPdf,
            tooltip: DownloadMessages.downloadTooltip,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWave(color: AppColors.appColor, size: 50.0),
            const SizedBox(height: 12),
            Text(
              DownloadMessages.loadingLabel,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.appColor,
                fontWeight: FontWeight.bold,
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
            const Icon(Icons.picture_as_pdf,
                color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              DownloadMessages.pdfLoadFailedMessage,
              style: const TextStyle(fontSize: 16),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${DownloadMessages.errorLabel} $errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appColor,
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                DownloadMessages.retryLabel,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: loadPdf,
            ),
          ],
        ),
      ),
    );
  }
}