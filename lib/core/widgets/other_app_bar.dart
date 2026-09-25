import 'package:flutter/material.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart'; // Import your AppColors file

class OtherAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  OtherAppBar({
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
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: leading ??
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: onBackPressed,
            ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.appColor,
            ),
          ),
        ),

      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
