import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Add this import
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);

  final CompanyController companyController = Get.put(CompanyController());

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.appColor.withOpacity(0.06),
              Colors.white,
            ],
          ),
        ),
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

  // ================= LOADING =================

  Widget _buildLoading(double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(
            color: AppColors.appColor,
            size: height * 0.08,
          ),
          SizedBox(height: height * 0.02),
          Text(
            'Privacy Policy...',
            style: TextStyle(
              fontSize: height * 0.018,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY =================

  Widget _buildEmptyState(double width) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: width * 0.1,
              color: AppColors.appColor.withOpacity(0.4),
            ),
            SizedBox(height: width * 0.05),
            Text(
              'Privacy Policy Not Available',
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.02),
            Text(
              'Please check back later.',
              style: TextStyle(
                fontSize: width * 0.035,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================= CONTENT =================

  Widget _buildPrivacyPolicyContent(String htmlContent, double width) {
    final sections = _parseHtmlIntoSections(htmlContent, width);

    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.04),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      ),
    );
  }

  // ================= HTML PARSER =================

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
        ),
      );
    }

    if (headingMatches.isEmpty) {
      final paragraphs = _extractParagraphs(cleanedHtml);
      sections.add(_buildIntroSection(paragraphs, width));
    }

    return sections;
  }

  // ================= UI SECTIONS =================

  Widget _buildIntroSection(List<String> paragraphs, double width) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...paragraphs.map(
                (p) => Padding(
              padding: EdgeInsets.only(bottom: width * 0.02),
              child: _buildParagraph(p, width),
            ),
          ),
          Divider(color: Colors.grey.shade300),
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
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeading(heading, level, width),
          SizedBox(height: width * 0.03),
          ...paragraphs.map(
                (p) => Padding(
              padding: EdgeInsets.only(bottom: width * 0.02),
              child: _buildParagraph(p, width),
            ),
          ),
          if (listItems.isNotEmpty) _buildBulletList(listItems, width),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  // ================= TEXT HELPERS =================

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
    final size =
    level == 1 ? width * 0.055 : level == 2 ? width * 0.05 : width * 0.045;

    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: AppColors.appColor,
      ),
    );
  }

  Widget _buildParagraph(String text, double width) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: width * 0.038,
        height: 1.6,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildBulletList(List<String> items, double width) {
    return Column(
      children: items.map((e) => _buildBulletPoint(e, width)).toList(),
    );
  }

  Widget _buildBulletPoint(String text, double width) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: width * 0.02, right: width * 0.03),
            width: width * 0.015,
            height: width * 0.015,
            decoration: BoxDecoration(
              color: AppColors.appColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: width * 0.038,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}