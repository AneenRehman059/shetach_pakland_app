
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/app_dialogs.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';


// update
class TicketListView extends StatefulWidget {
  const TicketListView({super.key});

  @override
  State<TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends State<TicketListView> {
  final TicketController controller = Get.put(TicketController());
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isInitialized = false;
  String _statusFilter = 'Open';
  String? get _userType => (controller.userType.value);
  String? _departmentArg;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPriority;
  String _selectedSort = 'Newest First';
  bool get _anyFilterActive =>
      _selectedPriority != null || _selectedSort != 'Newest First';

  TextStyle _headerStyle() => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade400,
    letterSpacing: 0.8,
  );

  Widget _sortRow({
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor)),
        if (selected) ...[
          const Spacer(),
          Icon(Icons.check_rounded, size: 14, color: AppColors.primaryColor),
        ],
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final arg = Get.arguments;
    _statusFilter =
    (arg is Map<String, dynamic>)
        ? (arg['status'] as String? ?? 'Open')
        : 'Open';
    _departmentArg =
    (arg is Map<String, dynamic>) ? arg['department'] as String? : null;

    final userId = await _storage.read(key: "user_id");

    controller.filterStatus(_statusFilter);
    if (_departmentArg != null && _departmentArg!.isNotEmpty) {
      controller.filterDepartment(_departmentArg!);
    } else {
      controller.clearDepartmentUsers();
    }

    if (_userType == "Client" && userId != null && userId.isNotEmpty) {
      controller.filterUserId(userId);
    }

    await controller.refreshAll(userType: _userType);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _refreshTickets() async {
    await controller.loadTickets();
    await controller.refreshAll(userType: _userType);
    _searchController.clear();
    controller.filterTitle.value = '';
  }

