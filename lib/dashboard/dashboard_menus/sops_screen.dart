import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/pdf_viewer_screen.dart';
import 'package:pakland/constants/api_constant.dart';
import 'package:pakland/controllers/get_company_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../constants/download_contant.dart';
import '../../constants/image_url_helper.dart';
import '../../controllers/theme_controller.dart';
import '../../customs/toast_message.dart';
import '../../function/screen_helper.dart';
import '../../permission_service.dart';
import '../../status_bar_wrapper.dart';

class SOPsScreen extends StatefulWidget {
  const SOPsScreen({super.key});
  @override
  State<SOPsScreen> createState() => _SOPsScreenState();
}

class _SOPsScreenState extends State<SOPsScreen> with TickerProviderStateMixin {
  final CompanyController _companyController = Get.find<CompanyController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final Map<int, bool> _isDownloading = {};
  final Map<int, bool> _isDownloaded = {};
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _themeController.updateStatusBar();
    _colorController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _colorAnimation = ColorTween(begin: Colors.red, end: Colors.green).animate(_colorController);
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _downloadSOP(BuildContext context, String url, String fileName, int index) async {
    final hasPermission = await DownloadUtils.requestPermission();
    if (!hasPermission) {
      if (await Permission.storage.isDenied || await Permission.manageExternalStorage.isDenied) {
        showTopSnackBar(context, "Permission denied. Please allow storage access in app settings.", Colors.red.withOpacity(0.7), icon: Icons.error);
      }
      return;
    }
    setState(() { _isDownloading[index] = true; _isDownloaded[index] = false; });
    try {
      final fileExists = await DownloadUtils.checkFileExists(fileName);
      String downloadedFileName = fileExists ? '${fileName}_${DateTime.now().millisecondsSinceEpoch}' : fileName;
      final result = await DownloadUtils.downloadFile(url, downloadedFileName);
      setState(() { _isDownloading[index] = false; _isDownloaded[index] = result; });
      if (result) {
        showTopSnackBar(context, "File downloaded successfully!", Colors.green.withOpacity(0.7), icon: Icons.check_circle, duration: const Duration(seconds: 5));
      } else {
        showTopSnackBar(context, title: "Alert", "Download failed", Colors.red.withOpacity(0.7), icon: Icons.error);
      }
    } catch (e) {
      setState(() => _isDownloading[index] = false);
      showTopSnackBar(context, title: "Alert", "Download failed: ${e.toString()}", Colors.red.withOpacity(0.7), icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    return StatusBarWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text("SOPs", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
          centerTitle: true, backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: isTV ? 70 : kToolbarHeight,
        ),
        body: SafeArea(
          child: Obx(() {
            if (_companyController.isLoading.value) {
              return Center(child: SpinKitFadingCircle(color: AppColors.appColor, size: 50.0));
            }
            if (_companyController.mobileSOPs.isEmpty) {
              return Center(child: Text('No SOPs available', style: TextStyle(color: Colors.black)));
            }

            // TV pe GridView, mobile pe ListView
            if (isTV) {
              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.0,
                ),
                itemCount: _companyController.mobileSOPs.length,
                itemBuilder: (context, index) {
                  final sop = _companyController.mobileSOPs[index];
                  final path = sop['image_path']?.toString() ?? '';
                  final fullUrl = ImageUrlHelper.resolve(path, ApiConstants.baseUrl);
                  final sopName = sop['SOPs_name']?.toString() ?? 'Unnamed SOP';
                  final fileType = fullUrl.toLowerCase().endsWith('.pdf') ? 'PDF' : 'DOC';
                  return _TVSOPItem(context, sopName, fileType, fullUrl, index);
                },
              );
            }

            return ListView.builder(
              itemCount: _companyController.mobileSOPs.length,
              itemBuilder: (context, index) {
                final sop = _companyController.mobileSOPs[index];
                final path = sop['image_path']?.toString() ?? '';
                final fullUrl = ImageUrlHelper.resolve(path, ApiConstants.baseUrl);
                final sopName = sop['SOPs_name']?.toString() ?? 'Unnamed SOP';
                final fileType = fullUrl.toLowerCase().endsWith('.pdf') ? 'PDF' : 'DOC';
                return Padding(padding: const EdgeInsets.all(8.0), child: _buildSOPItem(context, sopName, fileType, fullUrl, index));
              },
            );
          }),
        ),
      ),
    );
  }

  // TV SOP item — card style with focus
  Widget _TVSOPItem(BuildContext context, String title, String type, String url, int index) {
    final isDownloading = _isDownloading[index] ?? false;
    final isDownloaded = _isDownloaded[index] ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => PDFViewerScreen(title: title, pdfUrl: url)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.description, color: type == "PDF" ? Colors.blue : Colors.green, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) => IconButton(
                icon: Icon(isDownloaded ? Icons.check_circle : Icons.download,
                    color: isDownloading ? _colorAnimation.value : (isDownloaded ? Colors.green : Colors.blue), size: 24),
                onPressed: isDownloading ? null : () => _downloadSOP(context, url, title, index),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Mobile — same as before
  Widget _buildSOPItem(BuildContext context, String title, String type, String url, int index) {
    final isDownloading = _isDownloading[index] ?? false;
    final isDownloaded = _isDownloaded[index] ?? false;

    return Column(children: [
      ListTile(
        onTap: () => Get.to(() => PDFViewerScreen(title: title, pdfUrl: url)),
        leading: Container(width: 45, height: 45,
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(Icons.description, color: type == "PDF" ? Colors.blue : Colors.green, size: 24)),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) => IconButton(
            icon: Icon(isDownloaded ? Icons.check_circle : Icons.download,
                color: isDownloading ? _colorAnimation.value : (isDownloaded ? Colors.green : Colors.blue), size: 26),
            onPressed: isDownloading ? null : () => _downloadSOP(context, url, title, index),
          ),
        ),
      ),
      const Divider(thickness: 0.6, color: Colors.black45),
    ]);
  }
}