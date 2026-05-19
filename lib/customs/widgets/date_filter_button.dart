import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';

class DateFilterButton extends StatelessWidget {
  final Rxn<DateTime> selectedDate;
  final String labelPrefix;
  final VoidCallback onDateChanged;

  const DateFilterButton({
    super.key,
    required this.selectedDate,
    required this.labelPrefix,
    required this.onDateChanged,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
      height: 35, // ✅ Match height with search bar
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Compact
        ),
        iconAlignment: IconAlignment.start,
        icon: Icon(Icons.calendar_today,
            color: AppColors.primaryColor, size: 18),
        label: Text(

          selectedDate.value != null
              ? '$labelPrefix: ${_formatDate(selectedDate.value!)}'
              : '$labelPrefix Date',
          style: TextStyle(fontSize: 13, color: Colors.black87,fontWeight: FontWeight.w500),
        ),
        onPressed: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate.value ?? now,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 5),
          );
          if (picked != null) {
            selectedDate.value = picked;
            onDateChanged();
          }
        },
      ),
    ));
  }
}
