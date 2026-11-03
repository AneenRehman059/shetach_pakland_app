import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:pakland/features/auth/presentation/screens/signup_screen.dart';

class LoginHelpSheet extends StatelessWidget {
  const LoginHelpSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginHelpSheet(),
    );
  }

  // ---- Support contact (WhatsApp comes from company data) ----
  String get _whatsapp {
    if (Get.isRegistered<CompanyController>()) {
      return Get.find<CompanyController>().whatsappNumber.value.trim();
    }
    return '';
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final number = _whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (number.isEmpty) {
      showTopSnackBar(
        context,
        title: 'Support',
        'Support number is not available right now.',
        Colors.orange.withOpacity(0.8),
        icon: Icons.info,
      );
      return;
    }
    final uri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent("Hello, I need help with logging in to my account.")}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        showTopSnackBar(
          context,
          title: 'Error',
          'Could not open WhatsApp.',
          Colors.red.withOpacity(0.7),
          icon: Icons.error,
        );
      }
    }
  }

  Future<void> _call(BuildContext context) async {
    final number = _whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:$number'));
    } catch (_) {}
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _whatsapp));
    if (context.mounted) {
      showTopSnackBar(
        context,
        title: 'Copied',
        'Support number copied to clipboard.',
        Colors.green.withOpacity(0.7),
        icon: Icons.check_circle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.support_agent_rounded,
                      color: AppColors.appColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose an option below to get started.',
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // quick self-help
            _sectionLabel('Quick help'),
            _HelpTile(
              icon: Icons.lock_reset_rounded,
              title: 'Forgot password?',
              subtitle: 'Reset your password using OTP',
              onTap: () {
                Navigator.pop(context);
                Get.to(() => ForgotPasswordScreen());
              },
            ),
            _HelpTile(
              icon: Icons.person_add_alt_1_rounded,
              title: 'New here? Create an account',
              subtitle: 'Register to access your files and payments',
              onTap: () {
                Navigator.pop(context);
                Get.to(() => SignUpNScreen());
              },
            ),

            // contact
            const SizedBox(height: 8),
            _sectionLabel('Contact support'),
            Obx(() {
              final hasNumber =
                  Get.isRegistered<CompanyController>() &&
                      Get.find<CompanyController>()
                          .whatsappNumber
                          .value
                          .isNotEmpty;
              return Column(
                children: [
                  _HelpTile(
                    icon: Icons.chat_rounded,
                    iconColor: const Color(0xFF25D366),
                    title: 'Chat on WhatsApp',
                    subtitle: hasNumber ? _whatsapp : 'Chat with our support team',
                    onTap: () => _openWhatsApp(context),
                    trailing: hasNumber
                        ? IconButton(
                      tooltip: 'Copy number',
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () => _copy(context),
                    )
                        : null,
                  ),
                  if (hasNumber)
                    _HelpTile(
                      icon: Icons.call_rounded,
                      title: 'Call support',
                      subtitle: 'Speak directly with our team',
                      onTap: () => _call(context),
                    ),
                ],
              );
            }),

            // footer
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 18, color: AppColors.appColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Our support team is available to assist you with login and account issues.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Colors.grey.shade500,
      ),
    ),
  );
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.appColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}