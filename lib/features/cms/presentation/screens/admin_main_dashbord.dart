import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:material_charts/material_charts.dart';
import 'package:pakland/core/widgets/sos_buttton.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/charts/PieChartWidget.dart';
import 'package:pakland/core/widgets/app_bar2.dart';
import 'package:pakland/core/widgets/app_dropdown.dart';
import 'package:pakland/core/widgets/app_toolTip.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/cms/presentation/screens/admin_dashboard.dart';
import 'package:pakland/features/cms/presentation/screens/cms_dashboard_screen.dart';
import 'package:pakland/features/cms/presentation/widgets/department_bar_chart_main_admin.dart';


class AdminMainDashboard extends StatefulWidget {
  final TicketController ticketController;
  final String userType;
  final String userId;
  // Removed onRefresh parameter - using controller's refresh method directly

  // Rx variables for branch/department selection
  final selectedBranchName = RxnString();
  final selectedDepartmentName = RxnString();

  AdminMainDashboard({
    Key? key,
    required this.ticketController,
    required this.userType,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> {
  late RefreshController _refreshController;
  final ScrollController _tableScrollController = ScrollController();
  final SocialController socialController = Get.put(SocialController());
  final _storage = const FlutterSecureStorage();
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _refreshController = RefreshController(initialRefresh: false);
    if (widget.userType == 'Customer') {
      widget.ticketController.fetchDepartmentByUID(widget.userId);
    }

    // Ensure controller is initialized
    if (!widget.ticketController.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.ticketController.initializeController();
      });
    }
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: "user_type") ?? '';
    if (mounted) {
      setState(() => _userType = userType);
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  // Define reusable text styles
  TextStyle get _headingTextStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondaryColor,
  );

  TextStyle get _sectionTitleStyle => const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    const TextStyle dropdownLables = TextStyle(fontWeight: FontWeight.bold);

