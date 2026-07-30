import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pakland/features/sos/presentation/widgets/sos_buttton.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/charts/PieChartWidget.dart';
import 'package:pakland/core/widgets/widgets/app_bar.dart';
import 'package:pakland/core/widgets/widgets/app_dropdown.dart';
import 'package:pakland/core/widgets/widgets/app_toolTip.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/dashboard/presentation/screens/cms/admin_dashboard.dart';
import 'package:pakland/features/dashboard/presentation/screens/cms/cms_dashboard_screen.dart';
import 'package:pakland/features/dashboard/presentation/screens/cms/department_bar_chart_main_admin.dart';

class AdminMainDashboard extends StatefulWidget {
  final TicketController ticketController;
  final String userType;
  final String userId;
  final selectedBranchName = RxnString();
  final selectedDepartmentName = RxnString();

  AdminMainDashboard({Key? key, required this.ticketController, required this.userType, required this.userId}) : super(key: key);

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
    if (widget.userType == 'Customer') widget.ticketController.fetchDepartmentByUID(widget.userId);
    if (!widget.ticketController.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.ticketController.initializeController());
    }
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: "user_type") ?? '';
    if (mounted) setState(() => _userType = userType);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  TextStyle get _headingTextStyle => TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondaryColor);
  TextStyle get _sectionTitleStyle => const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87);

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    const TextStyle dropdownLables = TextStyle(fontWeight: FontWeight.bold);

    return WillPopScope(
      onWillPop: () async {
        final route = _userType.toLowerCase() == 'admin' ? '/main_screen' : '/clintDashboard';
        Get.offAllNamed(route);
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
          child: CustomAppBar(title: "Admin Dashboard", custom_RouteName: "/main_screen"),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(
            waterDropColor: AppColors.primaryColor,
            complete: Container(padding: const EdgeInsets.symmetric(vertical: 10), child: const Icon(Icons.done, color: Colors.green)),
            refresh: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor), strokeWidth: 2),
              const SizedBox(width: 10),
              const Text('Refreshing...', style: TextStyle(color: Colors.grey)),
            ]),
          ),
          onRefresh: () async {
            try { await widget.ticketController.refreshDashboardData(); _refreshController.refreshCompleted(); }
            catch (e) { _refreshController.refreshFailed(); }
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
                        // Hold Criteria
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
                          child: Row(children: [
                            Expanded(child: Row(spacing: 5.0, children: [
                              Icon(Icons.filter_alt, size: isTV ? 22 : 18, color: AppColors.primaryColor),
                              Text('Hold Criteria', style: dropdownLables),
                              AppTooltip(message: 'When checked, filters will be preserved during refresh'),
                            ])),
                            Obx(() => Checkbox(
                              value: widget.ticketController.isHoldfilterState.value,
                              activeColor: AppColors.primaryColor,
                              onChanged: (value) {
                                widget.ticketController.isHoldfilterState.value = value!;
                                Get.snackbar('Filter State', value ? '✅ Filters will be preserved' : '🔄 Filters will reset', snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2), backgroundColor: value ? Colors.green : Colors.orange, colorText: Colors.white, margin: EdgeInsets.all(8));
                              },
                            )),
                          ]),
                        ),

                        // Branch filter
                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Project', style: dropdownLables),
                            _buildBrancheFilter(),
                          ])),
                        ]),

                        // Pie chart
                        Container(
                          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.textPrimaryColor.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))], border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
                          padding: const EdgeInsets.all(8),
                          child: Obx(() => PieChartWidget(ticketCounts: _getTicketCountsMap(), ticketColors: {'Open': AppColors.errorColor, 'In Progress': AppColors.warningColor, 'Done': AppColors.successColor, 'Closed': AppColors.closeColor}, title: 'Tickets Distribution')),
                        ),

                        // Bar chart
                        Container(
                          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
                          padding: const EdgeInsets.all(16),
                          child: Obx(() => _buildHorizontalStackedBarChart()),
                        ),

                        // Department table — TV pe focusable cards, mobile pe DataTable
                        Obx(() => isTV
                            ? _buildTVDepartmentCards()
                            : _buildStatusByDepartmentTable()),
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

  Map<String, int> _getTicketCountsMap() {
    Map<String, int> counts = {};
    if (widget.ticketController.openTicketsCount.value > 0) counts['Open'] = widget.ticketController.openTicketsCount.value;
    if (widget.userType != "Customer" && widget.ticketController.inProgressTicketsCount.value > 0) counts['In Progress'] = widget.ticketController.inProgressTicketsCount.value;
    if (widget.ticketController.doneTicketsCount.value > 0) counts['Done'] = widget.ticketController.doneTicketsCount.value;
    if (widget.userType != "Customer" && widget.ticketController.closedTicketsCount.value > 0) counts['Closed'] = widget.ticketController.closedTicketsCount.value;
    return counts;
  }

  Widget _buildBrancheFilter() {
    return Obx(() => AppDropdown<String?>(
      hint: Text('Project', style: const TextStyle(fontWeight: FontWeight.bold)),
      value: widget.ticketController.filterBranche.value,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('All Projects', style: const TextStyle(fontWeight: FontWeight.bold))),
        ...widget.ticketController.branches.map((brns) => DropdownMenuItem<String?>(value: brns['brn_code']?.toString() ?? '', child: Text(brns['brn_name']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)))),
      ],
      onChanged: (value) async {
        if (value == null || value.isEmpty) { widget.ticketController.filterBranche.value = null; widget.selectedDepartmentName.value = null; }
        else { widget.ticketController.filterBranche.value = value; widget.selectedBranchName.value = value; widget.ticketController.selectBracnch(value); }
        widget.ticketController.applyFiltersLocally();
      },
    ));
  }

  // ─────────────────────────────────────────
  // TV — Focusable department cards
  // ─────────────────────────────────────────
  Widget _buildTVDepartmentCards() {
    var deptStatusMap = <String, Map<String, int>>{};
    String? selectedBranch = widget.ticketController.filterBranche.value;
    List<TicketModel> filteredTickets = widget.ticketController.tickets;
    if (selectedBranch != null && selectedBranch.isNotEmpty) {
      filteredTickets = filteredTickets.where((t) => t.brn_code == selectedBranch).toList();
    }
    for (var ticket in filteredTickets) {
      if (!deptStatusMap.containsKey(ticket.title)) deptStatusMap[ticket.title] = {};
      deptStatusMap[ticket.title]![ticket.status] = (deptStatusMap[ticket.title]![ticket.status] ?? 0) + 1;
    }

    if (deptStatusMap.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Departments Status", style: _headingTextStyle),
        const SizedBox(height: 16),
        // Header row
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(flex: 3, child: Text('Department', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
            Expanded(child: Text('Open', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorColor))),
            Expanded(child: Text('In Progress', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warningColor))),
            Expanded(child: Text('Done', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.successColor))),
            if (widget.userType != "Customer") Expanded(child: Text('Closed', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.closeColor))),
            Expanded(child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor))),
          ]),
        ),
        const SizedBox(height: 8),
        // Department rows — each focusable
        ...deptStatusMap.entries.map((entry) {
          final deptName = entry.key;
          final statusCounts = entry.value;
          final total = (statusCounts['Open'] ?? 0) + (statusCounts['In Progress'] ?? 0) + (statusCounts['Done'] ?? 0) + (widget.userType != "Customer" ? (statusCounts['Closed'] ?? 0) : 0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _TVDeptRow(
              deptName: deptName,
              statusCounts: statusCounts,
              total: total,
              showClosed: widget.userType != "Customer",
              onTap: () => _navigateToAdminDashboardWithFilters(deptName),
            ),
          );
        }).toList(),

        const Divider(),

        // Total row
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(flex: 3, child: Text('All', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 16))),
            Expanded(child: _statCell(_sumStat(deptStatusMap, 'Open'), AppColors.errorColor)),
            Expanded(child: _statCell(_sumStat(deptStatusMap, 'In Progress'), AppColors.warningColor)),
            Expanded(child: _statCell(_sumStat(deptStatusMap, 'Done'), AppColors.successColor)),
            if (widget.userType != "Customer") Expanded(child: _statCell(_sumStat(deptStatusMap, 'Closed'), AppColors.closeColor)),
            Expanded(child: _statCell(
              _sumStat(deptStatusMap, 'Open') + _sumStat(deptStatusMap, 'In Progress') + _sumStat(deptStatusMap, 'Done') + (widget.userType != "Customer" ? _sumStat(deptStatusMap, 'Closed') : 0),
              AppColors.primaryColor, fontSize: 18,
            )),
          ]),
        ),
      ]),
    );
  }

  int _sumStat(Map<String, Map<String, int>> map, String key) {
    return map.values.fold(0, (sum, counts) => sum + (counts[key] ?? 0));
  }

  Widget _statCell(int value, Color color, {double fontSize = 15}) {
    return Text('$value', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: value > 0 ? color : Colors.grey, fontSize: fontSize));
  }

  // ─────────────────────────────────────────
  // MOBILE — DataTable same as before
  // ─────────────────────────────────────────
  Widget _buildStatusByDepartmentTable() {
    var deptStatusMap = <String, Map<String, int>>{};
    String? selectedBranch = widget.ticketController.filterBranche.value;
    List<TicketModel> filteredTickets = widget.ticketController.tickets;
    if (selectedBranch != null && selectedBranch.isNotEmpty) {
      filteredTickets = filteredTickets.where((ticket) => ticket.brn_code == selectedBranch).toList();
    }
    for (var ticket in filteredTickets) {
      if (!deptStatusMap.containsKey(ticket.title)) deptStatusMap[ticket.title] = {};
      deptStatusMap[ticket.title]![ticket.status] = (deptStatusMap[ticket.title]![ticket.status] ?? 0) + 1;
    }
    Map<String, int> grandTotals = {'Open': 0, 'In Progress': 0, 'Done': 0, 'Closed': 0};
    for (var entry in deptStatusMap.entries) {
      grandTotals['Open'] = (grandTotals['Open'] ?? 0) + (entry.value['Open'] ?? 0);
      grandTotals['In Progress'] = (grandTotals['In Progress'] ?? 0) + (entry.value['In Progress'] ?? 0);
      grandTotals['Done'] = (grandTotals['Done'] ?? 0) + (entry.value['Done'] ?? 0);
      if (widget.userType != "Customer") grandTotals['Closed'] = (grandTotals['Closed'] ?? 0) + (entry.value['Closed'] ?? 0);
    }
    double screenWidth = MediaQuery.of(context).size.width;
    int totalColumns = widget.userType != "Customer" ? 6 : 5;
    double columnWidth = ((screenWidth * 0.7) / totalColumns).clamp(80.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)), boxShadow: [BoxShadow(color: AppColors.textPrimaryColor.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Departments Status", style: _headingTextStyle),
        const SizedBox(height: 15),
        Theme(
          data: Theme.of(context).copyWith(scrollbarTheme: ScrollbarThemeData(thumbVisibility: WidgetStateProperty.all(true), trackVisibility: WidgetStateProperty.all(true), thickness: WidgetStateProperty.all(6.0), radius: const Radius.circular(10), thumbColor: WidgetStateProperty.all(AppColors.primaryColor.withOpacity(0.6)), trackColor: WidgetStateProperty.all(AppColors.primaryColor.withOpacity(0.15)), trackBorderColor: WidgetStateProperty.all(Colors.transparent))),
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true, sortColumnIndex: 0, columnSpacing: 0, horizontalMargin: 0, headingRowHeight: 30.0, dataRowHeight: 40.0, showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.resolveWith<Color?>((states) => AppColors.primaryColor.withOpacity(0.15)),
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.grey.shade50),
                columns: [
                  DataColumn(label: Container(width: MediaQuery.of(context).size.width * 0.3, padding: const EdgeInsets.only(left: 8, right: 8), child: Text('Department', style: _sectionTitleStyle))),
                  DataColumn(label: Container(padding: const EdgeInsets.only(left: 8, right: 8), child: Text('Open', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorColor)))),
                  DataColumn(label: Container(padding: const EdgeInsets.only(left: 8, right: 8), child: Text('In Progress', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warningColor)))),
                  DataColumn(label: Container(padding: const EdgeInsets.only(left: 8, right: 8), child: Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.successColor)))),
                  if (widget.userType != "Customer") DataColumn(label: Container(padding: const EdgeInsets.only(left: 8, right: 8), child: Text('Closed', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.closeColor)))),
                  DataColumn(label: Container(padding: const EdgeInsets.only(left: 8, right: 8), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)))),
                ],
                rows: [
                  ...deptStatusMap.entries.map((entry) {
                    final deptName = entry.key;
                    final statusCounts = entry.value;
                    return DataRow(
                      color: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.selected) ? AppColors.primaryColor.withOpacity(0.05) : Colors.white),
                      onSelectChanged: (_) => _navigateToAdminDashboardWithFilters(deptName),
                      cells: [
                        DataCell(Container(width: columnWidth + 20, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), child: Text(deptName, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)))),
                        DataCell(Container(width: columnWidth, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), color: (statusCounts['Open'] ?? 0) > 0 ? AppColors.errorColor.withOpacity(0.05) : Colors.transparent, child: Text('${statusCounts['Open'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: (statusCounts['Open'] ?? 0) > 0 ? AppColors.errorColor : Colors.grey)))),
                        DataCell(Container(width: columnWidth, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), color: (statusCounts['In Progress'] ?? 0) > 0 ? AppColors.warningColor.withOpacity(0.05) : Colors.transparent, child: Text('${statusCounts['In Progress'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: (statusCounts['In Progress'] ?? 0) > 0 ? AppColors.warningColor : Colors.grey)))),
                        DataCell(Container(width: columnWidth, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), color: (statusCounts['Done'] ?? 0) > 0 ? AppColors.successColor.withOpacity(0.05) : Colors.transparent, child: Text('${statusCounts['Done'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: (statusCounts['Done'] ?? 0) > 0 ? AppColors.successColor : Colors.grey)))),
                        if (widget.userType != "Customer") DataCell(Container(width: columnWidth, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), color: (statusCounts['Closed'] ?? 0) > 0 ? AppColors.closeColor.withOpacity(0.05) : Colors.transparent, child: Text('${statusCounts['Closed'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: (statusCounts['Closed'] ?? 0) > 0 ? AppColors.closeColor : Colors.grey)))),
                        DataCell(Container(width: columnWidth, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), color: AppColors.primaryColor.withOpacity(0.05), child: Text('${(statusCounts['Open'] ?? 0) + (statusCounts['In Progress'] ?? 0) + (statusCounts['Done'] ?? 0) + (widget.userType != "Customer" ? (statusCounts['Closed'] ?? 0) : 0)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)))),
                      ],
                    );
                  }).toList(),
                  DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) => AppColors.primaryColor.withOpacity(0.2)),
                    onSelectChanged: (_) {},
                    cells: [
                      DataCell(Container(width: columnWidth + 20, padding: const EdgeInsets.only(left: 8, right: 8), child: Text('All', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)))),
                      DataCell(Container(width: columnWidth, padding: const EdgeInsets.only(left: 8, right: 8), child: Text('${grandTotals['Open'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorColor)))),
                      DataCell(Container(width: columnWidth, padding: const EdgeInsets.only(left: 8, right: 8), child: Text('${grandTotals['In Progress'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warningColor)))),
                      DataCell(Container(width: columnWidth, padding: const EdgeInsets.only(left: 8, right: 8), child: Text('${grandTotals['Done'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.successColor)))),
                      if (widget.userType != "Customer") DataCell(Container(width: columnWidth, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), child: Text('${grandTotals['Closed'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.closeColor)))),
                      DataCell(Container(width: columnWidth, padding: const EdgeInsets.only(left: 8, right: 8), color: AppColors.primaryColor.withOpacity(0.1), child: Text('${(grandTotals['Open'] ?? 0) + (grandTotals['In Progress'] ?? 0) + (grandTotals['Done'] ?? 0) + (widget.userType != "Customer" ? (grandTotals['Closed'] ?? 0) : 0)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontSize: 16)))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHorizontalStackedBarChart() {
    Map<String, Map<String, int>> deptStatusData = {};
    String? selectedBranch = widget.ticketController.filterBranche.value;
    List<TicketModel> filteredTickets = widget.ticketController.tickets;
    if (selectedBranch != null && selectedBranch.isNotEmpty) {
      filteredTickets = filteredTickets.where((ticket) => ticket.brn_code == selectedBranch).toList();
    }
    for (var ticket in filteredTickets) {
      deptStatusData.putIfAbsent(ticket.title, () => {});
      deptStatusData[ticket.title]![ticket.status] = (deptStatusData[ticket.title]![ticket.status] ?? 0) + 1;
    }
    List<String> statusTypes = ['Open', 'In Progress', 'Done'];
    if (widget.userType != "Customer") statusTypes.add('Closed');
    return DepartmentBarChartBody(deptStatusData: deptStatusData, statusTypes: statusTypes, statusColors: {'Open': AppColors.errorColor, 'In Progress': AppColors.warningColor, 'Done': AppColors.successColor, 'Closed': AppColors.closeColor}, departments: deptStatusData.keys.toList(), headingTextStyle: _headingTextStyle);
  }

  void _navigateToAdminDashboardWithFilters(String departmentName) {
    Map<String, dynamic>? selectedDept;
    try { selectedDept = widget.ticketController.departments.firstWhere((dept) => dept['DeptName']?.toString() == departmentName); } catch (e) { selectedDept = null; }
    String? deptId = selectedDept?['DeptID']?.toString();
    if (deptId != null && deptId.isNotEmpty) { widget.ticketController.filterDepartment.value = deptId; widget.selectedDepartmentName.value = departmentName; }
    Get.to(() => AdminDashboard(ticketController: widget.ticketController, userType: widget.userType));
  }
}

// ─────────────────────────────────────────
// TV Department Row — with VISIBLE focus
// ─────────────────────────────────────────
class _TVDeptRow extends StatefulWidget {
  final String deptName;
  final Map<String, int> statusCounts;
  final int total;
  final bool showClosed;
  final VoidCallback onTap;

  const _TVDeptRow({required this.deptName, required this.statusCounts, required this.total, required this.showClosed, required this.onTap});

  @override
  State<_TVDeptRow> createState() => _TVDeptRowState();
}

class _TVDeptRowState extends State<_TVDeptRow> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.primaryColor.withOpacity(0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isFocused ? AppColors.primaryColor : Colors.grey.shade200,
              width: _isFocused ? 2.5 : 1,
            ),
            boxShadow: _isFocused
                ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)]
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
          ),
          child: Row(children: [
            // Department name
            Expanded(flex: 3, child: Row(children: [
              if (_isFocused) Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryColor),
              if (_isFocused) const SizedBox(width: 6),
              Expanded(child: Text(widget.deptName, style: TextStyle(fontWeight: _isFocused ? FontWeight.bold : FontWeight.w500, color: _isFocused ? AppColors.primaryColor : Colors.black87, fontSize: 15))),
            ])),
            // Stats
            Expanded(child: _cell('${widget.statusCounts['Open'] ?? 0}', AppColors.errorColor)),
            Expanded(child: _cell('${widget.statusCounts['In Progress'] ?? 0}', AppColors.warningColor)),
            Expanded(child: _cell('${widget.statusCounts['Done'] ?? 0}', AppColors.successColor)),
            if (widget.showClosed) Expanded(child: _cell('${widget.statusCounts['Closed'] ?? 0}', AppColors.closeColor)),
            Expanded(child: _cell('${widget.total}', AppColors.primaryColor, bold: true, fontSize: 16)),
          ]),
        ),
      ),
    );
  }

  Widget _cell(String value, Color color, {bool bold = false, double fontSize = 15}) {
    return Text(value, textAlign: TextAlign.center, style: TextStyle(color: value == '0' ? Colors.grey : color, fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: fontSize));
  }
}