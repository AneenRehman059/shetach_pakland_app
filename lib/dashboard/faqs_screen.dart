import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import '../bottom_app_bar/bottom_app_bar.dart';
import '../controllers/faqs_controller.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  final FaqController controller = Get.put(FaqController());

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F6F9),

        appBar: AppBar(
          elevation: 0,
          title: const Text(
            "FAQs",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.appColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Get.offAll(() => MainWrapper(initialIndex: 0));
              },
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
                    child: SpinKitWave(
                      color: AppColors.appColor,
                      size: w * 0.12,
                    ),
                  );
                }

                final list = controller.filteredFaqs;

                if (list.isEmpty) {
                  return const Center(child: Text("No FAQs found."));
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    w * 0.04,
                    h * 0.015,
                    w * 0.04,
                    h * 0.10, // bottom padding using MediaQuery
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
                  itemBuilder: (context, index) {
                    return _beautifulFaqCard(context, list[index], index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.015, w * 0.04, 0),
      child: Container(
        height: h * 0.053,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: w * 0.035),
            prefixIcon: Icon(Icons.search, color: AppColors.appColor, size: w * 0.055),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: h * 0.01),
          ),
          style: TextStyle(fontSize: w * 0.038),
        ),
      ),
    );
  }

  Widget _beautifulFaqCard(BuildContext context, faq, int index) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(vertical: h * 0.005),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: Key("${index}_${controller.selectedIndex.value}"),
            initiallyExpanded: controller.selectedIndex.value == index,

            onExpansionChanged: (expanded) {
              controller.selectedIndex.value = expanded ? index : -1;
            },

            tilePadding: EdgeInsets.symmetric(
              horizontal: w * 0.045,
              vertical: h * 0.012,
            ),
            childrenPadding: EdgeInsets.fromLTRB(
              w * 0.05,
              0,
              w * 0.045,
              h * 0.02,
            ),

            iconColor: AppColors.appColor,
            collapsedIconColor: Colors.grey[600],

            title: Text(
              faq.question,
              style: TextStyle(
                fontSize: w * 0.042,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.3,
              ),
            ),

            children: [
              Container(
                padding: EdgeInsets.all(w * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: h * 0.007),
                height: w * 0.02,
                width: w * 0.02,
                decoration: BoxDecoration(
                  color: AppColors.appColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: w * 0.03),

              Expanded(
                child: Text(
                  e.trim(),
                  style: TextStyle(
                    fontSize: w * 0.04,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
