import 'package:pakland/core/widgets/loader.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class SocialMediaLinksScreen extends StatelessWidget {
  final String brnCode;
  final CompanyController _companyController = Get.find<CompanyController>();

  SocialMediaLinksScreen({Key? key, required this.brnCode}) : super(key: key);

  static const Color _pageBg = Color(0xFFF4F7FA);

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    _companyController.loadCompanyDataFromStorage();

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppHeaderBar(
        title: const Text("Social"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (_companyController.isLoading.value) {
            return Center(
              child: AppLoader(size: 100),
            );
          }

          final filtered = _companyController.socialLinks
              .where((item) => item['brn_code']?.toString() == brnCode)
              .toList();

          return RefreshIndicator(
            color: AppColors.appColor,
            onRefresh: () async {
              await _companyController.fetchAndStoreCompanyDetails("SHE");
            },
            child: filtered.isEmpty ? _buildEmpty() : _buildList(filtered),
          );
        }),
      ),
    );
  }


  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.appColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.link_off_rounded,
                size: 40, color: AppColors.appColor.withOpacity(0.6)),
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'No social links found',
            style: TextStyle(
              fontSize: 16,
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
    );
  }


  Widget _buildList(List filtered) {
    return ResponsiveBody(
      maxWidth: 640,
      child: ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildHeader(filtered.length);

            final item = filtered[index - 1];
            final socialId = (item['social_Id'] ?? 'No Social Id').toString();
            final url = (item['url'] ?? '').toString();
            final docPath = (item['doc_path'] ?? '').toString();
            final fullImageUrl = docPath.isNotEmpty ? '${ApiConstants.baseUrl}$docPath' : '';

            return _buildLinkCard(
              title: socialId,
              url: url,
              imageUrl: fullImageUrl,
            );
          },
        ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
              child: const Icon(Icons.public_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Follow Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$count ${count == 1 ? 'platform' : 'platforms'} • Tap to open",
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard({
    required String title,
    required String url,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openUrl(url),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.link_rounded,
                      color: AppColors.appColor,
                    ),
                  )
                      : Icon(Icons.link_rounded, color: AppColors.appColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B3A42),
                        ),
                      ),
                      if (url.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.open_in_new_rounded,
                      size: 17, color: AppColors.appColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
