import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/controllers/social_controller.dart';
import '../../constants/image_constant.dart';
import '../../controllers/theme_controller.dart';
import '../../function/screen_helper.dart';
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
    final bool isTV = ScreenHelper.isTV(context);
    final screenSize = MediaQuery.of(context).size;
    final horizontalPadding = screenSize.width * 0.05;

    // TV pe 4 columns, mobile pe 2
    final int crossAxisCount = isTV ? 4 : 2;
    final double buttonSize = isTV
        ? screenSize.width * 0.10
        : screenSize.width * 0.20;

    return StatusBarWrapper(
      child: WillPopScope(
        onWillPop: () async {
          Get.offAll(() => MainWrapper());
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              // Background Image
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

              // Content
              Column(
                children: [
                  AppBar(
                    title: Text('Pay Online',
                        style: TextStyle(
                            color: AppColors.whiteBg,
                            fontSize: isTV ? 22 : 16)),
                    centerTitle: true,
                    backgroundColor: AppColors.appColor,
                    iconTheme: IconThemeData(color: AppColors.whiteBg),
                    toolbarHeight: isTV ? 70 : kToolbarHeight,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, size: isTV ? 30 : 24),
                      onPressed: () => Get.offAll(() => MainWrapper()),
                    ),
                  ),

                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitWave(color: AppColors.appColor, size: 50.0),
                              SizedBox(height: 16),
                              Text('Loading', style: TextStyle(color: AppColors.appColor)),
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
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: screenSize.width * 0.05,
                            mainAxisSpacing: screenSize.height * 0.03,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final branch = controller.branches[index];
                            return isTV
                                ? _TVBranchButton(
                              imageUrl: branch['image_url'] ?? '',
                              brnCode: branch['brn_code'] ?? '',
                              brnName: branch['brn_name'] ?? '',
                              size: buttonSize,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PayOnlineScreen(
                                    brnCode: branch['brn_code'] ?? '',
                                    brnName: branch['brn_name'] ?? '',
                                  ),
                                ),
                              ),
                            )
                                : _buildMobileButton(
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

  // Mobile — same as before
  Widget _buildMobileButton(String imageUrl, String brnCode, String brnName,
      double size, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PayOnlineScreen(brnCode: brnCode, brnName: brnName),
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
                child: Image.asset(ImageConstant.logo, fit: BoxFit.contain),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(brnName, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// TV Branch Button — with focus
class _TVBranchButton extends StatefulWidget {
  final String imageUrl;
  final String brnCode;
  final String brnName;
  final double size;
  final VoidCallback onTap;

  const _TVBranchButton({
    required this.imageUrl,
    required this.brnCode,
    required this.brnName,
    required this.size,
    required this.onTap,
  });

  @override
  State<_TVBranchButton> createState() => _TVBranchButtonState();
}

class _TVBranchButtonState extends State<_TVBranchButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
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
        child: AnimatedScale(
          scale: _isFocused ? 1.08 : 1.0,
          duration: Duration(milliseconds: 150),
          child: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 150),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.whiteBg,
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: _isFocused ? 20 : 4,
                      spreadRadius: _isFocused ? 3 : 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: _isFocused
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: Image.asset(ImageConstant.logo, fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.brnName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isFocused ? Colors.white : Colors.white70,
                  fontSize: 16,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}