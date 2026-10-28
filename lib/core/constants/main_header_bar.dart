import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';

enum DayPhase { morning, afternoon, evening, night }

DayPhase dayPhaseFor(DateTime t) {
  final h = t.hour;
  if (h >= 5 && h < 12) return DayPhase.morning;
  if (h >= 12 && h < 17) return DayPhase.afternoon;
  if (h >= 17 && h < 20) return DayPhase.evening;
  return DayPhase.night;
}

class _PhaseTheme {
  final List<Color> gradient;
  final String greeting;
  final IconData icon;
  final Color iconColor;

  const _PhaseTheme({
    required this.gradient,
    required this.greeting,
    required this.icon,
    required this.iconColor,
  });
}

_PhaseTheme _themeFor(DayPhase p) {
  switch (p) {
    case DayPhase.morning:
      return const _PhaseTheme(
        gradient: [Color(0xFF1F4B59), Color(0xFF3A8490)],
        greeting: 'Good morning',
        icon: Icons.wb_twilight_rounded,
        iconColor: Color(0xFFFFD27A),
      );
    case DayPhase.afternoon:
      return const _PhaseTheme(
        gradient: [Color(0xFF1F4B59), Color(0xFF4F8B99)],
        greeting: 'Good afternoon',
        icon: Icons.wb_sunny_rounded,
        iconColor: Color(0xFFFFE08A),
      );
    case DayPhase.evening:
      return const _PhaseTheme(
        gradient: [Color(0xFF1F4B59), Color(0xFF7A4A66)],
        greeting: 'Good evening',
        icon: Icons.wb_twilight_rounded,
        iconColor: Color(0xFFFFB27A),
      );
    case DayPhase.night:
      return const _PhaseTheme(
        gradient: [Color(0xFF07151D), Color(0xFF173B49)],
        greeting: 'Good night',
        icon: Icons.nights_stay_rounded,
        iconColor: Color(0xFFFFF3C4),
      );
  }
}

class MainHeaderBar extends StatefulWidget implements PreferredSizeWidget {
  final RxString userName;

  final RxString userType;

  final RxInt notificationCount;

  final VoidCallback? onNotificationTap;

  const MainHeaderBar({
    super.key,
    required this.userName,
    required this.userType,
    required this.notificationCount,
    this.onNotificationTap,
  });

  static const double _rowHeight = 68;

  @override
  Size get preferredSize => const Size.fromHeight(_rowHeight + 14);

  @override
  State<MainHeaderBar> createState() => _MainHeaderBarState();
}

