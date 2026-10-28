import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';

import '../../../core/constants/image_constant.dart';


class AuthFadeSlide extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;
  final bool fade;

  const AuthFadeSlide({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 24,
    this.fade = true,
  });

  @override
  Widget build(BuildContext context) {
    const int baseMs = 550;
    final int totalMs = baseMs + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) {
        final moved = Transform.translate(
          offset: Offset(0, (1 - t) * offsetY),
          child: child,
        );
        return fade ? Opacity(opacity: t, child: moved) : moved;
      },
      child: child,
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String logoPath;
  final String title;
  final String subtitle;
  final double logoSize;

  const AuthHeader({
    super.key,
    required this.logoPath,
    required this.title,
    required this.subtitle,
    this.logoSize = 84,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(logoPath, height: logoSize, width: logoSize),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class AuthGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final int delayMs;

  final double tint;

  const AuthGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 22),
    this.radius = 26,
    this.delayMs = 0,
    this.tint = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return AuthFadeSlide(
      delayMs: delayMs,
      fade: false,
      offsetY: 30,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.14 + tint * 0.3),
              Colors.black.withOpacity(tint),
            ],
          ),
        ),
        child: AuthFadeSlide(
          delayMs: delayMs + 150,
          offsetY: 0,
          child: child,
        ),
      ),
    );
  }
}


class _AuthAssetIcon extends StatelessWidget {
  final String path;
  final Color color;
  final double size;
  const _AuthAssetIcon(this.path, {required this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: Image.asset(
        path,
        width: size,
        height: size,
        color: color,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (_, __, ___) => Icon(Icons.circle_outlined, color: color, size: size),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final String? assetIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.assetIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.errorText,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure = widget.isPassword;
  static final RegExp _emailRegex =
  RegExp(r'^[\w\.\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');

  bool get _isEmail => widget.keyboardType == TextInputType.emailAddress;

  Widget? _buildSuffix() {
    if (widget.isPassword) {
      return IconButton(
        splashRadius: 20,
        icon: _AuthAssetIcon(
          _obscure ? ImageConstant.authEyeOff : ImageConstant.authEye,
          color: Colors.white70,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    }
    if (_isEmail) {
      final text = widget.controller.text;
      if (text.isEmpty) return null;
      final valid = _emailRegex.hasMatch(text);
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(
          valid ? Icons.check_circle : Icons.error_outline,
          color: valid ? Colors.greenAccent.shade400 : AppColors.softCorelRedColor,
          size: 20,
        ),
      );
    }
    return null;
  }

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final Color errorColor = AppColors.softCorelRedColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          cursorColor: Colors.white,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            if (_isEmail) setState(() {});
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: Colors.black.withOpacity(0.22),
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.assetIcon != null
                ? _AuthAssetIcon(widget.assetIcon!, color: Colors.white70, size: 20)
                : Icon(widget.icon, color: Colors.white70, size: 20),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: _buildSuffix(),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            border: _border(Colors.white.withOpacity(0.2)),
            enabledBorder: _border(hasError ? errorColor : Colors.white.withOpacity(0.2)),
            focusedBorder: _border(hasError ? errorColor : Colors.white, 1.5),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 6, right: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(Icons.error_outline, size: 14, color: errorColor),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(color: errorColor, fontSize: 12, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.lightAppColor, AppColors.appColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.5),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: AppLoader(),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  final String label;
  const AuthOrDivider({super.key, this.label = 'or'});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: Colors.white.withOpacity(0.25)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class AuthSectionLabel extends StatelessWidget {
  final String text;
  const AuthSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: Colors.white.withOpacity(0.18)),
        ),
      ],
    );
  }
}

class AuthGlassCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;

  const AuthGlassCircle({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.14),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: child,
      ),
    );
  }
}