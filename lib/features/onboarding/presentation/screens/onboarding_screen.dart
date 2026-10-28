import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';

class _OnboardData {
  final String image;
  final String title;
  final String description;

  const _OnboardData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brandColor = Color(0xFF0F3E49);

  final PageController _pageController = PageController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int _currentPage = 0;

  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  final List<_OnboardData> _pages = const [
    _OnboardData(
      image: 'assets/images/dashboard.jpeg',
      title: 'All Your Services,\nOne Dashboard',
      description:
      'Access Customer Portal, Billing, Payment Plans, Bookings and more from a single home screen.',
    ),
    _OnboardData(
      image: 'assets/images/cportal.jpeg',
      title: 'Your Customer Portal',
      description:
      'View your personal info, file status and complete payment details anytime, anywhere.',
    ),
    _OnboardData(
      image: 'assets/images/opayment.jpeg',
      title: 'Pay Securely Online',
      description:
      'Confirm your booking, check outstanding dues and pay instantly right from your phone.',
    ),
    _OnboardData(
      image: 'assets/images/preceipt.jpeg',
      title: 'Track Every Receipt',
      description:
      'Keep a clear record of all your payments with detailed, easy to review receipts.',
    ),
    _OnboardData(
      image: 'assets/images/astatement.jpeg',
      title: 'Full Account Statement',
      description:
      'Get a complete breakdown of installments, dues and your entire payment history.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finishOnboarding() async {

    try {
      await _storage.write(key: "onboarding_seen", value: "true");
    } catch (e) {
      debugPrint("Secure storage write error: $e");
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3A5E68),
              Color(0xFF14586A),
              Color(0xFF2FA8C4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: TextButton(
                    onPressed: isLastPage ? null : _finishOnboarding,
                    child: Text(
                      isLastPage ? '' : 'Skip',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: Listenable.merge([_pageController, _floatController]),
                      builder: (context, child) {
                        double page = index.toDouble();
                        if (_pageController.position.haveDimensions) {
                          page = _pageController.page ?? _currentPage.toDouble();
                        }
                        final double pageOffset = (page - index).clamp(-1.0, 1.0);

                        final double floatY =
                            sin(_floatController.value * 2 * pi) *
                                6 *
                                (1 - pageOffset.abs()).clamp(0.0, 1.0);

                        return _OnboardPage(
                          data: _pages[index],
                          brandColor: _brandColor,
                          pageOffset: pageOffset,
                          floatY: floatY,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final bool active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 22 : 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _brandColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        key: ValueKey(isLastPage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  final Color brandColor;
  final double pageOffset;
  final double floatY;

  const _OnboardPage({
    required this.data,
    required this.brandColor,
    required this.pageOffset,
    required this.floatY,
  });

  @override
  Widget build(BuildContext context) {
    final double absOffset = pageOffset.abs();

    final double cardShift = pageOffset * 30;
    final double cardOpacity = (1 - absOffset * 0.8).clamp(0.0, 1.0);

    final double imageShift = pageOffset * 55;
    final double imageScale = (1 - (absOffset * 0.38)).clamp(0.55, 1.0);
    final double imageOpacity = (1 - absOffset * 0.72).clamp(0.0, 1.0);

    final double arcLift = -sin(absOffset.clamp(0.0, 1.0) * pi) * 18;

    final double blurSigma = sin(absOffset.clamp(0.0, 1.0) * pi) * 10;

    final double titleShift = pageOffset * 60;
    final double titleOpacity = (1 - absOffset * 1.6).clamp(0.0, 1.0);

    final double descShift = pageOffset * 70;
    final double descOpacity = (1 - absOffset * 2.0).clamp(0.0, 1.0);

    final Size screenSize = MediaQuery.of(context).size;
    final bool isShortScreen = screenSize.height < 700;
    final bool isNarrowScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {

        final double imageBoxHeight =
        (constraints.maxHeight * 0.62).clamp(240.0, 460.0);
        final double imageAssetHeight = imageBoxHeight * 0.99;
        final double imageAssetWidth = imageAssetHeight * (190 / 400);

        final double titleFontSize = isShortScreen ? 20 : (isNarrowScreen ? 22 : 24);
        final double descFontSize = isShortScreen ? 13 : 14;
        final double spacingAfterImage = isShortScreen ? 16 : 32;
        final double spacingAfterTitle = isShortScreen ? 8 : 12;
        final double verticalCardPadding = isShortScreen ? 16 : 28;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(cardShift, 0),
                      child: Opacity(
                        opacity: cardOpacity,
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.10),
                                    Colors.white.withOpacity(0.08),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalCardPadding,
                      horizontal: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: imageBoxHeight,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(imageShift, floatY + arcLift),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0022)
                                  ..rotateY(pageOffset * 1.4),
                                child: Transform.scale(
                                  scale: imageScale,
                                  child: Opacity(
                                    opacity: imageOpacity,
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: blurSigma,
                                        sigmaY: blurSigma * 0.4,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.25),
                                              blurRadius: 24,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset(
                                            data.image,
                                            height: imageAssetHeight,
                                            width: imageAssetWidth,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacingAfterImage),
                        Transform.translate(
                          offset: Offset(titleShift, 0),
                          child: Opacity(
                            opacity: titleOpacity,
                            child: Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacingAfterTitle),
                        Transform.translate(
                          offset: Offset(descShift, 0),
                          child: Opacity(
                            opacity: descOpacity,
                            child: Text(
                              data.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: descFontSize,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}