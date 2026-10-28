import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color borderColor;
  final double borderRadius;
  final Color fillColor;
  final bool showCounter;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor = const Color.fromRGBO(142, 62, 99, 0.9),
    this.borderRadius = 8,
    this.fillColor = const Color(0xFFF5F7FB),
    this.showCounter = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  InputDecoration _decoration() {
    return InputDecoration(
      labelText: widget.label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
      hintText: widget.hint,
      filled: true,
      fillColor: widget.fillColor,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      counterText: widget.showCounter && widget.maxLength != null
          ? '$_charCount / ${widget.maxLength}'
          : '',
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor, width: 1),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: widget.maxLength,
      controller: _controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      decoration: _decoration(),
    );
  }
}

