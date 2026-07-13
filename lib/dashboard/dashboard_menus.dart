import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/dashboard/dashboard_menus/bookiong_screen.dart';
import 'package:pakland/dashboard/dashboard_menus/customer_portal_screen.dart';
import 'package:pakland/dashboard/dashboard_menus/downloads_screen.dart';
import 'package:pakland/dashboard/dashboard_menus/events_screen.dart';
import 'package:pakland/dashboard/dashboard_menus/privacy_policy_screen.dart';
import 'package:pakland/dashboard/dashboard_menus/sops_screen.dart';
import 'package:pakland/dashboard/sales_center_screen.dart';
import 'package:pakland/development_progress.dart';
import 'package:pakland/dashboard/dashboard_menus/online_payments_screen.dart';
import 'package:pakland/dashboard/dashboard_menus/social_screen.dart';
import '../bottom_app_bar/bottom_app_bar.dart';
import '../constants/image_constant.dart';
import '../controllers/get_company_controller.dart';
import '../controllers/theme_controller.dart';
import '../customs/login_check_util.dart';
import '../function/screen_helper.dart';
import '../status_bar_wrapper.dart';
import 'cms_components/cms_dashboard_screen.dart';
import 'dashboard_menus/bill_reg_no_screen.dart';
import 'dashboard_menus/check_form_number_screen.dart';
import 'dashboard_menus/payment_plans_screen.dart';
import '../login_screen.dart';

class DashboardMenus extends StatefulWidget {
  const DashboardMenus({super.key});

  @override
  State<DashboardMenus> createState() => _DashboardMenusState();
}

