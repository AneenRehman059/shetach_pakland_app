import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/constants/image_constant.dart';
import 'package:pakland/customs/app_bar.dart';
import '../constants/api_constant.dart';
import '../controllers/get_company_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/tickets_controller.dart';
import '../main.dart';
import '../services/fcm_notification_service.dart';
import 'dashboard_menus.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CompanyController companyController = Get.put(CompanyController());
  final TicketController ticketController = Get.put(TicketController());
  final LoginController loginController = Get.put(LoginController());
  final RxInt currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    companyController.fetchAndStoreCompanyDetails("SHET");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ticketController.loadActiveSOSEmergencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sliderHeight = MediaQuery.of(context).size.height * 0.25;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(
          ImageConstant.logo,
          height: 55,
        ),
        actions: [
          Obx(() {
            final userType = loginController.userType.value;
            final isAdmin = userType == "Admin" || userType == "Customer";

            if (!isAdmin) return const SizedBox.shrink();

            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => Get.toNamed('/SOSListView'),
                  icon: Icon(
                    Icons.notifications,
                    color: AppColors.appColor,
                    size: 26,
                  ),
                ),
                Obx(() {
                  if (ticketController.activeSOSCount.value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            Container(height: 1,
              width: double.infinity,
              color: AppColors.appColor,),
            SizedBox(height: 5),
            Obx(() {
              return Stack(
                children: [
                  CarouselSlider(
                    items: _buildSliderItems(context),
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.easeInOut,
                      viewportFraction: 1,
                      enlargeCenterPage: true,
                      height: sliderHeight,
                      onPageChanged: (index, reason) {
                        currentIndex.value = index;
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: _buildIndicatorDots(),
                  ),
                ],
              );
            }),
            const SizedBox(height: 5),
            Expanded(
              child: DashboardMenus(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSliderItems(BuildContext context) {
    return companyController.sliders.map((e) {
      final rawPath = e['image_path'] ?? "";
      final url = "${ApiConstants.baseUrl}/$rawPath";
      // debugPrint("🔗 Slider URL: $url");

      return Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Image.network(
          url,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SpinKitWave(
                color: AppColors.appColor,
                size: 30.0,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint("❌ Failed to load: $url -> $error");
            return Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image,
                  size: 50, color: Colors.grey),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildIndicatorDots() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: companyController.sliders.asMap().entries.map((entry) {
        return Container(
          width: currentIndex.value == entry.key ? 12 : 8,
          height: currentIndex.value == entry.key ? 12 : 8,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex.value == entry.key
                ? AppColors.appColor
                : Colors.white.withOpacity(0.6),
          ),
        );
      }).toList(),
    ));
  }
}