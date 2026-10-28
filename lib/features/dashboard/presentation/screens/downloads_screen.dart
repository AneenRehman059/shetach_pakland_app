import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/pdf_viewer_screen.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pakland/core/constants/download_constant.dart';
import 'package:pakland/core/widgets/custom_messages.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/core/widgets/document_list_widgets.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final CompanyController _companyController = Get.find<CompanyController>();

  final Map<int, bool> _isDownloading = {};
  final Map<int, bool> _isDownloaded  = {};

  Future<void> _downloadDocument(
      BuildContext context, String url, String fileName, int index) async {

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
      final directory          = await DownloadUtils.getDownloadsDirectory();
      final fileExists         = await DownloadUtils.checkFileExists(fileName);
      final timestamp          = DateTime.now().millisecondsSinceEpoch;
      final downloadedFileName = fileExists ? '${fileName}_$timestamp' : fileName;

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
        backgroundColor: kDocPageBg,
        appBar: AppHeaderBar(
          title: const Text("Downloads"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Obx(() {
            if (_companyController.isLoading.value) {
              return DocLoadingState(label: DownloadMessages.loadingLabel);
            }

            final docs = _companyController.mobileDocuments;

            if (docs.isEmpty) {
              return const DocEmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No downloads available',
                message: 'Documents shared by the company will appear here.',
              );
            }

            return Column(
              children: [
                DocListHeader(
                  count: docs.length,
                  singular: 'Document',
                  plural: 'Documents',
                ),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final document = docs[index];
                      final path     = document['path']?.toString() ?? '';
                      final fullUrl  = '${ApiConstants.baseUrl}$path';
                      final fileName =
                          document['file']?.toString() ?? 'Unnamed Document';

                      return _buildDocumentItem(context, fileName, fullUrl, index);
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
      BuildContext context, String title, String url, int index) {
    return DocumentListTile(
      title: title,
      type: DocFileType.fromUrl(url),
      isDownloading: _isDownloading[index] ?? false,
      isDownloaded: _isDownloaded[index] ?? false,
      downloadTooltip: DownloadMessages.downloadTooltip,
      onOpen: () => Get.to(() => PDFViewerScreen(title: title, pdfUrl: url)),
      onDownload: () => _downloadDocument(context, url, title, index),
    );
  }
}
