import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../colors.dart';
import '../../constants/api_constant.dart';
import '../../controllers/tickets_controller.dart';
import '../../customs/widgets/app_dialogs.dart';
import '../../function/screen_helper.dart';
import '../../models/ticket_models.dart';

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

  @override
  void initState() { super.initState(); _initializeData(); }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  Future<void> _initializeData() async {
    final arg = Get.arguments;
    _statusFilter = (arg is Map<String, dynamic>) ? (arg['status'] as String? ?? 'Open') : 'Open';
    _departmentArg = (arg is Map<String, dynamic>) ? arg['department'] as String? : null;
    final userId = await _storage.read(key: "user_id");
    controller.filterStatus(_statusFilter);
    if (_departmentArg != null && _departmentArg!.isNotEmpty) controller.filterDepartment(_departmentArg!);
    else controller.clearDepartmentUsers();
    if (_userType == "Client" && userId != null && userId.isNotEmpty) controller.filterUserId(userId);
    await controller.refreshAll(userType: _userType);
    if (mounted) setState(() => _isInitialized = true);
  }

  Future<void> _refreshTickets() async {
    await controller.loadTickets();
    await controller.refreshAll(userType: _userType);
    _searchController.clear();
    controller.filterTitle.value = '';
  }

  List<TicketModel> _getFilteredTickets(List<TicketModel> list, String searchQuery) {
    if (searchQuery.isEmpty) return list;
    final query = searchQuery.toLowerCase();
    return list.where((t) => t.id.toLowerCase().contains(query) || t.description.toLowerCase().trim().contains(query) || (t.userName ?? '').toLowerCase().contains(query) || (t.brn_code ?? '').toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final arg = Get.arguments;
    final String statusFilter = (arg is Map<String, dynamic>) ? (arg['status'] as String? ?? 'All') : 'All';

    return WillPopScope(
      onWillPop: () async { Get.find<TicketController>().resetAllFilters(); return true; },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: isTV ? 70 : kToolbarHeight,
          actions: [PopupMenuButton<TicketSortType>(offset: const Offset(0, 50), icon: Icon(Icons.sort, color: Colors.white, size: isTV ? 30 : 24), onSelected: controller.setSortType, itemBuilder: (_) => const [PopupMenuItem(value: TicketSortType.newest, child: Text('Newest First')), PopupMenuItem(value: TicketSortType.oldest, child: Text('Oldest First'))])],
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: Text('$statusFilter Tickets', textAlign: TextAlign.center, style: TextStyle(fontSize: isTV ? 22 : 16)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined, size: isTV ? 30 : 24),
            onPressed: () {
              controller.filterStatus.value = '';
              if (controller.userType.value == "Admin" || controller.userType.value == "Customer") { controller.resetAllFilters(); Get.offNamed('/adminDashboard'); }
              else { controller.resetAllFilters(); Get.offNamed('/clintDashboard'); }
            },
          ),
        ),
        floatingActionButton: controller.userType.value != "Admin" && controller.userType.value != "Customer"
            ? FloatingActionButton(onPressed: () => Get.toNamed('/tickets/create'), child: const Icon(Icons.add)) : null,
        body: !_isInitialized
            ? Center(child: SpinKitWave(color: AppColors.primaryColor, size: 24.0))
            : Obx(() {
          if (controller.isLoading.value) return Center(child: SpinKitWave(color: AppColors.primaryColor, size: 24.0));
          final list = controller.applyFiltersLocally();
          final currentStatus = controller.filterStatus.value ?? _statusFilter;
          final searchQuery = controller.filterTitle.value;
          if (list.isEmpty) {
            return Column(children: [_buildSearchField(isTV), Expanded(child: Center(child: Text(searchQuery.isEmpty ? 'No tickets found' : 'No tickets found for "$searchQuery"')))]);
          }
          return RefreshIndicator(
            onRefresh: _refreshTickets,
            child: Column(children: [
              _buildSearchField(isTV),
              Expanded(child: ((_userType == "Admin" || _userType == "Customer") && (currentStatus == "Open" || currentStatus == "In Progress" || currentStatus == "Assigned"))
                  ? AdminTicketList(list: _getFilteredTickets(list, searchQuery), statusFilter: currentStatus, onRefresh: _refreshTickets, storage: _storage, isTV: isTV)
                  : ClientTicketList(list: _getFilteredTickets(list.where((t) => t.status == currentStatus).toList(), searchQuery), statusFilter: currentStatus, isTV: isTV)),
            ]),
          );
        }),
      ),
    );
  }

  Widget _buildSearchField(bool isTV) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: isTV ? 48 : 36,
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: isTV ? 16 : 13),
          decoration: InputDecoration(
            isDense: true, labelText: 'Search', hintText: 'Search...',
            labelStyle: TextStyle(fontSize: isTV ? 16 : 13), hintStyle: TextStyle(fontSize: isTV ? 16 : 13),
            prefixIcon: Icon(Icons.search, size: isTV ? 24 : 18, color: AppColors.primaryColor),
            suffixIcon: controller.filterTitle.value.isNotEmpty ? IconButton(icon: Icon(Icons.clear, size: isTV ? 24 : 18), onPressed: () { _searchController.clear(); controller.filterTitle.value = ''; }) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5)),
          ),
          onChanged: (value) => controller.filterTitle.value = value,
        ),
      ),
    );
  }
}

