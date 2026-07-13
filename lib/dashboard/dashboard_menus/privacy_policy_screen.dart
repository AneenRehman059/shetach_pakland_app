import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../controllers/get_company_controller.dart';
import '../../function/screen_helper.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);
  final CompanyController companyController = Get.put(CompanyController());

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(color: Colors.white, fontSize: isTV ? 22 : 16)),
        centerTitle: true, backgroundColor: AppColors.appColor,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: isTV ? 70 : kToolbarHeight,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppColors.appColor.withOpacity(0.06), Colors.white]),
        ),
        child: GetX<CompanyController>(
          builder: (controller) {
            if (controller.isLoading.value) return _buildLoading(height);
            final privacyPolicy = controller.privacyPolicy.value;
            if (privacyPolicy.isEmpty) return _buildEmptyState(width);
            return _buildContent(privacyPolicy, width, isTV);
          },
        ),
      ),
    );
  }

  Widget _buildLoading(double height) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    SpinKitWave(color: AppColors.appColor, size: height * 0.08),
    SizedBox(height: height * 0.02),
    Text('Privacy Policy...', style: TextStyle(fontSize: height * 0.018, fontWeight: FontWeight.w500, color: Colors.grey[700])),
  ]));

  Widget _buildEmptyState(double width) => Center(child: Padding(padding: EdgeInsets.all(width * 0.08), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.lock_outline, size: width * 0.1, color: AppColors.appColor.withOpacity(0.4)),
    SizedBox(height: width * 0.05),
    Text('Privacy Policy Not Available', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    SizedBox(height: width * 0.02),
    Text('Please check back later.', style: TextStyle(fontSize: width * 0.035, color: Colors.grey[600]), textAlign: TextAlign.center),
  ])));

  Widget _buildContent(String htmlContent, double width, bool isTV) {
    final sections = _parseHtmlIntoSections(htmlContent, width, isTV);
    // TV pe 2 column layout
    if (isTV) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.03),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(width * 0.04),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections),
    );
  }

  List<Widget> _parseHtmlIntoSections(String html, double width, bool isTV) {
    final List<Widget> sections = [];
    String cleaned = html.replaceAll('\r', '').replaceAll('\n', '')
        .replaceAll('&ldquo;', '"').replaceAll('&rdquo;', '"')
        .replaceAll('&rsquo;', "'").replaceAll('&#39;', "'").replaceAll('&amp;', '&');

    final firstHeadingIndex = cleaned.indexOf('<h');
    if (firstHeadingIndex > 0) {
      final introParagraphs = _extractParagraphs(cleaned.substring(0, firstHeadingIndex));
      if (introParagraphs.isNotEmpty) sections.add(_buildIntroSection(introParagraphs, width, isTV));
    }

    final headingPattern = RegExp(r'<(h[1-3])>(.*?)<\/\1>', dotAll: true);
    final headingMatches = headingPattern.allMatches(cleaned).toList();

    for (int i = 0; i < headingMatches.length; i++) {
      final match = headingMatches[i];
      final headingText = match.group(2)!.replaceAll(RegExp(r'<.*?>'), '').trim();
      final content = i < headingMatches.length - 1 ? cleaned.substring(match.end, headingMatches[i + 1].start) : cleaned.substring(match.end);
      final level = int.parse(match.group(1)!.substring(1));
      sections.add(_buildHeadingSection(headingText, level, _extractParagraphs(content), _extractListItems(content), width, isTV));
    }

    if (headingMatches.isEmpty) sections.add(_buildIntroSection(_extractParagraphs(cleaned), width, isTV));
    return sections;
  }

  Widget _buildIntroSection(List<String> paragraphs, double width, bool isTV) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.06),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...paragraphs.map((p) => Padding(padding: EdgeInsets.only(bottom: width * 0.02), child: _buildParagraph(p, width, isTV))),
        Divider(color: Colors.grey.shade300),
      ]),
    );
  }

  Widget _buildHeadingSection(String heading, int level, List<String> paragraphs, List<String> listItems, double width, bool isTV) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.06),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeading(heading, level, width, isTV),
        SizedBox(height: width * 0.03),
        ...paragraphs.map((p) => Padding(padding: EdgeInsets.only(bottom: width * 0.02), child: _buildParagraph(p, width, isTV))),
        if (listItems.isNotEmpty) _buildBulletList(listItems, width, isTV),
        Divider(color: Colors.grey.shade300),
      ]),
    );
  }

  List<String> _extractParagraphs(String content) {
    final List<String> paragraphs = [];
    for (final match in RegExp(r'<p>(.*?)<\/p>', dotAll: true).allMatches(content)) {
      final text = match.group(1)!.replaceAll(RegExp(r'<.*?>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isNotEmpty) paragraphs.add(text);
    }
    return paragraphs;
  }

  List<String> _extractListItems(String content) {
    final List<String> items = [];
    for (final match in RegExp(r'<li>(.*?)<\/li>', dotAll: true).allMatches(content)) {
      final text = match.group(1)!.replaceAll(RegExp(r'<.*?>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isNotEmpty) items.add(text);
    }
    return items;
  }

  Widget _buildHeading(String text, int level, double width, bool isTV) {
    final size = isTV
        ? (level == 1 ? 24.0 : level == 2 ? 20.0 : 18.0)
        : (level == 1 ? width * 0.055 : level == 2 ? width * 0.05 : width * 0.045);
    return Text(text, style: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: AppColors.appColor));
  }

  Widget _buildParagraph(String text, double width, bool isTV) {
    return Text(text, textAlign: TextAlign.justify,
        style: TextStyle(fontSize: isTV ? 15.0 : width * 0.038, height: 1.6, color: Colors.grey[800]));
  }

  Widget _buildBulletList(List<String> items, double width, bool isTV) {
    return Column(children: items.map((e) => _buildBulletPoint(e, width, isTV)).toList());
  }

  Widget _buildBulletPoint(String text, double width, bool isTV) {
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.02),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(margin: EdgeInsets.only(top: width * 0.02, right: width * 0.03),
            width: width * 0.015, height: width * 0.015,
            decoration: BoxDecoration(color: AppColors.appColor, shape: BoxShape.circle)),
        Expanded(child: Text(text, style: TextStyle(fontSize: isTV ? 15.0 : width * 0.038, height: 1.5, color: Colors.grey[800]))),
      ]),
    );
  }
}