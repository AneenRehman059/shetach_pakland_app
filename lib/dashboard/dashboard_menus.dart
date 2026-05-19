import 'package:flutter/material.dart';
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
    colors: [
      AppColors.appColor,
      AppColors.lightAppColor,
    ],
  );

  late ScrollController _scrollController;
  bool _showDownArrow = true;

  // Map to handle navigation based on tab_name
  Widget _getScreenForTab(String tabName) {
    switch (tabName.toLowerCase()) {
      case 'customer portal':
        return CustomerPortalScreen();
      case 'cms':
        return CMSDashboardScreen();
      case 'billing':
        return ClientListScreen();
      case 'booking':
        return BookingScreen();
      case 'payment plan':
        return PaymentPlanScreen();
      case 'social':
        return SocialScreen();
      case 'dev progress':
      case 'development progress':
        return GetDevelopmentProgressScreen();
      case 'events':
        return GetEventsScreen();
      case 'downloads':
        return DocumentsScreen();
      case 'sops':
        return SOPsScreen();
      case 'privacy policy':
        return PrivacyPolicyScreen();
      case 'form validation':
        return VerifyFormNumberScreen();
      default:
        return Container(); // Fallback
    }
  }

  // Check if screen requires login
  bool _requiresLogin(String tabName) {
    final loginRequiredTabs = [
      'customer portal',
      'cms',
      'billing',
      'online payments',
    ];
    return loginRequiredTabs.contains(tabName.toLowerCase());
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

  void _handleNavigationWithLoginCheck(BuildContext context, Widget screen, {bool requiresLogin = false}) async {
    if (requiresLogin) {
      final isLoggedIn = await LoginCheckUtil.isUserLoggedIn();

      if (!isLoggedIn) {
        LoginCheckUtil.showLoginRequiredDialog(
          context,
          onYesPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatusBarWrapper(child: screen)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarWrapper(
      child: _buildMainUI(context),
    );
  }

  Widget _buildMainUI(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide > 600;

    return Container(
      decoration: BoxDecoration(
        gradient: activeGradient,
      ),
      child: Obx(() {
        final tempTabs = companyController.mobileTabs;
        final temp=[];
        for(var tab in tempTabs){
          if(tab['isActive']==true){
            temp.add(tab);
          }
        }

        final tabs = temp;

        if (companyController.isLoading.value && tabs.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (tabs.isEmpty) {
          return Center(
            child: Text(
              'No menu items available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
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
                    crossAxisCount: isTablet ? 3 : 3,
                    crossAxisSpacing: screenSize.width * 0.09,
                    mainAxisSpacing: screenSize.height * 0.01,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final tabName = tab['home_menu_en'] ?? tab['home_menu_en'] ?? 'Unknown';
                    final iconPath = tab['icon']?.toString() ?? '';
                    final isActive = tab['isActive'] ?? true;

                    // // Skip inactive tabs
                    // if (!isActive) return SizedBox.shrink();

                    return _buildMenuItem(
                      context,
                      iconPath,
                      tabName,
                      onTap: () {
                        final screen = _getScreenForTab(tabName);
                        final requiresLogin = _requiresLogin(tabName);
                        _handleNavigationWithLoginCheck(
                          context,
                          screen,
                          requiresLogin: requiresLogin,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
            Positioned(
              bottom: screenSize.height * 0.02,
              left: 0,
              right: 0,
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
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _showDownArrow ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
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

  Widget _buildMenuItem(BuildContext context, String iconPath, String text, {VoidCallback? onTap}) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide > 600;

    // Get full image URL from controller
    String fullImageUrl = companyController.getFullImageUrl(iconPath);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(screenSize.width * 0.03),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isTablet ? screenSize.width * 0.16 : screenSize.width * 0.18,
            height: isTablet ? screenSize.width * 0.16 : screenSize.width * 0.18,
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
            child: Center(
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                width: isTablet ? screenSize.width * 0.08 : screenSize.width * 0.09,
                height: isTablet ? screenSize.width * 0.08 : screenSize.width * 0.09,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: isTablet ? screenSize.width * 0.08 : screenSize.width * 0.09,
                    color: Colors.grey,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: isTablet ? screenSize.width * 0.08 : screenSize.width * 0.09,
                    height: isTablet ? screenSize.width * 0.08 : screenSize.width * 0.09,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
                  : Icon(
                Icons.image_not_supported,
                size: isTablet ? screenSize.width * 0.08 : screenSize.width * 0.09,
                color: Colors.grey,
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
                fontSize: isTablet ? screenSize.width * 0.025 : screenSize.width * 0.03,
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