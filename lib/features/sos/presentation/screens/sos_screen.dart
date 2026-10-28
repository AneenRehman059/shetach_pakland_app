import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/core/widgets/app_bar2.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class SOSView extends StatefulWidget {
  const SOSView({super.key});

  @override
  State<SOSView> createState() => _SOSViewState();
}

class _SOSViewState extends State<SOSView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final SOSController _sosController = Get.put(SOSController());
  String brnCode = '';
  String brnName = '';
  String distance = '';

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      brnCode = args['brn_code'] ?? '';
      brnName = args['brn_name'] ?? '';
      distance = args['distance'] ?? '';
      _sosController.brnCode.value = brnCode;
    }
    print("------------------${brnName}-----------------");

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
    appBar: AppHeaderBar(title: Text("SOS/Emergency",style: TextStyle(color: AppColors.whiteBg,fontSize: 18),),
    backgroundColor: AppColors.appColor,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.whiteBg),),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.064),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.074),

              Obx(() => _sosController.countdown.value > 0
                  ? _buildCountdownDisplay()
                  : const SizedBox()),

              Text(
                'Are you in emergency?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.074,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondaryColor,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              Text(
                'Help will reach you soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    color: AppColors.textPrimaryColor.withOpacity(0.5)
                ),
              ),

              SizedBox(height: screenHeight * 0.035),

              _buildSOSButton(),

              SizedBox(height: screenHeight * 0.050),
              Obx(() => _sosController.isSOSActive.value
                  ? _buildCancelButton()
                  : Text(
                'Press and hold button\nfor 3 seconds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.053, vertical: screenHeight * 0.012),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.053),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, color: Colors.red, size: screenWidth * 0.053),
              SizedBox(width: screenWidth * 0.021),
              Text(
                'SOS in ${_sosController.countdown.value}s',
                style: TextStyle(
                  fontSize: screenWidth * 0.048,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
      ],
    );
  }

  Widget _buildCancelButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        ElevatedButton(
          onPressed: _sosController.cancelEmergencySOS,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.black54, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            fixedSize: Size(screenWidth * 0.7, screenHeight * 0.06),
          ),
          child: Text('CANCEL',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black54),),
        ),
        SizedBox(height: screenHeight * 0.025),
      ],
    );
  }

  Widget _buildSOSButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTapDown: (_) => _sosController.startHolding(),
      onTapUp: (_) => _sosController.stopHolding(),
      onTapCancel: () => _sosController.stopHolding(),
      child: SizedBox(
        width: screenWidth * 0.747,
        height: screenWidth * 0.747,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Obx(() {
              if (!_sosController.isSOSActive.value &&
                  !_sosController.isHolding.value) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: screenWidth * 0.694,
                            height: screenWidth * 0.694,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.errorColor.withOpacity(0.1),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value * 0.9,
                          child: Container(
                            width: screenWidth * 0.587,
                            height: screenWidth * 0.587,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.errorColor.withOpacity(0.2),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value * 0.8,
                          child: Container(
                            width: screenWidth * 0.48,
                            height: screenWidth * 0.48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.errorColor.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),

            Obx(() => Container(
              width: screenWidth * 0.427,
              height: screenWidth * 0.427,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _sosController.isSOSActive.value
                    ? Colors.red
                    : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (_sosController.isSOSActive.value
                        ? Colors.red
                        : Colors.red)
                        .withOpacity(0.4),
                    blurRadius: screenWidth * 0.067,
                    spreadRadius: screenWidth * 0.021,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Obx(() => _sosController.isHolding.value
                      ? SizedBox(
                    width: screenWidth * 0.374,
                    height: screenWidth * 0.374,
                    child: CircularProgressIndicator(
                      value: _sosController.holdProgress.value,
                      strokeWidth: screenWidth * 0.016,
                      backgroundColor: Colors.white24,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const SizedBox()),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("HELP ME !",style: TextStyle(color: AppColors.whiteBg,fontSize: 18,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}