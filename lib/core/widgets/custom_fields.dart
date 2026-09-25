import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:flutter/services.dart';
class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextStyle? labelStyle;
  final IconData? icon;
  final String? imagePath;
  final bool obscureText;
  final bool showVisibilityIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final double? height;
  final bool isSignUpStyle;
  final bool readOnly;
  final VoidCallback? onTap;
  final double? borderRadius;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.labelStyle,
    this.icon,
    this.imagePath,
    this.obscureText = false,
    this.showVisibilityIcon = false,
    this.keyboardType,
    this.onChanged,
    this.controller,
    this.validator,
    this.contentPadding,
    this.height,
    this.isSignUpStyle = false,
    this.readOnly = false,
    this.onTap,
    this.borderRadius,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isEmailValid = false;
  bool _isEmailInvalid = false;
  final _emailRegex = RegExp(
      r'^[\w\.\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$'
  );

  int _getMaxLength() {
    switch (widget.label) {
      case 'First Name':
      case 'Name*':
      case 'First Name*':
      case 'Last Name*':
        return 35;
      case 'Password':
      case 'Password*':
      case 'Old Password':
      case 'New Password':
      case 'Confirm Password':
        return 20;
      case 'Email':
      case 'Email*':
        return 200;
      case 'Phone No':
      case 'Phone No*':
      case 'Mobile No.*':
      case 'Mobile No':
        return 15;
      case 'Address':
      case 'Address*':
      case 'Message':
        return 500;
      case 'CNIC':
      case 'CNIC*':
        return 15;
      case 'Plot No*':
        return 15;
      default:
        return 100;
    }
  }

  int? _getMinLength() {
    switch (widget.label) {
      case 'Password':
        return 8;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    if (widget.keyboardType == TextInputType.emailAddress) {
      widget.controller?.addListener(_validateEmail);
    }
  }

  @override
  void dispose() {
    if (widget.keyboardType == TextInputType.emailAddress) {
      widget.controller?.removeListener(_validateEmail);
    }
    super.dispose();
  }

  void _validateEmail() {
    if (widget.controller == null) return;

    final text = widget.controller!.text;
    final isValid = _emailRegex.hasMatch(text);

    setState(() {
      _isEmailValid = text.isNotEmpty && isValid;
      _isEmailInvalid = text.isNotEmpty && !isValid;
    });
  }

  Widget _buildEmailValidationIcon() {
    if (_isEmailValid) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (_isEmailInvalid) {
      return const Icon(Icons.error, color: Colors.red);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    final horizontalPadding = screenSize.width * 0.04;
    final verticalPadding = screenSize.height * 0.015;

    // Responsive font sizes
    final double labelFontSize = screenWidth > 600 ? 14 : 13;
    final double hintFontSize = screenWidth > 600 ? 15 : 14;

    // Responsive icon sizes
    final double iconSize = screenWidth > 600 ? 22 : 20;
    final double visibilityIconSize = screenWidth > 600 ? 20 : 18;

    // Responsive heights and paddings
    final double defaultTextFieldHeight = screenHeight * 0.06;
    final double labelSpacing = screenHeight * 0.008;
    final EdgeInsets defaultContentPadding = EdgeInsets.symmetric(
      vertical: screenHeight * 0.015,
      horizontal: screenWidth * 0.04,
    );
    final EdgeInsets signUpContentPadding = EdgeInsets.symmetric(
      vertical: screenHeight * 0.012,
      horizontal: screenWidth * 0.03,
    );

    if (widget.isSignUpStyle) {
      return _buildSignUpTextField(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        labelFontSize: labelFontSize,
        hintFontSize: hintFontSize,
        iconSize: iconSize,
        visibilityIconSize: visibilityIconSize,
        defaultTextFieldHeight: defaultTextFieldHeight,
        labelSpacing: labelSpacing,
        contentPadding: signUpContentPadding,
      );
    }
    return _buildLoginTextField(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      labelFontSize: labelFontSize,
      hintFontSize: hintFontSize,
      iconSize: iconSize,
      visibilityIconSize: visibilityIconSize,
      defaultTextFieldHeight: defaultTextFieldHeight,
      labelSpacing: labelSpacing,
      contentPadding: defaultContentPadding,
    );
  }

  Widget _buildLoginTextField({
    required double screenWidth,
    required double screenHeight,
    required double labelFontSize,
    required double hintFontSize,
    required double iconSize,
    required double visibilityIconSize,
    required double defaultTextFieldHeight,
    required double labelSpacing,
    required EdgeInsets contentPadding,
  }) {
    final size = MediaQuery.of(context).size;

    final horizontalPadding = size.width * 0.04;
    final verticalPadding = size.height * 0.015;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: widget.labelStyle ?? TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: labelFontSize,
          ),
        ),
        SizedBox(height: labelSpacing),
        Container(
          height: widget.height ?? defaultTextFieldHeight,
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? screenWidth * 0.025,
            ),
            border: Border.all(
              color: _isEmailInvalid ? Colors.red : AppColors.appColor,
              width: 1.0,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: _getMaxLength(),
            onChanged: (value) {
              widget.onChanged?.call(value);

              if (widget.keyboardType == TextInputType.emailAddress) {
                _validateEmail();
              }
            },
            validator: (value) {
              final minLength = _getMinLength();
              if (minLength != null && (value?.length ?? 0) < minLength && (value?.isNotEmpty ?? false)) {
                return '${widget.label} must be at least $minLength characters';
              }

              if (widget.validator != null) {
                return widget.validator!(value);
              }

              return null;
            },
            style: TextStyle(
              color: Colors.black,
              fontSize: hintFontSize,
            ),
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            decoration: InputDecoration(
              prefixIcon: widget.icon != null
                  ? Icon(
                widget.icon,
                size: iconSize,
                color: AppColors.appColor,
              )
                  : (widget.imagePath != null
                  ? Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Image.asset(
                  widget.imagePath!,
                  width: iconSize,
                  height: iconSize,
                ),
              )
                  : null),
              suffixIcon: widget.showVisibilityIcon
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: visibilityIconSize,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : (widget.keyboardType == TextInputType.emailAddress
                  ? _buildEmailValidationIcon()
                  : null),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.black38,
                fontSize: hintFontSize,
              ),
              hintTextDirection: TextDirection.ltr,
             // contentPadding: widget.contentPadding ?? contentPadding,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpTextField({
    required double screenWidth,
    required double screenHeight,
    required double labelFontSize,
    required double hintFontSize,
    required double iconSize,
    required double visibilityIconSize,
    required double defaultTextFieldHeight,
    required double labelSpacing,
    required EdgeInsets contentPadding,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: widget.labelStyle ?? TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: labelSpacing),
        SizedBox(
          height: widget.height ?? defaultTextFieldHeight,
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: _getMaxLength(),
            onChanged: (value) {
              widget.onChanged?.call(value);

              if (widget.keyboardType == TextInputType.emailAddress) {
                _validateEmail();
              }
            },
            validator: (value) {
              final minLength = _getMinLength();
              if (minLength != null && (value?.length ?? 0) < minLength && (value?.isNotEmpty ?? false)) {
                return '${widget.label} must be at least $minLength characters';
              }

              if (widget.validator != null) {
                return widget.validator!(value);
              }

              return null;
            },
            style: TextStyle(
              color: Colors.black,
              fontSize: hintFontSize,
            ),
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            decoration: InputDecoration(
              contentPadding: widget.contentPadding ?? contentPadding,
              prefixIcon: widget.icon != null
                  ? Icon(
                widget.icon,
                size: iconSize,
                color: AppColors.appColor,
              )
                  : null,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: hintFontSize,
                color: Colors.black38,
              ),
              filled: true,
              fillColor: AppColors.bgColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? screenWidth * 0.02,
                ),
                borderSide: BorderSide(
                  color: _isEmailInvalid ? Colors.red : AppColors.appColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? screenWidth * 0.02,
                ),
                borderSide: BorderSide(
                  color: _isEmailInvalid ? Colors.red : AppColors.appColor,
                ),
              ),
              suffixIcon: widget.showVisibilityIcon
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  size: visibilityIconSize,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : (widget.keyboardType == TextInputType.emailAddress
                  ? _buildEmailValidationIcon()
                  : null),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}