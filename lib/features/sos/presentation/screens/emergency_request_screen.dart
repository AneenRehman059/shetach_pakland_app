import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/features/cms/presentation/screens/cms_dashboard_screen.dart';

class EmergencyRequestScreen extends StatelessWidget {
  const EmergencyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    final headerHeight = screenHeight * 0.32;
    final horizontalPadding = screenWidth * 0.06;
    final titleFontSize = screenWidth * 0.072;
    final bodyFontSize = screenWidth * 0.038;
    final stepFontSize = screenWidth * 0.036;

    return WillPopScope(
      onWillPop: () async{
        Get.off(() => CMSDashboardScreen());
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: headerHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B3C), Color(0xFFFF4422)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.only(
                top: topPadding + screenHeight * 0.04,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: screenHeight * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Emergency\nRequest sent!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.022),
                  Text(
                    'Please stay calm!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    'Help will reachout to you soon.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What next?',
                      style: TextStyle(
                        fontSize: screenWidth * 0.052,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    _StepItem(
                      isFirst: true,
                      isLast: false,
                      isCompleted: false,
                      description:
                      'You will receive a call from\ncontrol room.',
                      stepFontSize: stepFontSize,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),


                    _StepItem(
                      isFirst: false,
                      isLast: true,
                      isCompleted: false,
                      description:
                      'Responder will help you get\nout of the situation and take\nnecessary actions',
                      stepFontSize: stepFontSize,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}


class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.description,
    required this.stepFontSize,
    required this.screenWidth,
    required this.screenHeight,
    this.hasLink = false,
    this.linkText,
  });

  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final String description;
  final bool hasLink;
  final String? linkText;
  final double stepFontSize;
  final double screenWidth;
  final double screenHeight;

  static const _lineColor = Color(0xFFD0D5DD);
  static const _circleColor = Color(0xFFFF5A3C);
  static const _emptyCircleColor = Color(0xFFE4E7EC);
  static const _linkColor = Color(0xFF3B82F6);
  static const _textColor = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    final circleSize = screenWidth * 0.06;
    final lineWidth = 1.5;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: circleSize + screenWidth * 0.04,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: lineWidth,
                    height: screenHeight * 0.012,
                    color: _lineColor,
                  )
                else
                  SizedBox(height: screenHeight * 0.012),

                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? _circleColor : Colors.white,
                    border: Border.all(
                      color: isCompleted ? _circleColor : _emptyCircleColor,
                      width: 1.8,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: circleSize * 0.55,
                  )
                      : null,
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: lineWidth,
                      color: _lineColor,
                    ),
                  )
                else
                  SizedBox(height: screenHeight * 0.012),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: screenWidth * 0.03,
                top: screenHeight * 0.008,
                bottom: screenHeight * 0.028,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: stepFontSize,
                      color: _textColor,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (hasLink && linkText != null) ...[
                    SizedBox(height: screenHeight * 0.006),
                    GestureDetector(
                      onTap: () {
                      },
                      child: Text(
                        linkText!,
                        style: TextStyle(
                          fontSize: stepFontSize,
                          color: _linkColor,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: _linkColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}