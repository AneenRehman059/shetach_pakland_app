import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/faqs/presentation/controllers/faqs_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  final FaqController controller = Get.put(FaqController());

  static const Color _ink = Color(0xFF1B2733);
  static const Color _muted = Color(0xFF6B7785);
  static const Color _border = Color(0xFFE8ECF4);

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
          title: const Text('FAQs'),
          subtitle: 'Answers to common questions',
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
            _searchBar(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.faqs.isEmpty) {
                  return Center(
                    child: AppLoader(size: 80),
                  );
                }

                final list = controller.filteredFaqs;

                if (list.isEmpty) return _emptyState();

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    90 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _faqCard(context, list[index], index),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          cursorColor: AppColors.appColor,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
          decoration: InputDecoration(
            hintText: 'Search questions…',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA0AAB8),
            ),
            prefixIcon: Icon(Icons.search_rounded,
                color: AppColors.appColor, size: 23),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
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
              child: Icon(Icons.help_outline_rounded,
                  size: 40, color: AppColors.appColor),
            ),
            const SizedBox(height: 18),
            const Text(
              'No FAQs found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqCard(BuildContext context, faq, int index) {
    return Obx(() {
      final bool open = controller.selectedIndex.value == index;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: open ? AppColors.appColor.withOpacity(0.45) : _border,
            width: open ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(open ? 0.12 : 0.05),
              blurRadius: open ? 18 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: AppColors.appColor.withOpacity(0.05),
            ),
            child: ExpansionTile(
              key: Key('${index}_${controller.selectedIndex.value}'),
              initiallyExpanded: open,
              onExpansionChanged: (expanded) {
                controller.selectedIndex.value = expanded ? index : -1;
              },
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              iconColor: AppColors.appColor,
              collapsedIconColor: _muted,
              leading: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: open
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.appColor,
                            Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
                          ],
                        )
                      : null,
                  color: open ? null : AppColors.appColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: open ? Colors.white : AppColors.appColor,
                  ),
                ),
              ),
              title: Text(
                faq.question,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  height: 1.35,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _bulletAnswer(faq.answer),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _bulletAnswer(String answer) {
    final lines = answer
        .split(RegExp(r'\. |\n| - '))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == lines.length - 1 ? 0 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    color: AppColors.appColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lines[i],
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: Color(0xFF3A4654),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
