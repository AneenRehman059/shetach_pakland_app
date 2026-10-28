import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/features/billing/presentation/controllers/pay_online_controller.dart';
import 'package:pakland/features/dashboard/presentation/screens/main_screen.dart';
import 'package:pakland/features/recent_activity/presentation/screens/recent_activity_screen.dart';
import 'package:pakland/features/auth/presentation/screens/change_password_screen.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/controllers/theme_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/feedback/presentation/screens/feedback_screen.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:pakland/features/profile/presentation/screens/personal_detail_screen.dart';
import 'package:pakland/features/faqs/presentation/screens/faqs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final loginController = Get.find<LoginController>();
  final themeController = Get.find<ThemeController>();

  final payOnlineController = Get.isRegistered<PayOnlineController>()
      ? Get.find<PayOnlineController>()
      : Get.put(PayOnlineController());

  final Color menuBackgroundColor = AppColors.appColor;
  final storage = const FlutterSecureStorage();
  String? userName;
  String? email;
  String? profileImagePath;
  bool _isBiometricEnabled = false;
  String? _cachedClientImageUrl;
  StreamSubscription? _profileUpdateSubscription;
  Worker? _clientDetailWorker;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBiometricState();
    _loadCachedClientImageUrl();
    _loadClientImage();
    _profileUpdateSubscription = loginController.onProfileUpdate.listen((_) => _loadUserData());

    _clientDetailWorker = ever(payOnlineController.clientDetailModel, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _profileUpdateSubscription?.cancel();
    _clientDetailWorker?.dispose();
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

  Future<void> _loadCachedClientImageUrl() async {
    final saved = await storage.read(key: "cached_client_image_url");
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _cachedClientImageUrl = saved);
    }
  }

  Future<void> _loadClientImage() async {
    final username = await storage.read(key: "user_id") ?? "";
    const brnCode = '0000';

    if (username.isNotEmpty) {
      await payOnlineController.fetchClientDetails(
        username: username,
        brnCode: brnCode,
        blockNo: '',
        plotNo: '',
      );

      final resolvedUrl = _resolveClientImageUrl();
      if (resolvedUrl != null) {
        await storage.write(key: "cached_client_image_url", value: resolvedUrl);
        if (mounted) setState(() => _cachedClientImageUrl = resolvedUrl);
      }
    }
  }

  String? _resolveClientImageUrl() {
    final clientImage = payOnlineController.clientDetailModel.value?.obj.image;
    if (clientImage == null || clientImage.isEmpty) return null;
    final normalizedPath = clientImage.replaceAll('\\', '/');
    final rawUrl = normalizedPath.startsWith('http')
        ? normalizedPath
        : '${ApiConstants.baseUrl}/$normalizedPath'.replaceAll(RegExp(r'(?<!:)//+'), '/');
    return Uri.encodeFull(rawUrl);
  }

  ImageProvider _getProfileImage() {
    final freshUrl = _resolveClientImageUrl();
    if (freshUrl != null) {
      return CachedNetworkImageProvider(freshUrl);
    }

    if (_cachedClientImageUrl != null && _cachedClientImageUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(_cachedClientImageUrl!);
    }

    if (profileImagePath == null || profileImagePath!.isEmpty) return AssetImage(ImageConstant.user_profile);
    if (profileImagePath!.startsWith('http')) return CachedNetworkImageProvider(profileImagePath!);
    return CachedNetworkImageProvider('${ApiConstants.baseUrl}/${profileImagePath!.replaceAll('\\', '/')}');
  }

  Future<void> _openEditProfile() async {
    final r = await Get.to(() => EditProfileScreen());
    if (r == true) await _loadUserData();
  }

  void _showLogoutDialog(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: w * 0.85, constraints: BoxConstraints(maxWidth: 400, maxHeight: h * 0.4),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle),
            child: Image.asset('assets/images/logout.png', height: h * 0.05, width: h * 0.05, fit: BoxFit.contain),
          ),
          SizedBox(height: h * 0.016),
          const Text("Logout", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
          SizedBox(height: h * 0.008),
          Text("Are you sure you want to logout?", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.5, color: Colors.black54, height: 1.4)),
          SizedBox(height: h * 0.024),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.symmetric(vertical: h * 0.015),
                ),
                onPressed: () => Get.back(),
                child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade200,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.symmetric(vertical: h * 0.015),
                ),
                onPressed: () async { Get.back(); await loginController.logout(); },
                child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    return WillPopScope(
      onWillPop: () async { Get.back(); return false; },
      child: Scaffold(
        backgroundColor: isTV ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF4F6FB),
        appBar: isTV
            ? null
            : AppHeaderBar(
                title: const Text('Profile'),
                subtitle: 'Manage your account',
                // Profile is a bottom-nav tab -> never show a back arrow
                automaticallyImplyLeading: false,
              ),
        body: isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(size.width * 0.04, 18, size.width * 0.04, 0),
          child: _buildProfileCard(context, size),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: bottomPadding + size.height * 0.03,
              left: size.width * 0.04,
              right: size.width * 0.04,
            ),
            child: _buildMenuItems(context, isTV: false),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, Size size) {
    final w = size.width;
    const ink = Color(0xFF1B2733);
    const muted = Color(0xFF6B7785);

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.055),
        border: Border.all(color: const Color(0xFFE8ECF4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.appColor, AppColors.lightAppColor],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: CircleAvatar(
                    radius: w * 0.095,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getProfileImage(),
                    onBackgroundImageError: (e, s) => setState(() => profileImagePath = null),
                  ),
                ),
              ),

            ],
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? "Loading...",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: w * 0.047,
                    color: ink,
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.mail_outline_rounded, size: 14, color: muted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        email ?? "Loading...",
                        style: TextStyle(
                          color: muted,
                          fontWeight: FontWeight.w500,
                          fontSize: w * 0.03,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTVAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.82)],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(children: [

          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Manage your account',
                  style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _TVHeaderIconButton(
            icon: Icons.edit_rounded,
            onTap: () async {
              final r = await Get.to(() => EditProfileScreen());
              if (r == true) await _loadUserData();
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(children: [
      _buildTVAppBar(context),
      Expanded(
        child: Row(children: [
          Container(
            width: size.width * 0.25,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.appColor.withOpacity(0.9), AppColors.appColor.withOpacity(0.4)]),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: CircleAvatar(radius: size.width * 0.06, backgroundColor: Colors.grey.shade200, backgroundImage: _getProfileImage(), onBackgroundImageError: (e, s) => setState(() => profileImagePath = null)),
                ),
              ),
              const SizedBox(height: 14),
              Text(userName ?? "Loading...", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.appColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Text(email ?? "Loading...", style: TextStyle(color: AppColors.appColor, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildMenuItems(context, isTV: true))),
        ]),
      ),
    ]);
  }

  Widget _buildMenuItems(BuildContext context, {required bool isTV}) {
    final h = MediaQuery.of(context).size.height;
    final horizontalPad = isTV ? 0.0 : MediaQuery.of(context).size.width * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad),
      child: Column(children: [
        _sectionLabel("ACCOUNT"),
        _cardGroup([
          _menuTile(context, 'assets/images/detail.png', 'Personal Details', isTV: isTV,
              onTap: () async { final r = await Get.to(() => EditProfileScreen()); if (r == true) await _loadUserData(); }),
          _menuTile(context, 'assets/images/history.png', 'Recent Activity', isTV: isTV, onTap: () => Get.to(() => RecentActivityScreen())),
          _menuTile(context, 'assets/images/passwords.png', 'Change Password', isTV: isTV, onTap: () => Get.to(() => ChangePasswordScreen())),
          _biometricTile(context, isTV: isTV),
        ], isTV: isTV),

        SizedBox(height: h * 0.024),
        _sectionLabel("SUPPORT"),
        _cardGroup([
          _menuTile(context, 'assets/images/supp.png', 'Help & Feedback', isTV: isTV, onTap: () => Get.to(() => HelpSupportScreen())),
          _menuTile(context, 'assets/images/faqs.png', 'FAQs', isTV: isTV, onTap: () => Get.to(() => FaqScreen())),
        ], isTV: isTV),

        SizedBox(height: h * 0.024),
        _cardGroup(danger: true, [
          _menuTile(context, 'assets/images/logout.png', 'Logout', isTV: isTV,
              iconColor: Colors.redAccent.shade200, textColor: Colors.redAccent.shade200, onTap: () => _showLogoutDialog(context)),
          _menuTile(context, 'assets/images/delete.png', 'Delete Account', isTV: isTV,
              iconColor: Colors.redAccent.shade200, textColor: Colors.redAccent.shade200, onTap: () {}),
        ], isTV: isTV),
        SizedBox(height: h * 0.02),
      ]),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Row(children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.grey.shade600)),
      ]),
    );
  }

  Widget _cardGroup(List<Widget> children, {required bool isTV, bool danger = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isTV ? Theme.of(Get.context!).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isTV
            ? null
            : Border.all(
                color: danger ? Colors.redAccent.withOpacity(0.18) : const Color(0xFFE8ECF4),
                width: 1,
              ),
        boxShadow: isTV
            ? []
            : [BoxShadow(color: AppColors.appColor.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 66),
                  child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context, String imagePath, String title, {
    required bool isTV, required VoidCallback onTap, Color? textColor, Color? iconColor,
  }) {
    if (!isTV) {
      final accent = iconColor ?? AppColors.appColor;
      return InkWell(
        onTap: onTap,
        splashColor: accent.withOpacity(0.08),
        highlightColor: accent.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Image.asset(imagePath, height: 21, width: 21, fit: BoxFit.contain),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor ?? const Color(0xFF1B2733),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: (textColor ?? Colors.grey).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: textColor?.withOpacity(0.8) ?? Colors.grey.shade500,
                size: 20,
              ),
            ),
          ]),
        ),
      );
    }

    return _TVMenuTile(imagePath: imagePath, title: title, textColor: textColor, iconColor: iconColor, onTap: onTap);
  }

  Widget _biometricTile(BuildContext context, {required bool isTV}) {
    final iconSize = isTV ? 26.0 : 20.0;
    final fontSize = isTV ? 18.0 : 15.5;

    final content = Row(children: [
      Container(
        width: isTV ? 46 : 42,
        height: isTV ? 46 : 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.appColor.withOpacity(0.09), borderRadius: BorderRadius.circular(13)),
        child: Image.asset('assets/images/fingerprint.png', height: iconSize, width: iconSize, fit: BoxFit.contain),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text('Biometric Login', style: TextStyle(color: const Color(0xFF1B2733), fontSize: fontSize, fontWeight: isTV ? FontWeight.w500 : FontWeight.w600))),
      Transform.scale(scale: 0.85, child: Switch(
        value: _isBiometricEnabled,
        activeColor: Colors.white,
        activeTrackColor: AppColors.appColor,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
        onChanged: (v) async { if (v) await _enableBiometricLogin(); else await _disableBiometricLogin(); },
      )),
    ]);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isTV ? 14 : 8),
      child: content,
    );
  }
}

