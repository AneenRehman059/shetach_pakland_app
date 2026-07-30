import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';

class MessageTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly; // Added readOnly parameter
  final double? borderRadius;

  const MessageTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.labelStyle,
    this.controller,
    this.onChanged,
    this.validator,
    this.readOnly = false, // Default to false for backward compatibility
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle ?? const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[100] : AppColors.bgColor, // Different background when read-only
            borderRadius:  BorderRadius.circular(
    borderRadius ?? 8,
    ),
            border: Border.all(
              color: readOnly ? Colors.grey : AppColors.appColor, // Different border color when read-only
            ),
          ),
          child: Stack(
            children: [
              TextFormField(
                controller: controller,
                onChanged: onChanged,
                validator: validator,
                maxLines: null,
                expands: true,
                maxLength: 500,
                readOnly: readOnly, // Added readOnly property
                enabled: !readOnly, // Disable when read-only
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: readOnly ? Colors.grey : Colors.black38, // Different hint color when read-only
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(
                      borderRadius ?? 8,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(
                      borderRadius ?? 8,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(
                      borderRadius ?? 8,
                    ),
                  ),
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(
                      borderRadius ?? 8,
                    ),
                  ), // Added for read-only state
                  counterText: "", // Hide the default counter
                  filled: readOnly, // Fill background when read-only
                  fillColor: readOnly ? Colors.grey[100] : null, // Fill color when read-only
                ),
                style: TextStyle(
                  color: readOnly ? Colors.grey[700] : Colors.black, // Different text color when read-only
                ),
              ),
              Positioned(
                bottom: 8,
                right: 12,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller ?? TextEditingController(),
                  builder: (context, value, child) {
                    return Text(
                      '${value.text.length}/500',
                      style: TextStyle(
                        fontSize: 12,
                        color: value.text.length > 500
                            ? Colors.red
                            : (readOnly ? Colors.grey : Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}