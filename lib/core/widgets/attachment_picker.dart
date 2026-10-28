import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pakland/core/theme/colors.dart';


class WhatsAppAttachmentPicker extends StatefulWidget {
  final Function(List<File>) onChanged;
  final List<File>? initialFiles;
  final int maxTotalSizeInMB;
  final String? attamentLable;

  const WhatsAppAttachmentPicker({
    Key? key,
    required this.onChanged,
    this.initialFiles,
    this.maxTotalSizeInMB = 10,
    this.attamentLable,
  }) : super(key: key);

  @override
  State<WhatsAppAttachmentPicker> createState() =>
      _WhatsAppAttachmentPickerState();
}

class _WhatsAppAttachmentPickerState extends State<WhatsAppAttachmentPicker> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _files = widget.initialFiles ?? [];
  }

  int _totalSizeInBytes() {
    int total = 0;
    for (var file in _files) {
      total += file.lengthSync();
    }
    return total;
  }

  bool _canAddFiles(List<File> newFiles) {
    int newFilesSize = newFiles.fold(0, (sum, f) => sum + f.lengthSync());
    int maxBytes = widget.maxTotalSizeInMB * 1024 * 1024;
    return (_totalSizeInBytes() + newFilesSize) <= maxBytes;
  }

  void _addFiles(List<File> newFiles) {
    if (!_canAddFiles(newFiles)) {
      final maxMB = widget.maxTotalSizeInMB;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot add files. Total size must not exceed $maxMB MB.'),
        ),
      );
      return;
    }

    setState(() {
      _files.addAll(newFiles);
    });
    widget.onChanged(_files);
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
    widget.onChanged(_files);
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes >= 1024 * 1024) return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    if (bytes >= 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    return "$bytes B";
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Attach',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.blue),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                  children: [
                    _buildOptionItem(
                      icon: Icons.photo_library,
                      iconColor: Colors.purple,
                      title: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickMedia();
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.camera_alt,
                      iconColor: Colors.pink,
                      title: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.location_on,
                      iconColor: Colors.green,
                      title: 'Location',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.contact_page,
                      iconColor: Colors.orange,
                      title: 'Contact',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.insert_drive_file,
                      iconColor: Colors.blue,
                      title: 'Document',
                      onTap: () {
                        Navigator.pop(context);
                        _pickDocuments();
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.audiotrack,
                      iconColor: Colors.deepPurple,
                      title: 'Audio',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAudio();
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.poll,
                      iconColor: Colors.brown,
                      title: 'Poll',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildOptionItem(
                      icon: Icons.event,
                      iconColor: Colors.red,
                      title: 'Event',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp4', 'mov', 'mkv', '3gp', 'avi', 'flv', 'webm',

        'jpg', 'jpeg', 'png', 'gif', 'heic', 'webp'
      ],
    );

    if (result != null && result.files.isNotEmpty) {
      _addFiles(result.files.map((e) => File(e.path!)).toList());
    }
  }

  Future<void> _pickImages() async {
    final pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages != null) {
      _addFiles(pickedImages.map((e) => File(e.path)).toList());
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      _addFiles([File(pickedImage.path)]);
    }
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      _addFiles([File(pickedVideo.path)]);
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp3', 'm4a', 'wav', 'aac', 'opus', 'ogg', 'amr',
      ],
    );

    if (result != null && result.files.isNotEmpty) {
      _addFiles(result.files.map((e) => File(e.path!)).toList());
    }
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
      ],
    );
    if (result != null && result.files.isNotEmpty) {
      _addFiles(result.files.map((e) => File(e.path!)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalBytes = _totalSizeInBytes();
    String totalSizeStr = totalBytes >= 1024 * 1024
        ? "${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB"
        : totalBytes >= 1024
        ? "${(totalBytes / 1024).toStringAsFixed(2)} KB"
        : "$totalBytes B";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_files.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                final fileName = file.path.split('/').last;
                final fileSize = _getFileSize(file);

                return Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 8),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: _getFileThumbnail(file),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName.length > 10
                                ? '${fileName.substring(0, 10)}...'
                                : fileName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          Text(
                            fileSize,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: IconButton(
                          icon: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.cancel,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                          onPressed: () => _removeFile(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        GestureDetector(
          onTap: _showAttachmentOptions,
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.attach_file,
                  size: 20,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Attach',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Text(
              "Total: $totalSizeStr / ${widget.maxTotalSizeInMB} MB",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _getFileThumbnail(File file) {
    final path = file.path.toLowerCase();

    if (path.endsWith('.jpg') || path.endsWith('.png') || path.endsWith('.jpeg')) {
      return Image.file(file, fit: BoxFit.cover);
    } else if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      return Stack(
        children: [
          Container(color: Colors.black12),
          const Center(
            child: Icon(Icons.videocam, color: Colors.red, size: 24),
          ),
        ],
      );
    } else if (path.endsWith('.mp3') || path.endsWith('.wav')) {
      return const Center(
        child: Icon(Icons.audiotrack, color: Colors.purple, size: 24),
      );
    } else if (path.endsWith('.pdf')) {
      return const Center(
        child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
      );
    } else {
      return const Center(
        child: Icon(Icons.insert_drive_file, color: Colors.blue, size: 24),
      );
    }
  }
}