class _TVHeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TVHeaderIconButton({required this.icon, required this.onTap});

  @override
  State<_TVHeaderIconButton> createState() => _TVHeaderIconButtonState();
}

class _TVHeaderIconButtonState extends State<_TVHeaderIconButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _isFocused ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _TVMenuTile extends StatefulWidget {
  final String imagePath;
  final String title;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _TVMenuTile({required this.imagePath, required this.title, this.textColor, this.iconColor, required this.onTap});

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
        duration: const Duration(milliseconds: 150),
        color: _isFocused ? AppColors.appColor.withOpacity(0.08) : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.015, vertical: 14),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: (widget.iconColor ?? AppColors.appColor).withOpacity(_isFocused ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: _isFocused ? Border.all(color: widget.iconColor ?? AppColors.appColor, width: 1.5) : null,
                ),
                child: Image.asset(widget.imagePath, height: 24, width: 24, fit: BoxFit.contain,
                    color: widget.iconColor, colorBlendMode: widget.iconColor != null ? BlendMode.srcIn : null),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(widget.title,
                  style: TextStyle(
                    color: widget.textColor ?? const Color(0xFF1E1E1E),
                    fontSize: 17,
                    fontWeight: _isFocused ? FontWeight.w700 : FontWeight.w500,
                  ))),
              Icon(Icons.chevron_right_rounded, color: _isFocused ? (widget.iconColor ?? AppColors.appColor) : Colors.grey.shade400, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}