import 'package:pakland/core/widgets/loader.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:pakland/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:pakland/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/communication_policy_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/widgets/auth_hero_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? cnic;
  const ForgotPasswordScreen({super.key, this.cnic});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final ForgotPasswordController forgotPasswordController =
  Get.put(ForgotPasswordController());
  final CommunicationPolicyController _communicationPolicyController =
  Get.put(CommunicationPolicyController());
  final LoginController loginController = Get.find<LoginController>();
  final _storage = const FlutterSecureStorage();

  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _conpassFocusNode = FocusNode();

  // Stable keys: layout rebuild hone par bhi fields recreate nahi honge
  // (isi se keyboard close ho raha tha)
  final GlobalKey _newPassKey = GlobalKey(debugLabel: 'newPassField');
  final GlobalKey _confirmPassKey = GlobalKey(debugLabel: 'confirmPassField');

  String _newPasswordStrength = '';
  Color _newPasswordStrengthColor = Colors.grey;
  String _confirmPasswordStrength = '';
  Color _confirmPasswordStrengthColor = Colors.grey;

  // Only one OTP method is shown - driven by
  // /api/MobileAPi/GetCommunicationPolicy's key_code:
  //   via_WABA / whatsapp -> WHATSAPP
  //   itel / telenor      -> SMS
  //   email               -> EMAIL
  String get _otpMethod => _communicationPolicyController.otpMethod.value.value;

  Map<String, String> _fieldErrors = {
    'newPassword': '',
    'confirmPassword': '',
  };

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  /// Returns (label, color) for a password
  (String, Color) _evaluateStrength(String password) {
    if (password.isEmpty) return ('', Colors.grey);

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    final length = password.length;

    int types = 0;
    if (hasUppercase) types++;
    if (hasLowercase) types++;
    if (hasNumber) types++;
    if (hasSpecialChar) types++;

    if (length > 8 && types == 4) return ('Strong', Colors.green);
    if (length == 8) return ('Average', Colors.orange);
    if (length > 8 && types >= 2) return ('Average', Colors.orange);
    return ('Weak', Colors.red);
  }

  void _checkNewPasswordStrength(String password) {
    final result = _evaluateStrength(password);
    if (!mounted) return;
    if (result.$1 == _newPasswordStrength &&
        result.$2 == _newPasswordStrengthColor) {
      return;
    }
    setState(() {
      _newPasswordStrength = result.$1;
      _newPasswordStrengthColor = result.$2;
    });
  }

  void _checkConfirmPasswordStrength(String password) {
    final result = _evaluateStrength(password);
    if (!mounted) return;
    if (result.$1 == _confirmPasswordStrength &&
        result.$2 == _confirmPasswordStrengthColor) {
      return;
    }
    setState(() {
      _confirmPasswordStrength = result.$1;
      _confirmPasswordStrengthColor = result.$2;
    });
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors = {
      'newPassword': '',
      'confirmPassword': '',
    };

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      _fieldErrors['newPassword'] = 'Please enter a new password';
      isValid = false;
    } else {
      final hasMinLength = newPassword.length >= 8;
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(newPassword);
      final hasLowercase = RegExp(r'[a-z]').hasMatch(newPassword);
      final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);
      final hasSpecialChar =
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassword);

      if (!(hasMinLength &&
          hasUppercase &&
          hasLowercase &&
          hasNumber &&
          hasSpecialChar)) {
        _fieldErrors['newPassword'] =
        'Password must be at least 8 characters, include uppercase, lowercase, number, and a special character';
        isValid = false;
      }
    }

    if (confirmPassword.isEmpty) {
      _fieldErrors['confirmPassword'] = 'Please confirm your password';
      isValid = false;
    } else if (confirmPassword != newPassword) {
      _fieldErrors['confirmPassword'] = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleUpdate() async {
    if (!_validateFields()) return;

    final newPassword = newPasswordController.text.trim();
    final userId = await _storage.read(key: "user_id") ?? "";
    final mobileNo = await _storage.read(key: "mobile_no1") ?? "";
    final emailAddress = await _storage.read(key: "email_no1") ?? "";
    final userName = await _storage.read(key: "user_name") ?? "";

    try {
      final response = await forgotPasswordController.updatePassword(
        cnic: widget.cnic!,
        password: newPassword,
        mobileNo: mobileNo,
        emailAddress: emailAddress,
        userName: userName,
        otpVia: _otpMethod,
      );

      if (response["StatusCode"] == "200") {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                phoneNumber: mobileNo,
                isPasswordReset: true,
                userId: widget.cnic!,
                otpVia: _otpMethod,
                password: newPassword,
              ),
            ),
          );
        });
      } else {
        if (!mounted) return;
        showTopSnackBar(
          context,
          title: "Alert",
          "Some technical fault occured! Try again later.",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showTopSnackBar(
        context,
        title: "Alert",
        "Alert: ${e.toString()}",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      _checkNewPasswordStrength(newPasswordController.text);
      if (confirmPasswordController.text.isNotEmpty) {
        _checkConfirmPasswordStrength(confirmPasswordController.text);
      }
    });

    confirmPasswordController.addListener(() {
      _checkConfirmPasswordStrength(confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _passFocusNode.dispose();
    _conpassFocusNode.dispose();
    super.dispose();
  }

  void _clearError(String key) {
    if ((_fieldErrors[key] ?? '').isNotEmpty) {
      setState(() => _fieldErrors[key] = '');
    }
  }

  Widget _buildOtpSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'Select OTP method',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: 0.2,
            ),
          ),
        ),
        Obx(() {
          if (_communicationPolicyController.isLoading.value) {
            return const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: AppLoader(),
              ),
            );
          }
          final method = _communicationPolicyController.otpMethod.value;
          return Row(
            children: [
              // Already selected + locked: user change nahi kar sakta
              IgnorePointer(
                child: Checkbox(
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.appColor,
                  checkColor: Colors.white,
                ),
              ),
              Text(
                method.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      resizeToAvoidBottomInset: true,
      body: ResponsiveBody(
        child: AuthHeroLayout(
          title: 'Forgot Password',
          subtitle:
          'Create a strong new password to get back into your account.',
          heroIcon: Icons.lock_reset_rounded,
          cardBuilder: (context, info) {
            final double gap = info.gap;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KeyedSubtree(
                  key: _newPassKey,
                  child: AuthPasswordField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: newPasswordController,
                    focusNode: _passFocusNode,
                    errorText: _fieldErrors['newPassword'] ?? '',
                    obscure: _obscureNew,
                    icon: Icons.lock_outline_rounded,
                    onToggle: () =>
                        setState(() => _obscureNew = !_obscureNew),
                    onChanged: (_) => _clearError('newPassword'),
                    onSubmitted: (_) => _conpassFocusNode.requestFocus(),
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
                ),
                SizedBox(height: gap),
                KeyedSubtree(
                  key: _confirmPassKey,
                  child: AuthPasswordField(
                    label: 'Confirm Password',
                    hint: 'Re-enter new password',
                    controller: confirmPasswordController,
                    focusNode: _conpassFocusNode,
                    errorText: _fieldErrors['confirmPassword'] ?? '',
                    obscure: _obscureConfirm,
                    icon: Icons.verified_user_outlined,
                    action: TextInputAction.done,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
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
                ),
                SizedBox(height: gap),
                _buildOtpSelector(),
                SizedBox(height: gap + 6),
                Obx(
                      () => AuthGradientButton(
                    label: 'Update Password',
                    icon: Icons.verified_user_rounded,
                    loading: forgotPasswordController.isLoading.value,
                    onTap: _handleUpdate,
                  ),
                ),
                if (!info.compact) ...[
                  const SizedBox(height: 10),
                  const AuthInfoCaption(
                    text:
                    'After updating, you will be asked to verify with a one-time code.',
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}