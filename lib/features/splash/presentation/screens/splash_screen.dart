import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/services/fcm_notification_service.dart';
import 'package:pakland/core/constants/image_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    // ✅ No need to capture here anymore — already done in main()
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _checkLoginStatus(context);
    });
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    String? userId;

    try {
      userId = await _storage.read(key: "user_id");
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
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    const Text(
                      'PAKLAND HOUSING',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // Text(
                    //   'A Project of BSM Developers',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.black,
                    //   ),
                    // ),
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