import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:photo_view/photo_view.dart';   // <-- added
import 'package:pakland/core/theme/colors.dart';

import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/full_screen_image_view.dart';
import 'package:pakland/features/billing/presentation/controllers/get_payment_plans_controller.dart';

class PaymentPlanScreen extends StatefulWidget {
  const PaymentPlanScreen({super.key});

  @override
  State<PaymentPlanScreen> createState() => _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  final PaymentPlanController controller = Get.put(PaymentPlanController());

  @override
  void initState() {
    super.initState();
    controller.loadBranches();
  }

  @override
  void dispose() {
    controller.selectedBranchName("All");
    controller.selectedBranchCode("");
    controller.plansWithNames.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => MainWrapper());
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteBg,
        body: Obx(() {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.appColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                        top: 30, left: 10, right: 10, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainWrapper()),
                                  );
                                },
                              ),
                            ),
                            Text(
                              "Payment Plan",
                              style: TextStyle(
                                color: AppColors.whiteBg,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  /// Dropdown
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Projects*",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            value: controller.selectedBranchName.value,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: "All",
                                child: Text("All"),
                              ),
                              ...controller.branchList
                                  .where((branch) => branch.brnName != "All")
                                  .map<DropdownMenuItem<String>>((branch) {
                                return DropdownMenuItem<String>(
                                  value: branch.brnName,
                                  child: Text(branch.brnName),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              if (value != null) controller.changeBranch(value);
                            },
                            buttonStyleData: ButtonStyleData(

                              height: 40,
                              padding: const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                              ),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                            ),
                            dropdownStyleData: DropdownStyleData(

                              maxHeight: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(height: 40),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: controller.plansWithNames.isEmpty
                        ? Center(child: Text("No payment plan found"))
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.plansWithNames.length,
                      itemBuilder: (context, index) {
                        final plan = controller.plansWithNames[index];
                        final List<String> allImageUrls = controller.plansWithNames
                            .map((e) => plan["image_url"]!)
                            .toList();
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan["plan_name"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 5),

                              GestureDetector(
                                // onTap: () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (_) => FullScreenImageView(imageUrl: plan["image_url"]!),
                                //     ),
                                //   );
                                // },

                                onTap: () {
                                  Get.to(() => FullScreenImageView(
                                    imageUrl: plan["image_url"]!,
                                    allImages: allImageUrls,  // ✅
                                    initialIndex: index,      // ✅ jis pe tap kiya
                                  ));
                                },
                                child: Hero(
                                  tag: plan["image_url"]!,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: plan["image_url"]!,
                                      fit: BoxFit.fill,
                                      height: MediaQuery.of(context).size.height * 0.3,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              /// LOADER
              if (controller.isLoading.value && !controller.areImagesLoaded.value)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitWave(color: AppColors.appColor, size: 50.0),
                        SizedBox(height: 10),
                        Text('Loading...',
                            style:
                            TextStyle(color: AppColors.appColor, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

