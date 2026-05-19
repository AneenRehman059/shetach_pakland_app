import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/constants/image_constant.dart';
import 'package:pakland/customs/custom_fields.dart';
import 'package:pakland/customs/app_bar.dart';
import '../controllers/update_password_controller.dart';
import '../controllers/login_controller.dart';
import 'bottom_app_bar/bottom_app_bar.dart';
import 'customs/custom_buttons.dart';
import 'customs/toast_message.dart';
import 'dashboard/profile_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final UpdatePasswordController _controller =
  Get.put(UpdatePasswordController());
  final LoginController _loginController = Get.find<LoginController>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _newPasswordStrength = '';
  Color _newPasswordStrengthColor = Colors.grey;
  String _confirmPasswordStrength = '';
  Color _confirmPasswordStrengthColor = Colors.grey;
  final FocusNode _oldPassFocusNode = FocusNode();
  final FocusNode _newPassFocusNode = FocusNode();
  final FocusNode _conPassFocusNode = FocusNode();

  Map<String, String> _fieldErrors = {
    'oldPassword': '',
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
      _confirmPasswordStrength = '';
      _confirmPasswordStrengthColor = Colors.grey;
    });
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors = {
      'oldPassword': '',
      'newPassword': '',
      'confirmPassword': '',
    };

    // Old password validation
    if (oldPasswordController.text.isEmpty) {
      _fieldErrors['oldPassword'] = 'Please enter your old password';
      isValid = false;
    }

    // New password validation
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

    // Confirm password validation
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
      // Logout and navigate to login screen
      await _loginController.logout();
    } else {
      _clearFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Change Password",style: TextStyle(color: AppColors.whiteBg),),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          actions: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Get.offAll(() => MainWrapper(initialIndex: 0));
              },
            ),
          ],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                ),
                child: ListView(
                  children: [
                    SizedBox(height:size.height * 0.06,),
                    Center(
                      child: Image.asset(
                        ImageConstant.logo,
                        height: size.height * 0.12,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: "Old Password",
                          hintText: "Enter old password",
                          imagePath: 'assets/images/passwords.png',
                          controller: oldPasswordController,
                          obscureText: true,
                          showVisibilityIcon: true,
                          borderRadius: 30,
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        if (_fieldErrors['oldPassword']?.isNotEmpty ?? false)
                          Padding(
                            padding: EdgeInsets.only(left: 8, top: 4),
                            child: Text(
                              _fieldErrors['oldPassword']!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.012),

                    // New Password Field with Error Message
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: "New Password",
                          hintText: "Enter new password",
                          imagePath: 'assets/images/passwords.png',
                          controller: newPasswordController,
                          obscureText: true,
                          showVisibilityIcon: true,   borderRadius: 30,
                          height: MediaQuery.of(context).size.height * 0.05,
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
                    SizedBox(height: size.height * 0.012),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: "Confirm Password",
                          hintText: "Re-enter new password",
                          imagePath: 'assets/images/passwords.png',
                          controller: confirmPasswordController,
                          obscureText: true,
                          showVisibilityIcon: true,   borderRadius: 30,
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),

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
                    SizedBox(height: size.height * 0.04),

                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: size.width * 0.26,),
                      child: SizedBox(
                        height: size.height * 0.05,
                        child: Obx(() => ElevatedButton(
                          onPressed: _controller.isLoading.value
                              ? null
                              : _handleUpdate,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            backgroundColor: _controller.isLoading.value
                                ? AppColors.appColor.withOpacity(0.7)
                                : AppColors.appColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _controller.isLoading.value
                              ? const SpinKitWave(
                            color: Colors.white,
                            size: 24.0,
                          )
                              : Text(
                            "UPDATE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.045,
                            ),
                          ),
                        )),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}