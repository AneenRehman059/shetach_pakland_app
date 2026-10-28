import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final String? username;
  final double size;

  const BiometricLoginButton({
    Key? key,
    required this.onPressed,
    required this.isEnabled,
    this.username,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.fingerprint,
              size: size,
              color: isEnabled
                  ? AppColors.whiteBg
                  : AppColors.whiteBg.withOpacity(0.4),
            ),
            onPressed: onPressed,
            tooltip: isEnabled
                ? 'Login with fingerprint'
                : 'Enable biometric login from app settings',
          ),
        ],
      ),
    );
  }
}