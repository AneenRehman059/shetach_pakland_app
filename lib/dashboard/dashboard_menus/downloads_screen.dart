import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/pdf_viewer_screen.dart';
import 'package:pakland/constants/api_constant.dart';
import 'package:pakland/controllers/get_company_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants/download_contant.dart';
import '../../customs/custom_messages.dart';
import '../../customs/toast_message.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with TickerProviderStateMixin {
  final CompanyController _companyController = Get.find<CompanyController>();

  final Map<int, bool> _isDownloading = {};
  final Map<int, bool> _isDownloaded  = {};

  late AnimationController _colorController;
  late Animation<Color?>   _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnimation =
        ColorTween(begin: Colors.blue, end: Colors.green).animate(_colorController);
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  // ── Main download handler ──────────────────────────────────────────
  Future<void> _downloadDocument(
      BuildContext context, String url, String fileName, int index) async {

    // ── 1. Permission check ────────────────────────────────────────
    PermissionStatus status;

    if (await Permission.photos.isGranted) {
      status = PermissionStatus.granted;
    } else {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }

    if (!status.isGranted) {
      if (mounted) {
        final isPermanentlyDenied =
            status.isPermanentlyDenied ||
                await Permission.photos.isPermanentlyDenied ||
                await Permission.storage.isPermanentlyDenied;

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

    // ── 2. Storage space check ─────────────────────────────────────
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

    setState(() {
      _isDownloading[index] = true;
      _isDownloaded[index]  = false;
    });

    try {
      // ── 3. Duplicate file check ──────────────────────────────────
      final directory          = await DownloadUtils.getDownloadsDirectory();
      final fileExists         = await DownloadUtils.checkFileExists(fileName);
      final timestamp          = DateTime.now().millisecondsSinceEpoch;
      final downloadedFileName = fileExists ? '${fileName}_$timestamp' : fileName;

      // ── 4. Download ──────────────────────────────────────────────
      final result = await DownloadUtils.downloadFile(url, downloadedFileName);

      setState(() {
        _isDownloading[index] = false;
        _isDownloaded[index]  = result;
      });

      if (!mounted) return;

      if (result) {
        final sanitized = DownloadUtils.sanitizeFileName(downloadedFileName);
        final finalPath = '${directory?.path}/$sanitized.pdf';
        final message   = fileExists
            ? '${DownloadMessages.duplicateFileMessage} $downloadedFileName\n'
            '${DownloadMessages.savedPathLabel} $finalPath'
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
      setState(() => _isDownloading[index] = false);
      if (mounted) {
        showTopSnackBar(
          context,
          DownloadMessages.downloadFailedMessage,
          Colors.red.shade800,
          title: DownloadMessages.downloadFailedTitle,
          icon: Icons.error,
        );
      }
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
      return await _probeStorageWrite((await getTemporaryDirectory()).path);
    }
  }

  Future<bool> _probeStorageWrite(String dirPath) async {
    final probe = File(
        '$dirPath/probe_${DateTime.now().millisecondsSinceEpoch}.tmp');
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
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(MainWrapper());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Downloads", style: TextStyle(color: AppColors.whiteBg)),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Obx(() {
            if (_companyController.isLoading.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitWave(color: AppColors.appColor, size: 50),
                    const SizedBox(height: 8),
                    Text(
                      DownloadMessages.loadingLabel,
                      style: TextStyle(fontSize: 14, color: AppColors.appColor),
                    ),
                  ],
                ),
              );
            }

            if (_companyController.mobileDocuments.isEmpty) {
              return const Center(
                child: Text(
                  'No downloads available',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }

            return ListView.builder(
              itemCount: _companyController.mobileDocuments.length,
              itemBuilder: (context, index) {
                final document = _companyController.mobileDocuments[index];
                final path     = document['path']?.toString() ?? '';
                final fullUrl  = '${ApiConstants.baseUrl}$path';
                final fileName =
                    document['file']?.toString() ?? 'Unnamed Document';

                return _buildDocumentItem(context, fileName, fullUrl, index);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
      BuildContext context, String title, String url, int index) {
    final isDownloading = _isDownloading[index] ?? false;
    final isDownloaded  = _isDownloaded[index]  ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            onTap: () => Get.to(() => PDFViewerScreen(title: title, pdfUrl: url)),
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description, color: Colors.blue, size: 24),
            ),
            title: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            trailing: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return IconButton(
                  tooltip: DownloadMessages.downloadTooltip,
                  icon: Icon(
                    isDownloaded ? Icons.check_circle : Icons.download,
                    color: isDownloading
                        ? _colorAnimation.value
                        : (isDownloaded ? Colors.green : Colors.blue),
                    size: 26,
                  ),
                  onPressed: isDownloading
                      ? null
                      : () => _downloadDocument(context, url, title, index),
                );
              },
            ),
          ),
          const Divider(thickness: 0.6, color: Colors.black45),
        ],
      ),
    );
  }
}