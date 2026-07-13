import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:pakland/colors.dart';
import 'package:pakland/dashboard/about_us_screen.dart';
import 'package:pakland/dashboard/profile_screen.dart';
import 'package:pakland/dashboard/sales_center_screen.dart';

import '../constants/image_constant.dart';
import '../customs/login_check_util.dart';
import '../dashboard/cms_components/ticket_detail_screen.dart';
import '../dashboard/main_screen.dart';
import '../function/screen_helper.dart';
import '../repo/ticket_repo.dart';
import '../services/fcm_notification_service.dart';

class BottomNavItem {
  final String label;
  final String iconPath;
  final String routeName;
  final bool requiresLogin;
  final IconData icon;

  const BottomNavItem({
    required this.label,
    required this.iconPath,
    required this.routeName,
    required this.icon,
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

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey =
  GlobalKey<CurvedNavigationBarState>();

  static final List<BottomNavItem> _navItems = [
    BottomNavItem(
      label: 'Home',
      iconPath: ImageConstant.home,
      routeName: '/home',
      icon: Icons.home_rounded,
    ),
    BottomNavItem(
      label: 'Profile',
      iconPath: ImageConstant.usr,
      routeName: '/profile',
      icon: Icons.person_rounded,
      requiresLogin: true,
    ),
    BottomNavItem(
      label: 'Sales',
      iconPath: ImageConstant.sales,
      routeName: '/sales-centers',
      icon: Icons.store_rounded,
    ),
    BottomNavItem(
      label: 'About Us',
      iconPath: ImageConstant.about,
      routeName: '/about-us',
      icon: Icons.info_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), _handleKillStateNotification);
      // TV pe landscape, mobile pe portrait
      if (ScreenHelper.isTV(context)) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
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
          if (ticket != null) FirebaseNotificationService().triggerSOSNavigation(ticket);
        } else {
          _openTicket(ticketId);
        }
      }
      return;
    }
    final ticketId = pendingKillStateTicketId;
    if (ticketId != null && ticketId.isNotEmpty) {
      pendingKillStateTicketId = null;
      _openTicket(ticketId);
    }
  }

  Future<void> _openTicket(String ticketId) async {
    final ticket = await TicketRepository().getTicket(ticketId);
    if (ticket != null && mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => TicketDetailView(ticket: ticket)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    if (isTV) return _buildTVLayout(context);

    // Mobile — same as before
    return WillPopScope(
      onWillPop: () async {
        if (widget.child != null) return true;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _bottomNavigationKey.currentState?.setPage(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: _getCurrentScreen(),
        bottomNavigationBar: _buildCurvedNavBar(),
      ),
    );
  }

  Widget _buildTVLayout(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Row(
          children: [
            // TV Side Nav
            _TVSideNav(
              items: _navItems,
              currentIndex: _currentIndex,
              onTap: (index) async => await _handleNavTap(index, oldIndex: _currentIndex),
            ),
            // Main content
            Expanded(child: _getCurrentScreen()),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    if (widget.child != null) return widget.child!;
    switch (_currentIndex) {
      case 0: return const MainScreen();
      case 1: return ProfileScreen();
      case 2: return const SalesCenterScreen();
      case 3: return const AboutUsScreen();
      default: return const MainScreen();
    }
  }

  Widget _buildCurvedNavBar() {
    return SafeArea(
      top: false,
      child: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _currentIndex,
        height: 60,
        backgroundColor: AppColors.lightAppColor,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        items: List.generate(_navItems.length, (index) {
          final selected = _currentIndex == index;
          return ImageIcon(
            AssetImage(_navItems[index].iconPath),
            size: 26,
            color: selected ? AppColors.appColor : AppColors.lightAppColor,
          );
        }),
        onTap: (index) async => await _handleNavTap(index, oldIndex: _currentIndex),
      ),
    );
  }

  Future<void> _handleNavTap(int index, {required int oldIndex}) async {
    final navItem = _navItems[index];
    if (navItem.requiresLogin) {
      final isLoggedIn = await LoginCheckUtil.isUserLoggedIn();
      if (!isLoggedIn) {
        _bottomNavigationKey.currentState?.setPage(oldIndex);
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
    if (_currentIndex != index) setState(() => _currentIndex = index);
  }
}

// ─────────────────────────────────────────────────────
// TV SIDE NAV — Netflix/YouTube TV style
// ─────────────────────────────────────────────────────
class _TVSideNav extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const _TVSideNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.appColor,
            AppColors.appColor.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 24),

          // Logo with white circular background
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                )
              ],
            ),
            child: Image.asset(
              ImageConstant.logo,
              height: 48,
              width: 48,
            ),
          ),

          SizedBox(height: 8),

          // App name
          Text(
            'PAK LAND',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withOpacity(0.3),
          ),

          SizedBox(height: 16),

          // Nav items
          ...List.generate(items.length, (index) {
            return _TVNavItem(
              item: items[index],
              isSelected: currentIndex == index,
              onTap: () => onTap(index),
            );
          }),

          Spacer(),

          // Version at bottom
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'v1.0.1',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TVNavItem extends StatefulWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _TVNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TVNavItem> createState() => _TVNavItemState();
}

class _TVNavItemState extends State<_TVNavItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isSelected || _isFocused;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Colors.white
                  : _isFocused
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.item.icon,
                    size: 28,
                    color: widget.isSelected
                        ? AppColors.appColor
                        : Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                // Label
                Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected
                        ? AppColors.appColor
                        : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}