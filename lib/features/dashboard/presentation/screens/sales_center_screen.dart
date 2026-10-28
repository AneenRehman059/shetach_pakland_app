import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/utils/screen_helper.dart';

class _Palette {
  static const bg = Color(0xFFF6F7FB);
  static const cardBg = Colors.white;
  static const ink = Color(0xFF14181F);
  static const inkMuted = Color(0xFF6B7280);
  static const inkFaint = Color(0xFF9AA1AC);
  static const hairline = Color(0xFFE7E9F0);
  static const whatsapp = Color(0xFF1FAF56);
  static const gold = Color(0xFFC9A24B);
}

class SalesCenterScreen extends StatefulWidget {
  const SalesCenterScreen({super.key});
  @override
  State<SalesCenterScreen> createState() => _SalesCenterScreenState();
}

class _SalesCenterScreenState extends State<SalesCenterScreen> {
  final SocialController socialController = Get.put(SocialController());
  final CompanyController companyController = Get.find<CompanyController>();

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final mediaQuery = MediaQuery.of(context);
    final w = mediaQuery.size.width;
    final h = mediaQuery.size.height;
    final padding = mediaQuery.padding;

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => MainWrapper());
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.appColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _Palette.bg,
          body: isTV
              ? _buildTVScaffold(w, h)
              : _buildMobileScaffold(w, h, padding),
        ),
      ),
    );
  }

  Widget _buildMobileScaffold(double w, double h, EdgeInsets padding) {
    return Column(
      children: [
        _buildHeader(w, h, padding),
        Expanded(
          child: Obx(() {
            if (socialController.isLoading.value) {
              return _buildLoadingState(w, false);
            }
            if (socialController.branches.isEmpty) {
              return _buildEmptyState(w);
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  w * 0.045, h * 0.024, w * 0.045, h * 0.04),
              itemCount: socialController.branches.length,
              itemBuilder: (context, index) {
                final branch = socialController.branches[index];
                final whatsapp = (branch['phone_no'] ?? '').toString();
                return Padding(
                  padding: EdgeInsets.only(bottom: h * 0.02),
                  child: _BranchCard(
                    name: branch['brn_name'] ?? '',
                    address: _formatAddress(branch),
                    phone: branch['phone_no'] ?? '',
                    email: branch['email_address'] ?? '',
                    whatsapp: whatsapp,
                    screenWidth: w,
                    onCall: () => _makePhoneCall(branch['phone_no'] ?? ''),
                    onEmail: () => _sendEmail(branch['email_address'] ?? ''),
                    onWhatsApp: () => _openWhatsApp(whatsapp),
                    onMap: () => _openMaps(
                      branch['latitude'] ?? '',
                      branch['longitude'] ?? '',
                      _formatAddress(branch),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(double w, double h, EdgeInsets padding) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.30),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -w * 0.22,
            right: -w * 0.16,
            child: Container(
              width: w * 0.6,
              height: w * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -w * 0.28,
            left: -w * 0.12,
            child: Container(
              width: w * 0.42,
              height: w * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.045),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(w * 0.03, h * 0.012, w * 0.045, h * 0.026),
              child: Row(
                children: [

                  SizedBox(width: w * 0.032),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Centers',
                          style: TextStyle(
                            fontSize: w * 0.056,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: h * 0.004),
                        Text(
                          'Reach our team, wherever you are',
                          style: TextStyle(
                            fontSize: w * 0.031,
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: w * 0.032, vertical: h * 0.009),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(w * 0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(ImageConstant.sales,
                            color: Colors.white.withOpacity(0.95),
                            height: w * 0.038,
                            width: w * 0.038),
                        SizedBox(width: w * 0.016),
                        Text(
                          '${socialController.branches.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: w * 0.034,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(double w, bool isTV) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/images/loading.json',
            width: isTV ? 180 : 150,
            height: isTV ? 180 : 150,
          ),
          SizedBox(height: isTV ? 20 : 16),
          Text(
            'Loading sales centers…',
            style: TextStyle(
              color: _Palette.inkMuted,
              fontWeight: FontWeight.w600,
              fontSize: isTV ? 20 : w * 0.033,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double w) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.065),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.appColor.withOpacity(0.12),
                  AppColors.appColor.withOpacity(0.015),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Image.asset(ImageConstant.sales,
                height: w * 0.14, width: w * 0.14, color: AppColors.appColor),
          ),
          SizedBox(height: w * 0.055),
          Text(
            'No sales centers found',
            style: TextStyle(
              color: _Palette.ink,
              fontWeight: FontWeight.w800,
              fontSize: w * 0.047,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: w * 0.022),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.14),
            child: Text(
              'Please check back later or contact support for branch details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Palette.inkFaint,
                fontSize: w * 0.033,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTVScaffold(double w, double h) {
    return Column(
      children: [
        _buildTVAppBar(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(ImageConstant.sales, height: 20, width: 20, color: AppColors.appColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Main Offices',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: _Palette.ink,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (socialController.isLoading.value) {
              return _buildLoadingState(w, true);
            }
            if (socialController.branches.isEmpty) {
              return _buildEmptyState(w);
            }
            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: w * 0.03,
                mainAxisSpacing: h * 0.025,
                childAspectRatio: 1.7,
              ),
              itemCount: socialController.branches.length,
              itemBuilder: (context, index) {
                final branch = socialController.branches[index];
                final whatsapp = (branch['phone_no'] ?? '').toString();
                return _TVBranchCard(
                  branch: branch,
                  whatsapp: whatsapp,
                  onCall: () => _makePhoneCall(branch['phone_no'] ?? ''),
                  onEmail: () => _sendEmail(branch['email_address'] ?? ''),
                  onWhatsApp: () => _openWhatsApp(whatsapp),
                  onMap: () => _openMaps(branch['latitude'] ?? '', branch['longitude'] ?? '', _formatAddress(branch)),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTVAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
          ],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.30), blurRadius: 22, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [

            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sales Centers',
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Reach our team, wherever you are',
                    style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> branch) {
    List<String> parts = [];
    void add(String? v) {
      if (v != null && v.trim().isNotEmpty) parts.add(v.trim());
    }

    add(branch['add_1']);
    add(branch['add_2']);
    add(branch['add_3']);
    add(branch['add_4']);
    return parts.join(', ');
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone) async {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = '92${digits.substring(1)}';
    }
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMaps(String lat, String lng, String address) async {
    if (lat.isEmpty || lng.isEmpty) {
      await _openMapsAddr(address);
      return;
    }
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await _openMapsAddr(address);
    }
  }

  Future<void> _openMapsAddr(String address) async {
    final enc = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$enc');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _BranchCard extends StatefulWidget {
  final String name, address, phone, email, whatsapp;
  final double screenWidth;
  final VoidCallback onCall, onEmail, onWhatsApp, onMap;

  const _BranchCard({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.whatsapp,
    required this.screenWidth,
    required this.onCall,
    required this.onEmail,
    required this.onWhatsApp,
    required this.onMap,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final w = widget.screenWidth;
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _Palette.cardBg,
          borderRadius: BorderRadius.circular(w * 0.05),
          border: Border.all(color: _Palette.hairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: w * 0.042, vertical: w * 0.034),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.appColor,
                    Color.lerp(AppColors.appColor, Colors.black, 0.22)!,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(w * 0.021),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(w * 0.026),
                    ),
                    child: Image.asset(ImageConstant.sales,
                        height: w * 0.05, width: w * 0.05, color: Colors.white),
                  ),
                  SizedBox(width: w * 0.032),
                  Expanded(
                    child: Text(
                      widget.name.trim(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.043,
                        letterSpacing: 0.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2.5,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _Palette.gold.withOpacity(0.0),
                    _Palette.gold.withOpacity(0.85),
                    _Palette.gold.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.042, w * 0.038, w * 0.042, w * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.address.isNotEmpty) ...[
                    _ContactRow(
                      imagePath: ImageConstant.map,
                      label: widget.address,
                      screenWidth: w,
                      onTap: widget.onMap,
                      onHighlight: _setPressed,
                      trailing: Icon(Icons.chevron_right_rounded,
                          color: _Palette.inkFaint, size: w * 0.05),
                    ),
                    _fadeDivider(w),
                  ],
                  if (widget.phone.isNotEmpty) ...[
                    _ContactRow(
                        icon: Icons.phone_rounded,
                        label: widget.phone,
                        screenWidth: w,
                        onTap: widget.onCall,
                        onHighlight: _setPressed),
                    _fadeDivider(w),
                  ],
                  if (widget.email.isNotEmpty) ...[
                    _ContactRow(
                        icon: Icons.email_rounded,
                        label: widget.email,
                        screenWidth: w,
                        onTap: widget.onEmail,
                        onHighlight: _setPressed),
                  ],
                  if (widget.whatsapp.isNotEmpty) ...[
                    _fadeDivider(w),
                    _ContactRow(
                      imagePath: ImageConstant.whatsapp,
                      label: widget.whatsapp,
                      screenWidth: w,
                      onTap: widget.onWhatsApp,
                      onHighlight: _setPressed,
                      iconColor: _Palette.whatsapp,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fadeDivider(double w) => Padding(
    padding: EdgeInsets.symmetric(vertical: w * 0.008),
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _Palette.hairline,
            _Palette.hairline,
            Colors.transparent,
          ],
          stops: const [0.0, 0.06, 0.94, 1.0],
        ),
      ),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final double screenWidth;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing;
  final ValueChanged<bool>? onHighlight;

  const _ContactRow({
    this.icon,
    this.imagePath,
    required this.label,
    required this.screenWidth,
    required this.onTap,
    this.iconColor,
    this.trailing,
    this.onHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final w = screenWidth;
    final color = iconColor ?? AppColors.appColor;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(w * 0.03),
      child: InkWell(
        borderRadius: BorderRadius.circular(w * 0.03),
        onTap: onTap,
        onHighlightChanged: onHighlight,
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: w * 0.018, horizontal: w * 0.008),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.024),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(w * 0.028),
                ),
                child: imagePath != null
                    ? Image.asset(imagePath!,
                    height: w * 0.044, width: w * 0.044)
                    : Icon(icon, size: w * 0.044, color: color),
              ),
              SizedBox(width: w * 0.032),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: w * 0.0355,
                    color: _Palette.ink,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _TVBranchCard extends StatefulWidget {
  final Map<String, dynamic> branch;
  final String whatsapp;
  final VoidCallback onCall, onEmail, onWhatsApp, onMap;

  const _TVBranchCard({
    required this.branch,
    required this.whatsapp,
    required this.onCall,
    required this.onEmail,
    required this.onWhatsApp,
    required this.onMap,
  });

  @override
  State<_TVBranchCard> createState() => _TVBranchCardState();
}

class _TVBranchCardState extends State<_TVBranchCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.branch['brn_name'] ?? '';
    final phone = widget.branch['phone_no'] ?? '';
    final email = widget.branch['email_address'] ?? '';
    final address = [
      widget.branch['add_1'],
      widget.branch['add_2'],
      widget.branch['add_3'],
      widget.branch['add_4'],
    ].where((v) => v != null && v.toString().trim().isNotEmpty).join(', ');

    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) => KeyEventResult.ignored,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: _isFocused
            ? (Matrix4.identity()..scale(1.015))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isFocused ? AppColors.appColor : _Palette.hairline,
            width: _isFocused ? 2.5 : 1,
          ),
          boxShadow: _isFocused
              ? [BoxShadow(color: AppColors.appColor.withOpacity(0.28), blurRadius: 22, spreadRadius: 1)]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.appColor,
                    Color.lerp(AppColors.appColor, Colors.black, 0.22)!,
                  ],
                ),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(8)),
                  child: Image.asset(ImageConstant.sales, height: 18, width: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (address.isNotEmpty)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(ImageConstant.map, height: 18, width: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(fontSize: 13, color: _Palette.ink, height: 1.35),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    const SizedBox(height: 10),
                    Row(children: [
                      if (phone.isNotEmpty) _btn(Icons.phone_rounded, 'Call', widget.onCall),
                      if (phone.isNotEmpty) const SizedBox(width: 6),
                      if (email.isNotEmpty) _btn(Icons.email_rounded, 'Email', widget.onEmail),
                      if (email.isNotEmpty) const SizedBox(width: 6),
                      if (widget.whatsapp.isNotEmpty) _btn(Icons.chat_bubble_rounded, 'WA', widget.onWhatsApp, color: _Palette.whatsapp, imagePath: ImageConstant.whatsapp),
                      if (widget.whatsapp.isNotEmpty) const SizedBox(width: 6),
                      _btn(Icons.navigation_rounded, 'Map', widget.onMap, imagePath: ImageConstant.map),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap, {Color? color, String? imagePath}) {
    final c = color ?? AppColors.appColor;
    return Expanded(
      child: Material(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imagePath != null
                    ? Image.asset(imagePath, height: 18, width: 18)
                    : Icon(icon, color: c, size: 18),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 10.5, color: c, fontWeight: FontWeight.w700, letterSpacing: 0.1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TVIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TVIconBtn({required this.icon, required this.onTap});
  @override
  State<_TVIconBtn> createState() => _TVIconBtnState();
}

class _TVIconBtnState extends State<_TVIconBtn> {
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