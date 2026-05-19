import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final double opacity;

  // NEW OPTIONAL PARAMETERS
  final double? borderRadius;
  final bool autoWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.opacity = 1.0,
    this.borderRadius,
    this.autoWidth = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
    (backgroundColor ??
        (isOutlined ? AppColors.bgColor : AppColors.appColor))
        .withOpacity(opacity);

    return SizedBox(
      width: autoWidth ? null : double.infinity,
      height: 40,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: AppColors.appColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
        ),
        child: Padding(
          padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10),
          child: isLoading
              ? SpinKitWave(
            color: AppColors.appColor,
            size: 24.0,
          )
              : Text(
            text,
            style: TextStyle(
              color: textColor ?? AppColors.appColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
        ),
        child: Padding(
          padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10),
          child: isLoading
              ? SpinKitWave(
            color: Colors.white,
            size: 24.0,
          )
              : Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}