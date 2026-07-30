import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/charts/BarChartWidget.dart';
import 'package:pakland/core/widgets/charts/PieChartWidget.dart';
import 'package:pakland/core/widgets/widgets/app_bar.dart';
import 'package:pakland/core/widgets/widgets/app_dropdown.dart';
import 'package:pakland/core/widgets/widgets/date_filter_button.dart';
import 'package:pakland/features/sos/presentation/widgets/sos_buttton.dart';
import 'package:pakland/core/widgets/widgets/statusCard.dart';
import 'package:pakland/core/utils/screen_helper.dart';

class AdminDashboard extends StatefulWidget {
  final TicketController ticketController;
  final String userType;
  final selectedBranchName = RxnString();
  final selectedDepartmentName = RxnString();
  final selectedStaffName = RxnString();

  AdminDashboard({super.key, required this.ticketController, required this.userType});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _carouselIndex = 0;
  final _storage = const FlutterSecureStorage();
  String _userType = '';

  TextStyle get dropdownLables => const TextStyle(fontWeight: FontWeight.bold);
  TextStyle get dropdownItemsText => const TextStyle(fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _loadUserType();
    if (widget.ticketController.list_to_admin.value == 'list_to_admin') {
      widget.ticketController.main_d_to_admin.value = 'main_d_to_admin';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.ticketController.applyFiltersLocally();
      widget.ticketController.filterTitle.value = '';
    });
    widget.ticketController.main_d_to_admin.value = 'main_d_to_admin';
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: "user_type") ?? '';
    if (mounted) setState(() => _userType = userType);
  }

  @override
  void dispose() {
    widget.ticketController.main_d_to_admin.value = '';
    widget.ticketController.filterDepartment.value = null;
    super.dispose();
  }

  Widget _buildStatusFilter() {
    return Obx(() {
      final items = <DropdownMenuItem<String?>>[
        DropdownMenuItem<String?>(value: null, child: Text('All', style: dropdownItemsText)),
        if (widget.userType != "Customer") DropdownMenuItem<String?>(value: 'Open', child: Text('Open', style: dropdownItemsText)),
        DropdownMenuItem<String?>(value: 'In Progress', child: Text('In Progress', style: dropdownItemsText)),
        DropdownMenuItem<String?>(value: 'Done', child: Text('Done', style: dropdownItemsText)),
        if (widget.userType != "Customer") DropdownMenuItem<String?>(value: 'Closed', child: Text('Closed', style: dropdownItemsText)),
      ];
      final currentValue = widget.ticketController.filterStatus.value;
      final validValues = items.map((item) => item.value).toSet();
      final validatedValue = validValues.contains(currentValue) ? currentValue : null;
      if (currentValue != validatedValue && validatedValue == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.ticketController.filterStatus.value = null);
      }
      return AppDropdown<String?>(hint: Text('Status', style: dropdownLables), value: validatedValue, items: items, onChanged: (value) {
        widget.ticketController.filterStatus.value = (value == null || value.isEmpty) ? null : value;
        widget.ticketController.applyFiltersLocally();
      });
    });
  }

  Widget _buildPriorityFilter() {
    return Obx(() => AppDropdown<String?>(
      hint: Text('Priority', style: dropdownLables),
      value: widget.ticketController.filterPriority.value,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('All', style: dropdownItemsText)),
        DropdownMenuItem<String?>(value: 'High', child: Text('High', style: dropdownItemsText)),
        DropdownMenuItem<String?>(value: 'Medium', child: Text('Medium', style: dropdownItemsText)),
        DropdownMenuItem<String?>(value: 'Low', child: Text('Low', style: dropdownItemsText)),
      ],
      onChanged: (value) {
        widget.ticketController.filterPriority.value = value;
        widget.ticketController.applyFiltersLocally();
      },
    ));
  }

  Widget _buildBranheFilter() {
    return Obx(() => AppDropdown<String?>(
      hint: Text('Project', style: dropdownLables),
      value: widget.ticketController.filterBranche.value,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('All Projects', style: dropdownItemsText)),
        ...widget.ticketController.branches.map((brns) => DropdownMenuItem<String?>(value: brns['brn_code']?.toString() ?? '', child: Text(brns['brn_name']?.toString() ?? 'Unknown', style: dropdownItemsText))),
      ],
      onChanged: (value) {
        if (value == null || value.isEmpty) { widget.ticketController.filterBranche.value = null; widget.selectedDepartmentName.value = null; }
        else { widget.ticketController.filterBranche.value = value; widget.selectedBranchName.value = value; widget.ticketController.selectBracnch(value); }
        widget.ticketController.applyFiltersLocally();
      },
    ));
  }

  Widget _buildDepartmentFilter() {
    return Obx(() => AppDropdown<String?>(
      hint: Text('Department', style: dropdownLables),
      value: widget.ticketController.filterDepartment.value,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('All Departments', style: dropdownItemsText)),
        ...widget.ticketController.departments.map((dept) => DropdownMenuItem<String?>(value: dept['DeptID']?.toString() ?? '', child: Text(dept['DeptName']?.toString() ?? 'Unknown', style: dropdownItemsText))),
      ],
      onChanged: (value) {
        widget.ticketController.filterDepartment.value = (value == null || value.isEmpty) ? null : value;
        widget.ticketController.applyFiltersLocally();
      },
    ));
  }

  Widget _buildTitleSearchField() {
    return SizedBox(
      height: 35,
      child: TextField(
        decoration: InputDecoration(
          isDense: true, labelText: 'Search', labelStyle: const TextStyle(fontSize: 13, color: Colors.black),
          hintText: 'Search...', hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor, size: 18),
          suffixIcon: widget.ticketController.filterTitle.value.isNotEmpty
              ? IconButton(icon: Icon(Icons.clear, size: 16, color: Colors.grey), onPressed: () { widget.ticketController.filterTitle.value = ''; widget.ticketController.applyFiltersLocally(); })
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryColor, width: 1.2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        ),
        style: const TextStyle(fontSize: 13, color: Colors.black),
        onChanged: (value) { widget.ticketController.filterTitle.value = value; widget.ticketController.applyFiltersLocally(); },
      ),
    );
  }

  Widget _buildStaffFilter() {
    return Obx(() => AppDropdown<String?>(
      hint: Text('Staff', style: dropdownLables),
      value: widget.ticketController.filterStaff.value,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('All Staff', style: dropdownItemsText)),
        ...widget.ticketController.StaffUsers.map((staff) => DropdownMenuItem<String?>(value: staff['User_id']?.toString() ?? '', child: Text(staff['user_name']?.toString() ?? 'Unknown', style: dropdownItemsText))),
      ],
      onChanged: (value) {
        if (value == null || value.isEmpty) { widget.ticketController.filterStaff.value = null; widget.selectedStaffName.value = null; }
        else { widget.ticketController.filterStaff.value = value; widget.selectedStaffName.value = value; }
        widget.ticketController.applyFiltersLocally();
      },
    ));
  }

  List<Widget> _buildDashboardSlides() {
    final screenHeight = 300;
    final chartHeight = screenHeight * 0.4;

    return [
      // Tickets list
      Container(
        decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.textPrimaryColor.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))], border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final list = widget.ticketController.applyFiltersLocally();
          final currentStatus = widget.ticketController.filterStatus.value ?? 'All';
          final statusLabel = currentStatus == 'All' ? 'All Tickets' : '$currentStatus Tickets';
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(statusLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('${list.length}', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 8),
            Expanded(child: list.isEmpty
                ? Center(child: Text('No tickets found', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.2)),
              itemBuilder: (context, index) {
                final t = list[index];
                final statusColor = AppColors.statusColor(t.status);
                final color = AppColors.priorityColor(t.ticketPriority);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(backgroundColor: AppColors.priorityColor(t.ticketPriority).withOpacity(0.12), child: t.title.contains('SOS') ? Icon(Icons.emergency, color: Colors.red) : Icon(Icons.receipt_long_outlined, color: color)),
                  title: Text(t.id, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(t.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Chip(label: Text(t.status, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: statusColor),
                  onTap: () => Get.toNamed('/tickets/${t.id}', arguments: {'ticket': t}),
                );
              },
            )),
          ]);
        }),
      ),
      // Pie chart
      Container(
        height: MediaQuery.of(context).size.height * 0.50,
        decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.textPrimaryColor.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))], border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
        padding: const EdgeInsets.all(25),
        child: Obx(() => PieChartWidget(title: 'Total Tickets', ticketCounts: {
          if (widget.userType != "Customer") 'Open': widget.ticketController.openTicketsCount.value,
          'In Progress': widget.ticketController.inProgressTicketsCount.value,
          if (widget.userType != "Customer") 'Closed': widget.ticketController.closedTicketsCount.value,
          'Done': widget.ticketController.doneTicketsCount.value,
        }, ticketColors: {'Open': AppColors.errorColor, 'In Progress': AppColors.warningColor, 'Closed': AppColors.blueGrey, 'Done': AppColors.successColor})),
      ),
      // Bar chart
      Container(
        height: chartHeight.toDouble(),
        decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
        padding: const EdgeInsets.all(16),
        child: Obx(() => BarChartWidget(
          data: {
            if (widget.userType != "Customer") 'Open': widget.ticketController.openTicketsCount.value,
            'In Progress': widget.ticketController.inProgressTicketsCount.value,
            if (widget.userType != "Customer") 'Closed': widget.ticketController.closedTicketsCount.value,
            'Done': widget.ticketController.doneTicketsCount.value,
          },
          barColors: {'Open': AppColors.errorColor, 'In Progress': AppColors.warningColor, 'Closed': AppColors.blueGrey, 'Done': AppColors.successColor, 'Dropped': AppColors.grey},
        )),
      ),
    ];
  }

  Widget _buildDashboardCarousel() {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.45;
    final slides = _buildDashboardSlides();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: carouselHeight, width: double.infinity,
        child: CarouselSlider(
          items: slides, carouselController: _carouselController,
          options: CarouselOptions(height: carouselHeight, viewportFraction: 1, enlargeCenterPage: true, enableInfiniteScroll: true, autoPlay: false, onPageChanged: (index, reason) => setState(() => _carouselIndex = index)),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(slides.length, (idx) {
        final isActive = idx == _carouselIndex;
        return GestureDetector(
          onTap: () => _carouselController.animateToPage(idx),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 4), height: 8, width: isActive ? 20 : 8, decoration: BoxDecoration(color: isActive ? AppColors.primaryColor : Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(8))),
        );
      })),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final screenHeight = MediaQuery.of(context).size.height * 0.01;
    final screenWidth = MediaQuery.of(context).size.width * 0.02;

    return WillPopScope(
      onWillPop: () async {
        final route = _userType.toLowerCase() == 'admin' ? '/mainDashboard' : (_userType.toLowerCase() == 'customer' ? '/main_screen' : '/clintDashboard');
        Get.offAllNamed(route);
        return false;
      },
      child: Scaffold(
        appBar:  PreferredSize(
      preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
      child: CustomAppBar(
        custom_RouteName: widget.userType.toLowerCase() == 'admin' ? '/dashboard' : '/main_screen',
        title: '${widget.ticketController.dashboardTitle}',
      ),
    ),
        body: RefreshIndicator(
          onRefresh: () async { await widget.ticketController.refreshDashboardData(); setState(() {}); },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                spacing: screenHeight,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status cards — TV pe 4 in a row, mobile same
                  if (widget.userType == "Admin") ...[
                    isTV
                        ? Row(spacing: screenWidth, children: [
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/open.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'Open', icon: Icons.open_in_new, count: widget.ticketController.openTicketsCount.value, color: AppColors.errorColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'Open'})))),
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/inprogress.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'In Progress', icon: Icons.rotate_90_degrees_cw_rounded, count: widget.ticketController.inProgressTicketsCount.value, color: AppColors.warningColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'In Progress'})))),
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/done.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'Done', icon: Icons.done_outline, count: widget.ticketController.doneTicketsCount.value, color: AppColors.successColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'Done'})))),
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/close.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'Closed', icon: Icons.archive, count: widget.ticketController.closedTicketsCount.value, color: Colors.blueGrey, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'Closed'})))),
                    ])
                        : Row(spacing: screenWidth, children: [
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/open.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'Open', icon: Icons.open_in_new, count: widget.ticketController.openTicketsCount.value, color: AppColors.errorColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'Open'})))),
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/inprogress.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'In Progress', icon: Icons.rotate_90_degrees_cw_rounded, count: widget.ticketController.inProgressTicketsCount.value, color: AppColors.warningColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'In Progress'})))),
                    ]),
                  ],
                  // Secondary row (mobile only)
                  if (!isTV)
                    Row(spacing: screenWidth, children: [
                      if (widget.userType == "Customer") Expanded(child: Obx(() => StatusCard(image: 'assets/images/inprogress.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'In Progress', icon: Icons.assignment_outlined, count: widget.ticketController.inProgressTicketsCount.value, color: AppColors.warningColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'In Progress'})))),
                      Expanded(child: Obx(() => StatusCard(image: 'assets/images/done.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'Done', icon: Icons.done_outline, count: widget.ticketController.doneTicketsCount.value, color: AppColors.successColor, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'Done'})))),
                      if (widget.userType == "Admin") Expanded(child: Obx(() => StatusCard(image: 'assets/images/close.png', totalCount: widget.ticketController.totleTicketsCount.value, title: 'Closed', icon: Icons.archive, count: widget.ticketController.closedTicketsCount.value, color: Colors.blueGrey, onTap: () => Get.toNamed('/tickets', arguments: {'status': 'Closed'})))),
                    ]),
                  // Hold filter
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
                    decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
                    child: Row(children: [
                      Expanded(child: Text('Hold Filter Criteria', style: dropdownLables)),
                      Obx(() => Checkbox(value: widget.ticketController.isHoldfilterState.value, activeColor: AppColors.primaryColor, onChanged: (value) {
                        widget.ticketController.isHoldfilterState.value = value!;
                        Get.snackbar('Filter State', value ? '✅ Filters will be preserved during refresh' : '🔄 Filters will reset during refresh', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2), backgroundColor: value ? Colors.green : Colors.orange, colorText: Colors.white, margin: EdgeInsets.all(8));
                      })),
                    ]),
                  ),
                  // Filters — TV pe 2 column grid
                  if (isTV)
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Project', style: dropdownLables), _buildBranheFilter()])),
                      SizedBox(width: screenWidth),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Department', style: dropdownLables), _buildDepartmentFilter()])),
                    ])
                  else ...[
                    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Project', style: dropdownLables), _buildBranheFilter()]))]),
                    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Department', style: dropdownLables), _buildDepartmentFilter()]))]),
                  ],
                  if (widget.userType == "Admin")
                    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Staff', style: dropdownLables), _buildStaffFilter()]))]),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Status', style: dropdownLables), _buildStatusFilter()])),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Priority', style: dropdownLables), _buildPriorityFilter()])),
                  ]),
                  Row(children: [
                    Expanded(child: DateFilterButton(selectedDate: widget.ticketController.filterFromDate, labelPrefix: 'From', onDateChanged: () => widget.ticketController.applyFiltersLocally())),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(child: DateFilterButton(selectedDate: widget.ticketController.filterToDate, labelPrefix: 'To', onDateChanged: () => widget.ticketController.applyFiltersLocally())),
                  ]),
                  _buildTitleSearchField(),
                  _buildDashboardCarousel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}