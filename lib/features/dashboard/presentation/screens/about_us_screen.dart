import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/other_app_bar.dart';

import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/constants/text_contants.dart';
import 'package:pakland/core/widgets/app_bar.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key,});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth <= 600;
    final isLargeScreen = screenWidth > 600;
    final isTablet = screenWidth > 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    // Responsive font sizes
    final double titleFontSize = isSmallScreen ? 14 : (isMediumScreen ? 15 : (isLargeScreen ? 16 : 18));
    final double bodyFontSize = isSmallScreen ? 12 : (isMediumScreen ? 13 : (isLargeScreen ? 14 : 15));
    final double quoteFontSize = isSmallScreen ? 12 : (isMediumScreen ? 13 : 14);
    final double marqueeFontSize = isSmallScreen ? 14 : (isMediumScreen ? 15 : 16);
    final double sectionTitleFontSize = isSmallScreen ? 16 : (isMediumScreen ? 17 : (isLargeScreen ? 18 : 20));

    // Responsive spacing
    final double smallSpacing = screenHeight * 0.008;
    final double mediumSpacing = screenHeight * 0.012;
    final double largeSpacing = screenHeight * 0.02;
    final double sectionSpacing = screenHeight * 0.03;
    final double horizontalPadding = screenWidth * 0.04;
    final double sectionHorizontalPadding = isLargeScreen ? screenWidth * 0.1 : screenWidth * 0.04;

    // Responsive image heights
    final double topImageHeight = isSmallScreen ? 130 : (isMediumScreen ? 150 : (isLargeScreen ? 300 : 220));
    final double metroImageHeight = isSmallScreen ? 150 : (isMediumScreen ? 180 : (isLargeScreen ? 200 : 220));
    final double bottomImageHeight = isSmallScreen ? 200 : (isMediumScreen ? 250 : (isLargeScreen ? 300 : 350));

    // Responsive container widths
    final double journeyTextWidth = isSmallScreen ? screenWidth * 0.7 : (isMediumScreen ? 250 : (isLargeScreen ? 300 : 350));
    final double missionContainerWidth = isSmallScreen ? screenWidth * 0.8 : (isMediumScreen ? screenWidth * 0.75 : screenWidth * 0.7);
    final double successTextPadding = isLargeScreen ? screenWidth * 0.2 : screenWidth * 0.15;

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => MainWrapper());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "About Us",
            style: TextStyle(
              color: AppColors.whiteBg,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: isSmallScreen ? 50 : kToolbarHeight,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 1,
                width: double.infinity,
                color: AppColors.whiteBg,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: AppColors.appColor,
                        width: double.infinity,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: smallSpacing * 1.5),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTextContent.beliefQuote,
                                    style: TextStyle(
                                      fontSize: quoteFontSize,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: mediumSpacing),
                                  Text(
                                    AppTextContent.aboutDescription,
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(height: sectionSpacing),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: largeSpacing),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 5 : 6,
                          horizontal: isSmallScreen ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.appColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(screenWidth * 0.05),
                            bottomRight: Radius.circular(screenWidth * 0.05),
                          ),
                        ),
                        child: Text(
                          AppTextContent.ourMajorClients,
                          style: TextStyle(
                            color: AppColors.whiteBg,
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                        ),
                      ),
                      Container(
                        color: AppColors.whiteBg,
                        child: SizedBox(
                          height: isSmallScreen ? 35 : 40,
                          child: Marquee(
                            text: AppTextContent.marqueeText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: marqueeFontSize,
                              color: AppColors.appColor,
                            ),
                            blankSpace: screenWidth * 0.12,
                            velocity: isSmallScreen ? 40.0 : 50.0,
                            pauseAfterRound: Duration(seconds: 1),
                            startPadding: 10.0,
                            accelerationDuration: Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          ),
                        ),
                      ),
                      SizedBox(height: mediumSpacing),
                      Image.asset(
                        height: topImageHeight,
                        ImageConstant.she_t,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      SizedBox(height: mediumSpacing),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 5 : 6,
                                horizontal: isSmallScreen ? 10 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.appColor,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(screenWidth * 0.05),
                                  bottomRight: Radius.circular(screenWidth * 0.05),
                                ),
                              ),
                              child:Text(
                                AppTextContent.ourJourneyTitle,
                                style: TextStyle(
                                  color: AppColors.whiteBg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                            ),
                            SizedBox(height: mediumSpacing),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: Container(
                                width: journeyTextWidth,
                                child: Text(
                                  AppTextContent.ourJourneyDescription,
                                  style: TextStyle(
                                    fontSize: bodyFontSize,
                                    height: 1.4,
                                    color: AppColors.appColor,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      Image.asset(
                        height: metroImageHeight,
                        ImageConstant.metro,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      SizedBox(height: largeSpacing),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 5 : 6,
                                horizontal: isSmallScreen ? 10 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.appColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(screenWidth * 0.05),
                                  bottomLeft: Radius.circular(screenWidth * 0.05),
                                ),
                              ),
                              child: Text(
                                AppTextContent.ourSuccessTitle,
                                style: TextStyle(
                                  color: AppColors.whiteBg,
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                            ),
                            SizedBox(height: largeSpacing),
                            Padding(
                              padding: EdgeInsets.only(
                                left: successTextPadding,
                                right: horizontalPadding,
                              ),
                              child: Text(
                                AppTextContent.ourSuccessDescription,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  color: AppColors.appColor,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            SizedBox(height: largeSpacing),
                            Container(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                    children: [
                                      Image.asset(
                                        height: bottomImageHeight,
                                        ImageConstant.bsm_g,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: horizontalPadding),
                                          child: Container(
                                            width: missionContainerWidth,
                                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                            decoration: BoxDecoration(
                                              color: AppColors.appColor.withOpacity(0.9),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "OUR MISSION",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: sectionTitleFontSize,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, isSmallScreen ? -15 : -20),
                                    child: Padding(
                                      padding: EdgeInsets.only(right: horizontalPadding),
                                      child: Container(
                                        width: missionContainerWidth,
                                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                        margin: EdgeInsets.only(right: 0),
                                        decoration: BoxDecoration(
                                          color: AppColors.appColor,
                                        ),
                                        child: Text(
                                          AppTextContent.ourWelcomeDescription,
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: largeSpacing * 1.5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}