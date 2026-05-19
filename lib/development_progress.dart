import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../controllers/get_events_controller.dart';
import '../../constants/api_constant.dart';
import 'dashboard/develope_progress_det_screen.dart';
import '../../colors.dart';
import '../../customs/app_bar.dart';

class GetDevelopmentProgressScreen extends StatelessWidget {
  final EventsController eventsController = Get.put(EventsController());

  GetDevelopmentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        title: Text("Development Progress",style: TextStyle(color: AppColors.whiteBg),),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.015),

            Expanded(
              child: Obx(() {
                if (eventsController.isLoading.value) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: SpinKitWave(
                          color: AppColors.appColor,
                          size: 50.0,
                        ),
                      ),
                      Text('Loading',style: TextStyle(color: AppColors.appColor),),
                    ],
                  );
                }

                if (eventsController.uniqueDevelopment.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Development Progress found",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 3 : 2,
                    crossAxisSpacing: screenWidth * 0.03,
                    mainAxisSpacing: screenWidth * 0.03,
                    childAspectRatio: screenWidth > 600 ? 0.9 : 0.8,
                  ),
                  itemCount: eventsController.uniqueDevelopment.length,
                  itemBuilder: (context, index) {
                    final dev = eventsController.uniqueDevelopment[index];
                    final imageUrl = "${ApiConstants.baseUrl}${dev.imagePath}";

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => DevelopmentProgressDetailScreen(
                            eventId: dev.eventId, eventName: dev.eventName));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(screenWidth * 0.04),
                            child: Image.network(
                              imageUrl,
                              height: screenHeight * 0.15,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image,
                                  size: 60, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            dev.eventName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}