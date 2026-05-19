import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pakland/colors.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final BoxFit fit;
  final Duration autoScrollInterval;

  const ImageSlider({
    super.key,
    required this.imagePaths,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.autoScrollInterval = const Duration(seconds: 3),
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollInterval, (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.imagePaths.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handlePageChange(int index) {
    setState(() => _currentPage = index);
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: _handlePageChange,
        itemBuilder: (context, index) {
          return Image.asset(
            widget.imagePaths[index],
            fit: widget.fit,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.error)),
              );
            },
          );
        },
      ),
    );
  }
}
