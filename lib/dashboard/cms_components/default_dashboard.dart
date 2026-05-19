import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';


import '../../colors.dart';
import '../../controllers/tickets_controller.dart';
import '../../customs/widgets/BarChartWidget.dart';
import '../../customs/widgets/PieChartWidget.dart';
import '../../customs/widgets/app_bar.dart';

class DefaultDashboard extends StatefulWidget {
  final TicketController ticketController;
  // Removed onRefresh parameter - using controller's refresh method directly

  const DefaultDashboard({
    super.key,
    required this.ticketController,
  });

  @override
  State<DefaultDashboard> createState() => _DefaultDashboardState();
}

class _DefaultDashboardState extends State<DefaultDashboard> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _carouselIndex = 0;

  List<Widget> _buildDashboardSlides() {
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = screenHeight * 0.4; // Fixed height for charts

    return [
      // 0) All Tickets list with filters applied (scrollable)
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryColor.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final list = widget.ticketController.applyFiltersLocally();
          final currentStatus = widget.ticketController.filterStatus.value ?? 'All';
          final statusLabel = currentStatus == 'All' ? 'All Tickets' : '$currentStatus Tickets';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    statusLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${list.length}',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: list.isEmpty
                    ? Center(
                  child: Text(
                    'No tickets found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final t = list[index];
                    final statusColor = AppColors.statusColor(t.status);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4
                      ),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.12),
                        child: Text(
                          t.ticketPriority ?? 'P4',
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12
                          ),
                        ),
                      ),
                      title: Text(
                        t.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        t.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Chip(
                        label: Text(
                          t.status,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: statusColor.withOpacity(0.08),
                        labelStyle: TextStyle(color: statusColor),
                      ),
                      onTap: () => Get.toNamed(
                          '/tickets/${t.id}',
                          arguments: {'ticket': t}
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),

      // 1) Total Tickets Pie chart
      Container(
        height: chartHeight,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryColor.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Obx(() => PieChartWidget(
          title: 'Total Tickets',
          ticketCounts: {
            'Open': widget.ticketController.openTicketsCount.value,
            'In Progress': widget.ticketController.inProgressTicketsCount.value,
            'Closed': widget.ticketController.closedTicketsCount.value,
            'Done': widget.ticketController.doneTicketsCount.value,
          },
          ticketColors: {
            'Open': AppColors.errorColor,
            'In Progress': AppColors.warningColor,
            'Closed': AppColors.successColor,
            'Done': AppColors.grey,
          },
        )),
      ),

      // 2) Bar chart slide
      Container(
        height: chartHeight,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Obx(() => BarChartWidget(data: {
          'Open': widget.ticketController.openTicketsCount.value,
          'In Progress': widget.ticketController.inProgressTicketsCount.value,
          'Closed': widget.ticketController.closedTicketsCount.value,
          'Done': widget.ticketController.doneTicketsCount.value,
        }, barColors: {
          'Open': AppColors.errorColor,
          'In Progress': AppColors.warningColor,
          'Closed': AppColors.successColor,
          'Dropped': AppColors.grey,
        })),
      ),
    ];
  }

  Widget _buildDashboardCarousel() {
    final slides = _buildDashboardSlides();
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        CarouselSlider(
          items: slides,
          carouselController: _carouselController,
          options: CarouselOptions(
            height: screenHeight * 0.45, // Fixed height
            viewportFraction: 1,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() => _carouselIndex = index);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (idx) {
            final isActive = idx == _carouselIndex;
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 20 : 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        custom_RouteName: '/dashboard',
        title: 'Dashboard',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.ticketController.refreshDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOS Emergency Card (for Team/Staff users)
              Obx(() => widget.ticketController.activeSOSCount.value > 0
                  ? Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🚨 ACTIVE SOS EMERGENCIES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.ticketController.activeSOSCount.value} Active Emergency${widget.ticketController.activeSOSCount.value != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        // Navigate to SOS emergencies list
                        Get.toNamed('/tickets',
                            arguments: {'status': 'SOS'}
                        );
                      },
                    ),
                  ],
                ),
              )
                  : const SizedBox()),
              const SizedBox(height: 8),

              // Status cards
              Row(
                children: [
                  Expanded(
                    child: Obx(
                          () => _StatusCard(
                        image: 'assets/images/open.png',
                        total_count: widget.ticketController.totleTicketsCount.value,
                        title: 'Open',
                        icon: Icons.open_in_new,
                        count: widget.ticketController.openTicketsCount.value,
                        color: AppColors.errorColor,
                        onTap: () {
                          print('🔍 Default Dashboard: Clicked Open status card');
                          Get.toNamed(
                            '/tickets',
                            arguments: {'status': 'Open'},
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                          () => _StatusCard(
                        image: 'assets/images/inprogress.png',
                        total_count: widget.ticketController.totleTicketsCount.value,
                        title: 'In Progress',
                        icon: Icons.rotate_90_degrees_cw_rounded,
                        count: widget.ticketController.inProgressTicketsCount.value,
                        color: AppColors.warningColor,
                        onTap: () {
                          print('🔍 Default Dashboard: Clicked In Progress status card');
                          Get.toNamed(
                            '/tickets',
                            arguments: {'status': 'In Progress'},
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Secondary cards
              Row(
                children: [
                  Expanded(
                    child: Obx(
                          () => _StatusCard(
                        image: 'assets/images/done.png',
                        total_count: widget.ticketController.totleTicketsCount.value,
                        title: 'Done',
                        icon: Icons.done_outline,
                        count: widget.ticketController.doneTicketsCount.value,
                        color: AppColors.successColor,
                        onTap: () {
                          print('🔍 Default Dashboard: Clicked Done status card');
                          Get.toNamed(
                            '/tickets',
                            arguments: {'status': 'Done'},
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                          () => _StatusCard(
                        image: 'assets/images/close.png',
                        total_count: widget.ticketController.totleTicketsCount.value,
                        title: 'Closed',
                        icon: Icons.archive,
                        count: widget.ticketController.closedTicketsCount.value,
                        color: Colors.blueGrey,
                        onTap: () {
                          print('🔍 Default Dashboard: Clicked Closed status card');
                          Get.toNamed(
                            '/tickets',
                            arguments: {'status': 'Closed'},
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Charts carousel
              _buildDashboardCarousel(),

              // Add bottom padding for better scrolling
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );

  }
}

class _StatusCard extends StatelessWidget {
  final String? image;
  final String title;
  final IconData icon;
  final int count;
  final int total_count;
  final Color color;
  final VoidCallback? onTap;

  const _StatusCard({
    this.image,
    required this.title,
    required this.icon,
    required this.count,
    required this.total_count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: 100, // Fixed height
      decoration: BoxDecoration(
        image: image != null ? DecorationImage(
          image: AssetImage(image!),
          fit: BoxFit.cover,
        ) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 10.0,
            alignment: WrapAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _graph_status(context, count, total_count, color),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.arrow_circle_right_rounded,
                    size: 28,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

Widget _graph_status(BuildContext context, int count, int totalCount, Color color) {
  double progress = (totalCount == 0) ? 0 : count / totalCount.toDouble();

  return SizedBox(
    width: 40,
    height: 40,
    child: Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.9),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 3,
            backgroundColor: Colors.white.withOpacity(0.5),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Center(
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}