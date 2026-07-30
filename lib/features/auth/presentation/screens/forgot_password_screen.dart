import 'package:flutter/material.dart';
import 'package:pakland/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/widgets/toast_message.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? cnic;
  const ForgotPasswordScreen({super.key , this.cnic});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());
  final LoginController loginController = Get.find<LoginController>();
  final _storage = const FlutterSecureStorage();

  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _conpassFocusNode = FocusNode();

  String _newPasswordStrength = '';
  Color _newPasswordStrengthColor = Colors.grey;
  String _confirmPasswordStrength = '';
  Color _confirmPasswordStrengthColor = Colors.grey;
  String _otpMethod = 'sms';

  Map<String, String> _fieldErrors = {
    'newPassword': '',
    'confirmPassword': '',
  };

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

    // Count how many character types are included
    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    // Determine strength level
    if (length > 8 && characterTypesCount == 4) {
      // Strong: More than 8 characters and includes all character types
      setState(() {
        _newPasswordStrength = 'Strong';
        _newPasswordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      // Average: Exactly 8 characters (always show as Average regardless of character types)
      setState(() {
        _newPasswordStrength = 'Average';
        _newPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      // Average: More than 8 characters with at least 2 character types
      setState(() {
        _newPasswordStrength = 'Average';
        _newPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      // Weak: Less than 8 characters or doesn't meet above criteria
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

  void _checkConfirmPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _confirmPasswordStrength = '';
        _confirmPasswordStrengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    int length = password.length;

    // Count how many character types are included
    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    // Determine strength level
    if (length > 8 && characterTypesCount == 4) {
      // Strong: More than 8 characters and includes all character types
      setState(() {
        _confirmPasswordStrength = 'Strong';
        _confirmPasswordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      // Average: Exactly 8 characters (always show as Average regardless of character types)
      setState(() {
        _confirmPasswordStrength = 'Average';
        _confirmPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      // Average: More than 8 characters with at least 2 character types
      setState(() {
        _confirmPasswordStrength = 'Average';
        _confirmPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      // Weak: Less than 8 characters or doesn't meet above criteria
      setState(() {
        _confirmPasswordStrength = 'Weak';
        _confirmPasswordStrengthColor = Colors.red;
      });
    } else {
      setState(() {
        _confirmPasswordStrength = '';
        _confirmPasswordStrengthColor = Colors.grey;
      });
    }
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors = {
      'newPassword': '',
      'confirmPassword': '',
    };

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Password validation
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

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      _fieldErrors['confirmPassword'] = 'Please confirm your password';
      isValid = false;
    } else if (confirmPassword != newPasswordController.text.trim()) {
      _fieldErrors['confirmPassword'] = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleUpdate() async {
    if (!_validateFields()) {
      return;
    }

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
      );

      if (response["StatusCode"] == "200") {
        showTopSnackBar(
            context,
            "Password updated successfully",
            Colors.green.withOpacity(0.7),
            icon: Icons.check_circle
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                phoneNumber: mobileNo,
                isPasswordReset: true,
                userId: widget.cnic!,
              ),
            ),
          );
        });
      } else {
        showTopSnackBar(
            context,
            title:"Alert",
            "Some technical fault occured! Try again later.",
            Colors.red.withOpacity(0.7),
            icon: Icons.warning
        );
      }
    } catch (e) {
      showTopSnackBar(
          context,
          title:"Alert",
          "Alert: ${e.toString()}",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning
      );
    }
  }

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      _checkNewPasswordStrength(newPasswordController.text);
      // Also update confirm password strength when new password changes
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
    newPasswordController.removeListener(() {});
    confirmPasswordController.removeListener(() {});

    _passFocusNode.dispose();
    _conpassFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Forgot Password",style: TextStyle(color: AppColors.whiteBg),),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
              ),
              child: ListView(
                children: [
                  Center(
                    child: Image.asset(
                      ImageConstant.logo,
                      height: size.height * 0.12,
                    ),
                  ),
                  SizedBox(height: size.height * 0.050),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: newPasswordController,
                        label: 'Enter new password',
                        hintText: 'Enter new password',
                        imagePath: 'assets/images/passwords.png',
                        obscureText: true,
                        showVisibilityIcon: true,
                        borderRadius: 30,
                        height: MediaQuery.of(context).size.height * 0.05,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                      ),

                      // New Password Strength Indicator
                      if (_newPasswordStrength.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              Text(
                                'Strength: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _newPasswordStrength,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _newPasswordStrengthColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_fieldErrors['newPassword']?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Text(
                            _fieldErrors['newPassword']!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.025),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        hintText: "Re-enter new password",
                        controller: confirmPasswordController,
                        label: "Confirm Password",
                        imagePath: 'assets/images/passwords.png',
                        obscureText: true,
                        showVisibilityIcon: true,   borderRadius: 30,
                        height: MediaQuery.of(context).size.height * 0.05,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                      ),

                      // Confirm Password Strength Indicator
                      if (_confirmPasswordStrength.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              Text(
                                'Strength: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _confirmPasswordStrength,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _confirmPasswordStrengthColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Password match indicator
                      if (confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              Icon(
                                newPasswordController.text == confirmPasswordController.text
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: newPasswordController.text == confirmPasswordController.text
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                newPasswordController.text == confirmPasswordController.text
                                    ? 'Passwords match'
                                    : 'Passwords do not match',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: newPasswordController.text == confirmPasswordController.text
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_fieldErrors['confirmPassword']?.isNotEmpty ?? false)
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Text(
                            _fieldErrors['confirmPassword']!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.025),
                  Text(
                    'Select OTP Method',
                    style: TextStyle(
                        color: AppColors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'sms',
                            groupValue: _otpMethod,
                            onChanged: (value) {
                              setState(() {
                                _otpMethod = value!;
                              });
                            },
                            activeColor: Colors.black,
                            fillColor: MaterialStateProperty.all(Colors.black),
                          ),
                          Text(
                            'SMS',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'email',
                            groupValue: _otpMethod,
                            onChanged: (value) {
                              setState(() {
                                _otpMethod = value!;
                              });
                            },
                            activeColor: AppColors.black,
                            fillColor: MaterialStateProperty.all(Colors.black),
                          ),
                          Text(
                            'EMAIL',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'whatsapp',
                            groupValue: _otpMethod,
                            onChanged: (value) {
                              setState(() {
                                _otpMethod = value!;
                              });
                            },
                            activeColor: AppColors.black,
                            fillColor: MaterialStateProperty.all(Colors.black),
                          ),
                          Text(
                            'WHATSAPP',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),

                  Obx(() {
                    if (forgotPasswordController.isLoading.value) {
                      return Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.appColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: SpinKitWave(
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: CustomButton(
                          text: "UPDATE",
                          onPressed: _handleUpdate,
                          isLoading: false,
                          textColor: Colors.white,
                          autoWidth: true,
                          borderRadius: 30,
                        ),
                      );
                    }
                  }),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}