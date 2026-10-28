import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pakland/core/theme/colors.dart';

class LoginCheckUtil {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<bool> isUserLoggedIn() async {
    final userId = await _storage.read(key: "user_id");
    return userId != null && userId.isNotEmpty;
  }

  static Future<void> showLoginRequiredDialog(
      BuildContext context, {
        VoidCallback? onYesPressed,
      }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, _, __) =>
          _LoginRequiredDialog(onLogin: onYesPressed),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _LoginRequiredDialog extends StatelessWidget {
  final VoidCallback? onLogin;

  const _LoginRequiredDialog({this.onLogin});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 600;
    final isTiny = width < 350;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 24 : 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.appColor.withOpacity(0.10),
                        AppColors.appColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTiny ? 18 : 24,
                  32,
                  isTiny ? 18 : 24,
                  isTiny ? 18 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBadge(size: isSmall ? 84 : 96),
                    const SizedBox(height: 22),

                    Text(
                      'Login Required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmall ? 21 : 23,
                        fontWeight: FontWeight.w700,
                        color: AppColors.appColor,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.iconColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Please sign in to your account to access this feature and enjoy the full experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmall ? 14 : 15,
                        height: 1.5,
                        color: AppColors.darkGrey,
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onLogin?.call();
                        },
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: const Text(
                          'Login Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.appColor,
                          elevation: 3,
                          shadowColor: AppColors.appColor.withOpacity(0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final double size;

  const _IconBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.appColor.withOpacity(0.08),
      ),
      alignment: Alignment.center,
      child: Container(
        height: size * 0.74,
        width: size * 0.74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lightAppColor, AppColors.appColor],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          size: size * 0.38,
          color: Colors.white,
        ),
      ),
    );
  }
}