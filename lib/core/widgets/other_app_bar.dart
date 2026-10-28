import 'package:flutter/material.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class OtherAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const OtherAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.actions,
    this.leading,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeaderBar(
      title: Text(title),
      leading: leading,
      onBackPressed: onBackPressed,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64 + 12);
}