class AdminTicketList extends StatelessWidget {
  final List<TicketModel> list;
  final String statusFilter;
  final Future<void> Function() onRefresh;
  final FlutterSecureStorage storage;
  final bool isTV;

  const AdminTicketList({super.key, required this.list, required this.statusFilter, required this.onRefresh, required this.storage, this.isTV = false});

  @override
  Widget build(BuildContext context) {
    final TicketController controller = Get.find();
    if (list.isEmpty) return const Center(child: Text('No tickets found'));

    // TV pe GridView, mobile pe ListView
    if (isTV) {
      return GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final t = list[index];
          final color = AppColors.priorityColor(t.ticketPriority ?? 'Medium');
          return Card(
            elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Get.toNamed('/tickets/${t.id}', arguments: {'ticket': t}),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(children: [
                  CircleAvatar(backgroundColor: color.withOpacity(0.15), child: t.title.contains('SOS') ? const Icon(Icons.emergency, color: Colors.red) : Icon(Icons.receipt_long_outlined, color: color)),
                  SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(t.id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text(t.description, style: TextStyle(fontSize: 12, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
                  Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.statusColor(t.status), borderRadius: BorderRadius.circular(8)), child: Text(t.status, style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
                ]),
              ),
            ),
          );
        },
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final t = list[index];
        final color = AppColors.priorityColor(t.ticketPriority ?? 'Medium');
        final isSOSTicket = t.title.toLowerCase().contains('sos');
        if (isSOSTicket && statusFilter.toLowerCase() == 'sos') return _buildSOSTicketTile(context, t, color, controller);
        return Dismissible(
          key: ValueKey('ticket-${t.id}'),
          direction: controller.userType.value == "Admin" ? DismissDirection.horizontal : DismissDirection.endToStart,
          background: controller.userType.value == "Admin" ? _buildSwipe(icon: Icons.assignment, color: AppColors.primaryColor, alignment: Alignment.centerLeft, label: 'Assign') : const SizedBox.shrink(),
          secondaryBackground: _buildSwipe(icon: Icons.edit, color: Colors.deepOrange, alignment: Alignment.centerRight, label: 'Mark As'),
          confirmDismiss: (direction) async {
            final userId = await storage.read(key: "user_id");
            if (userId == null || userId.isEmpty) { Get.snackbar('Error', 'User not authenticated.'); return false; }
            if (direction == DismissDirection.endToStart) await _handleStatusPriority(controller, t);
            else { if (controller.userType.value != "Admin") { Get.snackbar('Permission Denied', 'Only admins can assign tickets.', backgroundColor: Colors.redAccent, colorText: Colors.white); return false; } await _handleAssignment(t); }
            return false;
          },
          child: TicketTile(t: t, color: color, userType: controller.userType.value),
        );
      },
    );
  }

  Widget _buildSOSTicketTile(BuildContext context, TicketModel t, Color color, TicketController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.red, width: 1)),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.emergency, color: Colors.red, size: 15)),
          Expanded(child: Text(t.id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0), decoration: BoxDecoration(color: AppColors.statusColor(t.status), borderRadius: BorderRadius.circular(8)), child: Text(t.ticketPriority ?? 'Critical', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
        ]),
        const SizedBox(height: 8),
        Text(t.description.trim(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 4),
          Expanded(child: Text(t.userName ?? 'Unknown User', style: const TextStyle(fontSize: 12, color: Colors.grey))),
          const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4),
          Text(_formatTime(t.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        const SizedBox(height: 12),
        if (t.latitude != null && t.longitude != null)
          IconButton(onPressed: () async { final url = 'https://maps.google.com/?q=${t.latitude},${t.longitude}'; if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: const Size(0, 36)), icon: const Icon(Icons.map, color: Colors.white)),
      ])),
    );
  }

  String _formatTime(DateTime dt) { final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12; final m = dt.minute.toString().padLeft(2, '0'); final ampm = dt.hour >= 12 ? 'pm' : 'am'; return '${dt.day.toString().padLeft(2,'0')}-${dt.month.toString().padLeft(2,'0')}${(dt.year%100).toString().padLeft(2,'0')} $h:$m $ampm'; }

  Future<void> _handleAssignment(TicketModel ticket) async {
    final controller = Get.find<TicketController>();
    try {
      await controller.fetchUsersDeptId(ticket.title.split("-").first);
      final result = await AppDialogs.showAssignmentDialog(departmentUsers: controller.deptUsers, isLoadingUsers: controller.isLoading.value);
      if (result != null) {
        final success = await controller.assignTicket(brn_code: ticket.brn_code, ticketId: ticket.id, departmentId: ticket.title.split("-").first, assignedToUserId: result['userId']!, category: ticket.OprationID, dueDate: result['dueDate'] is DateTime ? result['dueDate'] as DateTime : null, remarks: result['remarks']);
        if (success) { await onRefresh(); Get.snackbar('✅ Success', 'Ticket assigned successfully', backgroundColor: AppColors.successColor, colorText: Colors.white); }
        else Get.snackbar('❌ Error', 'Failed to assign ticket', backgroundColor: AppColors.errorColor, colorText: Colors.white);
      }
    } catch (e) { Get.snackbar('Error', 'Failed to assign ticket: ${e.toString()}', backgroundColor: AppColors.errorColor, colorText: Colors.white); }
  }

  Future<void> _handleStatusPriority(TicketController controller, TicketModel ticket) async {
    final result = await AppDialogs.pickStatusAndPriority(initialStatus: ticket.status, initialPriority: ticket.ticketPriority ?? 'Medium', isAdmin: true, userType: controller.userType.value);
    if (result != null) { await controller.changeStatusAndPriority(ticket.id, result['status']!, controller.userType.value == "Admin" ? result['priority']! : result['priority']!, result['remarks'] ?? ''); await onRefresh(); }
  }

  Widget _buildSwipe({required IconData icon, required Color color, required Alignment alignment, required String label}) {
    return Container(color: color, alignment: alignment, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: alignment == Alignment.centerLeft ? MainAxisAlignment.start : MainAxisAlignment.end, children: [
      if (alignment == Alignment.centerRight) Text(label, style: const TextStyle(color: Colors.white)),
      const SizedBox(width: 8), Icon(icon, color: Colors.white), const SizedBox(width: 8),
      if (alignment == Alignment.centerLeft) Text(label, style: const TextStyle(color: Colors.white)),
    ]));
  }
}

