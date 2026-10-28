import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/features/events/presentation/controllers/get_events_controller.dart';
import 'package:pakland/features/events/data/models/get_events_model.dart';
import 'package:pakland/features/events/presentation/screens/get_events_detail_screen.dart'
    show EventDetailScreen;

class GetEventsScreen extends StatelessWidget {
  GetEventsScreen({super.key});

  final EventsController eventsController = Get.put(EventsController());

  static const Color _pageBg = Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppHeaderBar(
        title: const Text("Events"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (eventsController.isLoading.value) {
            return _buildLoading(screenWidth);
          }

          if (eventsController.uniqueEvents.isEmpty) {
            return _buildEmpty(screenWidth);
          }

          return RefreshIndicator(
            color: AppColors.appColor,
            onRefresh: () => eventsController.fetchEventsData(context: context),
            child: EventsGrid(
              events: eventsController.uniqueEvents,
              screenWidth: screenWidth,
              eventsController: eventsController,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoading(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLoader(size: (screenWidth * 0.14) * 1.8),
          const SizedBox(height: 14),
          Text(
            "Loading events...",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.appColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(double screenWidth) {
    return RefreshIndicator(
      color: AppColors.appColor,
      onRefresh: () => eventsController.fetchEventsData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: screenWidth * 0.4),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy_rounded,
                  size: 46, color: AppColors.appColor.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'No events available',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B3A42),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Pull down to refresh',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}


class EventsGrid extends StatelessWidget {
  final List<Event> events;
  final double screenWidth;
  final EventsController eventsController;

  const EventsGrid({
    super.key,
    required this.events,
    required this.screenWidth,
    required this.eventsController,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.iconColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gallery & Events",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.appColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${events.length} ${events.length == 1 ? 'event' : 'events'} • Tap to view photos",
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => EventItem(
                event: events[index],
                eventsController: eventsController,
              ),
              childCount: events.length,
            ),
          ),
        ),
      ],
    );
  }
}


class EventItem extends StatelessWidget {
  final Event event;
  final EventsController eventsController;

  const EventItem({
    super.key,
    required this.event,
    required this.eventsController,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = '${ApiConstants.baseUrl}${event.imagePath}';
    final int photoCount = eventsController.getEventsByEventId(event.eventId).length;

    return GestureDetector(
      onTap: () => Get.to(
            () => EventDetailScreen(eventId: event.eventId, eventName: event.eventName),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey.shade500, size: 36),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: AppLoader(size: 30),
                    ),
                  );
                },
              ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [Colors.transparent, Colors.black.withOpacity(0.78)],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "$photoCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.eventName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "View photos",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white.withOpacity(0.85), size: 13),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
