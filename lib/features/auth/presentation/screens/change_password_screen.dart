import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/features/auth/presentation/controllers/update_password_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/core/widgets/auth_hero_layout.dart';
import 'package:pakland/core/constants/image_constant.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final UpdatePasswordController _controller = Get.put(UpdatePasswordController());
  final LoginController _loginController = Get.find<LoginController>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _newPasswordStrength = '';
  Color _newPasswordStrengthColor = Colors.grey;
  final FocusNode _oldPassFocusNode = FocusNode();
  final FocusNode _newPassFocusNode = FocusNode();
  final FocusNode _conPassFocusNode = FocusNode();

  Map<String, String> _fieldErrors = {
    'oldPassword': '',
    'newPassword': '',
    'confirmPassword': '',
  };

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;


  void _checkNewPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _newPasswordStrength = '';
        _newPasswordStrengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    int length = password.length;

    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    if (length > 8 && characterTypesCount == 4) {
      setState(() {
        _newPasswordStrength = 'Strong';
        _newPasswordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      setState(() {
        _newPasswordStrength = 'Average';
        _newPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      setState(() {
        _newPasswordStrength = 'Average';
        _newPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      setState(() {
        _newPasswordStrength = 'Weak';
        _newPasswordStrengthColor = Colors.red;
      });
    } else {
      setState(() {
        _newPasswordStrength = '';
        _newPasswordStrengthColor = Colors.grey;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      _checkNewPasswordStrength(newPasswordController.text);
    });

    confirmPasswordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _oldPassFocusNode.dispose();
    _newPassFocusNode.dispose();
    _conPassFocusNode.dispose();
    super.dispose();
  }

  void _clearFields() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    setState(() {
      _fieldErrors = {
        'oldPassword': '',
        'newPassword': '',
        'confirmPassword': '',
      };
      _newPasswordStrength = '';
      _newPasswordStrengthColor = Colors.grey;
    });
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors = {
      'oldPassword': '',
      'newPassword': '',
      'confirmPassword': '',
    };

    if (oldPasswordController.text.isEmpty) {
      _fieldErrors['oldPassword'] = 'Please enter your old password';
      isValid = false;
    }

    final newPassword = newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      _fieldErrors['newPassword'] = 'Please enter a new password';
      isValid = false;
    } else {
      bool hasMinLength = newPassword.length >= 8;
      bool hasUppercase = RegExp(r'[A-Z]').hasMatch(newPassword);
      bool hasLowercase = RegExp(r'[a-z]').hasMatch(newPassword);
      bool hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);
      bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassword);

      if (!(hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar)) {
        _fieldErrors['newPassword'] = 'Password must be at least 8 characters, include uppercase, lowercase, number, and a special character';
        isValid = false;
      }
    }

    if (confirmPasswordController.text.isEmpty) {
      _fieldErrors['confirmPassword'] = 'Please confirm your password';
      isValid = false;
    } else if (confirmPasswordController.text != newPasswordController.text) {
      _fieldErrors['confirmPassword'] = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleUpdate() async {
    if (_controller.isLoading.value || !_validateFields()) return;

    final savedPassword = await _storage.read(key: "user_password") ?? "";

    if (oldPasswordController.text.trim() != savedPassword) {
      setState(() {
        _fieldErrors['oldPassword'] = 'Old password does not match!';
      });
      return;
    }

    bool success = await _controller.updatePassword(
      oldPasswordController.text.trim(),
      newPasswordController.text.trim(),
      context,
    );

    if (success) {
      await Future.delayed(const Duration(milliseconds: 1600));
      await _loginController.logout();
    } else {
      _clearFields();
    }
  }

  void _clearError(String key) {
    if ((_fieldErrors[key] ?? '').isNotEmpty) {
      setState(() => _fieldErrors[key] = '');
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        resizeToAvoidBottomInset: true,
        body: ResponsiveBody(
          child: AuthHeroLayout(
            title: 'Change Password',
            subtitle: 'Keep your account safe with a strong password.',
            heroIcon: Icons.lock_reset_rounded,
            onBack: () => Get.back(),
            trailing: AppHeaderAction(
              assetIcon: ImageConstant.icHouse,
              tooltip: 'Home',
              onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
            ),
            cardBuilder: (context, info) {
              final double gap = info.gap;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPasswordField(
                    label: 'Current Password',
                    hint: 'Enter current password',
                    controller: oldPasswordController,
                    focusNode: _oldPassFocusNode,
                    errorText: _fieldErrors['oldPassword'] ?? '',
                    obscure: _obscureOldPassword,
                    icon: Icons.lock_outline_rounded,
                    onToggle: () {
                      setState(() => _obscureOldPassword = !_obscureOldPassword);
                    },
                    onChanged: (_) => _clearError('oldPassword'),
                    onSubmitted: (_) => _newPassFocusNode.requestFocus(),
                  ),
                  SizedBox(height: gap),
                  AuthPasswordField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: newPasswordController,
                    focusNode: _newPassFocusNode,
                    errorText: _fieldErrors['newPassword'] ?? '',
                    obscure: _obscureNewPassword,
                    icon: Icons.vpn_key_outlined,
                    onToggle: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                    onChanged: (_) => _clearError('newPassword'),
                    onSubmitted: (_) => _conPassFocusNode.requestFocus(),
                    extras: [
                      if (newPasswordController.text.isNotEmpty &&
                          _newPasswordStrength.isNotEmpty)
                        PasswordStrengthMeter(
                          strength: _newPasswordStrength,
                          color: _newPasswordStrengthColor,
                        ),
                      if (newPasswordController.text.isNotEmpty)
                        PasswordRequirementChips(
                          password: newPasswordController.text,
                        ),
                    ],
                  ),
                  SizedBox(height: gap),
                  AuthPasswordField(
                    label: 'Confirm Password',
                    hint: 'Re-enter new password',
                    controller: confirmPasswordController,
                    focusNode: _conPassFocusNode,
                    errorText: _fieldErrors['confirmPassword'] ?? '',
                    obscure: _obscureConfirmPassword,
                    icon: Icons.verified_user_outlined,
                    action: TextInputAction.done,
                    onToggle: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    onChanged: (_) => _clearError('confirmPassword'),
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    extras: [
                      if (newPasswordController.text.isNotEmpty &&
                          confirmPasswordController.text.isNotEmpty)
                        PasswordMatchIndicator(
                          match: confirmPasswordController.text ==
                              newPasswordController.text,
                        ),
                    ],
                  ),
                  SizedBox(height: gap + 6),
                  Obx(
                    () => AuthGradientButton(
                      label: 'Update Password',
                      icon: Icons.verified_user_rounded,
                      loading: _controller.isLoading.value,
                      onTap: _handleUpdate,
                    ),
                  ),
                  if (!info.compact) ...[
                    const SizedBox(height: 10),
                    const AuthInfoCaption(
                      text:
                          'For your security you will be signed out after the password is changed.',
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
