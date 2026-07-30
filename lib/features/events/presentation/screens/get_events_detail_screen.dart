import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/full_screen_image_view.dart';
import 'package:pakland/core/constants/image_url_helper.dart';
import 'package:pakland/features/events/data/models/get_events_model.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/events/presentation/controllers/get_events_controller.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  final String eventName;
  final EventsController eventsController = Get.find();

  EventDetailScreen({super.key, required this.eventId,required this.eventName});

  @override
  Widget build(BuildContext context) {
    final List<Event> eventImages =
    eventsController.getEventsByEventId(eventId);

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(eventName,style: TextStyle(color: AppColors.whiteBg,fontSize: 18),),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAll(() => MainWrapper(initialIndex: 0));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: eventImages.isEmpty
                  ? Center(
                child: Text(
                  "No images found for this event",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              )
                  : Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    //crossAxisSpacing: screenWidth * 0.02,
                    //  mainAxisSpacing: screenWidth * 0.02,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: eventImages.length,
                  itemBuilder: (context, index) {
                    final event = eventImages[index];
                    final imageUrl = ImageUrlHelper.resolve(event.imagePath, ApiConstants.baseUrl);
                    final List<String> allImageUrls = eventImages
                        .map((e) => ImageUrlHelper.resolve(e.imagePath, ApiConstants.baseUrl))
                        .toList();

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => FullScreenImageView(
                          imageUrl: imageUrl,
                          allImages: allImageUrls,  // ✅
                          initialIndex: index,      // ✅ jis pe tap kiya
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white,
                            width: 0.5,
                          ),
                          color: Colors.grey[100],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SpinKitWave(
                                color: AppColors.appColor,
                                size: screenWidth * 0.08,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: screenWidth * 0.1,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}