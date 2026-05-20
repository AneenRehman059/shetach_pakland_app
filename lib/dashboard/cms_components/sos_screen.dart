import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../../controllers/sos_controller.dart';
import '../../customs/widgets/app_bar.dart';

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
    appBar: AppBar(title: Text("SOS/Emergency",style: TextStyle(color: AppColors.whiteBg,fontSize: 18),),
    backgroundColor: AppColors.appColor,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.whiteBg),),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.064), // 24px equivalent
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.074),

              // Countdown Display (when active)
              Obx(() => _sosController.countdown.value > 0
                  ? _buildCountdownDisplay()
                  : const SizedBox()),

              // Main Title
              Text(
                'Are you in emergency?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.074, // 28px equivalent
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
              // Instruction
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.053, vertical: screenHeight * 0.012), // 20px, 10px equivalent
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.053), // 20px equivalent
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, color: Colors.red, size: screenWidth * 0.053), // 20px equivalent
              SizedBox(width: screenWidth * 0.021), // 8px equivalent
              Text(
                'SOS in ${_sosController.countdown.value}s',
                style: TextStyle(
                  fontSize: screenWidth * 0.048, // 18px equivalent
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.025), // 20px equivalent
      ],
    );
  }

  Widget _buildCancelButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Text(
        //   'SOS Activated!',
        //   textAlign: TextAlign.center,
        //   style: TextStyle(
        //     fontSize: screenWidth * 0.042, // 16px equivalent
        //     color: Colors.red,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
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
            // Outer concentric circles (pulsing glow)
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
                            width: screenWidth * 0.587, // 220px equivalent
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
                            width: screenWidth * 0.48, // 180px equivalent
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

            // Main red button
            Obx(() => Container(
              width: screenWidth * 0.427, // 160px equivalent
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
                    blurRadius: screenWidth * 0.067, // 25px equivalent
                    spreadRadius: screenWidth * 0.021, // 8px equivalent
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress Ring
                  Obx(() => _sosController.isHolding.value
                      ? SizedBox(
                    width: screenWidth * 0.374, // 140px equivalent
                    height: screenWidth * 0.374,
                    child: CircularProgressIndicator(
                      value: _sosController.holdProgress.value,
                      strokeWidth: screenWidth * 0.016, // 6px equivalent
                      backgroundColor: Colors.white24,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const SizedBox()),

                  // Button Icon + Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("HELP ME !",style: TextStyle(color: AppColors.whiteBg,fontSize: 18,fontWeight: FontWeight.bold),),
                      // Obx(() => _sosController.isSOSActive.value
                      //     ? Padding(
                      //   padding: EdgeInsets.only(top: screenHeight * 0.0074), // 6px equivalent
                      //   child: Text(
                      //     'SOS\nACTIVE',
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: screenWidth * 0.032, // 12px equivalent
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // )
                      //     : const SizedBox()),
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