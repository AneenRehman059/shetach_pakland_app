import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/controllers/login_controller.dart';
import 'package:pakland/dashboard/main_screen.dart';
import 'package:pakland/dashboard/recent_activity_screen.dart';
import '../change_password_screen.dart';
import '../constants/api_constant.dart';
import '../constants/image_constant.dart';
import '../controllers/theme_controller.dart';
import '../customs/toast_message.dart';
import '../function/screen_helper.dart';
import '../help_support_screen.dart';
import '../personal_detail_screen.dart';
import 'faqs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final loginController = Get.find<LoginController>();
  final themeController = Get.find<ThemeController>();
  final Color menuBackgroundColor = AppColors.appColor;
  final storage = const FlutterSecureStorage();
  String? userName;
  String? email;
  String? profileImagePath;
  bool _isBiometricEnabled = false;
  StreamSubscription? _profileUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBiometricState();
    _profileUpdateSubscription = loginController.onProfileUpdate.listen((_) => _loadUserData());
  }

  @override
  void dispose() {
    _profileUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBiometricState() async {
    final saved = await storage.read(key: "biometric_enabled");
    setState(() => _isBiometricEnabled = saved == "true");
  }

  Future<void> _enableBiometricLogin() async {
    try {
      final auth = LocalAuthentication();
      if (!await auth.canCheckBiometrics && !await auth.isDeviceSupported()) {
        if (!mounted) return;
        showTopSnackBar(context, title: "Alert", "Biometric not supported.", Colors.red.withOpacity(0.7), icon: Icons.error);
        return;
      }
      final ok = await auth.authenticate(localizedReason: 'Enable biometric login', options: const AuthenticationOptions(biometricOnly: true));
      setState(() => _isBiometricEnabled = ok);
      if (ok) await storage.write(key: "biometric_enabled", value: "true");
    } catch (e) { setState(() => _isBiometricEnabled = false); }
  }

  Future<void> _disableBiometricLogin() async {
    setState(() => _isBiometricEnabled = false);
    await storage.delete(key: "biometric_enabled");
  }

  Future<void> _loadUserData() async {
    setState(() {
      userName = null; email = null;
    });
    userName = await storage.read(key: "user_name") ?? "Guest User";
    email = await storage.read(key: "email_no1") ?? "Not available";
    profileImagePath = await storage.read(key: "profile_image_path");
    if (mounted) setState(() {});
  }

  ImageProvider _getProfileImage() {
    if (profileImagePath == null || profileImagePath!.isEmpty) return AssetImage(ImageConstant.user_profile);
    if (profileImagePath!.startsWith('http')) return NetworkImage(profileImagePath!);
    return NetworkImage('${ApiConstants.baseUrl}/${profileImagePath!.replaceAll('\\', '/')}');
  }

  void _showLogoutDialog(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: w * 0.85, constraints: BoxConstraints(maxWidth: 400, maxHeight: h * 0.4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/logout.png', height: h * 0.06, width: h * 0.06, fit: BoxFit.contain),
          SizedBox(height: h * 0.012),
          Text("Logout", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: h * 0.008),
          Text("Are you sure you want to logout?", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black54)),
          SizedBox(height: h * 0.02),
          Row(children: [
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: EdgeInsets.symmetric(vertical: h * 0.015)), onPressed: () => Get.back(), child: Text("Cancel"))),
            SizedBox(width: w * 0.02),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: EdgeInsets.symmetric(vertical: h * 0.015)), onPressed: () async { Get.back(); await loginController.logout(); }, child: Text("Logout"))),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final w = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async { Get.back(); return false; },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 20)),
          centerTitle: true, backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: isTV ? 70 : kToolbarHeight,
        ),
        body: isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.02, horizontal: w * 0.04),
        child: Column(children: [
          CircleAvatar(radius: w * 0.12, backgroundImage: _getProfileImage(), onBackgroundImageError: (e, s) => setState(() => profileImagePath = null)),
          SizedBox(height: h * 0.01),
          Text(userName ?? "Loading...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: h * 0.005),
          Text(email ?? "Loading...", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
      Expanded(child: SingleChildScrollView(child: _buildMenuItems(context, isTV: false))),
    ]);
  }

  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(children: [
      // Left profile panel
      Container(
        width: size.width * 0.25,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(radius: size.width * 0.06, backgroundImage: _getProfileImage(), onBackgroundImageError: (e, s) => setState(() => profileImagePath = null)),
          SizedBox(height: 8),
          Text(userName ?? "Loading...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: 4),
          Text(email ?? "Loading...", style: TextStyle(color: Colors.black54, fontSize: 13), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
      // Right menu
      Expanded(child: SingleChildScrollView(child: _buildMenuItems(context, isTV: true))),
    ]);
  }

  Widget _buildMenuItems(BuildContext context, {required bool isTV}) {
    final h = MediaQuery.of(context).size.height;
    return Column(children: [
      Container(
        width: double.infinity,
        color: menuBackgroundColor,
        child: Column(children: [
          _menuTile(context, 'assets/images/detail.png', 'Personal Details', isTV: isTV,
              onTap: () async { final r = await Get.to(() => EditProfileScreen()); if (r == true) await _loadUserData(); }),
          Divider(color: Colors.black38, height: 1),
          _menuTile(context, 'assets/images/history.png', 'Recent Activity', isTV: isTV, onTap: () => Get.to(() => RecentActivityScreen())),
          Divider(color: Colors.black38, height: 1),
          _menuTile(context, 'assets/images/passwords.png', 'Change Password', isTV: isTV, onTap: () => Get.to(() => ChangePasswordScreen())),
          Divider(color: Colors.black38, height: 1),
          _biometricTile(context, isTV: isTV),
          Divider(color: Colors.black38, height: 1),
          _menuTile(context, 'assets/images/supp.png', 'Help & Feedback', isTV: isTV, onTap: () => Get.to(() => HelpSupportScreen())),
          Divider(color: Colors.black38, height: 1),
          _menuTile(context, 'assets/images/faqs.png', 'FAQs', isTV: isTV, onTap: () => Get.to(() => FaqScreen())),
          Divider(color: Colors.black38, height: 1),
        ]),
      ),
      SizedBox(height: h * 0.02),
      Container(
        width: double.infinity,
        color: Theme.of(context).cardColor,
        child: Column(children: [
          _menuTile(context, 'assets/images/logout.png', 'Logout', isTV: isTV,
              textColor: Theme.of(context).textTheme.bodyLarge!.color!, onTap: () => _showLogoutDialog(context)),
          Divider(color: Colors.black38, height: 1),
          _menuTile(context, 'assets/images/delete.png', 'Delete Account', isTV: isTV,
              textColor: Theme.of(context).textTheme.bodyLarge!.color!, onTap: () {}),
          Divider(color: Colors.black38, height: 1),
          SizedBox(height: h * 0.01),
        ]),
      ),
    ]);
  }

  Widget _menuTile(BuildContext context, String imagePath, String title, {
    required bool isTV, required VoidCallback onTap, Color? textColor,
  }) {
    if (!isTV) {
      // Mobile — same original
      final w = MediaQuery.of(context).size.width;
      final h = MediaQuery.of(context).size.height;
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.012),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300, width: 2)),
              child: Image.asset(imagePath, height: 22, width: 22, fit: BoxFit.contain),
            ),
            SizedBox(width: w * 0.04),
            Expanded(child: Text(title, style: TextStyle(color: textColor ?? Colors.white, fontSize: 16, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, color: textColor ?? Colors.white, size: 20),
          ]),
        ),
      );
    }

    // TV — with focus highlight
    return _TVMenuTile(imagePath: imagePath, title: title, textColor: textColor, onTap: onTap);
  }

  Widget _biometricTile(BuildContext context, {required bool isTV}) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final iconSize = isTV ? 26.0 : 22.0;
    final fontSize = isTV ? 18.0 : 16.0;

    final content = Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300, width: 2)),
        child: Image.asset('assets/images/fingerprint.png', height: iconSize, width: iconSize, fit: BoxFit.contain),
      ),
      SizedBox(width: w * 0.04),
      Expanded(child: Text('Biometric Login', style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500))),
      Transform.scale(scale: 0.8, child: Switch(
        value: _isBiometricEnabled, activeColor: Colors.greenAccent,
        onChanged: (v) async { if (v) await _enableBiometricLogin(); else await _disableBiometricLogin(); },
      )),
    ]);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: isTV ? 14 : h * 0.012),
      child: content,
    );
  }
}

// TV Menu Tile with focus
class _TVMenuTile extends StatefulWidget {
  final String imagePath;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _TVMenuTile({required this.imagePath, required this.title, this.textColor, required this.onTap});

  @override
  State<_TVMenuTile> createState() => _TVMenuTileState();
}

class _TVMenuTileState extends State<_TVMenuTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: _isFocused ? Colors.white.withOpacity(0.15) : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 14),
            child: Row(children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 150),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isFocused ? AppColors.appColor : Colors.grey.shade300, width: 2),
                  boxShadow: _isFocused ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 8)] : [],
                ),
                child: Image.asset(widget.imagePath, height: 26, width: 26, fit: BoxFit.contain),
              ),
              SizedBox(width: w * 0.03),
              Expanded(child: Text(widget.title,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 18,
                    fontWeight: _isFocused ? FontWeight.bold : FontWeight.w500,
                  ))),
              Icon(Icons.arrow_forward_ios, color: _isFocused ? Colors.white : (widget.textColor ?? Colors.white70), size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}