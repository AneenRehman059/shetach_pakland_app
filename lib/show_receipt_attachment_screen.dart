import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
    // 1. Request permission
    PermissionStatus status;

    if (await Permission.photos.isGranted) {
      status = PermissionStatus.granted;
    } else {
      status = await Permission.photos.request();
      // Fallback for older Android
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }

    if (!status.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Storage permission is required to save images.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        icon: const Icon(Icons.lock, color: Colors.white),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // 2. Download to temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'receipt_${widget.receiptNo}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

      // 3. Save to gallery
      final result = await GallerySaver.saveImage(savePath, albumName: 'Receipts');

      if (result == true) {
        Get.snackbar(
          'Saved!',
          'Receipt #${widget.receiptNo} saved to gallery.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade800,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        throw Exception('Gallery save returned false');
      }
    } catch (e) {
      Get.snackbar(
        'Download Failed',
        'Could not save the image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.appColor,
        title: Text(
          // 'Receipt #${widget.receiptNo}',
          'Receipt Attachment',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isDownloading
                ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
                if (_downloadProgress > 0)
                  Text(
                    '${(_downloadProgress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                  ),
              ],
            )
                : IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: 'Save to Gallery',
              onPressed: _downloadImage,
            ),
          ),
        ],
      ),
      body: InteractiveViewer(
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
                  const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load receipt image',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.imageUrl,
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}