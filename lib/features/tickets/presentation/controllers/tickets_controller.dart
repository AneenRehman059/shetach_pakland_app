import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/tickets/data/repositories/ticket_repo.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/feedback/data/models/comments_model.dart';
import 'package:pakland/features/cms/data/models/timeline_model.dart';
import 'package:pakland/core/network/http_message_mapper.dart';

class TicketController extends GetxController {
  final TicketRepository _service = TicketRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final RxnString main_d_to_admin = RxnString();
  final RxnString list_to_admin = RxnString();


  final RxString userType = ''.obs;
  final RxString userId = ''.obs;
  final RxString userName = ''.obs;
  final RxString email = ''.obs;

  final RxBool canReceiveSOS = false.obs;

  final tickets = <TicketModel>[].obs;
  final filteredTickets = <TicketModel>[].obs;

  final isLoading = false.obs;
  final updating = false.obs;
  var creating = false.obs;

  var branches = <Map<String, dynamic>>[].obs;
  var branchesAll = <Map<String, dynamic>>[].obs;
  var departments = <Map<String, dynamic>>[].obs;
  var deptOprations = <Map<String, dynamic>>[].obs;
  var deptUsers = <Map<String, dynamic>>[].obs;
  var StaffUsers = <Map<String, dynamic>>[].obs;
  final departmentUsers = <Map<String, dynamic>>[].obs;
  final loadingDepartmentUsers = false.obs;

  var selectedBranch = "".obs;
  var selectedDepartments = "".obs;
  var selectedDepartmentsCode = "".obs;
  var selectedDeptOprations = "".obs;
  var selectedDeptOprationsCode = "".obs;

  var isHoldfilterState = false.obs;
  String? _savedStatus;
  String? _savedPriority;
  String? _savedBranch;
  String? _savedDepartment;
  String? _savedStaff;
  String _savedSearch = '';
  DateTime? _savedFromDate;
  DateTime? _savedToDate;


  final timeline = <TimeLineModel>[].obs;
  final timelineLoading = false.obs;
  final comments = <CommentsModel>[].obs;
  final commentsLoading = false.obs;
  final addingComment = false.obs;

  final openTicketsCount = 0.obs;
  final inProgressTicketsCount = 0.obs;
  final closedTicketsCount = 0.obs;
  final doneTicketsCount = 0.obs;
  final sosTicketsCount = 0.obs;
  final totleTicketsCount = 0.obs;
  final activeSOSCount = 0.obs;
  final activeSOSTickets = <TicketModel>[].obs;

  final assignedTickets = <TicketAssignment>[].obs;
  final myAssignedTickets = <TicketAssignment>[].obs;
  final assignmentsLoading = false.obs;
  final assigningTicket = false.obs;

  final RxnString filterStatus = RxnString();
  final RxnString filterPriority = RxnString();
  final Rxn<DateTimeRange> filterDateRange = Rxn<DateTimeRange>();
  final Rxn<DateTime> filterFromDate = Rxn<DateTime>();
  final Rxn<DateTime> filterToDate = Rxn<DateTime>();
  final RxString filterTitle = ''.obs;
  final RxnString filterUserId = RxnString();
  final RxnString filterDepartment = RxnString();
  final RxnString filterBranche = RxnString();
  final RxnString filterStaff= RxnString();
  final RxnString selectionDepartment = RxnString();

  final Rx<TicketSortType> sortType = TicketSortType.newest.obs;


  final uploadProgress = 0.obs;
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();

