import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/download_constant.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/widgets/custom_messages.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

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
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      _currentPage = 0;
      _totalPages = 0;
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

    final hasPermission = await DownloadUtils.requestPermission();
    if (!hasPermission) {
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
      final directory   = await DownloadUtils.getDownloadsDirectory();
      final fileExists  = await DownloadUtils.checkFileExists(widget.title);
      final timestamp   = DateTime.now().millisecondsSinceEpoch;

      final downloadedFileName = fileExists
          ? '${widget.title}_$timestamp'
          : widget.title;

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
      backgroundColor: const Color(0xFFE9EEF3),
      appBar: AppHeaderBar(
        title: Text(widget.title),
        subtitle: _totalPages > 0
            ? 'Page ${_currentPage + 1} of $_totalPages'
            : 'PDF Document',
        centerTitle: true,
        actions: [_buildDownloadAction()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildDownloadAction() {
    if (_isDownloading) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: AppLoader(),
          ),
        ),
      );
    }

    return AppHeaderAction(
      icon: Icons.download_rounded,
      tooltip: DownloadMessages.downloadTooltip,
      onPressed: _downloadPdf,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoader(size: 88),
              const SizedBox(height: 12),
              Text(
                DownloadMessages.loadingLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.appColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (localFilePath != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: PDFView(
              filePath: localFilePath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onRender: (pages) {
                if (mounted) setState(() => _totalPages = pages ?? 0);
              },
              onPageChanged: (page, total) {
                if (mounted) {
                  setState(() {
                    _currentPage = page ?? 0;
                    _totalPages = total ?? _totalPages;
                  });
                }
              },
              onError: (error) {},
            ),
          ),
          if (_totalPages > 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFD64545).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFD64545), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                DownloadMessages.pdfLoadFailedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B3A42),
                ),
              ),
              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF1F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${DownloadMessages.errorLabel} $errorMessage',
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFFB03A3A),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 20),
                  label: Text(
                    DownloadMessages.retryLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: loadPdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
