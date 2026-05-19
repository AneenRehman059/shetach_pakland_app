import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/constants/image_constant.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/recent_activity_controller.dart';

class RecentActivityScreen extends StatelessWidget {
  RecentActivityScreen({super.key});

  final controller = Get.put(RecentActivityController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Recent Login Activity",
            style: TextStyle(color: AppColors.whiteBg),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Get.offAll(() => MainWrapper(initialIndex: 0));
              },
            ),
          ],
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: () => pickDate(context, true),
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: Text(
                        "From: ${DateFormat('dd/MM/yyyy').format(controller.fromDate.value)}",
                        style: TextStyle(fontSize: 14,color: AppColors.whiteBg),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: () => pickDate(context, false),
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: Text(
                        "To: ${DateFormat('dd/MM/yyyy').format(controller.toDate.value)}",
                        style: TextStyle(fontSize: 14,color: AppColors.whiteBg),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: 5,
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.grey.shade300,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 14, width: 120, color: Colors.white),
                                    const SizedBox(height: 6),
                                    Container(height: 14, width: 80, color: Colors.white),
                                  ],
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (controller.activityList.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Recent Activity Found",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount: controller.activityList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = controller.activityList[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(ImageConstant.calendar,height: 18,width: 18,),
                                      const SizedBox(width: 6),
                                      Text(
                                        controller.formatDate(item.logDate),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Image.asset(ImageConstant.time,height: 18,width: 18,),
                                      const SizedBox(width: 6),
                                      Text(
                                        controller.formatTime(item.logDate),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            InkWell(
                              onTap: () => openGoogleMap(item.latitude, item.longitude),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.appColorLight30,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(ImageConstant.route,height: 25,width: 25,),
                              ),
                            ),
                          ],
                        ),
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

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? controller.fromDate.value : controller.toDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (isFrom) {
        controller.fromDate.value = picked;
      } else {
        controller.toDate.value = picked;
      }
      controller.fetchActivity();
    }
  }

  void openGoogleMap(String lat, String lng) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
