import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/features/auth/presentation/controllers/update_password_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/screens/profile_screen.dart';
import 'package:pakland/core/utils/screen_helper.dart';

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
  String _confirmPasswordStrength = '';
  Color _confirmPasswordStrengthColor = Colors.grey;

  Map<String, String> _fieldErrors = {'oldPassword': '', 'newPassword': '', 'confirmPassword': ''};

  void _checkPasswordStrength(String password, bool isNew) {
    if (password.isEmpty) {
      setState(() {
        if (isNew) { _newPasswordStrength = ''; _newPasswordStrengthColor = Colors.grey; }
        else { _confirmPasswordStrength = ''; _confirmPasswordStrengthColor = Colors.grey; }
      });
      return;
    }
    bool hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLower = RegExp(r'[a-z]').hasMatch(password);
    bool hasNum = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    int types = [hasUpper, hasLower, hasNum, hasSpecial].where((b) => b).length;
    int len = password.length;

    String strength; Color color;
    if (len > 8 && types == 4) { strength = 'Strong'; color = Colors.green; }
    else if (len >= 8 && types >= 2) { strength = 'Average'; color = Colors.orange; }
    else { strength = 'Weak'; color = Colors.red; }

    setState(() {
      if (isNew) { _newPasswordStrength = strength; _newPasswordStrengthColor = color; }
      else { _confirmPasswordStrength = strength; _confirmPasswordStrengthColor = color; }
    });
  }

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() { _checkPasswordStrength(newPasswordController.text, true); });
    confirmPasswordController.addListener(() { _checkPasswordStrength(confirmPasswordController.text, false); });
  }

  @override
  void dispose() {
    oldPasswordController.dispose(); newPasswordController.dispose(); confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors = {'oldPassword': '', 'newPassword': '', 'confirmPassword': ''};
    if (oldPasswordController.text.isEmpty) { _fieldErrors['oldPassword'] = 'Please enter your old password'; isValid = false; }
    final newPass = newPasswordController.text.trim();
    if (newPass.isEmpty) { _fieldErrors['newPassword'] = 'Please enter a new password'; isValid = false; }
    else if (newPass.length < 8 || !RegExp(r'[A-Z]').hasMatch(newPass) || !RegExp(r'[a-z]').hasMatch(newPass) || !RegExp(r'[0-9]').hasMatch(newPass) || !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPass)) {
      _fieldErrors['newPassword'] = 'Password must be 8+ chars with uppercase, lowercase, number & special char'; isValid = false;
    }
    if (confirmPasswordController.text.isEmpty) { _fieldErrors['confirmPassword'] = 'Please confirm your password'; isValid = false; }
    else if (confirmPasswordController.text != newPasswordController.text) { _fieldErrors['confirmPassword'] = 'Passwords do not match'; isValid = false; }
    setState(() {});
    return isValid;
  }

  Future<void> _handleUpdate() async {
    if (_controller.isLoading.value || !_validateFields()) return;
    final savedPassword = await _storage.read(key: "user_password") ?? "";
    if (oldPasswordController.text.trim() != savedPassword) {
      setState(() => _fieldErrors['oldPassword'] = 'Old password does not match!');
      return;
    }
    bool success = await _controller.updatePassword(oldPasswordController.text.trim(), newPasswordController.text.trim(), context);
    if (success) { await Future.delayed(const Duration(milliseconds: 1600)); await _loginController.logout(); }
    else { oldPasswordController.clear(); newPasswordController.clear(); confirmPasswordController.clear(); }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async { Get.off(() => MainWrapper(initialIndex: 1)); return false; },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Change Password", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
          centerTitle: true, backgroundColor: AppColors.appColor,
          toolbarHeight: isTV ? 70 : kToolbarHeight,
          actions: [IconButton(icon: Icon(Icons.home, color: Colors.white, size: isTV ? 30 : 24), onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)))],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        resizeToAvoidBottomInset: true,
        body: isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(children: [
      Expanded(child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
        child: ListView(children: [
          SizedBox(height: size.height * 0.06),
          Center(child: Image.asset(ImageConstant.logo, height: size.height * 0.12)),
          SizedBox(height: size.height * 0.03),
          _buildFields(context, isTV: false),
        ]),
      )),
    ]);
  }

  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(children: [
      // Left — Logo
      Container(
        width: size.width * 0.3,
        color: Colors.white,
        child: Center(child: Image.asset(ImageConstant.logo, height: size.height * 0.3)),
      ),
      // Right — Form
      Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 24),
        child: _buildFields(context, isTV: true),
      )),
    ]);
  }

  Widget _buildFields(BuildContext context, {required bool isTV}) {
    final size = MediaQuery.of(context).size;
    final fieldHeight = isTV ? size.height * 0.07 : size.height * 0.05;
    final spacing = isTV ? 20.0 : size.height * 0.012;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Old Password
      CustomTextField(label: "Old Password", hintText: "Enter old password", imagePath: 'assets/images/passwords.png', controller: oldPasswordController, obscureText: true, showVisibilityIcon: true, borderRadius: 30, height: fieldHeight, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
      if (_fieldErrors['oldPassword']?.isNotEmpty ?? false)
        Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Text(_fieldErrors['oldPassword']!, style: TextStyle(color: Colors.red, fontSize: 12))),

      SizedBox(height: spacing),

      // New Password
      CustomTextField(label: "New Password", hintText: "Enter new password", imagePath: 'assets/images/passwords.png', controller: newPasswordController, obscureText: true, showVisibilityIcon: true, borderRadius: 30, height: fieldHeight, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
      if (_newPasswordStrength.isNotEmpty)
        Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Row(children: [
          Text('Strength: ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(_newPasswordStrength, style: TextStyle(fontSize: 12, color: _newPasswordStrengthColor, fontWeight: FontWeight.bold)),
        ])),
      if (_fieldErrors['newPassword']?.isNotEmpty ?? false)
        Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Text(_fieldErrors['newPassword']!, style: TextStyle(color: Colors.red, fontSize: 12))),

      SizedBox(height: spacing),

      // Confirm Password
      CustomTextField(label: "Confirm Password", hintText: "Re-enter new password", imagePath: 'assets/images/passwords.png', controller: confirmPasswordController, obscureText: true, showVisibilityIcon: true, borderRadius: 30, height: fieldHeight, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
      if (_confirmPasswordStrength.isNotEmpty)
        Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Row(children: [
          Text('Strength: ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(_confirmPasswordStrength, style: TextStyle(fontSize: 12, color: _confirmPasswordStrengthColor, fontWeight: FontWeight.bold)),
        ])),
      if (confirmPasswordController.text.isNotEmpty)
        Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Row(children: [
          Icon(newPasswordController.text == confirmPasswordController.text ? Icons.check_circle : Icons.error,
              color: newPasswordController.text == confirmPasswordController.text ? Colors.green : Colors.red, size: 16),
          SizedBox(width: 4),
          Text(newPasswordController.text == confirmPasswordController.text ? 'Passwords match' : 'Passwords do not match',
              style: TextStyle(fontSize: 12, color: newPasswordController.text == confirmPasswordController.text ? Colors.green : Colors.red)),
        ])),
      if (_fieldErrors['confirmPassword']?.isNotEmpty ?? false)
        Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Text(_fieldErrors['confirmPassword']!, style: TextStyle(color: Colors.red, fontSize: 12))),

      SizedBox(height: isTV ? 32 : size.height * 0.04),

      Center(child: SizedBox(
        width: isTV ? size.width * 0.2 : size.width * 0.48,
        height: fieldHeight,
        child: Obx(() => ElevatedButton(
          onPressed: _controller.isLoading.value ? null : _handleUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: _controller.isLoading.value ? AppColors.appColor.withOpacity(0.7) : AppColors.appColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _controller.isLoading.value
              ? SpinKitWave(color: Colors.white, size: 24.0)
              : Text("UPDATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isTV ? 18 : size.width * 0.045)),
        )),
      )),
      SizedBox(height: isTV ? 20 : size.height * 0.02),
    ]);
  }
}