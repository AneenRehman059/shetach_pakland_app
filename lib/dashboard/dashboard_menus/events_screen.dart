import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../colors.dart';
import '../../constants/api_constant.dart';
import '../../controllers/get_events_controller.dart';
import '../../models/get_events_model.dart';
import '../../function/screen_helper.dart';
import 'get_events_detail_screen.dart' show EventDetailScreen;

class GetEventsScreen extends StatelessWidget {
  final EventsController eventsController = Get.put(EventsController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTV = ScreenHelper.isTV(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black38,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
          child: AppBar(
            title: Text("Events", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
            centerTitle: true,
            backgroundColor: AppColors.appColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (eventsController.isLoading.value) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SpinKitWave(color: AppColors.appColor, size: isTV ? 60 : screenWidth * 0.12),
                Text("Loading", style: TextStyle(fontSize: isTV ? 18 : screenWidth * 0.04, color: AppColors.appColor)),
              ]));
            }

            if (eventsController.uniqueEvents.isEmpty) {
              return Center(child: Text('No events available', style: TextStyle(fontSize: isTV ? 20 : screenWidth * 0.04, color: AppColors.black)));
            }

            // TV pe 4 column, tablet pe 3, mobile pe 2
            final int crossAxisCount = isTV ? 4 : (screenWidth > 600 ? 3 : 2);

            return Padding(
              padding: EdgeInsets.all(isTV ? 20 : 8),
              child: GridView.builder(
                padding: EdgeInsets.only(top: isTV ? 16 : screenWidth * 0.03, left: isTV ? 0 : screenWidth * 0.01),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isTV ? 20 : screenWidth * 0.02,
                  mainAxisSpacing: isTV ? 20 : screenWidth * 0.01,
                ),
                itemCount: eventsController.uniqueEvents.length,
                itemBuilder: (context, index) {
                  final event = eventsController.uniqueEvents[index];
                  final imageUrl = '${ApiConstants.baseUrl}${event.imagePath}';

                  // TV pe focus wrapper
                  if (isTV) {
                    return _TVFocusCard(
                      onTap: () => Get.to(() => EventDetailScreen(eventId: event.eventId, eventName: event.eventName)),
                      child: _EventCard(
                        imageUrl: imageUrl,
                        eventName: event.eventName,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isTV: true,
                      ),
                    );
                  }

                  // Mobile — same as before
                  return GestureDetector(
                    onTap: () => Get.to(() => EventDetailScreen(eventId: event.eventId, eventName: event.eventName)),
                    child: _EventCard(
                      imageUrl: imageUrl,
                      eventName: event.eventName,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isTV: false,
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Shared card widget ────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final String imageUrl;
  final String eventName;
  final double screenWidth;
  final double screenHeight;
  final bool isTV;

  const _EventCard({
    required this.imageUrl,
    required this.eventName,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTV,
  });

  @override
  Widget build(BuildContext context) {
    final double imgHeight = isTV ? screenHeight * 0.22 : screenHeight * 0.15;
    final double radius = isTV ? 14 : screenWidth * 0.04;
    final double fontSize = isTV ? 15 : screenWidth * 0.03;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: imgHeight,
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), color: Colors.grey[300]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.network(
            imageUrl,
            fit: BoxFit.fill,
            errorBuilder: (ctx, e, s) => Container(color: Colors.grey[300], child: Icon(Icons.error, color: Colors.grey[600], size: screenWidth * 0.1)),
            loadingBuilder: (ctx, child, p) => p == null ? child : Center(child: SpinKitWave(color: AppColors.appColor, size: isTV ? 30 : screenWidth * 0.08)),
          ),
        ),
      ),
      SizedBox(height: screenHeight * 0.01),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: isTV ? 4 : 0),
        child: Text(
          eventName,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: AppColors.black),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}

// ─── TV Focus Card ─────────────────────────────────────────────────────────
class _TVFocusCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TVFocusCard({required this.child, required this.onTap});
  @override
  State<_TVFocusCard> createState() => _TVFocusCardState();
}

class _TVFocusCardState extends State<_TVFocusCard> {
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
        child: AnimatedScale(
          scale: _isFocused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused ? AppColors.appColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: _isFocused
                  ? [BoxShadow(color: AppColors.appColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}