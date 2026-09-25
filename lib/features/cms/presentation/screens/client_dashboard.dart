import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/charts/PieChartWidget.dart';
import 'package:pakland/core/widgets/app_bar2.dart';
import 'package:pakland/core/widgets/sos_buttton.dart';
import 'package:pakland/core/widgets/statusCard.dart';


class ClientDashboard extends StatefulWidget {
  final TicketController ticketController;

  const ClientDashboard({
    super.key,
    required this.ticketController,
  });

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final _storage = const FlutterSecureStorage();
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final id = await _storage.read(key: "user_id");
      setState(() {
        userId = id;
        isLoading = false;
      });
      print('User ID loaded: $userId');
    } catch (e) {
      print('Error loading user ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final SocialController socialController = Get.put(SocialController());
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed('/main_screen');
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/tickets/create'),
          backgroundColor: AppColors.primaryColor,
          icon: Icon(Icons.add, color: AppColors.textPrimaryColor),
          label: Text(
            'Create Ticket',
            style: TextStyle(color: AppColors.textPrimaryColor),
          ),
        ),
        appBar:
        CustomAppBar(
          custom_RouteName: '/main_screen',
          title: 'Client Dashboard',
          rightWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SOSButtonClone(
                onTap: () => Get.toNamed('/UserSOS'),
                isActive: false,
                branches: socialController.branches,
                username: userId?? '',
              ),

              /// 🔔 Notification Icon
              if (widget.ticketController.userType == "Admin" ||
                  (widget.ticketController.userType == "Customer" &&
                      widget.ticketController.canReceiveSOS.value))
                Stack(
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
                      child: Obx(
                            () => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            widget.ticketController.activeSOSCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        body: RefreshIndicator(
          onRefresh: widget.ticketController.refreshDashboardData,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(8.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ================= STATUS ROW 1 =================
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                            () => StatusCard(
                          image: 'assets/images/open.png',
                          totalCount: widget.ticketController.totleTicketsCount.value,
                          title: 'Open',
                          icon: Icons.open_in_new,
                          count: widget.ticketController.openTicketsCount.value,
                          color: AppColors.errorColor,
                          onTap: () {
                            Get.toNamed('/tickets',
                                arguments: {'status': 'Open'});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                            () => StatusCard(
                          image: 'assets/images/inprogress.png',
                          totalCount: widget.ticketController.totleTicketsCount.value,
                          title: 'In Progress',
                          icon: Icons.rotate_90_degrees_cw,
                          count:
                          widget.ticketController.inProgressTicketsCount.value,
                          color: AppColors.warningColor,
                          onTap: () {
                            Get.toNamed('/tickets',
                                arguments: {'status': 'In Progress'});
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ================= STATUS ROW 2 =================
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                            () => StatusCard(
                          image: 'assets/images/done.png',
                          totalCount: widget.ticketController.totleTicketsCount.value,
                          title: 'Done',
                          icon: Icons.done_outline,
                          count: widget.ticketController.doneTicketsCount.value,
                          color: AppColors.successColor,
                          onTap: () {
                            Get.toNamed('/tickets',
                                arguments: {'status': 'Done'});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                            () => StatusCard(
                          image: 'assets/images/close.png',
                          totalCount: widget.ticketController.totleTicketsCount.value,
                          title: 'Closed',
                          icon: Icons.archive,
                          count:
                          widget.ticketController.closedTicketsCount.value,
                          color: AppColors.blueGrey,
                          onTap: () {
                            Get.toNamed('/tickets',
                                arguments: {'status': 'Closed'});
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ================= PIE CHART =================
                Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimaryColor
                            .withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context)
                          .dividerColor
                          .withOpacity(0.2),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                        () => PieChartWidget(
                      title: 'My Tickets',
                      ticketCounts: {
                        'Open':
                        widget.ticketController.openTicketsCount.value,
                        'In Progress':
                        widget.ticketController
                            .inProgressTicketsCount.value,
                        'Closed':
                        widget.ticketController.closedTicketsCount.value,
                        'Done':
                        widget.ticketController.doneTicketsCount.value,
                      },
                      ticketColors: {
                        'Open': AppColors.errorColor,
                        'In Progress':
                        AppColors.warningColor,
                        'Closed': AppColors.blueGrey,
                        'Done': AppColors.successColor,
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
