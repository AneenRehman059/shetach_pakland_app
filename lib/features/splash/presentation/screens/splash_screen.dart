import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';
import 'package:pakland/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/services/video_background_service.dart';
import 'package:pakland/core/constants/image_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late AnimationController _textController;
  final String _housingText = "Housing";

  late Animation<double> _underlineAnimation;

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _underlineAnimation = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _textController.forward();

    _waitThenProceed();
  }
  Animation<double> _letterFade(int index) {
    final total = _housingText.length;
    final start = (index / total) * 0.7;
    final end = (start + 0.35).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _textController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Future<void> _waitThenProceed() async {
    final minDelay = Future.delayed(const Duration(seconds: 4));

    final videoReady = VideoBackgroundService.instance
        .initialize()
        .timeout(const Duration(seconds: 5), onTimeout: () {});

    await Future.wait([minDelay, videoReady]);

    if (mounted) _checkLoginStatus(context);
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    String? userId;
    String? onboardingSeen;

    try {
      userId = await _storage.read(key: "user_id");
      onboardingSeen = await _storage.read(key: "onboarding_seen");
    } catch (e) {
      debugPrint("Secure storage read error: $e");
      await _storage.deleteAll();
    }

    if (!mounted) return;

    if (userId != null && userId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainWrapper()),
      );
      return;
    }

    if (onboardingSeen == null || onboardingSeen.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(ImageConstant.welcome, fit: BoxFit.cover),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WELCOME TO',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PakLand ',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.t1,
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: List.generate(_housingText.length, (
                                  i,
                                  ) {
                                final anim = _letterFade(i);
                                return AnimatedBuilder(
                                  animation: anim,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: anim.value,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          (1 - anim.value) * 10,
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _housingText[i],
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.t2,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: ScaleTransition(
                    scale: _animation,
                    child: Image.asset(
                      ImageConstant.logo,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}