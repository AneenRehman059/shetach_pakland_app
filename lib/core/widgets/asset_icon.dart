import 'package:flutter/material.dart';

class AssetIcon extends StatelessWidget {
  final String path;
  final double size;
  final Color? color;

  const AssetIcon(this.path, {super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color ?? IconTheme.of(context).color,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}