class _MainHeaderBarState extends State<MainHeaderBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Timer? _timer;
  late DayPhase _phase;

  @override
  void initState() {
    super.initState();
    _phase = dayPhaseFor(DateTime.now());
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final p = dayPhaseFor(DateTime.now());
      if (p != _phase && mounted) setState(() => _phase = p);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final w = screenSize.width;
    final bool wideScreen = screenSize.height > screenSize.width &&
        (screenSize.width / screenSize.height) > 0.58;
    final theme = _themeFor(_phase);
    final base = theme.gradient.first;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.gradient.last.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -w * 0.22,
            right: -w * 0.14,
            child: _orb(w * 0.55, 0.05),
          ),
          Positioned(
            bottom: -w * 0.26,
            left: -w * 0.10,
            child: _orb(w * 0.40, 0.045),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _SkyPainter(_phase, _anim)),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: MainHeaderBar._rowHeight + 14,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, wideScreen ? 10 : 0, 16, wideScreen ? 4 : 14),
                child: Row(
                  children: [
                    _logo(),
                    const SizedBox(width: 12),
                    Expanded(child: _greetingBlock(w, theme)),
                    Obx(() {
                      if (widget.userType.value != 'Admin') {
                        return const SizedBox.shrink();
                      }
                      return _bell(base);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  Widget _logo() {
    return Image.asset(
      ImageConstant.logo,
      fit: BoxFit.cover,
      height: 75,
      width: 80,
    );
  }

  Widget _greetingBlock(double w, _PhaseTheme theme) {
    return Obx(() {
      final name = widget.userName.value.trim();
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(theme.icon, size: 15, color: theme.iconColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  theme.greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (w * 0.032).clamp(11.0, 15.0),
                    color: Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: (w * 0.046).clamp(15.0, 22.0),
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _bell(Color badgeBorder) {
    return Obx(() {
      final count = widget.notificationCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.white.withOpacity(0.14),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onNotificationTap,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.notifications_rounded,
                  color: Colors.yellowAccent.shade700,
                  size: 24,
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints:
                const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeBorder, width: 1.5),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _SkyPainter extends CustomPainter {
  final DayPhase phase;
  final Animation<double> anim;

  _SkyPainter(this.phase, this.anim) : super(repaint: anim);

  static const List<Offset> _stars = [
    Offset(0.07, 0.22),
    Offset(0.19, 0.70),
    Offset(0.31, 0.20),
    Offset(0.44, 0.78),
    Offset(0.54, 0.16),
    Offset(0.66, 0.62),
    Offset(0.73, 0.18),
    Offset(0.90, 0.28),
    Offset(0.60, 0.86),
    Offset(0.95, 0.74),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    switch (phase) {
      case DayPhase.morning:
        _clouds(canvas, size, t, 0.13);
        _sun(canvas, size, Offset(size.width * 0.80, size.height * 0.70),
            const Color(0xFFFFD27A), t,
            rays: false);
        break;
      case DayPhase.afternoon:
        _clouds(canvas, size, t, 0.14);
        _sun(canvas, size, Offset(size.width * 0.82, size.height * 0.34),
            const Color(0xFFFFE08A), t,
            rays: true);
        break;
      case DayPhase.evening:
        _starField(canvas, size, t, count: 4, strength: 0.55);
        _sun(canvas, size, Offset(size.width * 0.80, size.height * 0.78),
            const Color(0xFFFF9E5E), t,
            rays: false);
        break;
      case DayPhase.night:
        _starField(canvas, size, t, count: _stars.length, strength: 1.0);
        _moon(canvas, size, Offset(size.width * 0.82, size.height * 0.40), t);
        break;
    }
  }

  void _sun(Canvas canvas, Size size, Offset c, Color color, double t,
      {required bool rays}) {
    final pulse = 1 + 0.06 * math.sin(t * 2 * math.pi * 6);

    final glowR = 66.0 * pulse;
    canvas.drawCircle(
      c,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.50), color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: c, radius: glowR)),
    );

    if (rays) {
      final rayPaint = Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 10; i++) {
        final a = t * 2 * math.pi + i * (2 * math.pi / 10);
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c + dir * 24, c + dir * 33, rayPaint);
      }
    }

    canvas.drawCircle(c, 15, Paint()..color = color);
    canvas.drawCircle(
      c,
      15,
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _moon(Canvas canvas, Size size, Offset c, double t) {
    final pulse = 1 + 0.05 * math.sin(t * 2 * math.pi * 4);
    final glowR = 58.0 * pulse;
    const moonColor = Color(0xFFFFF3C4);

    canvas.drawCircle(
      c,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [moonColor.withOpacity(0.30), moonColor.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: c, radius: glowR)),
    );

    final full = Path()..addOval(Rect.fromCircle(center: c, radius: 14));
    final cut = Path()
      ..addOval(Rect.fromCircle(center: c + const Offset(7, -4), radius: 12));
    final crescent = Path.combine(PathOperation.difference, full, cut);
    canvas.drawPath(crescent, Paint()..color = moonColor);
  }

  void _starField(Canvas canvas, Size size, double t,
      {required int count, required double strength}) {
    final paint = Paint();
    for (int i = 0; i < count && i < _stars.length; i++) {
      final s = _stars[i];
      final tw = (math.sin(t * 2 * math.pi * 6 + i * 1.3) + 1) / 2;
      final opacity = ((0.30 + 0.70 * tw) * strength).clamp(0.0, 1.0);
      final r = (i % 3 == 0) ? 1.9 : 1.3;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(size.width * s.dx, size.height * s.dy),
        r,
        paint,
      );
    }
  }

  void _clouds(Canvas canvas, Size size, double t, double opacity) {
    const clouds = [
      [0.10, 0.30, 1.0],
      [0.55, 0.62, 0.75],
      [0.85, 0.22, 0.6],
    ];
    for (final c in clouds) {
      final x = (((c[0] + t * 1.2) % 1.2) - 0.2) * size.width;
      _cloud(canvas, Offset(x, size.height * c[1]), c[2], opacity);
    }
  }

  void _cloud(Canvas canvas, Offset o, double s, double opacity) {
    final p = Paint()..color = Colors.white.withOpacity(opacity);
    canvas.drawCircle(o + Offset(-14 * s, 2 * s), 9 * s, p);
    canvas.drawCircle(o + Offset(0, -4 * s), 13 * s, p);
    canvas.drawCircle(o + Offset(15 * s, 2 * s), 10 * s, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(o.dx - 23 * s, o.dy + 2 * s, 48 * s, 10 * s),
        Radius.circular(5 * s),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.phase != phase;
}