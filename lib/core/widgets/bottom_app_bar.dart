import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
  final String label;
  final String iconPath;
  final String routeName;
  final bool requiresLogin;

  const BottomNavItem({
    required this.label,
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

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey =
  GlobalKey<CurvedNavigationBarState>();

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
      label: 'Sales Centers',
      iconPath: ImageConstant.sales,
      routeName: '/sales-centers',
      requiresLogin: false,
    ),
    BottomNavItem(
      label: 'About Us',
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
    // ✅ Case 1: FCM data-only message (getInitialMessage worked)
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

    // ✅ Case 2: Local notification tap (your actual case!)
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
        onTap: (index) async {
          final oldIndex = _currentIndex;
          await _handleNavTap(index, oldIndex: oldIndex);
        },
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

    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

}