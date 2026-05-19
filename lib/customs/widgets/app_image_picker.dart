import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';



class AppImagePicker extends StatefulWidget {
  final bool multiple;
  final List<String>? initialPaths;
  final ValueChanged<List<String>> onChanged;
  final Color accentColor;
  const AppImagePicker({
    super.key,
    required this.onChanged,
    this.multiple = true,
    this.initialPaths,
    this.accentColor = const Color.fromRGBO(142, 62, 99, 1), // Use a constant value as default
  });

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  late List<String> _paths;

  @override
  void initState() {
    super.initState();
    _paths = List<String>.from(widget.initialPaths ?? const []);
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: widget.multiple,
    );
    if (result != null) {
      final picked =
      result.files
          .where((f) => (f.path ?? '').isNotEmpty)
          .map((f) => f.path!)
          .toList();
      setState(() {
        if (widget.multiple) {
          _paths.addAll(picked);
        } else {
          _paths = picked.isNotEmpty ? [picked.first] : _paths;
        }
      });
      widget.onChanged(List<String>.from(_paths));
    }
  }

  void _remove(String path) {
    setState(() => _paths.remove(path));
    widget.onChanged(List<String>.from(_paths));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: widget.accentColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: _pick,
            icon: Icon(Icons.add, color: widget.accentColor, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
          _paths.isEmpty
              ? Text(
            'No attachments',
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          )
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
            _paths.map((path) {
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildPreview(path),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _remove(path),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: widget.accentColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(String path) {
    if (kIsWeb) {
      return Container(
        width: 56,
        height: 56,
        color: AppColors.cardColor,
        child:  Icon(Icons.image, color: AppColors.textSecondaryColor),
      );
    }
    try {
      return Image.file(File(path), width: 56, height: 56, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        width: 56,
        height: 56,
        color: AppColors.cardColor,
        child:  Icon(
          Icons.image_not_supported,
          color: AppColors.textSecondaryColor,
        ),
      );
    }
  }
}
