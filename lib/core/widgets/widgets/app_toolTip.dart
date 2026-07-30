import 'package:flutter/material.dart';

class AppTooltip extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final double size;

  const AppTooltip({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color = Colors.grey,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}