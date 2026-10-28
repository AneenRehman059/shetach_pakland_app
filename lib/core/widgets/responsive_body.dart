import 'package:flutter/material.dart';

class ResponsiveBody extends StatelessWidget {
  final Widget child;

  final double maxWidth;

  final double designWidth;

  final double maxScale;

  const ResponsiveBody({
    Key? key,
    required this.child,
    this.maxWidth = 0,
    this.designWidth = 400,
    this.maxScale = 2.4,
  }) : super(key: key);

  static bool isTabletWidth(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.size.shortestSide < 600) return child;

    return LayoutBuilder(
      builder: (context, c) {
        if (!c.hasBoundedWidth || !c.hasBoundedHeight) return child;

        final double s =
            (mq.size.shortestSide / designWidth).clamp(1.0, maxScale).toDouble();
        final double w = c.maxWidth / s;
        final double h = c.maxHeight / s;

        return SizedBox(
          width: c.maxWidth,
          height: c.maxHeight,
          child: ClipRect(
            child: Transform.scale(
              scale: s,
              alignment: Alignment.topLeft,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: w,
                maxWidth: w,
                minHeight: h,
                maxHeight: h,
                child: MediaQuery(
                  data: mq.copyWith(
                    size: Size(w, h),
                    padding: mq.padding / s,
                    viewPadding: mq.viewPadding / s,
                    viewInsets: mq.viewInsets / s,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
