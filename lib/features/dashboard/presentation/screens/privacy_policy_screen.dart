import 'package:pakland/core/widgets/loader.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);

  final CompanyController companyController = Get.put(CompanyController());

  static const Color _pageBg = Color(0xFFF4F7FA);
  static const Color _bodyText = Color(0xFF3C4A52);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppHeaderBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GetX<CompanyController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return _buildLoading(height);
            }

            final privacyPolicy = controller.privacyPolicy.value;

            if (privacyPolicy.isEmpty) {
              return _buildEmptyState(width);
            }

            return _buildPrivacyPolicyContent(privacyPolicy, width);
          },
        ),
      ),
    );
  }


  Widget _buildLoading(double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLoader(size: (height * 0.07) * 1.8),
          const SizedBox(height: 14),
          Text(
            'Loading Privacy Policy...',
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


  Widget _buildEmptyState(double width) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: AppColors.appColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Privacy Policy Not Available',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B3A42),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Please check back later.',
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPrivacyPolicyContent(String htmlContent, double width) {
    final sections = _parseHtmlIntoSections(htmlContent, width);

    return ResponsiveBody(
      maxWidth: 720,
      child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(),
              const SizedBox(height: 16),
              ...sections,
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    "Thank you for trusting us with your information",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildHero() {
    return Container(
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Privacy Matters",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Please read how we collect, use and protect your information.",
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  List<Widget> _parseHtmlIntoSections(String html, double width) {
    final List<Widget> sections = [];

    String cleanedHtml = html
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&');

    final firstHeadingIndex = cleanedHtml.indexOf('<h');

    if (firstHeadingIndex > 0) {
      final introContent = cleanedHtml.substring(0, firstHeadingIndex);
      final introParagraphs = _extractParagraphs(introContent);

      if (introParagraphs.isNotEmpty) {
        sections.add(_buildIntroSection(introParagraphs, width));
      }
    }

    final headingPattern = RegExp(r'<(h[1-3])>(.*?)<\/\1>', dotAll: true);
    final headingMatches = headingPattern.allMatches(cleanedHtml).toList();

    for (int i = 0; i < headingMatches.length; i++) {
      final match = headingMatches[i];
      final headingTag = match.group(1)!;
      final headingText =
      match.group(2)!.replaceAll(RegExp(r'<.*?>'), '').trim();

      String content;
      if (i < headingMatches.length - 1) {
        content =
            cleanedHtml.substring(match.end, headingMatches[i + 1].start);
      } else {
        content = cleanedHtml.substring(match.end);
      }

      final level = int.parse(headingTag.substring(1));
      final paragraphs = _extractParagraphs(content);
      final listItems = _extractListItems(content);

      sections.add(
        _buildHeadingSection(
          headingText,
          level,
          paragraphs,
          listItems,
          width,
          i + 1,
        ),
      );
    }

    if (headingMatches.isEmpty) {
      final paragraphs = _extractParagraphs(cleanedHtml);
      sections.add(_buildIntroSection(paragraphs, width));
    }

    return sections;
  }


  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );

  Widget _buildIntroSection(List<String> paragraphs, double width) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < paragraphs.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == paragraphs.length - 1 ? 0 : 10),
              child: _buildParagraph(paragraphs[i], width),
            ),
        ],
      ),
    );
  }

  Widget _buildHeadingSection(
      String heading,
      int level,
      List<String> paragraphs,
      List<String> listItems,
      double width,
      int number,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.appColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$number",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.appColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildHeading(heading, level, width),
                ),
              ),
            ],
          ),
          if (paragraphs.isNotEmpty || listItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
          ],
          for (int i = 0; i < paragraphs.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: (i == paragraphs.length - 1 && listItems.isEmpty) ? 0 : 10,
              ),
              child: _buildParagraph(paragraphs[i], width),
            ),
          if (listItems.isNotEmpty) _buildBulletList(listItems, width),
        ],
      ),
    );
  }


  List<String> _extractParagraphs(String content) {
    final List<String> paragraphs = [];
    final pattern = RegExp(r'<p>(.*?)<\/p>', dotAll: true);

    for (final match in pattern.allMatches(content)) {
      final text = match.group(1)!
          .replaceAll(RegExp(r'<.*?>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (text.isNotEmpty) paragraphs.add(text);
    }
    return paragraphs;
  }

  List<String> _extractListItems(String content) {
    final List<String> items = [];
    final pattern = RegExp(r'<li>(.*?)<\/li>', dotAll: true);

    for (final match in pattern.allMatches(content)) {
      final text = match.group(1)!
          .replaceAll(RegExp(r'<.*?>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (text.isNotEmpty) items.add(text);
    }
    return items;
  }

  Widget _buildHeading(String text, int level, double width) {
    final double size = level == 1 ? 18 : (level == 2 ? 16.5 : 15.5);

    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.appColor,
      ),
    );
  }

  Widget _buildParagraph(String text, double width) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.65,
        color: _bodyText,
      ),
    );
  }

  Widget _buildBulletList(List<String> items, double width) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          _buildBulletPoint(items[i], width, isLast: i == items.length - 1),
      ],
    );
  }

  Widget _buildBulletPoint(String text, double width, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded,
                size: 17, color: AppColors.appColor.withOpacity(0.75)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: _bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
