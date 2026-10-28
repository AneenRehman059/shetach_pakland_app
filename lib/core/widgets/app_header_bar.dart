import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/asset_icon.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;

  final String? subtitle;

  final Widget? leading;

  final bool automaticallyImplyLeading;

  final VoidCallback? onBackPressed;

  final List<Widget>? actions;

  final PreferredSizeWidget? bottom;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;
  final double? elevation;
  final bool? centerTitle;
  final double? toolbarHeight;

  const AppHeaderBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.elevation,
    this.centerTitle,
    this.toolbarHeight,
  });

  static const double _rowHeight = 64;

  @override
  Size get preferredSize =>
      Size.fromHeight(_rowHeight + (bottom?.preferredSize.height ?? 0) + 12);

  String? get _titleText {
    final t = title;
    if (t is Text) return t.data ?? t.textSpan?.toPlainText();
    return null;
  }

  void _handleBack(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
    } else if (Navigator.of(context).canPop()) {
      Get.back();
    }
  }

  Widget _glassCircle({required Widget child, double size = 42}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final double titleSize = (w * 0.05).clamp(16.0, 22.0).toDouble();
    final double subtitleSize = (w * 0.03).clamp(11.0, 13.0).toDouble();
    final double sidePad = (w * 0.03).clamp(8.0, 20.0).toDouble();
    final double gapAfterLeading = (w * 0.032).clamp(8.0, 16.0).toDouble();
    final canPop = Navigator.of(context).canPop();
    final showBack = leading != null || (automaticallyImplyLeading && canPop);

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = _glassCircle(
        child: IconTheme(
          data: const IconThemeData(color: Colors.white, size: 22),
          child: Center(child: leading),
        ),
      );
    } else if (showBack) {
      leadingWidget = Material(
        color: Colors.white.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _handleBack(context),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
      );
    }

    final titleText = _titleText;
    final Widget titleWidget = titleText != null
        ? Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: titleSize,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              height: 1.15,
            ),
          )
        : (title ?? const SizedBox.shrink());

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -w * 0.22,
            right: -w * 0.16,
            child: Container(
              width: w * 0.6,
              height: w * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -w * 0.28,
            left: -w * 0.12,
            child: Container(
              width: w * 0.42,
              height: w * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.045),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _rowHeight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 0),
                    child: Row(
                      children: [
                        if (leadingWidget != null) ...[
                          leadingWidget,
                          SizedBox(width: gapAfterLeading),
                        ] else
                          SizedBox(width: sidePad * 0.6),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultTextStyle.merge(
                                style: const TextStyle(color: Colors.white),
                                child: titleWidget,
                              ),
                              if (subtitle != null && subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: subtitleSize,
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (actions != null && actions!.isNotEmpty)
                          IconTheme(
                            data: const IconThemeData(color: Colors.white),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: actions!,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (bottom != null) bottom!,
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppHeaderAction extends StatelessWidget {
  final IconData? icon;

  final String? assetIcon;
  final VoidCallback onPressed;
  final String? tooltip;

  const AppHeaderAction({
    super.key,
    this.icon,
    this.assetIcon,
    required this.onPressed,
    this.tooltip,
  }) : assert(icon != null || assetIcon != null);

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: assetIcon != null
                ? AssetIcon(assetIcon!, color: Colors.white, size: 21)
                : Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: tooltip == null ? button : Tooltip(message: tooltip!, child: button),
    );
  }
}
