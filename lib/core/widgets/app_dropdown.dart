import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:pakland/core/theme/colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final Widget? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isExpanded;
  final bool enabled;

  final double buttonHeight;
  final EdgeInsetsGeometry buttonPadding;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final double iconSize;
  final Color iconColor;
  final double dropdownMaxHeight;
  final double? dropdownWidth;
  final EdgeInsets? menuItemPadding;

  const AppDropdown({
    super.key,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = true,
    this.enabled = true,
    this.buttonHeight = 35,
    this.buttonPadding = const EdgeInsets.only(left: 14, right: 14),
    this.borderRadius = 10,
    this.borderColor = const Color(0xFF8E3E63),
    this.backgroundColor = Colors.white,
    this.iconSize = 30,
    this.iconColor = Colors.black45,
    this.dropdownMaxHeight = 200,
    this.dropdownWidth,
    this.menuItemPadding = const EdgeInsets.only(left: 14, right: 14),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor == const Color(0xFF8E3E63)
        ? AppColors.appColor
        : borderColor;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        style: TextStyle(fontSize: 14, color: Colors.black87,fontWeight: FontWeight.w500),
        isExpanded: isExpanded,
        hint: hint,
        items: items,
        value: value,
        onChanged: enabled ? onChanged : null,
        buttonStyleData: ButtonStyleData(
          height: buttonHeight,
          width: double.infinity,
          padding: buttonPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: effectiveBorderColor),
            color: backgroundColor,
          ),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.arrow_drop_down, color: iconColor),
          iconSize: iconSize,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: dropdownMaxHeight,
          width: dropdownWidth ?? MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          offset: const Offset(0, -5),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all<double>(6),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(

          height: 35,
          padding: menuItemPadding,
        ),
      ),
    );
  }
}


