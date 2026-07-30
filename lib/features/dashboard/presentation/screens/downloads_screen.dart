import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/pdf_viewer_screen.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/constants/download_contant.dart';
import 'package:pakland/core/constants/image_url_helper.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/services/permission_service.dart';

class DocumentsScreen extends StatefulWidget {
  DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with TickerProviderStateMixin {
  final CompanyController _companyController = Get.find<CompanyController>();

  final Map<int, bool> _isDownloading = {};
  final Map<int, bool> _isDownloaded = {};
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

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

  Future<void> _downloadDocument(
      BuildContext context, String url, String fileName, int index) async {
    // Always request permission using system dialog
    final hasPermission = await DownloadUtils.requestPermission();

    if (!hasPermission) {
      // Show snackbar only if user denied the permission
      return;
    }

    setState(() {
      _isDownloading[index] = true;
      _isDownloaded[index] = false;
    });

    try {
      print('=== Starting Download Process ===');
      print('URL: $url');
      print('File name: $fileName');
      print('Index: $index');

      // Get the download path before downloading
      final directory = await DownloadUtils.getDownloadsDirectory();
      final sanitizedFileName = DownloadUtils.sanitizeFileName(fileName);
      final expectedPath = '${directory?.path}/$sanitizedFileName.pdf';

      // First check if file exists
      final fileExists = await DownloadUtils.checkFileExists(fileName);

      if (fileExists) {
        // If file exists, we'll download with a different name or overwrite
        // Let's add timestamp to make it unique
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${sanitizedFileName}_$timestamp.pdf';
        final result = await DownloadUtils.downloadFile(url, uniqueFileName);

        setState(() {
          _isDownloading[index] = false;
          _isDownloaded[index] = result;
        });

        if (result) {
          showTopSnackBar(
            context,
            "File downloaded successfully!\nFile already existed, saved as: $uniqueFileName",
            Colors.green.withOpacity(0.7),
            icon: Icons.check_circle,
            duration: const Duration(seconds: 5),
          );
        } else {
          showTopSnackBar(
            context,
            title: "Alert",
            "Download failed",
            Colors.red.withOpacity(0.7),
            icon: Icons.error,
          );
        }
      } else {
        // File doesn't exist, download normally
        final result = await DownloadUtils.downloadFile(url, fileName);

        setState(() {
          _isDownloading[index] = false;
          _isDownloaded[index] = result;
        });

        if (result) {
          showTopSnackBar(
            context,
            "File downloaded successfully!\nPath: $expectedPath",
            Colors.green.withOpacity(0.7),
            icon: Icons.check_circle,
            duration: const Duration(seconds: 5),
          );
        } else {
          showTopSnackBar(
            context,
            title: "Alert",
            "Download failed",
            Colors.red.withOpacity(0.7),
            icon: Icons.error,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isDownloading[index] = false;
      });
      print('Download error: $e');
      showTopSnackBar(
        context,
        title: "Alert",
        "Download failed: ${e.toString()}",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
    }
  }

  void _showDownloadDebugInfo(String fileName) async {
    final directory = await DownloadUtils.getDownloadsDirectory();
    final sanitizedFileName = DownloadUtils.sanitizeFileName(fileName);
    final expectedPath = '${directory?.path}/$sanitizedFileName.pdf';

    print('=== DEBUG INFO ===');
    print('Expected path: $expectedPath');
    print('Directory exists: ${await directory?.exists()}');
    print('Directory path: ${directory?.path}');

    // List files in directory
    if (directory != null && await directory.exists()) {
      final files = directory.listSync();
      print('Files in directory:');
      for (var file in files) {
        print(' - ${file.path}');
      }
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
          title: Text("Downloads",style: TextStyle(color: AppColors.whiteBg),),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (_companyController.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitWave(
                            color: AppColors.appColor,
                            size: 50,
                          ),
                          Text(
                            "Loading",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.appColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_companyController.mobileDocuments.isEmpty) {
                    return Center(
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
                      final path = document['path']?.toString() ?? '';
                      final fullUrl = ImageUrlHelper.resolve(path, ApiConstants.baseUrl);
                      final fileName =
                          document['file_name']?.toString() ?? 'Unnamed Document';
                      final fileType =
                          document['doc_type']?.toString() ?? 'PDF';

                      return _buildDocumentItem(
                        context,
                        fileName,
                        fullUrl,
                        index,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
      BuildContext context, String title, String url, int index) {
    final isDownloading = _isDownloading[index] ?? false;
    final isDownloaded = _isDownloaded[index] ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              Get.to(() => PDFViewerScreen(
                title: title,
                pdfUrl: url,
              ));
            },
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description, color: Colors.blue, size: 24),
            ),
            title: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            trailing: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return IconButton(
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
          Divider(
            thickness: 0.6,
            color: Colors.black45,
          ),
        ],
      ),
    );
  }
}