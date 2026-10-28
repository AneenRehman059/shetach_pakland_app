import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/booking/presentation/screens/booking_screen.dart';
import 'package:pakland/features/customer_portal/presentation/screens/customer_portal_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/downloads_screen.dart';
import 'package:pakland/features/events/presentation/screens/events_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/privacy_policy_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/sops_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/sales_center_screen.dart';
import 'package:pakland/features/dashboard/data/development_progress.dart';
import 'package:pakland/features/billing/presentation/screens/online_payments_screen.dart';
import 'package:pakland/features/social/presentation/screens/social_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/core/controllers/theme_controller.dart';
import 'package:pakland/core/utils/login_check_util.dart';
import 'package:pakland/core/widgets/status_bar_wrapper.dart';
import 'package:pakland/features/cms/presentation/screens/cms_dashboard_screen.dart';
import 'package:pakland/features/billing/presentation/screens/bill_reg_no_screen.dart';
import 'package:pakland/features/billing/presentation/screens/check_form_number_screen.dart';
import 'package:pakland/features/billing/presentation/screens/payment_plans_screen.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';

class DashboardMenus extends StatefulWidget {
  const DashboardMenus({super.key});

  @override
  State<DashboardMenus> createState() => _DashboardMenusState();
}

class _DashboardMenusState extends State<DashboardMenus> {
  final themeController = Get.find<ThemeController>();
  final companyController = Get.find<CompanyController>();
  static const Color _screenBg = Color(0xFFF2F6F8);

  late ScrollController _scrollController;
  bool _showDownArrow = true;

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
        return Container();
    }
  }

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
    final isTablet = ScreenHelper.isTablet(context);

    return Container(
      color: _screenBg,
      child: Obx(() {
        final tempTabs = companyController.mobileTabs;
        final temp = [];
        for (var tab in tempTabs) {
          if (tab['isActive'] == true) {
            temp.add(tab);
          }
        }

        final tabs = temp;

        if (companyController.isLoading.value && tabs.isEmpty) {
          return Center(
            child: AppLoader(),
          );
        }

        if (tabs.isEmpty) {
          return Center(
            child: Text(
              'No menu items available',
              style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.t2,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'QUICK ACCESS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.appColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        crossAxisSpacing: screenSize.width * 0.04,
                        mainAxisSpacing: screenSize.height * 0.02,
                        childAspectRatio: isTablet ? 2.2 : 2.35,
                      ),
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final tab = tabs[index];
                        final tabName = tab['home_menu_en'] ?? tab['home_menu_en'] ?? 'Unknown';
                        final iconPath = tab['icon']?.toString() ?? '';
                        final isActive = tab['isActive'] ?? true;

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
                  ],
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
                    decoration: BoxDecoration(
                      color: AppColors.appColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.appColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
    String fullImageUrl = companyController.getFullImageUrl(iconPath);
    final iconColor = AppColors.appColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE3EAEF), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.appColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenSize.width * 0.12,
                height: screenSize.width * 0.12,
                alignment: Alignment.center,
                child: fullImageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.contain,
                    width: screenSize.width * 0.3,
                    height: screenSize.width * 0.3,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.image_not_supported,
                      size: screenSize.width * 0.06,
                      color: iconColor,
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        width: screenSize.width * 0.05,
                        height: screenSize.width * 0.05,
                        child: AppLoader(),
                      );
                    },
                  ),
                )
                    : Icon(Icons.image_not_supported, size: screenSize.width * 0.06, color: iconColor),
              ),
              SizedBox(width: screenSize.width * 0.03),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.033,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B2733),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}