class _DashboardMenusState extends State<DashboardMenus> {
  final themeController = Get.find<ThemeController>();
  final companyController = Get.find<CompanyController>();
  final activeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.appColor, AppColors.lightAppColor],
  );

  late ScrollController _scrollController;
  bool _showDownArrow = true;

  Widget _getScreenForTab(String tabName) {
    switch (tabName.toLowerCase()) {
      case 'customer portal': return CustomerPortalScreen();
      case 'cms': return CMSDashboardScreen();
      case 'billing': return ClientListScreen();
      case 'booking': return BookingScreen();
      case 'payment plan': return PaymentPlanScreen();
      case 'social': return SocialScreen();
      case 'dev progress':
      case 'development progress': return GetDevelopmentProgressScreen();
      case 'events': return GetEventsScreen();
      case 'downloads': return DocumentsScreen();
      case 'sops': return SOPsScreen();
      case 'privacy policy': return PrivacyPolicyScreen();
      case 'form validation': return VerifyFormNumberScreen();
      default: return Container();
    }
  }

  bool _requiresLogin(String tabName) {
    return ['customer portal', 'cms', 'billing', 'online payments']
        .contains(tabName.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    themeController.updateStatusBar();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      setState(() => _showDownArrow = true);
    } else if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() => _showDownArrow = false);
    }
  }

  void _scrollTo(bool toBottom) {
    _scrollController.animateTo(
      toBottom ? _scrollController.position.maxScrollExtent : _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleNavigationWithLoginCheck(BuildContext context, Widget screen,
      {bool requiresLogin = false}) async {
    if (requiresLogin) {
      final isLoggedIn = await LoginCheckUtil.isUserLoggedIn();
      if (!isLoggedIn) {
        LoginCheckUtil.showLoginRequiredDialog(
          context,
          onYesPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          },
        );
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StatusBarWrapper(child: screen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarWrapper(child: _buildMainUI(context));
  }

  Widget _buildMainUI(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isTV = ScreenHelper.isTV(context);
    final int crossAxisCount = isTV ? 4 : 3;

    return Container(
      decoration: BoxDecoration(gradient: activeGradient),
      child: Obx(() {
        final tempTabs = companyController.mobileTabs;
        final tabs = tempTabs.where((tab) => tab['isActive'] == true).toList();

        if (companyController.isLoading.value && tabs.isEmpty) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (tabs.isEmpty) {
          return Center(
            child: Text('No menu items available',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: screenSize.height * 0.02,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isTV
                        ? screenSize.width * 0.03
                        : screenSize.width * 0.09,
                    mainAxisSpacing: screenSize.height * 0.02,
                    childAspectRatio: isTV ? 1.1 : 0.85,
                  ),
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final tabName = tab['home_menu_en'] ?? 'Unknown';
                    final iconPath = tab['icon']?.toString() ?? '';
                    return isTV
                        ? _TVMenuItem(
                      iconUrl: companyController.getFullImageUrl(iconPath),
                      text: tabName,
                      screenSize: screenSize,
                      onTap: () {
                        _handleNavigationWithLoginCheck(
                          context,
                          _getScreenForTab(tabName),
                          requiresLogin: _requiresLogin(tabName),
                        );
                      },
                    )
                        : _buildMobileMenuItem(context, iconPath, tabName);
                  },
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: screenSize.height * 0.1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.appColor.withOpacity(0.1),
                      AppColors.appColor.withOpacity(0.3),
                      AppColors.appColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Scroll arrow
            Positioned(
              bottom: screenSize.height * 0.02,
              left: 0, right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _scrollTo(_showDownArrow),
                  child: Container(
                    padding: EdgeInsets.all(screenSize.width * 0.015),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        _showDownArrow
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        key: ValueKey<bool>(_showDownArrow),
                        color: Colors.white,
                        size: screenSize.width * 0.06,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Mobile menu item — same as before
  Widget _buildMobileMenuItem(BuildContext context, String iconPath, String text) {
    final screenSize = MediaQuery.of(context).size;
    String fullImageUrl = companyController.getFullImageUrl(iconPath);
    final double containerSize = screenSize.width * 0.18;
    final double iconSize = containerSize * 0.6; // icon = 60% of container

    return InkWell(
      onTap: () {
        _handleNavigationWithLoginCheck(
          context,
          _getScreenForTab(text),
          requiresLogin: _requiresLogin(text),
        );
      },
      borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
              color: AppColors.whiteBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            // ClipRRect prevents image from going outside
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
              child: Center(
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                  fullImageUrl,
                  fit: BoxFit.contain,
                  width: iconSize,
                  height: iconSize,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.image_not_supported,
                    size: iconSize,
                    color: Colors.grey,
                  ),
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                )
                    : Icon(Icons.image_not_supported, size: iconSize, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.005),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * 0.25,
              maxHeight: screenSize.height * 0.06,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.width * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// TV Menu Item with focus
class _TVMenuItem extends StatefulWidget {
  final String iconUrl;
  final String text;
  final Size screenSize;
  final VoidCallback? onTap;

  const _TVMenuItem({
    required this.iconUrl,
    required this.text,
    required this.screenSize,
    required this.onTap,
  });

  @override
  State<_TVMenuItem> createState() => _TVMenuItemState();
}

class _TVMenuItemState extends State<_TVMenuItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final double containerSize = widget.screenSize.width * 0.09;
    final double iconSize = containerSize * 0.6;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isFocused ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.screenSize.width * 0.02),
                  color: AppColors.whiteBg,
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: _isFocused ? 20 : 4,
                      spreadRadius: _isFocused ? 3 : 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: _isFocused
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.screenSize.width * 0.02),
                  child: Center(
                    child: widget.iconUrl.isNotEmpty
                        ? Image.network(
                      widget.iconUrl,
                      fit: BoxFit.contain,
                      width: iconSize,
                      height: iconSize,
                      errorBuilder: (c, e, s) => Icon(
                        Icons.image_not_supported,
                        size: iconSize,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (c, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                    )
                        : Icon(Icons.image_not_supported, size: iconSize, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: widget.screenSize.height * 0.008),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.screenSize.width * 0.016,
                  fontWeight: FontWeight.bold,
                  color: _isFocused ? Colors.white : Colors.white70,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}