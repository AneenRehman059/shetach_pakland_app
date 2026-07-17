import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../controllers/get_events_controller.dart';
import '../../constants/api_constant.dart';
import 'constants/image_url_helper.dart';
import 'dashboard/develope_progress_det_screen.dart';
import '../../colors.dart';
import '../../function/screen_helper.dart';

class GetDevelopmentProgressScreen extends StatelessWidget {
  final EventsController eventsController = Get.put(EventsController());
  GetDevelopmentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bool isTV = ScreenHelper.isTV(context);

    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
        child: AppBar(
          title: Text("Development Progress", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          SizedBox(height: screenHeight * 0.015),
          Expanded(
            child: Obx(() {
              if (eventsController.isLoading.value) {
                return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Center(child: SpinKitWave(color: AppColors.appColor, size: isTV ? 60 : 50)),
                  Text('Loading', style: TextStyle(color: AppColors.appColor, fontSize: isTV ? 18 : 14)),
                ]);
              }

              if (eventsController.uniqueDevelopment.isEmpty) {
                return Center(child: Text("No Development Progress found", style: TextStyle(color: Colors.black, fontSize: isTV ? 20 : 14)));
              }

              // TV pe 4 column, tablet pe 3, mobile pe 2
              final int crossAxisCount = isTV ? 4 : (screenWidth > 600 ? 3 : 2);
              final double aspectRatio = isTV ? 1.0 : (screenWidth > 600 ? 0.9 : 0.8);

              return GridView.builder(
                padding: EdgeInsets.all(isTV ? 24 : screenWidth * 0.03),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isTV ? 20 : screenWidth * 0.03,
                  mainAxisSpacing: isTV ? 20 : screenWidth * 0.03,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: eventsController.uniqueDevelopment.length,
                itemBuilder: (context, index) {
                  final dev = eventsController.uniqueDevelopment[index];
                  final imageUrl = ImageUrlHelper.resolve(dev.imagePath, ApiConstants.baseUrl);

                  return isTV
                      ? _TVDevCard(
                    imageUrl: imageUrl,
                    eventName: dev.eventName,
                    screenHeight: screenHeight,
                    isTV: isTV,
                    onTap: () => Get.to(() => DevelopmentProgressDetailScreen(
                        eventId: dev.eventId, eventName: dev.eventName)),
                  )
                      : _MobileDevCard(
                    imageUrl: imageUrl,
                    eventName: dev.eventName,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () => Get.to(() => DevelopmentProgressDetailScreen(
                        eventId: dev.eventId, eventName: dev.eventName)),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }
}

// ─── TV Card — with focus highlight ───────────────────────────────────────────
class _TVDevCard extends StatefulWidget {
  final String imageUrl;
  final String eventName;
  final double screenHeight;
  final bool isTV;
  final VoidCallback onTap;

  const _TVDevCard({
    required this.imageUrl,
    required this.eventName,
    required this.screenHeight,
    required this.isTV,
    required this.onTap,
  });

  @override
  State<_TVDevCard> createState() => _TVDevCardState();
}

class _TVDevCardState extends State<_TVDevCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? AppColors.appColor : Colors.transparent,
              width: 3,
            ),
            boxShadow: _isFocused
                ? [BoxShadow(color: AppColors.appColor.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)]
                : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
            color: _isFocused ? AppColors.appColor.withOpacity(0.05) : Colors.white,
          ),
          child: AnimatedScale(
            scale: _isFocused ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                child: Image.network(
                  widget.imageUrl,
                  height: widget.screenHeight * 0.22,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  errorBuilder: (ctx, e, s) => Container(
                    height: widget.screenHeight * 0.22,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.eventName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isFocused ? AppColors.appColor : AppColors.black,
                  ),
                ),
              ),
              // Focus indicator arrow
              if (_isFocused)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Row(children: [
                    Icon(Icons.play_arrow, color: AppColors.appColor, size: 18),
                    Text('Open', style: TextStyle(color: AppColors.appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  ]),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Mobile Card — same as before ─────────────────────────────────────────────
class _MobileDevCard extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const _MobileDevCard({
    required this.imageUrl,
    required this.eventName,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.01),
          child: Image.network(
            imageUrl,
            height: screenHeight * 0.2,
            width: double.infinity,
            fit: BoxFit.fill,
            errorBuilder: (ctx, e, s) => const Icon(Icons.broken_image, size: 60, color: Colors.white),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          eventName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ]),
    );
  }
}