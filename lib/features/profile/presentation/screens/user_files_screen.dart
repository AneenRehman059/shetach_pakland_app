import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/customer_portal/presentation/screens/customer_portal_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/features/billing/presentation/screens/payment_plan_detail_screen.dart';
import 'package:pakland/core/widgets/status_bar_wrapper.dart';
import 'package:pakland/core/theme/theme_controller.dart';

class UserFilesScreen extends StatefulWidget {
  @override
  State<UserFilesScreen> createState() => _UserFilesScreenState();
}

class _UserFilesScreenState extends State<UserFilesScreen> {
  final SocialController controller = Get.put(SocialController());
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    _themeController.updateStatusBar();

    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;
    final buttonSize = screenSize.width * 0.20;

    return StatusBarWrapper(
      child: WillPopScope(
        onWillPop: () async {
          Get.back();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Pay Online",style: TextStyle(color: AppColors.whiteBg),),
            centerTitle: true,
            backgroundColor: AppColors.appColor,
            iconTheme: IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Get.offAll(() => CustomerPortalScreen()),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Get.offAll(() => MainWrapper(initialIndex: 0));
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/pay_online_bg_img.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),

              Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitWave(
                                color: AppColors.appColor,
                                size: 50.0,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading',
                                style: TextStyle(
                                  color: AppColors.appColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: GridView.builder(
                          padding: EdgeInsets.only(
                            top: screenSize.height * 0.02,
                            bottom: screenSize.height * 0.02,
                          ),
                          itemCount: controller.branches.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: screenSize.width * 0.05,
                            mainAxisSpacing: screenSize.height * 0.03,
                            childAspectRatio: 1.5,
                          ),
                          itemBuilder: (context, index) {
                            final branch = controller.branches[index];
                            return _buildSocialButton(
                              branch['image_url'] ?? '',
                              branch['brn_code'] ?? '',
                              branch['brn_name'] ?? '',
                              buttonSize,
                              context,
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      String imageUrl, String brnCode, String brnName, double size, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PayOnlineScreen(brnCode: brnCode, brnName: brnName),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.asset(
                  ImageConstant.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Flexible(
            child: Text(
              brnName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

//
// Container(
// width: size,
// height: size,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: AppColors.whiteBg,
// boxShadow: [
// BoxShadow(
// color: Colors.black.withOpacity(0.2),
// blurRadius: 4,
// offset: Offset(0, 2),
// ),
// ],
// image: DecorationImage(
// image: NetworkImage(imageUrl),
// fit: BoxFit.contain,
// ),
// ),
// ),