    return WillPopScope(
      onWillPop: () async {
        final route = _userType.toLowerCase() == 'admin'
            ? '/main_screen'
            : '/clintDashboard';
        Get.offAllNamed(route);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Admin Dashboard",
          custom_RouteName: "/main_screen",

        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(
            waterDropColor: AppColors.primaryColor,
            complete: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Icon(Icons.done, color: Colors.green),
            ),
            refresh: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  strokeWidth: 2,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Refreshing...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          onRefresh: () async {

            try {
              // Refresh all dashboard data
              await widget.ticketController.refreshDashboardData();
              // Complete refresh
              _refreshController.refreshCompleted();
            } catch (e) {
              print('Error during refresh: $e');
              _refreshController.refreshFailed();
            }
          },
          child: SafeArea(
            child: Material(
              child: Scrollbar(
                controller: _tableScrollController,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          // margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  spacing: 5.0,
                                  children: [
                                    Icon(
                                      Icons.filter_alt,
                                      size: 18,
                                      color: AppColors.primaryColor,
                                    ),
                                    // const SizedBox(width: 8),
                                    Text(
                                        'Hold Criteria',
                                        style: dropdownLables
                                    ),
                                    // const SizedBox(width: 4),
                                    AppTooltip(message: 'When checked, filters will be preserved during refresh',)
                                  ],
                                ),
                              ),
                              Obx(
                                    () => Checkbox(
                                  value: widget.ticketController.isHoldfilterState.value,
                                  activeColor: AppColors.primaryColor,
                                  onChanged: (value) {
                                    widget.ticketController.isHoldfilterState.value = value!;

                                    // Show feedback to user
                                    Get.snackbar(
                                      'Filter State',
                                      value
                                          ? '✅ Filters will be preserved during refresh'
                                          : '🔄 Filters will reset during refresh',
                                      snackPosition: SnackPosition.TOP,
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: value ? Colors.green : Colors.orange,
                                      colorText: Colors.white,
                                      margin: EdgeInsets.all(8),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Project filter (single dropdown for all user types)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Project',
                                    style: dropdownLables,
                                  ),
                                  _buildBrancheFilter(),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 1) Total Tickets Pie chart - with legend at bottom
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
                          padding: const EdgeInsets.all(8),
                          child: Obx(
                                () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   '${_getProjectDisplayName()} Tickets',
                                //   style: _headingTextStyle,
                                // ),
                                // const SizedBox(height: 8),

                                PieChartWidget(
                                  ticketCounts: _getTicketCountsMap(),
                                  ticketColors: {
                                    'Open': AppColors.errorColor,
                                    'In Progress': AppColors.warningColor,
                                    'Done': AppColors.successColor,
                                    'Closed': AppColors.closeColor,
                                  },
                                  title: 'Tickets Distribution',
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2) Department-wise Status Horizontal Stacked Bar Chart
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Obx(() => _buildHorizontalStackedBarChart()),
                        ),

                        // 2) Departments Status in table
                        Obx(() => _buildStatusByDepartmentTable()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get pie chart data from ticket controller
  String _getProjectDisplayName() {
    // Get the selected branch code
    String? selectedBranchCode = widget.ticketController.filterBranche.value;

    if (selectedBranchCode == null) {
      // If no branch is selected, show 'All Projects'
      return 'All Projects';
    } else {
      // Find the branch name based on the selected code
      var selectedBranch = widget.ticketController.branches.firstWhere(
            (branch) => branch['brn_code']?.toString() == selectedBranchCode,
        orElse: () => {'brn_name': 'Unknown'},
      );

      String branchName = selectedBranch['brn_name']?.toString() ?? 'Unknown';
      return branchName;
    }
  }

  Map<String, int> _getTicketCountsMap() {
    Map<String, int> counts = {};

    // Add Open tickets
    if (widget.ticketController.openTicketsCount.value > 0) {
      counts['Open'] = widget.ticketController.openTicketsCount.value;
    }

    // Add In Progress tickets (for non-customer users)
    if (widget.userType != "Customer" &&
        widget.ticketController.inProgressTicketsCount.value > 0) {
      counts['In Progress'] = widget.ticketController.inProgressTicketsCount.value;
    }

    // Add Done tickets
    if (widget.ticketController.doneTicketsCount.value > 0) {
      counts['Done'] = widget.ticketController.doneTicketsCount.value;
    }

    // Add Closed tickets (for non-customer users)
    if (widget.userType != "Customer" &&
        widget.ticketController.closedTicketsCount.value > 0) {
      counts['Closed'] = widget.ticketController.closedTicketsCount.value;
    }

    return counts;
  }

  Widget _buildBrancheFilter() {
    return Obx(
          () => AppDropdown<String?>(
        hint: Text(
          'Project',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        value: widget.ticketController.filterBranche.value,
        items: [
          // Always show "All Departments" option
          DropdownMenuItem<String?>(
            value: null,
            child: Text('All Projects', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Populate department list dynamically
          ...widget.ticketController.branches.map(
                (brns) => DropdownMenuItem<String?>(
              value: brns['brn_code']?.toString() ?? '',
              child: Text(brns['brn_name']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        onChanged: (value) async {
          if (value == null || value.isEmpty) {
            widget.ticketController.filterBranche.value = null;
            widget.selectedDepartmentName.value = null;
          } else {
            widget.ticketController.filterBranche.value = value;
            widget.selectedBranchName.value = value;
            widget.ticketController.selectBracnch(value);
          }

          // Apply filters and refresh data
          widget.ticketController.applyFiltersLocally();

        },
      ),
    );
  }

  Widget _buildStatusByDepartmentTable() {
    // Fetch department and ticket status data
    var deptStatusMap = <String, Map<String, int>>{};

    // Get selected branch filter
    String? selectedBranch = widget.ticketController.filterBranche.value;

    // Filter tickets by selected branch if a branch is selected
    List<TicketModel> filteredTickets = widget.ticketController.tickets;
    if (selectedBranch != null && selectedBranch.isNotEmpty) {
      filteredTickets = widget.ticketController.tickets
          .where((ticket) => ticket.brn_code == selectedBranch)
          .toList();
    }

    // Group tickets by department and status
    for (var ticket in filteredTickets) {
      String deptName = ticket.title;
      String status = ticket.status;

      if (!deptStatusMap.containsKey(deptName)) {
        deptStatusMap[deptName] = {};
      }

      deptStatusMap[deptName]![status] = (deptStatusMap[deptName]![status] ?? 0) + 1;
    }

    // Calculate total counts across all departments
    Map<String, int> grandTotals = {
      'Open': 0,
      'In Progress': 0,
      'Done': 0,
      'Closed': 0,
    };

    for (var entry in deptStatusMap.entries) {
      var statusCounts = entry.value;
      grandTotals['Open'] = (grandTotals['Open'] ?? 0) + (statusCounts['Open'] ?? 0);
      grandTotals['In Progress'] = (grandTotals['In Progress'] ?? 0) + (statusCounts['In Progress'] ?? 0);
      grandTotals['Done'] = (grandTotals['Done'] ?? 0) + (statusCounts['Done'] ?? 0);
      if (widget.userType != "Customer") {
        grandTotals['Closed'] = (grandTotals['Closed'] ?? 0) + (statusCounts['Closed'] ?? 0);
      }
    }

    // Calculate dynamic column width based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    int totalColumns = widget.userType != "Customer" ? 6 : 5; // 5/6 columns + Total column
    double baseColumnWidth = (screenWidth * 0.7) / totalColumns;
    double minColumnWidth = 80.0;
    double columnWidth = baseColumnWidth > minColumnWidth ? baseColumnWidth : minColumnWidth;

    return Container(


      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              //Icon(Icons.table_chart, color: AppColors.primaryColor, size: 20),
              // const SizedBox(width: 8),
              Text(
                "Departments Status",
                style: _headingTextStyle,
              ),
              // const SizedBox(width: 8),
              // // Show selected project info
              // if (selectedBranch != null && selectedBranch.isNotEmpty) ...[
              //   Icon(Icons.info, color: AppColors.warningColor, size: 16),
              //   const SizedBox(width: 4),
              //   Text(
              //     "Filtered by Project",
              //     style: TextStyle(
              //       fontSize: 12,
              //       color: AppColors.warningColor,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ],
            ],
          ),
          const SizedBox(height: 15),
          Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all(true),
                trackVisibility: WidgetStateProperty.all(true),
                thickness: WidgetStateProperty.all(6.0),
                radius: const Radius.circular(10),
                thumbColor: WidgetStateProperty.all(
                  AppColors.primaryColor.withOpacity(0.6),
                ),
                trackColor: WidgetStateProperty.all(
                  AppColors.primaryColor.withOpacity(0.15),
                ),
                trackBorderColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortAscending: true,
                  sortColumnIndex: 0,
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  headingRowHeight: 30.0,
                  dataRowHeight: 40.0,
                  showCheckboxColumn: false, // Hide the checkbox column
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    return AppColors.primaryColor.withOpacity(0.15);
                  }),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    return Colors.grey.shade50;
                  }),
                  columns: [
                    DataColumn(
                      label: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                            'Department',
                            style: _sectionTitleStyle
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        //color: AppColors.errorColor.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Icon(Icons.error_outline, color: AppColors.errorColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Open',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        //color: AppColors.warningColor.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Icon(Icons.hourglass_empty, color: AppColors.warningColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'In Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        //color: AppColors.successColor.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Icon(Icons.check_circle_outline, color: AppColors.successColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Done',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.userType != "Customer")
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          //color: AppColors.closeColor.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Icon(Icons.lock_outline, color: AppColors.closeColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Closed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.closeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // New Total column
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        //color: AppColors.primaryColor.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Icon(Icons.calculate, color: AppColors.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                  rows: [
                    // Data rows for each department
                    ...deptStatusMap.entries.map((entry) {
                      String deptName = entry.key;
                      Map<String, int> statusCounts = entry.value;

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>((states) {
                          return states.contains(WidgetState.selected)
                              ? AppColors.primaryColor.withOpacity(0.05)
                              : Colors.white;
                        }),
                        onSelectChanged: (_) {
                          _navigateToAdminDashboardWithFilters(deptName);
                        },
                        cells: [
                          DataCell(
                            Container(
                              width: columnWidth + 20,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text(
                                deptName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              color: (statusCounts['Open'] ?? 0) > 0
                                  ? AppColors.errorColor.withOpacity(0.05)
                                  : Colors.transparent,
                              child: Text(
                                '${statusCounts['Open'] ?? 0}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (statusCounts['Open'] ?? 0) > 0
                                      ? AppColors.errorColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              color: (statusCounts['In Progress'] ?? 0) > 0
                                  ? AppColors.warningColor.withOpacity(0.05)
                                  : Colors.transparent,
                              child: Text(
                                '${statusCounts['In Progress'] ?? 0}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (statusCounts['In Progress'] ?? 0) > 0
                                      ? AppColors.warningColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              color: (statusCounts['Done'] ?? 0) > 0
                                  ? AppColors.successColor.withOpacity(0.05)
                                  : Colors.transparent,
                              child: Text(
                                '${statusCounts['Done'] ?? 0}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: (statusCounts['Done'] ?? 0) > 0
                                      ? AppColors.successColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          if (widget.userType != "Customer")
                            DataCell(
                              Container(
                                width: columnWidth,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                color: (statusCounts['Closed'] ?? 0) > 0
                                    ? AppColors.closeColor.withOpacity(0.05)
                                    : Colors.transparent,
                                child: Text(
                                  '${statusCounts['Closed'] ?? 0}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (statusCounts['Closed'] ?? 0) > 0
                                        ? AppColors.closeColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          // Total column - sum of all statuses
                          DataCell(
                            Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              color: AppColors.primaryColor.withOpacity(0.05),
                              child: Text(
                                '${(statusCounts['Open'] ?? 0) + (statusCounts['In Progress'] ?? 0) + (statusCounts['Done'] ?? 0) + (widget.userType != "Customer" ? (statusCounts['Closed'] ?? 0) : 0)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),

                    // Summary row for all departments at the bottom
                    DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((states) {
                        return AppColors.primaryColor.withOpacity(0.2);
                      }),
                      onSelectChanged: (_) {}, // Empty handler for summary row
                      cells: [
                        DataCell(
                          Container(
                            width: columnWidth + 20,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              'All',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidth,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              '${grandTotals['Open'] ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.errorColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidth,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              '${grandTotals['In Progress'] ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warningColor,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: columnWidth,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text(
                              '${grandTotals['Done'] ?? 0}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.successColor,
                              ),
                            ),
                          ),
                        ),
                        if (widget.userType != "Customer")
                          DataCell(
                            Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: Text(
                                '${grandTotals['Closed'] ?? 0}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.closeColor,
                                ),
                              ),
                            ),
                          ),
                        // Grand Total column
                        DataCell(
                          Container(
                            width: columnWidth,
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            color: AppColors.primaryColor.withOpacity(0.1),
                            child: Text(
                              '${(grandTotals['Open'] ?? 0) + (grandTotals['In Progress'] ?? 0) + (grandTotals['Done'] ?? 0) + (widget.userType != "Customer" ? (grandTotals['Closed'] ?? 0) : 0)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStackedBarChart() {
    // ─── Data Preparation ───────────────────────────────────────────────
    Map<String, Map<String, int>> deptStatusData = {};

    String? selectedBranch = widget.ticketController.filterBranche.value;
    List<TicketModel> filteredTickets = widget.ticketController.tickets;

    if (selectedBranch != null && selectedBranch.isNotEmpty) {
      filteredTickets = filteredTickets
          .where((ticket) => ticket.brn_code == selectedBranch)
          .toList();
    }

    for (var ticket in filteredTickets) {
      String deptName = ticket.title;
      String status = ticket.status;
      deptStatusData.putIfAbsent(deptName, () => {});
      deptStatusData[deptName]![status] =
          (deptStatusData[deptName]![status] ?? 0) + 1;
    }

    List<String> statusTypes = ['Open', 'In Progress', 'Done'];
    if (widget.userType != "Customer") statusTypes.add('Closed');

    Map<String, Color> statusColors = {
      'Open': AppColors.errorColor,
      'In Progress': AppColors.warningColor,
      'Done': AppColors.successColor,
      'Closed': AppColors.closeColor,
    };

    List<String> departments = deptStatusData.keys.toList();

    return DepartmentBarChartBody(
      deptStatusData: deptStatusData,
      statusTypes: statusTypes,
      statusColors: statusColors,
      departments: departments,
      headingTextStyle: _headingTextStyle,
    );
  }

  void _navigateToAdminDashboardWithFilters(String departmentName) {
    // Find the department ID based on the department name
    Map<String, dynamic>? selectedDept;
    try {
      selectedDept = widget.ticketController.departments.firstWhere(
            (dept) => dept['DeptName']?.toString() == departmentName,
      );
    } catch (e) {
      selectedDept = null;
    }

    String? deptId;
    if (selectedDept != null) {
      deptId = selectedDept['DeptID']?.toString();
    }

    // Set the department filter before navigation if we found a matching department
    if (deptId != null && deptId.isNotEmpty) {
      widget.ticketController.filterDepartment.value = deptId;
      widget.selectedDepartmentName.value = departmentName;
    }

    // Navigate to admin dashboard regardless - if department filter wasn't set,
    // the admin dashboard will show all tickets for the user type
    Get.to(()=>AdminDashboard(
        ticketController: widget.ticketController,
        userType: widget.userType
    ));

  }
}