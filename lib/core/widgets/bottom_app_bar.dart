import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/dashboard/presentation/screens/about_us_screen.dart';
import 'package:pakland/features/profile/presentation/screens/profile_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/sales_center_screen.dart';

import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/utils/login_check_util.dart';
import 'package:pakland/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/main_screen.dart';
import 'package:pakland/features/tickets/data/repositories/ticket_repo.dart';
import 'package:pakland/core/services/fcm_notification_service.dart';


class BottomNavItem {
  final String? label;
  final String iconPath;
  final String routeName;
  final bool requiresLogin;

  const BottomNavItem({
    this.label,
    required this.iconPath,
    required this.routeName,
    this.requiresLogin = false,
  });
}

class MainWrapper extends StatefulWidget {
  final int initialIndex;
  final Widget? child;

  const MainWrapper({super.key, this.initialIndex = 0, this.child});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _currentIndex;

  static final List<BottomNavItem> _navItems = [
    BottomNavItem(
      label: 'Home',
      iconPath: ImageConstant.home,
      routeName: '/home',
      requiresLogin: false,
    ),
    BottomNavItem(
      label: 'Profile',
      iconPath: ImageConstant.profile,
      routeName: '/profile',
      requiresLogin: true,
    ),
    BottomNavItem(
      label: 'Sales',
      iconPath: ImageConstant.sales,
      routeName: '/sales-centers',
      requiresLogin: false,
    ),
    BottomNavItem(
      label: 'About',
      iconPath: ImageConstant.about,
      routeName: '/about-us',
      requiresLogin: false,
    ),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _handleKillStateNotification();
      });
    });
  }

  Future<void> _handleKillStateNotification() async {
    final message = initialNotificationMessage;
    if (message != null) {
      initialNotificationMessage = null;
      final String ticketId = message.data['ticketId'] ?? '';
      final String type = message.data['type'] ?? '';
      final String action = message.data['action'] ?? '';
      if (ticketId.isNotEmpty) {
        if (type == 'SOS_EMERGENCY' && action == 'SOS_NOTIFICATION') {
          final ticket = await TicketRepository().getTicket(ticketId);
          if (ticket != null) {
            FirebaseNotificationService().triggerSOSNavigation(ticket);
          }
        } else {
          _openTicket(ticketId);
        }
      }
      return;
    }

    final ticketId = pendingKillStateTicketId;
    if (ticketId != null && ticketId.isNotEmpty) {
      pendingKillStateTicketId = null;
      print('🚀 Opening ticket from local notification: $ticketId');
      _openTicket(ticketId);
    }
  }

  Future<void> _openTicket(String ticketId) async {
    final repo = TicketRepository();
    final ticket = await repo.getTicket(ticketId);
    print('🎫 Ticket: $ticket');
    if (ticket != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TicketDetailView(ticket: ticket)),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        if (widget.child != null) return true;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: _getCurrentScreen(),
        bottomNavigationBar: _buildModernNavBar(),
      ),
    );
  }

  Widget _getCurrentScreen() {
    if (widget.child != null) return widget.child!;
    return _getScreenForIndex(_currentIndex);
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const MainScreen();
      case 1:
        return ProfileScreen();
      case 2:
        return const SalesCenterScreen();
      case 3:
        return const AboutUsScreen();
      default:
        return const MainScreen();
    }
  }

  Widget _buildModernNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkSurfaceColor : Colors.white;
    final count = _navItems.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.appColor.withOpacity(isDark ? 0.30 : 0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final total = constraints.maxWidth;
              final cap = total * 0.42;
              final selectedW = count == 1 ? total : (cap > 132 ? 132.0 : cap);
              final otherW = count == 1 ? 0.0 : (total - selectedW) / (count - 1);

              return Row(
                children: List.generate(
                  count,
                      (i) => _buildNavItem(
                    i,
                    isDark,
                    i == _currentIndex ? selectedW : otherW,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark, double width) {
    final item = _navItems[index];
    final selected = _currentIndex == index;
    final inactiveColor =
    isDark ? AppColors.darkTextSecondaryColor : AppColors.appColor;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
            colors: [AppColors.appColor, AppColors.lightAppColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            splashColor: AppColors.appColor.withOpacity(0.10),
            highlightColor: Colors.transparent,
            onTap: () async {
              HapticFeedback.selectionClick();
              final oldIndex = _currentIndex;
              await _handleNavTap(index, oldIndex: oldIndex);
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: ImageIcon(
                        AssetImage(item.iconPath),
                        size: 24,
                        color: selected ? Colors.white : inactiveColor,
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      child: selected
                          ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label ?? '',
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 13,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNavTap(int index, {required int oldIndex}) async {
    final navItem = _navItems[index];

    if (navItem.requiresLogin) {
      final isLoggedIn = await LoginCheckUtil.isUserLoggedIn();
      if (!isLoggedIn) {
        LoginCheckUtil.showLoginRequiredDialog(
          context,
          onYesPressed: () => Get.toNamed('/login'),
        );
        return;
      }
    }

    if (widget.child != null) {
      Get.offAllNamed(navItem.routeName);
      return;
    }

    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

}