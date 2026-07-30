import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/utils/screen_helper.dart';

class InfoCard extends StatefulWidget {
  final String title;
  final String amount;
  final int percent;
  final Size size;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.amount,
    required this.percent,
    required this.size,
    this.onTap,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    // TV pe bade fixed sizes, mobile pe proportional
    final double cardHeight = isTV ? 160 : widget.size.height * 0.22;
    final double progressSize = isTV ? 70 : widget.size.width * 0.15;
    final double titleFontSize = isTV ? 12 : widget.size.width * 0.027;
    final double percentFontSize = isTV ? 16 : widget.size.width * 0.035;
    final double amountFontSize = isTV ? 11 : widget.size.width * 0.023;
    final double strokeWidth = isTV ? 6 : widget.size.width * 0.012;

    Widget cardContent = Container(
      height: cardHeight,
      child: Card(
        elevation: _isFocused ? 8 : 3,
        color: AppColors.appColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _isFocused
              ? BorderSide(color: Colors.white, width: 2.5)
              : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isTV ? 12 : widget.size.height * 0.01,
            horizontal: isTV ? 8 : widget.size.width * 0.01,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Container(
                height: isTV ? 28 : widget.size.height * 0.03,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _isFocused ? Colors.white : AppColors.whiteBg,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: AppColors.appColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

              // Circular progress
              Stack(alignment: Alignment.center, children: [
                SizedBox(
                  height: progressSize,
                  width: progressSize,
                  child: CircularProgressIndicator(
                    value: widget.percent / 100,
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: strokeWidth,
                  ),
                ),
                Text(
                  '${widget.percent}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: percentFontSize,
                  ),
                ),
              ]),

              // Amount
              Text(
                widget.amount,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.whiteBg,
                  fontSize: amountFontSize,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    if (!isTV || widget.onTap == null) {
      return Expanded(child: cardContent);
    }

    // TV pe focusable
    return Expanded(
      child: Focus(
        onFocusChange: (f) => setState(() => _isFocused = f),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter)) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isFocused ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: cardContent,
          ),
        ),
      ),
    );
  }
}