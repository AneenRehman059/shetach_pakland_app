// cms_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/app_bar2.dart';
import 'package:pakland/features/cms/presentation/screens/admin_dashboard.dart';
import 'package:pakland/features/cms/presentation/screens/admin_main_dashbord.dart';
import 'package:pakland/features/cms/presentation/screens/client_dashboard.dart';
import 'package:pakland/features/cms/presentation/screens/default_dashboard.dart';

class CMSDashboardScreen extends StatefulWidget {
  const CMSDashboardScreen({super.key});

  @override
  State<CMSDashboardScreen> createState() => _CMSDashboardScreenState();
}

class _CMSDashboardScreenState extends State<CMSDashboardScreen> {
  final TicketController ticketController = Get.find<TicketController>();

  bool _hasNavigated = false; // Prevent multiple navigation calls

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (!ticketController.isInitialized) {
      await ticketController.initializeController();
    } else {
      await ticketController.refreshDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Get.offAll(() => MainWrapper());
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "Loading...", custom_RouteName: "/"),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Obx(() {

            if (ticketController.isLoading.value) {
              return Center(
                child: SpinKitWave(
                  color: AppColors.primaryColor,
                  size: 24.0,
                ),
              );
            }

            final userType = ticketController.userType.value;

            /// 🔹 2️⃣ Invalid User State
            if (userType.isEmpty || userType == "Invalid") {
              return _buildInvalidUserUI();
            }

            /// 🔹 3️⃣ Valid User → Navigate Once
            if (!_hasNavigated) {
              _hasNavigated = true;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToDashboard(userType);
              });
            }

            return const SizedBox(); // Empty while navigating
          }),
        ),
      ),
    );
  }

  /// 🔴 Invalid User UI
  Widget _buildInvalidUserUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invalid User'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 12),
              Text(
                "Invalid User",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🚀 Navigation Based On User Type
  void _navigateToDashboard(String userType) {
    switch (userType) {
      case 'Admin':
        Get.off(() => AdminMainDashboard(
          ticketController: ticketController,
          userType: userType,
          userId: ticketController.userId.value,
        ));
        break;

      case 'Customer':
        Get.off(() => AdminDashboard(
          ticketController: ticketController,
          userType: userType,
        ));
        break;

      case 'Client':
        Get.off(() => ClientDashboard(
          ticketController: ticketController,
        ));
        break;

      default:
        Get.off(() => DefaultDashboard(
          ticketController: ticketController,
        ));
        break;
    }
  }
}