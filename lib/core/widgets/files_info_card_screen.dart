import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String amount;
  final int percent;
  final Size size;

  const InfoCard({
    super.key,
    required this.title,
    required this.amount,
    required this.percent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = size.height * 0.22;
    final titleContainerHeight = size.height * 0.03;
    final progressIndicatorSize = size.width * 0.15;

    return Expanded(
      child: Container(
        height: cardHeight,
        child: Card(
          elevation: 3,
          color: AppColors.appColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.01,
              horizontal: size.width * 0.01,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title Container (white background)
                Container(
                  height: titleContainerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.whiteBg,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.027,
                          color: AppColors.appColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // Circular Progress Indicator with percentage
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: progressIndicatorSize,
                      width: progressIndicatorSize,
                      child: CircularProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent >= 80 ? Colors.white : Colors.white,
                        ),
                        strokeWidth: size.width * 0.012,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    Text(
                      amount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.whiteBg,
                          fontSize: size.width * 0.023,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}