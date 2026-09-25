import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_dropdown.dart';


class AppDialogs {
  AppDialogs._();

  static double dropdownWidth= 0.7;
  static Widget header({required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Use a back button that matches the platform's style
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: AppColors.textPrimaryColor), // Changed to 'close' for dialogs
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the title
        ],
      ),
    );
  }

  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header(title: title),
            Padding(padding: const EdgeInsets.all(16), child: Text(message)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    child: Text(confirmText, style: TextStyle(color: AppColors.textPrimaryColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> select({
    required String title,
    required List<String> options,
    String cancelText = 'Cancel',
  }) {
    return Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header(title: title),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final value = options[index];
                  return ListTile(
                    title: Text(value),
                    onTap: () => Get.back(result: value),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(cancelText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> input({
    required String title,
    required String hint,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController();
    return Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header(title: title),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(result: controller.text.trim()),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    child: Text(confirmText, style: TextStyle(color: AppColors.textPrimaryColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void fullScreenImage(String assetPath) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      useSafeArea: false,
    );
  }

// ===== OPTIMIZED STATUS & PRIORITY DIALOG =====
  static Future<Map<String, String>?> pickStatusAndPriority({
    String initialStatus = 'Open',
    String initialPriority = 'Medium',
    bool isAdmin = false,
    required String userType,
  }) async {
    final statuses = userType == 'Admin'
        ? ['Done', 'Closed']
        : userType == 'Customer'
        ? ['Done']
        : ['Open', 'In Progress', 'Done', 'Closed'];

    const priorities = ['Low', 'Medium', 'High', 'Critical'];
    const priorityMapping = {
      'Low': 'Low',
      'Medium': 'Medium',
      'High': 'High',
      'Critical': 'Critical'
    };

    String? selectedStatus = null;
    String? selectedPriority = null;

    final TextEditingController commentController = TextEditingController();

    return Get.dialog<Map<String, String>>(
      barrierDismissible: true,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              // Determine if Save button should be enabled
              final bool isSaveEnabled = userType == "Admin"
                  ? (selectedStatus != null && selectedPriority != null)
                  : selectedStatus != null;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  header(title: 'Update Status & Priority'),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppDropdown<String>(
                              dropdownWidth: MediaQuery.of(context).size.width * dropdownWidth,
                              hint: const Text(
                                'Select Status',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              value: selectedStatus,
                              items: statuses
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                  alignment: Alignment.topLeft,
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                                  .toList(),
                              onChanged: (v) => setState(() => selectedStatus = v),
                            ),
                            if (selectedStatus == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Status selection is required',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Priority Dropdown - Only for Admin
                        userType == "Admin"
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppDropdown<String>(
                              dropdownWidth: MediaQuery.of(context).size.width * dropdownWidth,
                              hint: const Text(
                                'Select Priority',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              value: selectedPriority,
                              items: priorities
                                  .map(
                                    (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                                  .toList(),
                              onChanged: (v) => setState(() => selectedPriority = v),
                            ),
                            if (selectedPriority == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Priority selection is required',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        )
                            : const SizedBox(height: 0),

                        // Closing Remarks Field
                        if (selectedStatus == 'Closed') ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: commentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add closing remarks...',
                              labelText: 'Remarks (Required)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Dialog Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSaveEnabled
                              ? () {
                            if (selectedStatus == 'Closed' &&
                                commentController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Validation Error',
                                'Closing remarks are required.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            Navigator.of(context).pop({
                              'status': selectedStatus!,
                              'priority': userType == "Admin"
                                  ? (priorityMapping[selectedPriority!] ?? 'Medium')
                                  : priorityMapping[initialPriority] ?? 'Medium',
                              if (selectedStatus == 'Closed')
                                'remarks': commentController.text.trim(),
                            });
                          }
                              : null, // Disable button when not enabled
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaveEnabled
                                ? AppColors.primaryColor
                                : Colors.grey[400],
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: Text('Save',
                              style: TextStyle(
                                color: isSaveEnabled
                                    ? AppColors.textPrimaryColor
                                    : Colors.grey[600],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  // ===== ASSIGNMENT DIALOG (Uses int for User ID) =====
  static Future<Map<String, dynamic>?> showAssignmentDialog({
    required List<Map<String, dynamic>> departmentUsers,
    required bool isLoadingUsers,
  }) {
    String? selectedUserId; // Use int? for the user ID
    DateTime? dueDate;
    String? remarks;

    return Get.dialog<Map<String, dynamic>>(
      barrierDismissible: true,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //header(title: 'Assign Ticket'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Assign To',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondaryColor)),
                        const SizedBox(height: 8),
                        if (isLoadingUsers)
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.appColor)),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else
                          AppDropdown<String>( // Use AppDropdown<int>
                            dropdownWidth: MediaQuery.of(context).size.width * 0.8,
                            hint: const Text('Select User', style: TextStyle(fontSize: 14, color: Colors.black54)),
                            value: selectedUserId,
                            items: departmentUsers.map((user) {
                              final userId = user['User_id']?.toString() ?? user['user_id']?.toString();

                              final userName = user['user_name']?.toString() ?? 'Unknown';
                              final userType = user['user_type']?.toString() ?? '';

                              if (userId == null) return null; // Skip if user ID is invalid

                              return DropdownMenuItem<String>(
                                value: userId,
                                child: Text(userName, style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).whereType<DropdownMenuItem<String>>().toList(), // Filter out nulls
                            onChanged: (val) => setState(() => selectedUserId = val),
                          ),
                        if (departmentUsers.isEmpty && !isLoadingUsers)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('No users available in this department.', style: TextStyle(color: Colors.grey)),
                          ),
                        const SizedBox(height: 16),
                        _buildOptionalFields(
                          onDueDateChanged: (val) => setState(() => dueDate = val),
                          onRemarksChanged: (val) => remarks = val,
                          initialDueDate: dueDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedUserId == null) {
                              Get.snackbar(
                                'Validation Error',
                                'Please select a user to assign the ticket.',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                            Navigator.of(context).pop({
                              'userId': selectedUserId,
                              'dueDate': dueDate,
                              'remarks': remarks ?? '',
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: Text('Save', style: TextStyle(color: AppColors.textPrimaryColor)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===== Helper Widgets for Dialogs =====

  // static Widget _buildDropdown({
  //   required String hintText,
  //   required String label,
  //   String? value,
  //   required List<String> items,
  //   required void Function(String?) onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //           color: AppColors.textSecondaryColor,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       AppDropdown<String>(
  //         hint: Text(
  //           hintText,
  //           style: const TextStyle(fontSize: 14, color: Colors.black54),
  //         ),
  //         value: value, // ✅ null allowed
  //         items: items
  //             .map(
  //               (e) => DropdownMenuItem<String>(
  //             value: e,
  //             child: Text(e),
  //           ),
  //         )
  //             .toList(),
  //         onChanged: onChanged,
  //       ),
  //     ],
  //   );
  // }



  static Widget _buildCommentField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Add closing remarks...',
        labelText: 'Remarks (Required)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static Widget _buildOptionalFields({
    required ValueChanged<DateTime?> onDueDateChanged,
    required ValueChanged<String?> onRemarksChanged,
    DateTime? initialDueDate, // Allow passing an initial due date
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Due Date Picker
        Text('Optional Fields', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondaryColor)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Due Date'),
          subtitle: Text(initialDueDate != null
              ? DateFormat('dd-MMM-yyyy').format(initialDueDate)
              : 'Not set'),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: Get.context!,
              initialDate: initialDueDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) onDueDateChanged(pickedDate);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: AppColors.dividerColor)),
        ),
        const SizedBox(height: 16),
        // Remarks Field
        TextField(
          maxLines: 2,
          onChanged: onRemarksChanged,
          decoration: InputDecoration(
            hintText: 'Add any remarks (optional)...',
            labelText: 'Remarks',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  static Widget _buildDialogActions({
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Text('Save', style: TextStyle(color: AppColors.textPrimaryColor)),
          ),
        ],
      ),
    );
  }
}
