import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/events/presentation/controllers/get_events_controller.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/events/data/models/get_events_model.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/constants/full_screen_image_view.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/core/constants/image_url_helper.dart';

class DevelopmentProgressDetailScreen extends StatelessWidget {
  final String eventId;
  final String eventName;
  final EventsController eventsController = Get.put(EventsController());

  DevelopmentProgressDetailScreen({super.key, required this.eventId, required this.eventName});

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final List<DevelopmentProgress> devImages = eventsController.getDevelopmentByEventId(eventId);

    // TV pe 5 columns, mobile pe 3
    final int crossAxisCount = isTV ? 5 : 3;
    final double childAspectRatio = isTV ? 1.4 : 1.2;

    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        title: Text(eventName, style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
        centerTitle: true, backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: isTV ? 70 : kToolbarHeight,
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white, size: isTV ? 30 : 24),
            onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: devImages.isEmpty
                ? const Center(child: Text("No images found", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
              padding: EdgeInsets.all(isTV ? 16 : 12),
              itemCount: devImages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isTV ? 8 : 0,
                mainAxisSpacing: isTV ? 8 : 0,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final dev = devImages[index];
                final imageUrl = ImageUrlHelper.resolve(dev.imagePath, ApiConstants.baseUrl);
                final List<String> allImageUrls = devImages
                    .map((e) => ImageUrlHelper.resolve(e.imagePath, ApiConstants.baseUrl))
                    .toList();

                return isTV
                    ? _TVImageCard(imageUrl: imageUrl, allImageUrls: allImageUrls, index: index)
                    : GestureDetector(
                  onTap: () => Get.to(() => FullScreenImageView(imageUrl: imageUrl, allImages: allImageUrls, initialIndex: index)),
                  child: Hero(
                    tag: imageUrl,
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, strokeAlign: 1), color: Colors.white),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(imageUrl, fit: BoxFit.fill, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 80)),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// TV Image Card with focus
class _TVImageCard extends StatefulWidget {
  final String imageUrl;
  final List<String> allImageUrls;
  final int index;

  const _TVImageCard({required this.imageUrl, required this.allImageUrls, required this.index});

  @override
  State<_TVImageCard> createState() => _TVImageCardState();
}

class _TVImageCardState extends State<_TVImageCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          Get.to(() => FullScreenImageView(imageUrl: widget.imageUrl, allImages: widget.allImageUrls, initialIndex: widget.index));
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => Get.to(() => FullScreenImageView(imageUrl: widget.imageUrl, allImages: widget.allImageUrls, initialIndex: widget.index)),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: Border.all(color: _isFocused ? Colors.white : Colors.white24, width: _isFocused ? 3 : 1),
            color: Colors.white,
            boxShadow: _isFocused ? [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)] : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Transform.scale(
            scale: _isFocused ? 1.03 : 1.0,
            child: Image.network(widget.imageUrl, fit: BoxFit.fill,
                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 80)),
          ),
        ),
      ),
    );
  }
}