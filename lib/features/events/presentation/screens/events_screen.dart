import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/events/presentation/controllers/get_events_controller.dart';
import 'package:pakland/features/events/data/models/get_events_model.dart';
import 'package:pakland/features/events/presentation/screens/get_events_detail_screen.dart' show EventDetailScreen;

class GetEventsScreen extends StatelessWidget {
  final EventsController eventsController = Get.put(EventsController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.black38,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Events",style: TextStyle(color: AppColors.whiteBg),),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      body: SafeArea(
        child: Obx(() {
          if (eventsController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(
                    color: AppColors.appColor,
                    size: screenWidth * 0.12,
                  ),
                  Text(
                    "Loading",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: AppColors.appColor,
                    ),
                  ),
                ],
              ),
            );
          }

          else if (eventsController.uniqueEvents.isEmpty) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'No events available',
                      style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.black),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      color: AppColors.whiteBg,
                      child: EventsGrid(
                        events: eventsController.uniqueEvents,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        eventsController: eventsController,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    )
    );
  }
}

class EventsGrid extends StatelessWidget {
  final List<Event> events;
  final double screenWidth;
  final double screenHeight;
  final EventsController eventsController;

  EventsGrid({
    required this.events,
    required this.screenWidth,
    required this.screenHeight,
    required this.eventsController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top:screenWidth * 0.03,left: screenWidth * 0.01),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: screenWidth > 600 ? 3 : 2,
          crossAxisSpacing: screenWidth * 0.02,
          mainAxisSpacing: screenWidth * 0.01,
          // childAspectRatio: screenWidth > 600 ? 0.8 : 0.9,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventItem(
            event: events[index],
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            eventsController: eventsController,
          );
        },
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final Event event;
  final double screenWidth;
  final double screenHeight;
  final EventsController eventsController;

  EventItem({
    required this.event,
    required this.screenWidth,
    required this.screenHeight,
    required this.eventsController,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = '${ApiConstants.baseUrl}${event.imagePath}';

    return GestureDetector(
      onTap: () {
        final allEvents = eventsController.getEventsByEventId(event.eventId);
        Get.to(() => EventDetailScreen(eventId: event.eventId,eventName: event.eventName));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenHeight * 0.15,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.error,
                      color: Colors.grey[600],
                      size: screenWidth * 0.1,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SpinKitWave(
                      color: AppColors.appColor,
                      size: screenWidth * 0.08,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            event.eventName,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}