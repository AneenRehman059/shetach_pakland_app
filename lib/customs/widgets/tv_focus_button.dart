import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../function/screen_helper.dart';

/// TV pe focus highlight dikhata hai, mobile pe normal InkWell
class TVFocusButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  const TVFocusButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
  });

  @override
  State<TVFocusButton> createState() => _TVFocusButtonState();
}

class _TVFocusButtonState extends State<TVFocusButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    // Mobile pe normal InkWell — koi change nahi
    if (!isTV) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: widget.borderRadius,
        child: widget.child,
      );
    }

    // TV pe focus highlight
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
            borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 12,
                spreadRadius: 2,
              )
            ]
                : [],
          ),
          child: Transform.scale(
            scale: _isFocused ? 1.05 : 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}