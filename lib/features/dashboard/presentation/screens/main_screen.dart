import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/core/services/fcm_notification_service.dart';
import 'package:pakland/features/dashboard/presentation/screens/dashboard_menus.dart';

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
  final RxString userType = ''.obs;

  @override
  void initState() {
    super.initState();
    companyController.fetchAndStoreCompanyDetails("SHET");
    _loadUserType();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ticketController.loadActiveSOSEmergencies();
    });
  }

  Future<void> _loadUserType() async {
    final storage = const FlutterSecureStorage();
    final type = await storage.read(key: "user_type") ?? "";
    userType.value = type;
    loginController.userType.value = type;
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final double sliderHeight = isTV
        ? MediaQuery.of(context).size.height * 0.42
        : MediaQuery.of(context).size.height * 0.25;

    return Scaffold(
      // TV pe AppBar nahi — side nav mein logo already hai
      appBar: isTV ? null : AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(ImageConstant.logo, height: 55),
        actions: [
          Obx(() {
            final isAdmin = userType.value == "Admin";
            if (!isAdmin) return const SizedBox.shrink();
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => Get.toNamed('/SOSListView'),
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.yellowAccent.shade700,
                    size: 26,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Obx(() => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      ticketController.activeSOSCount.value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TV pe notification bell upar right mein
            if (isTV)
              Obx(() {
                final isAdmin = userType.value == "Admin";
                if (!isAdmin) return SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Get.toNamed('/SOSListView'),
                        icon: Icon(
                          Icons.notifications,
                          color: Colors.yellowAccent.shade700,
                          size: 32,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Obx(() => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            ticketController.activeSOSCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                      ),
                    ],
                  ),
                );
              }),

            // Blue line
            Container(height: 1, width: double.infinity, color: AppColors.appColor),
            SizedBox(height: 5),

            // Slider
            Obx(() {
              if (companyController.sliders.isEmpty) return SizedBox.shrink();
              return Stack(
                children: [
                  CarouselSlider(
                    items: _buildSliderItems(context),
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.easeInOut,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
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

            SizedBox(height: 5),
            Expanded(child: DashboardMenus()),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSliderItems(BuildContext context) {
    return companyController.sliders.map((e) {
      final rawPath = e['image_path'] ?? "";
      final url = companyController.getFullImageUrl(rawPath);
      return SizedBox(
        width: double.infinity,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: SpinKitWave(color: AppColors.appColor, size: 30.0));
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
        final selected = currentIndex.value == entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: selected ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: selected ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        );
      }).toList(),
    ));
  }
}