import 'package:pakland/core/widgets/loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:photo_view/photo_view.dart';
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

  static const Color _pageBg = Color(0xFFF5F7FA);

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
        backgroundColor: _pageBg,
        body: Obx(() {
          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildBody(context)),
                ],
              ),
              if (controller.isLoading.value &&
                  !controller.areImagesLoaded.value)
                _buildLoadingOverlay(),
            ],
          );
        }),
      ),
    );
  }

  // ───────────────────────── Header ─────────────────────────

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: topPad + 8, left: 12, right: 12, bottom: 22),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainWrapper()),
              );
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Plan",
                  style: TextStyle(
                    color: AppColors.whiteBg,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Browse plans by project",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Body ─────────────────────────

  Widget _buildBody(BuildContext context) {
    final plans = controller.plansWithNames;
    final allImageUrls =
    plans.map((e) => e["image_url"]!).toList(); // see note in summary

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProjectFilter(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.t2,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Available Plans",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appColor,
                ),
              ),
              const Spacer(),
              if (plans.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${plans.length}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: plans.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _buildPlanCard(context, plan, index, allImageUrls);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              "Select Project",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                value: controller.selectedBranchName.value,
                isExpanded: true,
                items: [
                  DropdownMenuItem<String>(
                    value: "All",
                    child: _dropdownText("All"),
                  ),
                  ...controller.branchList
                      .where((branch) => branch.brnName != "All")
                      .map<DropdownMenuItem<String>>((branch) {
                    return DropdownMenuItem<String>(
                      value: branch.brnName,
                      child: _dropdownText(branch.brnName),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  if (value != null) controller.changeBranch(value);
                },
                buttonStyleData: ButtonStyleData(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.appColor.withOpacity(0.18)),
                    color: Colors.white,
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.appColor),
                  iconSize: 26,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 260,
                  offset: const Offset(0, -4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 46,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownText(String text) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: AppColors.appColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.apartment_rounded,
              size: 17, color: AppColors.appColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Plan card ─────────────────────────

  Widget _buildPlanCard(
      BuildContext context,
      Map<String, String> plan,
      int index,
      List<String> allImageUrls,
      ) {
    final imageUrl = plan["image_url"]!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.appColor,
                        AppColors.lightAppColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    plan["plan_name"]!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: GestureDetector(
              onTap: () {
                Get.to(() => FullScreenImageView(
                  imageUrl: imageUrl,
                  allImages: allImageUrls,
                  initialIndex: index,
                ));
              },
              child: Hero(
                tag: imageUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          color: const Color(0xFFEEF1F5),
                          child: Center(
                            child: SizedBox(
                              height: 26,
                              width: 26,
                              child: AppLoader(),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          color: const Color(0xFFEEF1F5),
                          child: Icon(Icons.broken_image_outlined,
                              size: 40, color: AppColors.mediumGrey),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.zoom_out_map_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text(
                                "Tap to view",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── States ─────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description_outlined,
                  size: 42, color: AppColors.appColor),
            ),
            const SizedBox(height: 18),
            Text(
              "No payment plan found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.appColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Try selecting a different project.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.darkGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoader(size: 80),
              const SizedBox(height: 12),
              Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.appColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
