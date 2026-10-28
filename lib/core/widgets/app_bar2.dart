import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? custom_RouteName;
  final String title;
  final Widget? rightWidget;
  final bool buttombar;

  const CustomAppBar({
    Key? key,
    this.custom_RouteName,
    required this.title,
    this.rightWidget,
    this.buttombar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppHeaderBar(
      title: Text(title),
      onBackPressed: custom_RouteName != null
          ? () => Get.toNamed(custom_RouteName!)
          : null,
      actions: rightWidget != null ? [rightWidget!] : null,
      bottom: buttombar
          ? const _HeaderTabs()
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    64 + 12 + (buttombar ? kTextTabBarHeight : 0),
  );
}

class _HeaderTabs extends StatelessWidget implements PreferredSizeWidget {
  const _HeaderTabs();

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: 'Details'),
        Tab(text: 'Timeline'),
        Tab(text: 'Comments'),
      ],
    );
  }
}
