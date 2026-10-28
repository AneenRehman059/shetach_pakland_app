import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/theme/colors.dart';

class AuthLayoutInfo {
  final double gap;


  final bool compact;

  const AuthLayoutInfo({required this.gap, required this.compact});
}


class AuthHeroLayout extends StatelessWidget {
  final String title;
  final String subtitle;

  final IconData heroIcon;

  final Widget Function(BuildContext context, AuthLayoutInfo info) cardBuilder;

  final VoidCallback? onBack;

  final Widget? trailing;

  const AuthHeroLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardBuilder,
    this.heroIcon = Icons.lock_rounded,
    this.onBack,
    this.trailing,
  });

  static const double _barH = 56;

  Widget _orb(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bool keyboardOpen = mq.viewInsets.bottom > 0;
    final double safeTop = mq.padding.top;
    final double safeBottom = mq.padding.bottom;
    final double screenW = mq.size.width;
    final bool canBack = onBack != null || Navigator.of(context).canPop();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final double w = c.hasBoundedWidth ? c.maxWidth : screenW;
          final double h = c.hasBoundedHeight ? c.maxHeight : mq.size.height;

          final bool compact = keyboardOpen || h < 620;
          final bool tall = !compact && h >= 740;

          final double contentH = compact ? 0 : (tall ? 164 : 94);
          final double spacer = compact ? 4 : contentH + 8;
          final double overlap = compact ? 26 : (tall ? 40 : 36);
          final double cardTop = safeTop + _barH + spacer;
          final double heroH = cardTop + overlap;
          final double gap = tall ? 14 : (compact ? 10 : 12);
          final double cardPad = compact ? 14 : (tall ? 18 : 16);

          final info = AuthLayoutInfo(gap: gap, compact: compact);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: heroH,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.appColor,
                            Color.lerp(AppColors.appColor, Colors.black, 0.30)!,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(34),
                          bottomRight: Radius.circular(34),
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
                            top: -screenW * 0.22,
                            right: -screenW * 0.16,
                            child: _orb(screenW * 0.6, 0.05),
                          ),
                          Positioned(
                            bottom: -screenW * 0.2,
                            left: -screenW * 0.14,
                            child: _orb(screenW * 0.45, 0.045),
                          ),
                          Positioned(
                            top: safeTop + _barH + 10,
                            left: screenW * 0.1,
                            child: _orb(14, 0.10),
                          ),
                          Positioned(
                            top: safeTop + _barH + 46,
                            right: screenW * 0.1,
                            child: _orb(9, 0.12),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.07),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.55],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!compact)
                    Positioned(
                      top: safeTop + _barH,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: contentH,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: screenW - 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _LogoBadge(
                                  size: tall ? 72 : 60,
                                  ring: tall,
                                  icon: heroIcon,
                                ),
                                SizedBox(height: tall ? 10 : 8),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: tall ? 22 : 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                    height: 1.2,
                                  ),
                                ),
                                if (tall) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.80),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: safeTop,
                    left: 0,
                    right: 0,
                    height: _barH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          if (canBack)
                            _GlassIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () {
                                if (onBack != null) {
                                  onBack!();
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              },
                            )
                          else
                            const SizedBox(width: 6),
                          if (compact) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            const Spacer(),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    top: safeTop + _barH,
                    bottom: 0,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(16, spacer, 16, 16 + safeBottom),
                      child: Container(
                        padding: EdgeInsets.all(cardPad),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xFFE8ECF4)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.appColor.withOpacity(0.14),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: cardBuilder(context, info),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final double size;
  final bool ring;
  final IconData icon;

  const _LogoBadge({
    required this.size,
    required this.ring,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double outer = ring ? size + 16 : size;

    final Widget logoCircle = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.17),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        ImageConstant.logo,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(icon, color: AppColors.appColor, size: size * 0.5),
      ),
    );

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: outer,
            height: outer,
            alignment: Alignment.center,
            decoration: ring
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    border: Border.all(color: Colors.white.withOpacity(0.30)),
                  )
                : null,
            child: logoCircle,
          ),
        ],
      ),
    );
  }
}


class AuthPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String errorText;
  final bool obscure;
  final VoidCallback onToggle;
  final IconData icon;
  final TextInputAction action;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final List<Widget> extras;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.obscure,
    required this.onToggle,
    this.errorText = '',
    this.icon = Icons.lock_outline_rounded,
    this.action = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.extras = const [],
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _focused = false;

  void _onFocusChange() {
    if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void initState() {
    super.initState();
    _focused = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AuthPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText.isNotEmpty;
    final Color borderColor = hasError
        ? Colors.red.shade400
        : (_focused ? AppColors.appColor : const Color(0xFFE2E8F0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: 0.2,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _focused ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: (_focused || hasError) ? 1.6 : 1.2,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.appColor.withOpacity(0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: _focused
                      ? AppColors.appColor
                      : const Color(0xFF9AA5B4),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  obscureText: widget.obscure,
                  enableSuggestions: false,
                  autocorrect: false,
                  textInputAction: widget.action,
                  cursorColor: AppColors.appColor,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA0AAB8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  widget.obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                onPressed: widget.onToggle,
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: Colors.red.shade500,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ...widget.extras,
      ],
    );
  }
}

class PasswordStrengthMeter extends StatelessWidget {
  final String strength;
  final Color color;

  const PasswordStrengthMeter({
    super.key,
    required this.strength,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (strength.isEmpty) return const SizedBox.shrink();
    final int level =
        strength == 'Strong' ? 3 : (strength == 'Average' ? 2 : 1);

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 2, right: 2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 5,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: i < level ? color : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strength,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRequirementChips extends StatelessWidget {
  final String password;

  const PasswordRequirementChips({super.key, required this.password});

  Widget _chip(String text, bool ok) {
    final Color green = Colors.green.shade600;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: ok ? green.withOpacity(0.10) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ok ? green.withOpacity(0.45) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 13,
            color: ok ? green : Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: ok ? green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMinLength = password.length >= 8;
    final bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final bool hasSpecialChar =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _chip('8+ characters', hasMinLength),
          _chip('Uppercase', hasUppercase),
          _chip('Lowercase', hasLowercase),
          _chip('Number', hasNumber),
          _chip('Special character', hasSpecialChar),
        ],
      ),
    );
  }
}

class PasswordMatchIndicator extends StatelessWidget {
  final bool match;

  const PasswordMatchIndicator({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final Color color = match ? Colors.green.shade600 : Colors.red.shade400;
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(
            match ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            match ? 'Passwords match' : 'Passwords do not match',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.appColor,
            Color.lerp(AppColors.appColor, Colors.black, 0.25)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.40),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const AppLoader(size: 24)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class AuthInfoCaption extends StatelessWidget {
  final String text;

  const AuthInfoCaption({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
