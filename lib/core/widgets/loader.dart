import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// App-wide loader. Every loading indicator in the app uses this widget
/// so that `assets/images/loading.json` is the only loader animation.
///
/// * If the parent gives it a tight size (e.g. `SizedBox(width: 20, height: 20)`)
///   it fills that space.
/// * Otherwise it uses [size] (default 60).
class AppLoader extends StatelessWidget {
  final double? size;

  const AppLoader({super.key, this.size});

  static const String asset = 'assets/images/loading.json';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool tight = constraints.hasTightWidth &&
            constraints.hasTightHeight &&
            constraints.maxWidth.isFinite &&
            constraints.maxHeight.isFinite;

        if (size == null && tight) {
          return Lottie.asset(asset, fit: BoxFit.contain);
        }

        final double s = size ?? 60;
        return SizedBox(
          width: s,
          height: s,
          child: Lottie.asset(asset, fit: BoxFit.contain),
        );
      },
    );
  }
}
