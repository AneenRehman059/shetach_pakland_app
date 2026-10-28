import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final double opacity;
  final double? borderRadius;
  final bool autoWidth;
  final EdgeInsetsGeometry? padding;

  final Gradient? gradient;
  final bool useGradient;

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
    this.gradient,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {

    final whiteToAppColorGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.lerp(AppColors.appColor, Colors.white, 0.40)!,
        Color.lerp(AppColors.appColor, Colors.white, 0.15)!,
        Color.lerp(AppColors.appColor, Colors.black, 0.10)!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final bgColor = (backgroundColor ??
        (isOutlined ? AppColors.bgColor : AppColors.appColor))
        .withOpacity(opacity);

    final effectiveGradient = gradient ?? whiteToAppColorGradient;

    return isOutlined
        ? OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: useGradient ? Colors.transparent : bgColor,
        side: BorderSide(color: AppColors.appColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size(autoWidth ? 0 : double.infinity, 45),
        maximumSize: Size(double.infinity, 45),
      ),
      child: useGradient
          ? Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
        child: Center(
          child: isLoading
              ? AppLoader(size: 24)
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
          : Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: isLoading
              ? AppLoader(size: 24)
              : Text(
            text,
            style: TextStyle(
              color: textColor ?? AppColors.appColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    )
        : ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: useGradient ? Colors.transparent : bgColor,
        shadowColor: useGradient ? Colors.transparent : null,
        elevation: useGradient ? 0 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size(autoWidth ? 0 : double.infinity, 45),
        maximumSize: Size(double.infinity, 45),
      ),
      child: useGradient
          ? Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: isLoading
                ? AppLoader(size: 24)
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
      )
          : Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: isLoading
              ? AppLoader(size: 24)
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