class ClientTicketList extends StatelessWidget {
  final List<TicketModel> list;
  final String statusFilter;
  final bool isTV;
  final TicketController controller = Get.find();

  ClientTicketList({super.key, required this.list, required this.statusFilter, this.isTV = false});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const Center(child: Text('No tickets found'));
    if (isTV) {
      return GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final t = list[index];
          final color = AppColors.priorityColor(t.ticketPriority ?? 'Medium');
          return Card(
            elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Get.toNamed('/tickets/${t.id}', arguments: {'ticket': t}),
              child: Padding(padding: EdgeInsets.all(12), child: Row(children: [
                CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(Icons.receipt_long_outlined, color: color)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(t.id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text(t.description, style: TextStyle(fontSize: 12, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.statusColor(t.status), borderRadius: BorderRadius.circular(8)), child: Text(t.status, style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
              ])),
            ),
          );
        },
      );
    }
    return ListView.separated(itemCount: list.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (context, index) { final t = list[index]; final color = AppColors.priorityColor(t.ticketPriority ?? 'Medium'); return TicketTile(t: t, color: color, userType: controller.userType.value); });
  }
}

class TicketTile extends StatelessWidget {
  final TicketModel t;
  final Color color;
  final String userType;
  final TicketController controller = Get.find();
  TicketTile({super.key, required this.t, required this.color, required this.userType});

  String _formatTime(DateTime dt) { return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${(dt.year%100).toString().padLeft(2,'0')}'; }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: t.title.contains('SOS') ? const Icon(Icons.emergency, color: Colors.red) : Icon(Icons.receipt_long_outlined, color: color)),
      title: Row(children: [Expanded(child: Text(t.id))]),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.description, maxLines: 2, overflow: TextOverflow.ellipsis)]),
      trailing: Text(_formatTime(t.createdAt)),
      onTap: () => Get.toNamed('/tickets/${t.id}', arguments: {'ticket': t}),
    );
  }
}