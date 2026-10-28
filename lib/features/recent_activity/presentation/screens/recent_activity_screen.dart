import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pakland/features/recent_activity/presentation/controllers/recent_activity_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class RecentActivityScreen extends StatelessWidget {
  RecentActivityScreen({super.key});

  final controller = Get.put(RecentActivityController());

  static const Color _ink = Color(0xFF1B2733);
  static const Color _muted = Color(0xFF6B7785);
  static const Color _border = Color(0xFFE8ECF4);

  BoxDecoration _cardDecoration({double radius = 20}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppHeaderBar(
          title: const Text('Recent Login Activity'),
          subtitle: 'Your sign-in history',
          onBackPressed: () => Get.off(() => MainWrapper(initialIndex: 1)),
          actions: [
            AppHeaderAction(
              assetIcon: ImageConstant.icHouse,
              tooltip: 'Home',
              onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildDateRangeCard(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return _buildShimmer();
                if (controller.activityList.isEmpty) return _buildEmptyState();
                return _buildList(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Obx(() => _dateTile(
                    label: 'FROM',
                    date: controller.fromDate.value,
                    onTap: () => pickDate(context, true),
                  )),
            ),
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.appColor),
            ),
            Expanded(
              child: Obx(() => _dateTile(
                    label: 'TO',
                    date: controller.toDate.value,
                    onTap: () => pickDate(context, false),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF5F8FA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 20, color: AppColors.appColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd MMM yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
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

  Widget _buildList(BuildContext context) {
    final bottom = 80.0 + MediaQuery.of(context).padding.bottom;
    final count = controller.activityList.length;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom),
      itemCount: count + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
            child: Row(
              children: [
                Text(
                  '$count login ${count == 1 ? 'record' : 'records'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ],
            ),
          );
        }
        final item = controller.activityList[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _activityCard(item),
        );
      },
    );
  }

  Widget _activityCard(dynamic item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.appColor,
                  Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.login_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Successful login',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Image.asset(ImageConstant.calendar, height: 15, width: 15),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        controller.formatDate(item.logDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset(ImageConstant.time, height: 15, width: 15),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        controller.formatTime(item.logDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'View location',
            child: Material(
              color: AppColors.appColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => openGoogleMap(item.latitude, item.longitude),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  child: Image.asset(ImageConstant.route, height: 24, width: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10, width: 80, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 130, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 100, color: Colors.white),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded,
                  size: 40, color: AppColors.appColor),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Recent Activity Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try selecting a different date range to see your login history.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, height: 1.45, color: _muted),
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