    everAll([
      filterStatus,
      filterPriority,
      filterDepartment,
      filterBranche,
      filterStaff,
      filterUserId,
      filterTitle,
      filterDateRange,
      filterFromDate,
      filterToDate,
    ], (_) => updateFilteredTickets());
  }

  int _getStatusCode(dynamic response, dynamic error) {
    try {
      if (response is Map<String, dynamic>) {
        final statusCode = response['StatusCode']?.toString();
        if (statusCode != null) {
          return int.tryParse(statusCode) ?? 500;
        }
      }

      if (error is String && error.contains('HttpException')) {
        final match = RegExp(r'(\d{3})').firstMatch(error);
        if (match != null) {
          return int.tryParse(match.group(1)!) ?? 500;
        }
      }

      return 500;
    } catch (e) {
      return 500;
    }
  }

  void _showSuccessMessage(String operation) {
    final message = HttpMessageMapper.getSuccessMessage(operation);
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _showErrorMessage(dynamic response, dynamic error, {String customMessage = ''}) {
    final statusCode = _getStatusCode(response, error);
    final message = customMessage.isNotEmpty ? customMessage : HttpMessageMapper.getMessage(statusCode);
    Get.snackbar(
      icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
      'Alert!',
      message,
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 4),
    );
  }

  void _showInfoMessage(String message) {
    Get.snackbar(
      icon: Icon(Icons.info, color: Colors.white),
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
  }

  void _showDynamicError(dynamic response, dynamic error, {String customMessage = ''}) {
    _showErrorMessage(response, error, customMessage: customMessage);
  }

  void setSortType(TicketSortType type) {
    sortType.value = type;
    updateFilteredTickets();
  }

  Future<void> _loadUserData() async {
    try {
      userName.value = await _storage.read(key: "user_name") ?? '';
      email.value = await _storage.read(key: "email_no1") ?? '';
      userId.value = await _storage.read(key: 'user_id') ?? '';
      userType.value = await _storage.read(key: 'user_type') ?? '';
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      await _loadUserData();
      if (userType.value == "Client") {
        fetchBranchesAll();
        await fetchDepartment();
      }else{
        await fetchBranches(userId.value);
        await fetchStaff();
        await fetchDepartmentByUID(userId.value);
      }

      await loadTickets();
    } catch (e) {
      print('Error fetching dashboard data: $e');
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBranchesAll() async {
    try {
      isLoading.value = true;
      final data = await _service.getBranchesALL(userId.value,"000000");
      print('branchhhhhhhhhhhhhhhhhhhhhhh $data');
      branchesAll.assignAll(data);
    } catch (e) {
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBranches(String userId) async {
    try {
      isLoading.value = true;

      final List<Map<String, dynamic>> data =
      await _service.getBranches(userId);

      final uniqueBranches = {
        for (var item in data) item['brn_code']: item
      }.values.toList();

      branches.assignAll(uniqueBranches);

    } catch (e) {
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDepartment() async {
    try {
      isLoading.value = true;
      final data = await _service.getDepartment();
      print('ddddddddddddddddddddddddddddd $data');
      departments.assignAll(data);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;

      final data = await _service.getStaffUsers();

      final Map<String, Map<String, dynamic>> uniqueStaffMap = {};

      for (final staff in data) {
        final id = staff['User_id']?.toString();
        final name = staff['user_name']?.toString();

        if (id != null && id.isNotEmpty && name != null && name.isNotEmpty) {
          uniqueStaffMap[id] = staff;
        }
      }

      StaffUsers.assignAll(uniqueStaffMap.values.toList());

      print('✅ Unique staff loaded: ${StaffUsers.length}');
    } catch (e) {
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDepartmentByUID(String userId) async {
    try {

      isLoading.value = true;
      final List<Map<String, dynamic>> data =
      await _service.getDepartmentByUID(userId);
      final uniqueBranches = {
        for (var item in data) item['DeptID']: item
      }.values.toList();
      departments.assignAll(uniqueBranches);
      print('✅ Loaded ${data.length} departments for $userId');
      _computeSOSPermission();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void _computeSOSPermission() {
    try {
      final isAdmin = userType.value == "Admin";
      final hasSOSDept = departments.any((d) {
        final id = (d['DeptID'] ?? d['DeptId'] ?? '').toString().toUpperCase();
        return id == 'SOS';
      });
      canReceiveSOS.value = isAdmin || hasSOSDept;
    } catch (_) {
      canReceiveSOS.value = userType.value == "Admin";
    }
  }

  Future<void> selectBracnch(String brnCode) async {
    try {
      selectedBranch.value = brnCode;
      final normalized = brnCode.trim();
      selectedBranch.value = normalized;

      if (selectedBranch.value.isNotEmpty) {
        await fetchdepartments(selectedBranch.value,userId.value);
      } else {
        departments.clear();
      }
    } catch (e) {
      print('Error selecting department: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to select department');
    }
  }
  Future<void> selectDepartment(String name) async {
    try {

      selectedDepartments.value = name;
      final normalized = name.trim();
      Map<String, dynamic> branch = departments.firstWhere(
            (b) {
          final opName = (b["OperationName"] ?? "").toString().trim();
          final deptName = (b["DeptName"] ?? "").toString().trim();
          final altName = (b["Operation"] ?? "").toString().trim();
          return opName == normalized || deptName == normalized || altName == normalized;
        },
        orElse: () => <String, dynamic>{},
      );

      final code = (branch["DeptID"] ?? branch["DeptId"] ?? branch["DeptCode"] ?? branch["Id"] ?? "").toString();
      selectedDepartmentsCode.value = normalized;

      if (selectedDepartmentsCode.value.isNotEmpty) {
        await fetchOpratons(selectedDepartmentsCode.value,selectedBranch.value);
      } else {
        departments.clear();
      }
    } catch (e) {
      print('Error selecting department: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to select department');
    }
  }
  Future<void> fetchdepartments(String brnCode,String userId) async {
    try {
      isLoading.value = true;
      final data = await _service.getDeparmentsbycode(brnCode,userId);
      departments.assignAll(data);
    } catch (e) {
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOpratons(String deptCode,String brnCode) async {
    try {
      isLoading.value = true;
      final data = await _service.getDeptOpration(deptCode,brnCode);
      deptOprations.assignAll(data);
    } catch (e) {
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsersDeptId(String deptCode) async {
    try {
      isLoading.value = true;

      final data = await _service.getUsersByDepartment(deptCode);

      final List<Map<String, dynamic>> users =
      List<Map<String, dynamic>>.from(data);

      final validUsers = users.where((u) =>
      (u['User_id'] != null && u['User_id'].toString().isNotEmpty) &&
          (u['user_name'] != null && u['user_name'].toString().isNotEmpty)
      );

      final uniqueUsersMap = <String, Map<String, dynamic>>{};

      for (var user in validUsers) {
        final userId = user['User_id'].toString();
        uniqueUsersMap[userId] = user;
      }

      final uniqueUsers = uniqueUsersMap.values.toList();

      deptUsers.assignAll(uniqueUsers);

      print('✅ Loaded ${deptUsers.length} unique users for dept $deptCode');

    } catch (e) {
      _showErrorMessage(null, e, customMessage: 'Failed to load department users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStaffUsers() async {
    try {
      isLoading.value = true;
      final data = await _service.getStaffUsers();
      StaffUsers.assignAll(data);
    } catch (e) {
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }

  }

  void resetAllFilters() {
    filterStatus.value = null;

    filterPriority.value = null;

    filterBranche.value = null;
    filterDepartment.value = null;

    filterStaff.value = null;

    filterUserId.value = null;

    filterTitle.value = '';

    filterDateRange.value = null;
    filterFromDate.value = null;
    filterToDate.value = null;

    updateFilteredTickets();
  }

  void holdStateFilters() {
    _savedStatus = filterStatus.value;
    _savedPriority = filterPriority.value;
    _savedBranch = filterBranche.value;
    _savedDepartment = filterDepartment.value;
    _savedStaff = filterStaff.value;
    _savedSearch = filterTitle.value;
    _savedFromDate = filterFromDate.value;
    _savedToDate = filterToDate.value;

    print('📦 Filters saved - Status: $_savedStatus, Branch: $_savedBranch');
  }

  void restoreHoldStateFilters() {
    filterStatus.value = _savedStatus;
    filterPriority.value = _savedPriority;
    filterBranche.value = _savedBranch;
    filterDepartment.value = _savedDepartment;
    filterStaff.value = _savedStaff;
    filterTitle.value = _savedSearch;
    filterFromDate.value = _savedFromDate;
    filterToDate.value = _savedToDate;

    print('🔄 Filters restored - Status: ${filterStatus.value}, Branch: ${filterBranche.value}');
  }

  void clearHoldState() {
    _savedStatus = null;
    _savedPriority = null;
    _savedBranch = null;
    _savedDepartment = null;
    _savedStaff = null;
    _savedSearch = '';
    _savedFromDate = null;
    _savedToDate = null;

    print('🧹 Hold state cleared');
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    try {
      final type = userType.value;
      final id = userId.value;

      List<TicketModel> allTickets;

      if (type == "Client" && id.isNotEmpty) {
        allTickets = await _service.getTicketsByUserId(id);
      } else if (type == "Customer") {
        allTickets = await _service.getMyAssignedTickets(id);
        allTickets= allTickets.where((t) => (t.status.toLowerCase().contains('done') || t.status.toLowerCase().contains('in progress'))).toList();
        print('✅ Loaded ${allTickets.length} tickets for user $id');
      } else {
        allTickets = await _service.getTicketsByAdminId(userId.value);
      }

      tickets.assignAll(allTickets);
      _updateStatusCounts();
      updateFilteredTickets();

    } catch (e) {
      print('Error loading tickets: $e');
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActiveSOSEmergencies() async {
    try {
      final sosTickets = await _service.getActiveSOSEmergencies();
      activeSOSTickets.assignAll(sosTickets);

      if (userType.value == "Customer" && departments.isNotEmpty) {
        final allowedDeptIds = departments.map((d) {
          final deptId = (d['DeptID'] ?? d['DeptId'] ?? '').toString().toUpperCase();
          return deptId;
        }).where((id) => id.isNotEmpty).toSet();

        final filteredSOSTickets = sosTickets.where((ticket) {
          final ticketDept = ticket.title.split('-').first.toString().toUpperCase();
          return allowedDeptIds.contains(ticketDept);
        }).toList();

        activeSOSCount.value = filteredSOSTickets.length;
      } else {
        activeSOSCount.value = sosTickets.length;
      }
    } catch (e) {
      print('Error loading active SOS emergencies: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to load SOS emergencies');
    }
  }

  void updateFilteredTickets() {
    filteredTickets.value = applyFiltersLocally();
    _updateStatusCounts();
  }

  void _updateStatusCounts() {
    Iterable<TicketModel> baseTickets = tickets;


    final s = filterStatus.value;
    if (s != null && s.isNotEmpty && s.toLowerCase() != 'all') {
      baseTickets = baseTickets.where((t) => (t.status ?? '').toLowerCase() == s.toLowerCase());
    }
    final p = filterPriority.value;
    if (p != null && p.isNotEmpty && p.toLowerCase() != 'all') {
      baseTickets = baseTickets.where((t) => (t.ticketPriority ?? '').toLowerCase() == p.toLowerCase());
    }

    final branch = filterBranche.value?? '';
    if (branch.isNotEmpty) {
      baseTickets = baseTickets.where((t) => t.brn_code.toLowerCase().contains(branch.toLowerCase()));
    }

    final staff = filterStaff.value?? '';
    if (staff.isNotEmpty) {
      baseTickets = baseTickets.where((t) => t.AssignedToUserId!.toLowerCase().contains(staff.toLowerCase()));
    }

    final dept = filterDepartment.value;
    if (dept != null && dept.isNotEmpty) {
      baseTickets = baseTickets.where((t) => t.title.toString() == dept.toString());
    }

    final title = filterTitle.value.trim();
    if (title.isNotEmpty) {
      baseTickets = baseTickets.where((t) => t.id.toLowerCase().contains(title.toLowerCase()));
    }

    final from = filterFromDate.value;
    final to = filterToDate.value;
    if (from != null) {
      baseTickets = baseTickets.where((t) => !t.createdAt.isBefore(from));
    }
    if (to != null) {
      baseTickets = baseTickets.where((t) => !t.createdAt.isAfter(to));
    }

    final filteredList = baseTickets.toList();

    openTicketsCount.value = filteredList.where((t) => t.status.toLowerCase() == 'open').length;
    inProgressTicketsCount.value = filteredList.where((t) => t.status.toLowerCase() == 'in progress').length;
    closedTicketsCount.value = filteredList.where((t) => t.status.toLowerCase() == 'closed').length;
    doneTicketsCount.value = filteredList.where((t) => t.status.toLowerCase() == 'done').length;
    sosTicketsCount.value = filteredList.where((t) => t.title.toLowerCase() == 'sos').length;
    totleTicketsCount.value = filteredList.length;
  }

  List<TicketModel> applyFiltersLocally() {
    Iterable<TicketModel> result = tickets;

    final s = filterStatus.value;
    if (s != null && s.isNotEmpty && s.toLowerCase() != 'all') {
      result = result.where(
            (t) => (t.status).toLowerCase().contains(s.toLowerCase()),
      );
    }

    final p = filterPriority.value;
    if (p != null && p.isNotEmpty && p.toLowerCase() != 'all') {
      result = result.where(
            (t) => (t.ticketPriority ?? '').toLowerCase() == p.toLowerCase(),
      );
    }

    final branch = filterBranche.value ?? '';
    if (branch.isNotEmpty) {
      result = result.where(
            (t) => t.brn_code.toLowerCase().contains(branch.toLowerCase()),
      );
    }

    final staff = filterStaff.value ?? '';
    print('tickets for user $staff');
    if (staff.isNotEmpty) {
      print('✅ Loaded ${result.length} tickets for user $staff');
      result = result.where(
            (t) => t.AssignedToUserId!.toLowerCase().contains(staff.toLowerCase()),
      );
      print('✅ Loaded ${result.length} tickets for user $staff');
    }

    final dept = filterDepartment.value;
    if (dept != null && dept.isNotEmpty) {
      result = result.where(
            (t) => t.title.toLowerCase().contains(dept.toLowerCase()),
      );
    }

    final title = filterTitle.value.trim().toLowerCase();
    if (title.isNotEmpty) {
      result = result.where((t) {
        return t.id.toLowerCase().contains(title) ||
            t.description.toLowerCase().contains(title) ||
            (t.userName ?? '').toLowerCase().contains(title) ||
            t.brn_code.toLowerCase().contains(title);
      });
    }

    final from = filterFromDate.value;
    final to = filterToDate.value;
    if (from != null) {
      result = result.where((t) => !t.createdAt.isBefore(from));
    }
    if (to != null) {
      result = result.where((t) => !t.createdAt.isAfter(to));
    }

    final List<TicketModel> sorted = result.toList();

    switch (sortType.value) {
      case TicketSortType.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TicketSortType.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return sorted;
  }


  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      radius: 10,
      onConfirm: () => Get.back(),
    );
  }

  Future<void> refreshStatusCounts({String? userType}) async {
    try {
      final currentUserType = userType ?? await _storage.read(key: "user_type");
      final userId = await _storage.read(key: "user_id");

      List<TicketModel> allTickets = [];

      if (currentUserType == "Client" && userId != null) {
        allTickets = await _service.getTicketsByUserId(userId);
      }
      else if
      (currentUserType == "Customer" || currentUserType == "Admin") {
        allTickets = await _service.getTicketsByAdminId(userId!);
      }

      if (currentUserType == "Admin" || currentUserType == "Customer") {
        final selectedBranche = filterBranche.value;
        if (selectedBranche != null && selectedBranche.isNotEmpty) {
          final d = selectedBranche.toLowerCase();
          allTickets = allTickets
              .where((t) => (t.brn_code ?? '').toLowerCase().contains(d))
              .toList();
        }
      }

      if (currentUserType == "Admin" || currentUserType == "Customer") {
        final selectedDepartment = filterDepartment.value;
        if (selectedDepartment != null && selectedDepartment.isNotEmpty) {
          final d = selectedDepartment.toLowerCase();
          allTickets = allTickets
              .where((t) => (t.title ?? '').toLowerCase().contains(d))
              .toList();
        }
      }

      final openTickets = allTickets.where((t) => t.status.toLowerCase() == 'open').toList();
      final inProgressTickets = allTickets.where((t) => t.status.toLowerCase() == 'in progress').toList();
      final closedTickets = allTickets.where((t) => t.status.toLowerCase() == 'closed').toList();
      final doneTickets = allTickets.where((t) => t.status.toLowerCase() == 'done').toList();
      final sosTickets = allTickets.where((t) => t.title.toLowerCase().contains('sos')).toList();

      openTicketsCount.value = openTickets.length;
      inProgressTicketsCount.value = inProgressTickets.length;
      closedTicketsCount.value = closedTickets.length;
      doneTicketsCount.value = doneTickets.length;
      totleTicketsCount.value = allTickets.length;

    } catch (e) {
      print('Error refreshing status counts: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to refresh status counts');
    }
  }

  Future<void> refreshAll({String? userType}) async {
    await loadTickets();
    await refreshStatusCounts(userType: userType);
  }

  Future<bool> checkBackendHealth() async {
    return await _service.checkBackendHealth();
  }

  Future<bool> changeStatusAndPriority(
      String ticketId,
      String status,
      String priority,
      String remarks,
      ) async {
    updating.value = true;
    try {
      final userId = await _storage.read(key: 'user_id');

      if (userId == null) {
        _showErrorMessage(null, null, customMessage: 'User not logged in');
        return false;
      }

      final ok = await _service.updateStatusAndPriority(
        ticketId: ticketId,
        userId: userId,
        status: status,
        priority: priority,
        remarks: remarks,
      );

      if (ok) {
        final idx = tickets.indexWhere((t) => t.id == ticketId);
        if (idx != -1) {
          final oldTicket = tickets[idx];
          tickets[idx] = TicketModel(
            id: oldTicket.id,
            brn_code: oldTicket.brn_code,
            title: oldTicket.title,
            OprationID: oldTicket.OprationID,
            description: oldTicket.description,
            status: status,
            ticketPriority: priority,
            createdAt: oldTicket.createdAt,
            updatedAt: DateTime.now(),
            dueDate: oldTicket.dueDate,
            attachmentPath: oldTicket.attachmentPath,
            userId: oldTicket.userId,
            latitude: oldTicket.latitude,
            longitude: oldTicket.longitude,
            userName: oldTicket.userName,
          );
        }

        _updateStatusCounts();
        await refreshStatusCounts();

        _showSuccessMessage('change_status');
        return true;
      } else {
        _showErrorMessage(null, null, customMessage: 'Failed to update ticket');
        return false;
      }
    } catch (e) {
      print('Error updating ticket: $e');
      _showErrorMessage(null, e);
      return false;
    } finally {
      updating.value = false;
    }
  }

  Future<void> initializeController({String? overrideUserType}) async {
    try {
      print('🔄 Initializing TicketController...');
      isLoading.value = true;

      await _loadUserData();

      final effectiveUserType = overrideUserType ?? userType.value;

      if (effectiveUserType.isEmpty) {
        print('⚠️ User type not found, cannot initialize controller');
        return;
      }

      print('👤 User Type: $effectiveUserType, User ID: ${userId.value}');

      if (effectiveUserType == "Client") {
        print('📦 Loading data for Client user...');
        await fetchBranchesAll();
        await fetchDepartment();
      } else {
        print('🏢 Loading data for ${effectiveUserType} user...');
        await fetchBranches(userId.value);
        await fetchStaff();
        await fetchDepartmentByUID(userId.value);
      }

      print('🎫 Loading tickets...');
      await loadTickets();

      print('📊 Updating status counts...');
      await refreshStatusCounts();

      print('✅ TicketController initialization completed successfully');
    } catch (e) {
      print('❌ Error initializing TicketController: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to initialize dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> quickInitialize() async {
    try {
      print('⚡ Quick initializing TicketController...');

      if (userType.value.isEmpty) {
        await _loadUserData();
      }

      if (tickets.isEmpty) {
        await loadTickets();
      }

      print('✅ Quick initialization completed');
    } catch (e) {
      print('❌ Error in quick initialization: $e');
    }
  }

  bool get isInitialized {
    return userType.value.isNotEmpty &&
        userId.value.isNotEmpty &&
        tickets.isNotEmpty;
  }

  Future<void> reinitialize() async {
    print('🔄 Reinitializing controller...');
    resetAllFilters();
    await initializeController();
  }
  Future<void> loadDashboardDataForUserType(String userType) async {
    try {
      isLoading.value = true;
      await _loadUserData();

      if (userType == "Client") {
        await fetchBranchesAll();
        await fetchDepartment();
      } else {
        await fetchBranches(userId.value);
        await fetchStaff();
        await fetchDepartmentByUID(userId.value);
      }

      await loadTickets();
    } catch (e) {
      print('Error loading dashboard data: $e');
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboardData() async {
    try {
      isLoading.value = true;

      if (isHoldfilterState.value) {
        holdStateFilters();
        print('📦 Filters saved before refresh');
      }

      await loadDashboardDataForUserType(userType.value);

      if (isHoldfilterState.value) {
        restoreHoldStateFilters();
        print('🔄 Filters restored after refresh');
      } else {
        resetAllFilters();
        print('🧹 All filters reset after refresh');
      }

      updateFilteredTickets();

      print('✅ Dashboard refreshed successfully');
    } catch (e) {
      print('❌ Error refreshing dashboard: $e');
      _showErrorMessage(null, e);
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter(String filterType, dynamic value) {
    switch (filterType) {
      case 'status':
        filterStatus.value = value as String?;
        break;
      case 'priority':
        filterPriority.value = value as String?;
        break;
      case 'branch':
        filterBranche.value = value as String?;
        if (value != null) {
          selectBracnch(value as String);
        }
        break;
      case 'department':
        filterDepartment.value = value as String?;
        break;
      case 'staff':
        filterStaff.value = value as String?;
        break;
      case 'fromDate':
        filterFromDate.value = value as DateTime?;
        break;
      case 'toDate':
        filterToDate.value = value as DateTime?;
        break;
      case 'search':
        filterTitle.value = value as String? ?? '';
        break;
    }

    updateFilteredTickets();
  }

  void clearAllFilters() {
    filterStatus.value = null;
    filterPriority.value = null;
    filterBranche.value = null;
    filterDepartment.value = null;
    filterStaff.value = null;
    filterFromDate.value = null;
    filterToDate.value = null;
    filterTitle.value = '';

    updateFilteredTickets();
  }

  void navigateToTicketList(String status) {
    Get.toNamed('/tickets', arguments: {'status': status});
  }

  void navigateToTicketDetail(TicketModel ticket) {
    Get.toNamed('/tickets/${ticket.id}', arguments: {'ticket': ticket});
  }

  void navigateToCreateTicket() {
    Get.toNamed('/tickets/create');
  }

  bool get canCreateTicket {
    final type = userType.value;
    return type != "Admin" && type != "Customer";
  }

  bool get isAdminOrCustomer {
    final type = userType.value;
    return type == "Admin" || type == "Customer";
  }

  bool get isClient {
    return userType.value == "Client";
  }

  String get dashboardTitle {
    switch (userType.value) {
      case 'Admin':
        return 'Admin Dashboard';
      case 'Customer':
        return 'Staff Dashboard';
      case 'Client':
        return 'User Dashboard';
      default:
        return 'Dashboard';
    }
  }
  void onRefresh() async {
    try {
      RefreshController _refreshController=RefreshController(initialRefresh: false);

      final currentSearchTerm = filterTitle.value;

      await fetchDashboardData();
      resetAllFilters();
      clearAllFilters();

      if (currentSearchTerm.isNotEmpty) {
        filterTitle.value = currentSearchTerm;
        applyFiltersLocally();
      }

      print('🔄 CMS Dashboard: Data refreshed successfully');
      _refreshController.refreshCompleted();
    } catch (e) {
      print('❌ CMS Dashboard: Error refreshing data - $e');
    }
  }

  Future<dynamic> createTicket(CreateTicketRequest request) async {
    creating.value = true;
    dynamic apiResponse;

    try {
      apiResponse = await _service.createTicket(request);

      if (apiResponse is Map<String, dynamic>) {
        final statusCode = apiResponse['StatusCode']?.toString();
        final message = apiResponse['Message']?.toString() ?? 'Unknown error';

        if (statusCode == "200") {
          if (apiResponse['obj'] != null) {
            try {
              final ticketData = apiResponse['obj'];
              if (ticketData is Map<String, dynamic>) {
              }
            } catch (e) {
              print('⚠️ Could not parse ticket from response: $e');
            }
          }
          _updateStatusCounts();
          await refreshStatusCounts();
          return apiResponse;
        } else {
          _showErrorMessage(apiResponse, null);
          return apiResponse;
        }
      } else {
        _showErrorMessage(apiResponse, null);
        return {
          "StatusCode": "500",
          "Message": "Invalid response format from server",
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error creating ticket: $e');
      print('Stack trace: $stackTrace');
      _showErrorMessage(apiResponse, e);
      return {
        "StatusCode": "500",
        "Message": "Exception occurred: ${e.toString()}",
        "obj": null,
      };
    } finally {
      creating.value = false;
    }
  }

  Future<dynamic> createTicketWithAttachments(
      CreateTicketRequest request,
      List<File> attachments, {
        void Function(int sent, int total)? onUploadProgress,
        void Function(int fileIndex, int sent, int total)? onFileProgress,
      }) async {
    creating.value = true;
    isUploading.value = true;
    uploadProgress.value = 0;
    dynamic apiResponse;

    try {
      apiResponse = await _service.createTicketWithAttachments(
        request,
        attachments,
        onUploadProgress: (sent, total) {
          uploadProgress.value = (sent / total * 100).round();
          onUploadProgress?.call(sent, total);
        },
      );

      if (apiResponse is Map<String, dynamic>) {
        final statusCode = apiResponse['StatusCode']?.toString();
        final message = apiResponse['Message']?.toString() ?? 'Unknown error';

        if (statusCode == "200") {
          if (apiResponse['obj'] != null) {
            try {
              final ticketData = apiResponse['obj'];
              if (ticketData is Map<String, dynamic>) {
              }
            } catch (e) {
              print('⚠️ Could not parse ticket from response: $e');
            }
          }
          _updateStatusCounts();
          await refreshStatusCounts();
          return apiResponse;
        } else {
          _showErrorMessage(apiResponse, null);
          return apiResponse;
        }
      } else {
        _showErrorMessage(apiResponse, null);
        return {
          "StatusCode": "500",
          "Message": "Invalid response format from server",
          "obj": null,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Error creating ticket with attachments: $e');
      print('Stack trace: $stackTrace');
      _showErrorMessage(apiResponse, e);
      return {
        "StatusCode": "500",
        "Message": "Exception occurred: ${e.toString()}",
        "obj": null,
      };
    } finally {
      creating.value = false;
      isUploading.value = false;
      uploadProgress.value = 0;
    }
  }

  Future<bool> addAttachmentsToTicket({
    required String ticketId,
    required List<File> attachments,
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    isUploading.value = true;
    uploadProgress.value = 0;

    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        _showErrorMessage(null, null, customMessage: 'User not logged in');
        return false;
      }

      final success = await _service.addTicketAttachments(
        ticketId: ticketId,
        userId: userId,
        attachments: attachments,
        onProgress: (sent, total) {
          uploadProgress.value = (sent / total * 100).round();
          onUploadProgress?.call(sent, total);
        },
      );

      if (success) {
        final updatedTicket = await _service.getTicket(ticketId);
        if (updatedTicket != null) {
          final index = tickets.indexWhere((t) => t.id == ticketId);
          if (index != -1) {
            tickets[index] = updatedTicket;
          }
        }

        _showSuccessMessage('add_attachment');
        return true;
      } else {
        _showErrorMessage(null, null, customMessage: 'Failed to add attachments');
        return false;
      }
    } catch (e) {
      print('Error adding attachments: $e');
      _showErrorMessage(null, e);
      return false;
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0;
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        _showErrorMessage(null, null, customMessage: 'User not logged in');
        return false;
      }

      final success = await _service.deleteTicket(ticketId, userId);
      if (success) {
        tickets.removeWhere((t) => t.id == ticketId);
        _updateStatusCounts();
        await refreshStatusCounts();
        _showSuccessMessage('delete_ticket');
        return true;
      } else {
        _showErrorMessage(null, null, customMessage: 'Failed to delete ticket');
        return false;
      }
    } catch (e) {
      print('Error deleting ticket: $e');
      _showErrorMessage(null, e);
      return false;
    }
  }

  Future<void> loadTicketTimeline(String ticketId) async {
    timelineLoading.value = true;
    try {
      final timelineData = await _service.getTicketTimeline(ticketId);
      timeline.assignAll(timelineData);
    } catch (e) {
      print('Error loading ticket timeline: $e');
      timeline.clear();
      _showErrorMessage(null, e);
    } finally {
      timelineLoading.value = false;
    }
  }

  Future<void> loadModuleTimeline(String module, String moduleItemId) async {
    timelineLoading.value = true;
    try {
      final List<TimeLineModel> combined = [];

      final primaryTimeline =
      await _service.getModuleTimeline(module, moduleItemId);
      combined.addAll(primaryTimeline);

      if (module == 'Ticket') {
        final sosTimeline =
        await _service.getModuleTimeline('SOS', moduleItemId);
        combined.addAll(sosTimeline);
      }

      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      timeline.assignAll(combined);
    } catch (e) {
      print('Error loading module timeline: $e');
      timeline.clear();
      _showErrorMessage(null, e);
    } finally {
      timelineLoading.value = false;
    }
  }

  void clearTimeline() {
    timeline.clear();
  }

  Future<void> loadComments(String ticketId) async {
    commentsLoading.value = true;
    try {
      final commentsData = await _service.getComments(ticketId);
      comments.assignAll(commentsData);
    } catch (e) {
      print('Error loading comments: $e');
      comments.clear();
      _showErrorMessage(null, e);
    } finally {
      commentsLoading.value = false;
    }
  }

  Future<bool> addComment({
    required String ticketId,
    required String text,
    String commentType = 'Text',
  }) async {
    addingComment.value = true;
    try {
      final success = await _service.addCommentText(
        ticketId: ticketId,
        text: text,
      );

      if (success) {
        await loadComments(ticketId);
        return true;
      } else {
        _showErrorMessage(null, null, customMessage: 'Failed to add comment');
        return false;
      }
    } catch (e) {
      print('Error adding comment: $e');
      _showErrorMessage(null, e);
      return false;
    } finally {
      addingComment.value = false;
    }
  }

  Future<bool> addCommentWithFile({
    required String ticketId,
    required File file,
    required String commentType,
    required int commentId,
    required String purposeName,
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    addingComment.value = true;
    isUploading.value = true;
    uploadProgress.value = 0;

    try {
      final success = await _service.addCommentFile(
        ticketId: ticketId,
        file: file,
        commentType: commentType,
        commentId: commentId,
        purposeName: purposeName,
        onProgress: (sent, total) {
          uploadProgress.value = (sent / total * 100).round();
          onUploadProgress?.call(sent, total);
        },
      );

      if (success) {
        await loadComments(ticketId);
        return true;
      } else {
        _showErrorMessage(null, null, customMessage: 'Failed to add comment with file');
        return false;
      }
    } catch (e) {
      print('Error adding comment with file: $e');
      _showErrorMessage(null, e);
      return false;
    } finally {
      addingComment.value = false;
      isUploading.value = false;
      uploadProgress.value = 0;
    }
  }

  void clearComments() {
    comments.clear();
  }

  Future<bool> submitFeedbackAndCloseTicket({
    required String ticketId,
    required int rating,
    required String comment,
    required String priority,
  }) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        _showErrorMessage(null, null, customMessage: 'User not logged in');
        return false;
      }

      final feedbackSuccess = await _service.submitTicketFeedback(
        ticketId: ticketId,
        userId: userId,
        rating: rating,
        comment: comment,
      );

      if (!feedbackSuccess) {
        _showErrorMessage(null, null, customMessage: 'Failed to submit feedback');
        return false;
      }

      final closeSuccess = await changeStatusAndPriority(
        ticketId,
        'Closed',
        priority,
        comment,
      );

      if (closeSuccess) {
        await loadTickets();
        await refreshStatusCounts();
        _showSuccessMessage('submit_feedback');
        return true;
      } else {
        _showInfoMessage('Feedback submitted but failed to close ticket');
        return false;
      }
    } catch (e) {
      print('Error submitting feedback and closing ticket: $e');
      _showErrorMessage(null, e);
      return false;
    }
  }

  Future<void> loadDepartmentUsers(String departmentId) async {
    loadingDepartmentUsers.value = true;
    try {
      final users = await _service.getUsersByDepartment(departmentId);
      departmentUsers.assignAll(users);
      print('👥 Loaded ${users.length} users for department $departmentId');
    } catch (e) {
      print('Error loading department users: $e');
      departmentUsers.clear();
      _showErrorMessage(null, e);
    } finally {
      loadingDepartmentUsers.value = false;
    }
  }

  Future<bool> assignTicket({
    required String brn_code,
    required String ticketId,
    required String departmentId,
    required String assignedToUserId,
    String? category,
    DateTime? dueDate,
    String? remarks,
  }) async {
    assigningTicket.value = true;
    dynamic apiResponse;

    try {
      final assignedByUserId = await _storage.read(key: 'user_id');
      if (assignedByUserId == null) {
        _showErrorMessage(null, null, customMessage: 'User not logged in');
        return false;
      }

      final request = AssignTicketRequest(
        brn_code: brn_code,
        ticketId: ticketId,
        departmentId: departmentId,
        category: category,
        assignedToUserId: assignedToUserId,
        assignedByUserId: assignedByUserId,
        dueDate: dueDate,
        remarks: remarks,
      );

      apiResponse = await _service.assignTicket(request);

      if (apiResponse != null) {
        final ticketIndex = tickets.indexWhere((t) => t.id == ticketId);
        if (ticketIndex != -1) {
          final oldTicket = tickets[ticketIndex];
          tickets[ticketIndex] = TicketModel(
            id: oldTicket.id,
            brn_code: oldTicket.brn_code,
            title: oldTicket.title,
            OprationID: oldTicket.OprationID,
            description: oldTicket.description,
            status: 'In Progress',
            ticketPriority: oldTicket.ticketPriority,
            createdAt: oldTicket.createdAt,
            updatedAt: DateTime.now(),
            dueDate: oldTicket.dueDate,
            attachmentPath: oldTicket.attachmentPath,
            userId: oldTicket.userId,
            latitude: oldTicket.latitude,
            longitude: oldTicket.longitude,
            userName: oldTicket.userName,
          );
        }

        _updateStatusCounts();
        await refreshStatusCounts();

        return true;
      } else {
        _showErrorMessage(apiResponse, null);
        return false;
      }
    } catch (e) {
      print('Error assigning ticket: $e');
      _showErrorMessage(apiResponse, e);
      return false;
    } finally {
      assigningTicket.value = false;
    }
  }

  void clearDepartmentUsers() {
    departmentUsers.clear();
  }

  String getUserDisplayName(String userId) {
    try {
      final user = departmentUsers.firstWhereOrNull((user) =>
      (user['User_id']?.toString() ?? '') == userId
      );
      return user?['user_name']?.toString() ?? 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }

  Future<void> openGoogleMapsLocation({
    required double latitude,
    required double longitude,
  }) async {
    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        mapUri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched) {
        _showInfoMessage('Could not launch Google Maps');
      }
    } catch (e) {
      _showErrorMessage(null, e, customMessage: 'Failed to open location');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}