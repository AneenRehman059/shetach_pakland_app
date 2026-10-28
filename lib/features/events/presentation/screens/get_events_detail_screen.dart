import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/full_screen_image_view.dart';
import 'package:pakland/features/events/data/models/get_events_model.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/events/presentation/controllers/get_events_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  final String eventName;
  final EventsController eventsController = Get.find();

  EventDetailScreen({super.key, required this.eventId, required this.eventName});

  static const Color _pageBg = Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    final List<Event> eventImages = eventsController.getEventsByEventId(eventId);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 5 : (screenWidth > 600 ? 4 : 2);

    final List<String> allImageUrls =
    eventImages.map((e) => "${ApiConstants.baseUrl}${e.imagePath}").toList();

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppHeaderBar(
        title: Text(eventName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
          ),
        ],
      ),
      body: SafeArea(
        child: eventImages.isEmpty
            ? _buildEmpty()
            : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(eventImages.length)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPhotoTile(
                    context,
                    imageUrl: allImageUrls[index],
                    allImageUrls: allImageUrls,
                    index: index,
                  ),
                  childCount: eventImages.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.collections_rounded, color: AppColors.appColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "$count ${count == 1 ? 'photo' : 'photos'} • Tap a photo to view full screen",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPhotoTile(
      BuildContext context, {
        required String imageUrl,
        required List<String> allImageUrls,
        required int index,
      }) {
    return GestureDetector(
      onTap: () => Get.to(
            () => FullScreenImageView(
          imageUrl: imageUrl,
          allImages: allImageUrls,
          initialIndex: index,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: AppLoader(size: 28),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined,
                        size: 32, color: Colors.grey.shade500),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.appColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.photo_library_outlined,
                size: 42, color: AppColors.appColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 18),
          const Text(
            "No images found for this event",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B3A42),
            ),
          ),
        ],
      ),
    );
  }
}