  List<TicketModel> _getFilteredTickets(
      List<TicketModel> list, String searchQuery) {
    var result = list.where((ticket) {
      final query = searchQuery.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          ticket.id.toLowerCase().contains(query) ||
          ticket.description.toLowerCase().trim().contains(query) ||
          (ticket.userName ?? '').toLowerCase().contains(query) ||
          (ticket.brn_code ?? '').toLowerCase().contains(query);

      final matchesPriority = _selectedPriority == null ||
          (ticket.ticketPriority ?? '').toLowerCase() ==
              _selectedPriority!.toLowerCase();

      return matchesSearch && matchesPriority;
    }).toList();

    if (_selectedSort == 'Newest First') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments;
    final String statusFilter =
    (arg is Map<String, dynamic>)
        ? (arg['status'] as String? ?? 'All')
        : 'All';

    return WillPopScope(
      onWillPop: () async {
        final controller = Get.find<TicketController>();
        controller.resetAllFilters();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: Text('$statusFilter Tickets', textAlign: TextAlign.center),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () {
              final controller = Get.find<TicketController>();
              controller.filterStatus.value = '';
              if (controller.userType.value == "Admin" ||
                  controller.userType.value == "Customer") {
                controller.resetAllFilters();
                Get.offNamed('/adminDashboard');
              } else {
                controller.resetAllFilters();
                Get.offNamed('/clintDashboard');
              }
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                tooltip: 'Filter & Sort',
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 52),
                onSelected: (_) {},
                itemBuilder: (_) => [

                  // ── Sort by Date ──
                  PopupMenuItem<String>(
                    enabled: false,
                    height: 28,
                    value: '__sh__',
                    child: Text('SORT BY DATE', style: _headerStyle()),
                  ),
                  PopupMenuItem<String>(
                    value: 's_new',
                    onTap: () => setState(() => _selectedSort = 'Newest First'),
                    height: 40,
                    child: _sortRow(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Newest First',
                      selected: _selectedSort == 'Newest First',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 's_old',
                    onTap: () => setState(() => _selectedSort = 'Oldest First'),
                    height: 40,
                    child: _sortRow(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Oldest First',
                      selected: _selectedSort == 'Oldest First',
                    ),
                  ),

                  const PopupMenuDivider(),

                  // ── Filter by Priority ──
                  PopupMenuItem<String>(
                    enabled: false,
                    height: 28,
                    value: '__ph__',
                    child: Text('FILTER BY PRIORITY', style: _headerStyle()),
                  ),

                  ...[null, 'Low', 'Medium', 'High'].map((priority) {
                    final label = priority ?? 'All';
                    final color = priority == null
                        ? AppColors.primaryColor
                        : AppColors.priorityColor(priority);
                    final isSelected = _selectedPriority == priority;
                    return PopupMenuItem<String>(
                      value: 'p_$label',
                      onTap: () => setState(() => _selectedPriority = priority),
                      height: 40,
                      child: Row(
                        children: [
                          Icon(
                            priority == null
                                ? Icons.all_inclusive
                                : Icons.receipt_long_outlined,
                            size: 15,
                            color: color,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            Icon(Icons.check_rounded, size: 14, color: color),
                          ],
                        ],
                      ),
                    );
                  }),
                ],

                // ── Icon with badge ──
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.sort,
                        color: _anyFilterActive
                            ? (_selectedPriority != null
                            ? AppColors.priorityColor(_selectedPriority!)
                            : Colors.yellowAccent)
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                    if (_anyFilterActive)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: controller.userType.value != "Admin" &&
            controller.userType.value != "Customer"
            ? FloatingActionButton(
          onPressed: () => Get.toNamed('/tickets/create'),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        )
            : null,

        body: !_isInitialized
            ? Center(
          child:
          SpinKitWave(color: AppColors.primaryColor, size: 24.0),
        )
            : Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: SpinKitWave(
                  color: AppColors.primaryColor, size: 24.0),
            );
          }

          final List<TicketModel> list = controller.applyFiltersLocally();
          final String currentStatus =
              controller.filterStatus.value ?? _statusFilter;
          final String searchQuery = controller.filterTitle.value;

          if (list.isEmpty) {
            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? 'No tickets found'
                          : 'No tickets found for "$searchQuery"',
                      style:
                      TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTickets,
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ((_userType == "Admin" ||
                      _userType == "Customer") &&
                      (currentStatus == "Open" ||
                          currentStatus == "In Progress" ||
                          currentStatus == "Assigned"))
                      ? AdminTicketList(
                    list: _getFilteredTickets(list, searchQuery),
                    statusFilter: currentStatus,
                    onRefresh: _refreshTickets,
                    storage: _storage,
                  )
                      : ClientTicketList(
                    list: _getFilteredTickets(
                      list
                          .where(
                              (t) => t.status == currentStatus)
                          .toList(),
                      searchQuery,
                    ),
                    statusFilter: currentStatus,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle:
            TextStyle(fontSize: 13, color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search,
                color: AppColors.primaryColor, size: 20),
            suffixIcon: controller.filterTitle.value.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                _searchController.clear();
                controller.filterTitle.value = '';
              },
            )
                : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            controller.filterTitle.value = value;
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔹 Admin Ticket List (With Swipe Actions)
// ─────────────────────────────────────────────────────────────────────────────

class AdminTicketList extends StatelessWidget {
  final List<TicketModel> list;
  final String statusFilter;
  final Future<void> Function() onRefresh;
  final FlutterSecureStorage storage;

  const AdminTicketList({
    super.key,
    required this.list,
    required this.statusFilter,
    required this.onRefresh,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    final TicketController controller = Get.find();

    return list.isEmpty
        ? const Center(child: Text('No tickets found'))
        : ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: list.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final t = list[index];
        final color =
        AppColors.priorityColor(t.ticketPriority ?? 'Medium');
        final userType = controller.userType.value;
        final bool canAssign = userType == "Admin";
        final isSOSTicket = t.title.toLowerCase().contains('sos');

        if (isSOSTicket && statusFilter.toLowerCase() == 'sos') {
          return _buildSOSTicketTile(context, t, color, controller);
        } else {
          return Dismissible(
            key: ValueKey('ticket-${t.id}'),
            direction: canAssign
                ? DismissDirection.horizontal
                : DismissDirection.endToStart,
            background: canAssign
                ? _buildSwipe(
              icon: Icons.assignment,
              color: AppColors.primaryColor,
              alignment: Alignment.centerLeft,
              label: 'Assign',
            )
                : const SizedBox.shrink(),
            secondaryBackground: _buildSwipe(
              icon: Icons.edit,
              color: Colors.deepOrange,
              alignment: Alignment.centerRight,
              label: 'Mark As',
            ),
            confirmDismiss: (direction) async {
              final userId = await storage.read(key: "user_id");
              if (userId == null || userId.isEmpty) {
                Get.snackbar('Error', 'User not authenticated.');
                return false;
              }
              if (direction == DismissDirection.endToStart) {
                await _handleStatusPriority(controller, t);
              } else {
                if (!canAssign) {
                  Get.snackbar(
                    'Permission Denied',
                    'Only admins can assign tickets.',
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  return false;
                }
                await _handleAssignment(t);
              }
              return false;
            },
            child: TicketTile(
              t: t,
              userType: controller.userType.value,
            ),
          );
        }
      },
    );
  }

  Widget _buildSOSTicketTile(
      BuildContext context,
      TicketModel t,
      Color color,
      TicketController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.emergency,
                        color: Colors.red, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#${t.id.toString().padLeft(5, '0')}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.statusColor(t.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                          AppColors.statusColor(t.status).withOpacity(0.5)),
                    ),
                    child: Text(
                      t.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusColor(t.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.description.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      t.userName ?? 'Unknown User',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                  Icon(Icons.access_time_rounded,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(t.createdAt),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (t.latitude != null && t.longitude != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url =
                          'https://maps.google.com/?q=${t.latitude},${t.longitude}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        Get.snackbar('Error', 'Could not open Google Maps',
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    },
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('GO TO LOCATION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = (dt.year % 100).toString().padLeft(2, '0');
    return '$day-$month$year $h:$m $ampm';
  }

  Future<void> _handleAssignment(TicketModel ticket) async {
    final controller = Get.find<TicketController>();
    try {
      await controller.fetchUsersDeptId(ticket.title.split("-").first);
      final result = await AppDialogs.showAssignmentDialog(
        departmentUsers: controller.deptUsers,
        isLoadingUsers: controller.isLoading.value,
      );
      if (result != null) {
        final success = await controller.assignTicket(
          brn_code: ticket.brn_code,
          ticketId: ticket.id,
          departmentId: ticket.title.split("-").first,
          assignedToUserId: result['userId']!,
          category: ticket.OprationID,
          dueDate: result['dueDate'] is DateTime
              ? result['dueDate'] as DateTime
              : null,
          remarks: result['remarks'],
        );
        if (success) {
          await onRefresh();
          Get.snackbar('✅ Success', 'Ticket assigned successfully',
              backgroundColor: AppColors.successColor,
              colorText: Colors.white);
        } else {
          Get.snackbar('❌ Error', 'Failed to assign ticket',
              backgroundColor: AppColors.errorColor,
              colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign ticket: ${e.toString()}',
          backgroundColor: AppColors.errorColor, colorText: Colors.white);
    }
  }

  Future<void> _handleStatusPriority(
      TicketController controller, TicketModel ticket) async {
    final result = await AppDialogs.pickStatusAndPriority(
      initialStatus: ticket.status,
      initialPriority: ticket.ticketPriority ?? 'Medium',
      isAdmin: true,
      userType: controller.userType.value,
    );
    if (result != null) {
      await controller.changeStatusAndPriority(
        ticket.id,
        result['status']!,
        result['priority']!,
        result['remarks'] ?? '',
      );
      await onRefresh();
    }
  }

  Widget _buildSwipe({
    required IconData icon,
    required Color color,
    required Alignment alignment,
    required String label,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (alignment == Alignment.centerRight)
            Text(label, style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          if (alignment == Alignment.centerLeft)
            Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔹 Client Ticket List (Plain ListView)
// ─────────────────────────────────────────────────────────────────────────────

class ClientTicketList extends StatelessWidget {
  final List<TicketModel> list;
  final String statusFilter;
  final TicketController controller = Get.find();

  ClientTicketList(
      {super.key, required this.list, required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return list.isEmpty
        ? const Center(child: Text('No tickets found'))
        : ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: list.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final t = list[index];
        return TicketTile(
          t: t,
          userType: controller.userType.value,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🔹 Shared Ticket Tile — Improved Card UI
// ─────────────────────────────────────────────────────────────────────────────

class TicketTile extends StatelessWidget {
  final TicketModel t;
  final String userType;
  final TicketController controller = Get.find();

  TicketTile({
    super.key,
    required this.t,
    required this.userType,
  });

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = (dt.year % 100).toString().padLeft(2, '0');
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '$day/$month/$year ${h.toString().padLeft(2, '0')}:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isSOSTicket = t.title.toLowerCase().contains('sos') ||
        t.description.toLowerCase().contains('emergency');
    final priorityColor = AppColors.priorityColor(t.ticketPriority ?? 'Medium');
    final statusColor = AppColors.statusColor(t.status);

    return InkWell(
      onTap: () =>
          Get.toNamed('/tickets/${t.id}', arguments: {'ticket': t}),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSOSTicket
                ? const BorderSide(color: Colors.red, width: 1)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Icon + ID + Status ──
                Row(
                  children: [
                    // Left accent bar / SOS icon
                    isSOSTicket
                        ? Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.emergency,
                          color: Colors.red, size: 14),
                    )
                        : Container(
                      width: 4,
                      height: 18,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      '#${t.id.toString().padLeft(5, '0')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSOSTicket
                            ? Colors.red
                            : AppColors.textSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                        Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        t.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Row 2: Description ──
                Text(
                  t.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 10),

                // ── Row 3: Priority chip + Date ──
                Row(
                  children: [
                    // Priority chip (receipt icon for normal, emergency for SOS)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isSOSTicket ? Colors.red : priorityColor)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (isSOSTicket ? Colors.red : priorityColor)
                                .withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSOSTicket
                                ? Icons.warning_amber_rounded
                                : Icons.receipt_long_outlined,
                            size: 11,
                            color: isSOSTicket ? Colors.red : priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSOSTicket
                                ? 'SOS'
                                : (t.ticketPriority ?? 'Medium'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                              isSOSTicket ? Colors.red : priorityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Date
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(t.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
                //
                // // ── Row 4: Username ──
                // if (t.userName != null && t.userName!.isNotEmpty) ...[
                //   const SizedBox(height: 8),
                //   Row(
                //     children: [
                //       Icon(Icons.person_outline,
                //           size: 13, color: Colors.grey.shade500),
                //       const SizedBox(width: 4),
                //       Text(
                //         t.userName!,
                //         style: TextStyle(
                //             fontSize: 12, color: Colors.grey.shade600),
                //       ),
                //     ],
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
