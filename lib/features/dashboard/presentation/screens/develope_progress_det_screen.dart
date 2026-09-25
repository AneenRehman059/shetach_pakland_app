import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/features/events/presentation/controllers/get_events_controller.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/events/data/models/get_events_model.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/full_screen_image_view.dart';

class DevelopmentProgressDetailScreen extends StatelessWidget {
  final String eventId;
  final String eventName;
  final EventsController eventsController = Get.put(EventsController());

  DevelopmentProgressDetailScreen({super.key, required this.eventId,required this.eventName});

  @override
  Widget build(BuildContext context) {
    final List<DevelopmentProgress> devImages =
    eventsController.getDevelopmentByEventId(eventId);

    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        title: Text(eventName,style: TextStyle(color: AppColors.whiteBg),),
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
              child: devImages.isEmpty
                  ? const Center(
                child: Text(
                  "No images found",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: devImages.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                //  crossAxisSpacing: 12,
                  //mainAxisSpacing: 12,

                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final dev = devImages[index];
                  final imageUrl =
                      "${ApiConstants.baseUrl}${dev.imagePath}";
                  final List<String> allImageUrls = devImages
                      .map((e) => "${ApiConstants.baseUrl}${e.imagePath}")
                      .toList();

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => FullScreenImageView(
                        imageUrl: imageUrl,
                        allImages: allImageUrls,  // ✅
                        initialIndex: index,      // ✅ jis pe tap kiya
                      ));
                    },
                    child: Hero(
                      tag: imageUrl,
                      child: Container(
                        decoration: BoxDecoration(
                        //  borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white, strokeAlign: 1),
                          color: Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stack) =>
                          const Icon(Icons.broken_image, size: 80),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
