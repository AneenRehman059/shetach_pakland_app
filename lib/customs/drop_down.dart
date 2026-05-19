import 'package:flutter/material.dart';
import 'package:pakland/colors.dart';

import 'package:flutter/material.dart';
import 'package:pakland/colors.dart';

import 'package:flutter/material.dart';
import 'package:pakland/colors.dart';

class ProjectDropdownDialog extends StatefulWidget {
  final List<String> projects;
  final ValueChanged<String> onProjectSelected;

  const ProjectDropdownDialog({
    super.key,
    required this.projects,
    required this.onProjectSelected,
  });

  @override
  State<ProjectDropdownDialog> createState() => _ProjectDropdownDialogState();
}

class _ProjectDropdownDialogState extends State<ProjectDropdownDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Select the Project',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onProjectSelected(project);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              project,
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (index != widget.projects.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownButton extends StatefulWidget {
  final String placeholder;
  final String imagePath;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const CustomDropdownButton({
    super.key,

    required this.placeholder,
    required this.imagePath,
    required this.items,
    this.onChanged,
  });

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  String? selectedValue;

  void _showProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ProjectDropdownDialog(
            projects: widget.items,
            onProjectSelected: (project) {
              setState(() => selectedValue = project);
              widget.onChanged?.call(project);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProjectDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.appColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedValue ?? widget.placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteBg,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_outlined, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
