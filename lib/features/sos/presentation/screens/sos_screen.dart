import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/core/widgets/widgets/app_bar.dart';
import 'package:pakland/core/utils/screen_helper.dart';

class SOSView extends StatefulWidget {
  const SOSView({super.key});
  @override
  State<SOSView> createState() => _SOSViewState();
}

class _SOSViewState extends State<SOSView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final SOSController _sosController = Get.find<SOSController>();
  String brnCode = '', brnName = '', distance = '';

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
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
        child: CustomAppBar(title: 'SOS'),
      ),
      body: isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
    );
  }

  // ─── MOBILE — same as before ───
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.064),
        child: Column(children: [
          SizedBox(height: screenHeight * 0.074),
          Obx(() => _sosController.countdown.value > 0 ? _buildCountdownDisplay(context) : const SizedBox()),
          Text('Are you in emergency?', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.074, fontWeight: FontWeight.bold, color: AppColors.textSecondaryColor)),
          Text('Help will reach you soon.', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.042, color: AppColors.textPrimaryColor.withOpacity(0.5))),
          SizedBox(height: screenHeight * 0.010),
          _buildSOSButton(context),
          SizedBox(height: screenHeight * 0.050),
          Obx(() => _sosController.isSOSActive.value ? _buildCancelButton(context) : Text('Press and hold button\nfor 3 seconds', textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.042, color: AppColors.errorColor, fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }

  // ─── TV — wider layout with side text ───
  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Left — text info
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Obx(() => _sosController.countdown.value > 0 ? _buildCountdownDisplay(context) : const SizedBox()),
              Text('Are you in emergency?', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textSecondaryColor)),
              SizedBox(height: 16),
              Text('Help will reach you soon.', style: TextStyle(fontSize: 22, color: AppColors.textPrimaryColor.withOpacity(0.5))),
              SizedBox(height: 32),
              Obx(() => _sosController.isSOSActive.value
                  ? _buildCancelButton(context)
                  : Text('Press and hold button\nfor 3 seconds', style: TextStyle(fontSize: 20, color: AppColors.errorColor, fontWeight: FontWeight.w500))),
            ]),
          ),
        ),
        // Right — SOS button
        Padding(
          padding: EdgeInsets.all(40),
          child: _buildSOSButton(context, isTV: true),
        ),
      ]),
    );
  }

  Widget _buildCountdownDisplay(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTV = ScreenHelper.isTV(context);
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.053, vertical: 10),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(screenWidth * 0.053), border: Border.all(color: Colors.red, width: 2)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.timer, color: Colors.red, size: isTV ? 28 : screenWidth * 0.053),
          SizedBox(width: 8),
          Text('SOS in ${_sosController.countdown.value}s', style: TextStyle(fontSize: isTV ? 22 : screenWidth * 0.048, fontWeight: FontWeight.bold, color: Colors.red)),
        ]),
      ),
      SizedBox(height: 20),
    ]);
  }

  Widget _buildCancelButton(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    return Column(children: [
      Text('SOS Activated!', textAlign: TextAlign.center, style: TextStyle(fontSize: isTV ? 22 : 16, color: Colors.red, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      ElevatedButton(onPressed: _sosController.cancelEmergencySOS, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, side: BorderSide(color: Colors.red, width: 2), padding: isTV ? EdgeInsets.symmetric(horizontal: 32, vertical: 16) : null), child: Text('CANCEL SOS', style: TextStyle(fontSize: isTV ? 18 : 14))),
      SizedBox(height: 20),
    ]);
  }

  Widget _buildSOSButton(BuildContext context, {bool isTV = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    // TV pe fixed size, mobile pe screenWidth based
    final btnSize = isTV ? 280.0 : screenWidth * 0.747;
    final innerSize = isTV ? 160.0 : screenWidth * 0.427;
    final outerSize1 = isTV ? 260.0 : screenWidth * 0.694;
    final outerSize2 = isTV ? 220.0 : screenWidth * 0.587;
    final outerSize3 = isTV ? 180.0 : screenWidth * 0.48;
    final iconSize = isTV ? 50.0 : screenWidth * 0.117;

    return GestureDetector(
      onTapDown: (_) => _sosController.startHolding(),
      onTapUp: (_) => _sosController.stopHolding(),
      onTapCancel: () => _sosController.stopHolding(),
      child: SizedBox(
        width: btnSize, height: btnSize,
        child: Stack(alignment: Alignment.center, children: [
          Obx(() {
            if (!_sosController.isSOSActive.value && !_sosController.isHolding.value) {
              return Stack(alignment: Alignment.center, children: [
                AnimatedBuilder(animation: _pulseAnimation, builder: (c, child) => Transform.scale(scale: _pulseAnimation.value, child: Container(width: outerSize1, height: outerSize1, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.errorColor.withOpacity(0.1))))),
                AnimatedBuilder(animation: _pulseAnimation, builder: (c, child) => Transform.scale(scale: _pulseAnimation.value * 0.9, child: Container(width: outerSize2, height: outerSize2, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.errorColor.withOpacity(0.2))))),
                AnimatedBuilder(animation: _pulseAnimation, builder: (c, child) => Transform.scale(scale: _pulseAnimation.value * 0.8, child: Container(width: outerSize3, height: outerSize3, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.errorColor.withOpacity(0.3))))),
              ]);
            }
            return const SizedBox();
          }),
          Obx(() => Container(
            width: innerSize, height: innerSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _sosController.isSOSActive.value ? Colors.orange : AppColors.errorColor, boxShadow: [BoxShadow(color: (_sosController.isSOSActive.value ? Colors.orange : AppColors.errorColor).withOpacity(0.4), blurRadius: 25, spreadRadius: 8)]),
            child: Stack(alignment: Alignment.center, children: [
              Obx(() => _sosController.isHolding.value ? SizedBox(width: innerSize * 0.875, height: innerSize * 0.875, child: CircularProgressIndicator(value: _sosController.holdProgress.value, strokeWidth: 6, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const SizedBox()),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_sosController.isSOSActive.value ? Icons.warning : Icons.emergency, size: iconSize, color: Colors.white),
                Obx(() => _sosController.isSOSActive.value ? Padding(padding: const EdgeInsets.only(top: 6), child: Text('SOS\nACTIVE', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isTV ? 16 : screenWidth * 0.032, fontWeight: FontWeight.bold))) : const SizedBox()),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }
}