import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/controllers/social_controller.dart';
import '../../constants/image_constant.dart';
import '../../controllers/theme_controller.dart';
import '../../payment_plan_detail_screen.dart';
import '../../status_bar_wrapper.dart';

class OnlinePaymentsScreen extends StatefulWidget {
  @override
  State<OnlinePaymentsScreen> createState() => _OnlinePaymentsScreenState();
}

class _OnlinePaymentsScreenState extends State<OnlinePaymentsScreen> {
  final SocialController controller = Get.put(SocialController());
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _themeController.updateStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;
    final buttonSize = screenSize.width * 0.20;

    return StatusBarWrapper(
      child: WillPopScope(
        onWillPop: () async {
          Get.offAll(() => MainWrapper());
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Background Image covering entire screen
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

              // Content Column
              Column(
                children: [
                  AppBar(
                    title: Text(
                      'Pay Online',
                      style: TextStyle(color: AppColors.whiteBg),
                    ),
                    centerTitle: true,
                    backgroundColor: AppColors.appColor,
                    iconTheme: IconThemeData(color: AppColors.whiteBg),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Get.offAll(() => MainWrapper()),
                    ),
                  ),

                  // Main Content
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
                            childAspectRatio: 1,
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
          Text(
            brnName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
