import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pakland/core/widgets/custom_messages.dart';
import 'package:pakland/core/widgets/toast_message.dart';

class ReceiptImageScreen extends StatefulWidget {
  final String imageUrl;
  final String receiptNo;

  const ReceiptImageScreen({
    super.key,
    required this.imageUrl,
    required this.receiptNo,
  });

  @override
  State<ReceiptImageScreen> createState() => _ReceiptImageScreenState();
}

class _ReceiptImageScreenState extends State<ReceiptImageScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _downloadImage() async {
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
        showTopSnackBar(
          context,
          DownloadMessages.permissionDeniedMessage,
          Colors.red.shade800,
          title: DownloadMessages.permissionDeniedTitle,
          icon: Icons.lock,
        );
      }
      return;
    }

    // ── Check available storage before downloading ──────────────────
    try {
      final bool hasSpace = await _hasEnoughStorage();
      if (!hasSpace) {
        if (mounted) {
          showTopSnackBar(
            context,
            DownloadMessages.insufficientStorageMessage,
            Colors.red.shade800,
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
          Colors.red.shade800,
          title: DownloadMessages.insufficientStorageTitle,
          icon: Icons.storage_rounded,
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'receipt_${widget.receiptNo}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = '${tempDir.path}/$fileName';

      await Dio().download(
        widget.imageUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      final result =
      await GallerySaver.saveImage(savePath, albumName: 'Receipts');

      if (result == true) {
        if (mounted) {
          showTopSnackBar(
            context,
            DownloadMessages.downloadSuccessMessage,
            Colors.green.shade800,
            title: DownloadMessages.downloadSuccessTitle,
            icon: Icons.check_circle,
          );
        }
      } else {
        throw Exception('Gallery save returned false');
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(
          context,
          DownloadMessages.downloadFailedMessage,
          Colors.red.shade800,
          title: DownloadMessages.downloadFailedTitle,
          icon: Icons.warning,
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
  }

  /// Returns true if device has at least [minRequiredMB] MB free.
  Future<bool> _hasEnoughStorage({int minRequiredMB = 50}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final stat = await FileStat.stat(tempDir.path);

      // FileStat doesn't give free space — use df via dart:io
      final result = await Process.run('df', [tempDir.path]);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().trim().split('\n');
        if (lines.length >= 2) {
          final parts = lines[1].trim().split(RegExp(r'\s+'));
          if (parts.length >= 4) {
            final availableKB = int.tryParse(parts[3]) ?? 0;
            final availableMB = availableKB / 1024;
            return availableMB >= minRequiredMB;
          }
        }
      }

      // Fallback: try writing a small probe file
      return await _probeStorageWrite(tempDir.path);
    } catch (_) {
      return await _probeStorageWrite(
          (await getTemporaryDirectory()).path);
    }
  }

  /// Fallback — tries writing a tiny file to confirm write access.
  Future<bool> _probeStorageWrite(String dirPath) async {
    final probeFile = File('$dirPath/storage_probe_${DateTime.now().millisecondsSinceEpoch}.tmp');
    try {
      await probeFile.writeAsBytes(List.filled(1024, 0)); // 1 KB probe
      await probeFile.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.appColor,
        title: const Text(
          'Receipt Attachment',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: 'Save to Gallery',
              onPressed: _isDownloading ? null : _downloadImage,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Receipt image ────────────────────────────────────────────
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.appColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image,
                          color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load receipt image',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.imageUrl,
                        style: const TextStyle(
                            color: Colors.white30, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Centered download progress overlay ───────────────────────
          if (_isDownloading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: _downloadProgress > 0
                                  ? _downloadProgress
                                  : null,
                              color: AppColors.appColor,
                              strokeWidth: 5,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                          if (_downloadProgress > 0)
                            Text(
                              '${(_downloadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Downloading…',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _downloadProgress > 0
                              ? _downloadProgress
                              : null,
                          backgroundColor: Colors.white12,
                          color: AppColors.appColor,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}