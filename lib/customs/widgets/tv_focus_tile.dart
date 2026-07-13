// lib/customs/widgets/tv_focus_tile.dart
// TV pe focusable row — white highlight + border jab focus aaye

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVFocusTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? focusColor;
  final BorderRadius? borderRadius;

  const TVFocusTile({
    super.key,
    required this.child,
    required this.onTap,
    this.focusColor,
    this.borderRadius,
  });

  @override
  State<TVFocusTile> createState() => _TVFocusTileState();
}

class _TVFocusTileState extends State<TVFocusTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isFocused
                ? (widget.focusColor ?? Colors.blue).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused
                  ? (widget.focusColor ?? Colors.blue)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: (widget.focusColor ?? Colors.blue).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}