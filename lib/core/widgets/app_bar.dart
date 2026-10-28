import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class CustomAppBar extends StatelessWidget {
  final double height;
  final bool showBackButton;
  final String? title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.height = 66,
    this.showBackButton = true,
    this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeaderBar(
      automaticallyImplyLeading: showBackButton,
      onBackPressed: onBackPressed ?? () => Get.offAllNamed('/home'),
      leading: showBackButton
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBackPressed ?? () => Get.offAllNamed('/home'),
            )
          : null,
      title: title != null
          ? Text(title!)
          : Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(ImageConstant.logo, height: 34),
              ),
            ),
    );
  }
}
