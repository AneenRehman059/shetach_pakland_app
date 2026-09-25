import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pakland/core/theme/colors.dart';



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
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      bottom: buttombar
          ? const TabBar(
        indicatorColor: Colors.green,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(text: 'Details'),
          Tab(text: 'Timeline'),
          Tab(text: 'Comments'),
        ],
      )
          : null,


      title: Row(
        children: [

          SizedBox(
            width: kToolbarHeight,
            child: custom_RouteName != null
                ? IconButton(
              icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
              onPressed: () => Get.toNamed(custom_RouteName!),
            )
                : IconButton(
              icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          // SizedBox(
          //   width: kToolbarHeight,
          //   child: custom_RouteName != null
          //       ? IconButton(
          //       icon: const Icon(
          //         Icons.arrow_back_outlined,
          //         color: Colors.white,
          //       ),
          //       onPressed: (){
          //         Get.toNamed(custom_RouteName!); // safe
          //       }
          //   )
          //       : IconButton(
          //     icon: const Icon(
          //       Icons.arrow_back_outlined,
          //       color: Colors.white,
          //     ),
          //     onPressed: () =>
          //         Get.back(),
          //   ),
          // ),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Expanded(
          //   child: Text(
          //     title,
          //     maxLines: 1,
          //     overflow: TextOverflow.ellipsis,
          //     textAlign: TextAlign.center,
          //     style: const TextStyle(
          //       color: Colors.white,
          //       fontSize: 18,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          rightWidget ?? const SizedBox(width: kToolbarHeight),
          // SizedBox(
          //   width: kToolbarHeight,
          //   child: rightWidget ?? const SizedBox(),
          // ),
        ],
      ),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(
    buttombar ? kToolbarHeight + kTextTabBarHeight : kToolbarHeight,
  );
}
