// chat_file_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ChatFilePicker {
  static const int maxTotalSizeInBytes = 3 * 1024 * 1024; // 3 MB limit

  /// ======== PICK FROM GALLERY =========
  static Future<List<File>> pickImages(BuildContext context) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images == null) return [];
    final files = images.map((e) => File(e.path)).toList();

    if (!_validateSize(context, files)) return [];

    return files;
  }

  /// ======== CAMERA PICK =========
  static Future<List<File>> pickCamera(BuildContext context) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);

    if (img == null) return [];

    final file = File(img.path);

    if (!_validateSize(context, [file])) return [];

    return [file];
  }

  /// ======== DOCUMENT PICK =========
  static Future<List<File>> pickDocuments(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ["pdf", "doc", "docx", "txt", "xls", "xlsx"],
      type: FileType.custom,
    );

    if (result == null) return [];

    final files = result.paths.map((p) => File(p!)).toList();

    if (!_validateSize(context, files)) return [];

    return files;
  }

  /// ======== AUDIO PICK =========
  static Future<List<File>> pickAudio(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.audio,
    );

    if (result == null) return [];

    final files = result.paths.map((p) => File(p!)).toList();

    if (!_validateSize(context, files)) return [];

    return files;
  }

  /// ======== VIDEO PICK =========
  static Future<List<File>> pickVideo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result == null) return [];

    final files = result.paths.map((p) => File(p!)).toList();

    if (!_validateSize(context, files)) return [];

    return files;
  }

  /// ======== VALIDATE TOTAL SIZE =========
  static bool _validateSize(BuildContext context, List<File> files) {
    int total = files.fold(0, (sum, f) => sum + f.lengthSync());

    if (total > maxTotalSizeInBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Total file size cannot exceed 3 MB")),
      );
      return false;
    }
    return true;
  }

  /// ======== ATTACHMENT SHEET UI (WhatsApp Style B1) =========
  static void openPickerSheet({
    required BuildContext context,
    required Function(List<File>) onFilesSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.35, // Fixed height
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Grid with fixed height
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2, // Fixed height for grid
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _option(
                    icon: Icons.photo,
                    label: "Gallery",
                    color: Colors.purple,
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await pickImages(context);
                      if (files.isNotEmpty) onFilesSelected(files);
                    },
                  ),
                  _option(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    color: Colors.pink,
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await pickCamera(context);
                      if (files.isNotEmpty) onFilesSelected(files);
                    },
                  ),
                  _option(
                    icon: Icons.insert_drive_file,
                    label: "Document",
                    color: Colors.blue,
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await pickDocuments(context);
                      if (files.isNotEmpty) onFilesSelected(files);
                    },
                  ),
                  _option(
                    icon: Icons.audiotrack,
                    label: "Audio",
                    color: Colors.orange,
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await pickAudio(context);
                      if (files.isNotEmpty) onFilesSelected(files);
                    },
                  ),
                  _option(
                    icon: Icons.videocam,
                    label: "Video",
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      final files = await pickVideo(context);
                      if (files.isNotEmpty) onFilesSelected(files);
                    },
                  ),
                ],
              ),
            ),

            // Spacer to push content up

            // Cancel button (WhatsApp style)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.grey[100],
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _option({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}