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
    final cardHeight = size.height * 0.20;
    final safePercent = percent.clamp(0, 100);

    return Expanded(
      child: SizedBox(
        height: cardHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            final pad = (w * 0.05).clamp(4.0, 12.0).toDouble();
            final titleHeight = (h * 0.2).clamp(18.0, 34.0).toDouble();
            final titleFont = (w * 0.105).clamp(9.0, 15.0).toDouble();
            final amountFont = (w * 0.09).clamp(9.0, 15.0).toDouble();
            final strokeWidth = (w * 0.035).clamp(3.0, 8.0).toDouble();
            final maxCircle = w * 0.66;

            return Card(
              elevation: 3,
              color: AppColors.appColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: pad * 0.8, horizontal: pad * 0.6),
                child: Column(
                  children: [
                    Container(
                      height: titleHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.whiteBg,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: titleFont,
                                color: AppColors.appColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: pad * 0.7),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxCircle, maxHeight: maxCircle),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: safePercent / 100,
                                    backgroundColor: Colors.black,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: strokeWidth,
                                  ),
                                  Center(
                                    child: FractionallySizedBox(
                                      widthFactor: 0.62,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '$safePercent%',
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          amount,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.whiteBg,
                            fontSize: amountFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}