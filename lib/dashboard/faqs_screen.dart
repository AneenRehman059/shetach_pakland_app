import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import '../bottom_app_bar/bottom_app_bar.dart';
import '../controllers/faqs_controller.dart';
import '../function/screen_helper.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final FaqController controller = Get.put(FaqController());

  @override
  void initState() {
    super.initState();
    // Force fetch if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Controller auto-fetches in its own initState
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async { Get.off(() => MainWrapper(initialIndex: 1)); return false; },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F6F9),
        appBar: AppBar(
          elevation: 0,
          title: Text("FAQs",
              style: TextStyle(color: Colors.white, fontSize: isTV ? 22 : 20, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.appColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: isTV ? 70 : kToolbarHeight,
          actions: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: isTV ? 30 : 24),
              onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
            ),
          ],
        ),
        body: Column(
          children: [
            _searchBar(context, isTV: isTV),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.faqs.isEmpty) {
                  return Center(child: SpinKitWave(color: AppColors.appColor, size: w * 0.12));
                }

                final list = controller.filteredFaqs;
                if (list.isEmpty) {
                  return Center(child: Text("No FAQs found.", style: TextStyle(fontSize: 16, color: Colors.black54)));
                }

                // TV — 2 columns
                if (isTV) {
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.015, w * 0.04, h * 0.05),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: w * 0.03,
                      mainAxisSpacing: h * 0.015,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _TVFaqCard(faq: list[index], index: index, controller: controller);
                    },
                  );
                }

                // Mobile — same as before
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.015, w * 0.04, h * 0.10),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
                  itemBuilder: (context, index) => _mobileFaqCard(context, list[index], index),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context, {required bool isTV}) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.015, w * 0.04, 0),
      child: Container(
        height: isTV ? 56 : h * 0.053,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          style: TextStyle(fontSize: isTV ? 16 : w * 0.038),
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: isTV ? 16 : w * 0.035),
            prefixIcon: Icon(Icons.search, color: AppColors.appColor, size: isTV ? 28 : w * 0.055),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: h * 0.01),
          ),
        ),
      ),
    );
  }

  // Mobile FAQ card — same as before
  Widget _mobileFaqCard(BuildContext context, faq, int index) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.005),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 3))],
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: Key("${index}_${controller.selectedIndex.value}"),
            initiallyExpanded: controller.selectedIndex.value == index,
            onExpansionChanged: (expanded) => controller.selectedIndex.value = expanded ? index : -1,
            tilePadding: EdgeInsets.symmetric(horizontal: w * 0.045, vertical: h * 0.012),
            childrenPadding: EdgeInsets.fromLTRB(w * 0.05, 0, w * 0.045, h * 0.02),
            iconColor: AppColors.appColor,
            collapsedIconColor: Colors.grey[600],
            title: Text(faq.question,
                style: TextStyle(fontSize: w * 0.042, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.3)),
            children: [
              Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: _bulletAnswer(context, faq.answer),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _bulletAnswer(BuildContext context, String answer) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    List<String> lines = answer.split(RegExp(r'\. |\n| - '));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((e) {
        if (e.trim().isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: h * 0.015),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: EdgeInsets.only(top: h * 0.007),
              height: w * 0.02, width: w * 0.02,
              decoration: BoxDecoration(color: AppColors.appColor, shape: BoxShape.circle),
            ),
            SizedBox(width: w * 0.03),
            Expanded(child: Text(e.trim(), style: TextStyle(fontSize: w * 0.04, height: 1.5, color: Colors.black87))),
          ]),
        );
      }).toList(),
    );
  }
}

// TV FAQ Card with focus
class _TVFaqCard extends StatefulWidget {
  final dynamic faq;
  final int index;
  final FaqController controller;

  const _TVFaqCard({required this.faq, required this.index, required this.controller});

  @override
  State<_TVFaqCard> createState() => _TVFaqCardState();
}

class _TVFaqCardState extends State<_TVFaqCard> {
  bool _isFocused = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          setState(() => _isExpanded = !_isExpanded);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isFocused ? AppColors.appColor : Colors.transparent, width: 2),
            boxShadow: [BoxShadow(
              color: _isFocused ? AppColors.appColor.withOpacity(0.2) : Colors.black.withOpacity(0.06),
              blurRadius: _isFocused ? 12 : 6,
              spreadRadius: _isFocused ? 2 : 1,
              offset: Offset(0, 3),
            )],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(widget.faq.question,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.appColor),
              ]),
              if (_isExpanded) ...[
                Divider(color: Colors.grey.shade200, height: 16),
                Text(widget.faq.answer, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}