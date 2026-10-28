import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/features/social/presentation/screens/social_media_links_screen.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class SocialScreen extends StatefulWidget {
  SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final SocialController controller = Get.put(SocialController());

  static const Color _pageBg = Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppHeaderBar(
        title: const Text("Social"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLoader(size: (screenWidth * 0.14) * 1.8),
                  const SizedBox(height: 14),
                  Text(
                    'Loading...',
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

          if (controller.branches.isEmpty) {
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
                    child: Icon(Icons.share_rounded,
                        size: 40, color: AppColors.appColor.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "No projects found",
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

          final branches = controller.branches;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(branches.length)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final branch = branches[index];
                      return _buildProjectCard(
                        branch['brn_code'] ?? '',
                        branch['brn_name'] ?? '',
                      );
                    },
                    childCount: branches.length,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.appColor, AppColors.lightAppColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.share_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Stay Connected",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select a project to follow it on social media ($count available).",
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(String brnCode, String brnName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Get.to(() => SocialMediaLinksScreen(brnCode: brnCode)),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.appColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(ImageConstant.logo, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  brnName,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: AppColors.appColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "View links",
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.grey.shade600),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
