import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../colors.dart';
import '../../controllers/tickets_controller.dart';
import '../../customs/custom_buttons.dart';
import '../../customs/toast_message.dart';
import '../../customs/widgets/app_bar.dart';
import '../../customs/widgets/app_dropdown.dart';
import '../../customs/widgets/app_text_field.dart';
import '../../customs/widgets/attachment_picker.dart';
import '../../function/screen_helper.dart';
import '../../models/ticket_models.dart';

class TicketCreateView extends StatefulWidget {
  const TicketCreateView({super.key});
  @override
  State<TicketCreateView> createState() => _TicketCreateViewState();
}

class _TicketCreateViewState extends State<TicketCreateView> {
  final TicketController controller = Get.find<TicketController>();
  final descriptionController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  final selectedBranchName = RxnString();
  final selectedDepartmentName = RxnString();
  final selectedOperationName = RxnString();
  final attachments = <File>[].obs;
  double _uploadProgress = 0.0;
  late List<double> _fileProgress = [];

  Future<String?> get userId async => await _storage.read(key: "user_id");

  String? _resolveSelectedOperationId() {
    try {
      final ops = controller.deptOprations;
      if (selectedOperationName.value == null) return null;
      final match = ops.firstWhere((m) => ((m['OperationName'] ?? m['Name'] ?? '').toString().trim() == selectedOperationName.value!.trim()), orElse: () => {});
      final id = (match['OperationId'] ?? match['OptionId'] ?? match['Id'] ?? match['OprationID'] ?? '').toString();
      return id.isEmpty ? null : id;
    } catch (_) { return null; }
  }

  void _submitTicket() async {
    if (selectedBranchName.value == null || selectedBranchName.value!.isEmpty) { showTopSnackBar(context, title: "Alert", "Please select a Project", Colors.red.withOpacity(0.7), icon: Icons.warning); return; }
    if (selectedDepartmentName.value == null || selectedDepartmentName.value!.isEmpty) { showTopSnackBar(context, title: "Alert", "Please select a department", Colors.red.withOpacity(0.7), icon: Icons.warning); return; }
    if (selectedOperationName.value == null || selectedOperationName.value!.isEmpty) { showTopSnackBar(context, title: "Alert", "Please select a category", Colors.red.withOpacity(0.7), icon: Icons.warning); return; }
    final desc = descriptionController.text.trim();
    if (desc.isEmpty) { showTopSnackBar(context, title: "Alert", "Please enter a description", Colors.red.withOpacity(0.7), icon: Icons.warning); return; }

    try {
      final userIdValue = await userId;
      if (userIdValue == null || userIdValue.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not authenticated. Please login again.'), backgroundColor: AppColors.errorColor, behavior: SnackBarBehavior.floating)); return; }
      final request = CreateTicketRequest(title: selectedDepartmentName.value ?? '', description: desc, userId: userIdValue, dueDate: null, attachmentPath: null, oprationID: _resolveSelectedOperationId() ?? (selectedOperationName.value ?? selectedDepartmentName.value ?? ''), brn_code: selectedBranchName.value ?? '', ticketPriority: 'Low');
      setState(() { _uploadProgress = 0.0; _fileProgress = List<double>.filled(attachments.length, 0.0); });
      final result = await controller.createTicketWithAttachments(request, attachments, onUploadProgress: (sent, total) { setState(() { _uploadProgress = total == 0 ? 0 : sent / total; }); }, onFileProgress: (index, sent, total) { if (total > 0 && index >= 0 && index < _fileProgress.length) setState(() { _fileProgress[index] = sent / total; }); });
      if (result == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No response received from server'), backgroundColor: AppColors.errorColor, behavior: SnackBarBehavior.floating)); setState(() => _uploadProgress = 0); return; }
      final status = result['StatusCode']?.toString();
      final message = result['Message']?.toString() ?? 'Unknown response';
      if (status == "200") {
        final ticket = result['obj'];
        final userName = await _storage.read(key: 'user_name') ?? 'Customer';
        Get.defaultDialog(title: "Complaint Submitted", titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green), backgroundColor: Colors.white, contentPadding: const EdgeInsets.all(16), barrierDismissible: false, onWillPop: () async => false,
            content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.receipt_long, size: 40, color: Colors.green), const SizedBox(height: 12),
              Text("Ticket ID: #${ticket?['TicketId']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8), Text("Name: $userName"), Text("Department: ${selectedDepartmentName.value}"),
              Text("Date & Time: ${DateFormat('dd MMM yyyy – hh:mm a').format(DateTime.now())}"),
            ]),
            confirm: ElevatedButton.icon(onPressed: () { setState(() => _uploadProgress = 0); Get.offNamed('/clintDashboard'); }, icon: const Icon(Icons.check_circle_outline), label: const Text("Go to Dashboard"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green)), radius: 10);
        setState(() => _uploadProgress = 0);
      } else if (status == "500") {
        Get.defaultDialog(title: "Unregister User Error", titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18), middleText: message.isNotEmpty ? message : 'You are not a registered user.', backgroundColor: Colors.white, middleTextStyle: const TextStyle(fontSize: 14, color: Colors.black87), textConfirm: 'OK', confirmTextColor: Colors.white, buttonColor: Colors.red, radius: 10, onConfirm: () { Get.back(); setState(() => _uploadProgress = 0); });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.errorColor, behavior: SnackBarBehavior.floating));
        setState(() => _uploadProgress = 0);
      }
    } catch (e, s) {
      print('❌ Ticket creation exception: $e');
      Get.defaultDialog(title: "Exception Occurred", titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18), middleText: e.toString(), backgroundColor: Colors.white, middleTextStyle: const TextStyle(fontSize: 14, color: Colors.black87), textConfirm: 'OK', confirmTextColor: Colors.white, buttonColor: Colors.red, radius: 10, onConfirm: () { Get.back(); setState(() => _uploadProgress = 0); });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetchBranchesAll());
  }

  @override
  void dispose() { descriptionController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
        child: CustomAppBar(custom_RouteName: '/clintDashboard', title: 'Create Ticket'),
      ),
      body: SafeArea(
        child: isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('Project', required: true),
        _buildProjectDropdown(),
        const SizedBox(height: 16),
        _fieldLabel('Department', required: true),
        _buildDepartmentDropdown(),
        const SizedBox(height: 16),
        _fieldLabel('Category', required: true),
        _buildCategoryDropdown(),
        const SizedBox(height: 16),
        _fieldLabel('Description', required: true),
        AppTextField(controller: descriptionController, label: '', hint: 'Type something...', maxLines: 5, maxLength: 1000, showCounter: true),
        const SizedBox(height: 8),
        WhatsAppAttachmentPicker(onChanged: (files) => attachments.assignAll(files)),
        const SizedBox(height: 16),
        _buildSubmitButton(),
      ]),
    );
  }

  Widget _buildTVLayout(BuildContext context) {

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _fieldLabel('Project', required: true, isTV: true),
        _buildProjectDropdown(),
        const SizedBox(height: 20),
        _fieldLabel('Department', required: true, isTV: true),
        _buildDepartmentDropdown(),
        const SizedBox(height: 20),
        _fieldLabel('Category', required: true, isTV: true),
        _buildCategoryDropdown(),
        const SizedBox(height: 20),
        _fieldLabel('Description', required: true, isTV: true),
        AppTextField(controller: descriptionController, label: '', hint: 'Type something...', maxLines: 6, maxLength: 1000, showCounter: true),
        const SizedBox(height: 16),
        WhatsAppAttachmentPicker(onChanged: (files) => attachments.assignAll(files)),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ]),
    );
    // final size = MediaQuery.of(context).size;
    // return Row(children: [
    //   // Left — dropdowns
    //   Expanded(child: SingleChildScrollView(
    //     padding: EdgeInsets.all(24),
    //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //       _fieldLabel('Project', required: true, isTV: true),
    //       _buildProjectDropdown(),
    //       const SizedBox(height: 20),
    //       _fieldLabel('Department', required: true, isTV: true),
    //       _buildDepartmentDropdown(),
    //       const SizedBox(height: 20),
    //       _fieldLabel('Category', required: true, isTV: true),
    //       _buildCategoryDropdown(),
    //     ]),
    //   )),
    //   // Right — description + attachments + submit
    //   Expanded(child: SingleChildScrollView(
    //     padding: EdgeInsets.all(24),
    //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //       _fieldLabel('Description', required: true, isTV: true),
    //       AppTextField(controller: descriptionController, label: '', hint: 'Type something...', maxLines: 6, maxLength: 1000, showCounter: true),
    //       const SizedBox(height: 16),
    //       WhatsAppAttachmentPicker(onChanged: (files) => attachments.assignAll(files)),
    //       const SizedBox(height: 24),
    //       _buildSubmitButton(),
    //     ]),
    //   )),
    // ]);
  }

  Widget _fieldLabel(String label, {bool required = false, bool isTV = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: isTV ? 18 : 16, fontWeight: FontWeight.bold, color: AppColors.textSecondaryColor)),
        if (required) Text('*', style: TextStyle(fontSize: isTV ? 18 : 16, color: Colors.red)),
      ]),
    );
  }

  Widget _buildProjectDropdown() {
    return Obx(() {
      final seen = <String>{};
      final uniqueItems = controller.branchesAll.where((m) { final code = (m['brn_code'] ?? m['brn_name'] ?? '').toString(); return seen.add(code); }).toList();
      return AppDropdown<String>(hint: const Text('Select Project', style: TextStyle(fontSize: 14, color: Colors.black54)), value: selectedBranchName.value, items: uniqueItems.map((m) { final name = (m['brn_name'] ?? '').toString(); final code = (m['brn_code'] ?? m['brn_name'] ?? '').toString(); return DropdownMenuItem<String>(value: code, child: Text(name)); }).toList(), onChanged: (val) { selectedBranchName.value = val; selectedDepartmentName.value = null; selectedOperationName.value = null; controller.departments.clear(); controller.deptOprations.clear(); if (val != null && val.isNotEmpty) controller.selectBracnch(val); });
    });
  }

  Widget _buildDepartmentDropdown() {
    return Obx(() {
      if (selectedBranchName.value == null) return AppDropdown<String>(hint: const Text('Select Department', style: TextStyle(fontSize: 14, color: Colors.grey)), value: null, items: [], onChanged: null, enabled: false);
      if (controller.isLoading.value && controller.departments.isEmpty) return AppDropdown<String>(hint: const Text('Loading Departments', style: TextStyle(fontSize: 14, color: Colors.grey)), value: null, items: [], onChanged: null, enabled: false);
      final filteredDepts = controller.departments.where((m) { final n = (m['DeptName'] ?? '').toString().toLowerCase(); return n != 'emergency'; }).toList();
      return AppDropdown<String>(hint: const Text('Select Department', style: TextStyle(fontSize: 14, color: Colors.black54)), value: selectedDepartmentName.value, items: filteredDepts.map((m) { final n = (m['DeptName'] ?? '').toString(); final id = (m['DeptID'] ?? '').toString(); return DropdownMenuItem<String>(value: id, child: Text(n)); }).toList(), onChanged: (val) { selectedDepartmentName.value = val; selectedOperationName.value = null; controller.deptOprations.clear(); if (val != null && val.isNotEmpty) controller.selectDepartment(val); });
    });
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (selectedDepartmentName.value == null) return AppDropdown<String>(hint: const Text('Select Category', style: TextStyle(fontSize: 14, color: Colors.grey)), value: null, items: [], onChanged: null, enabled: false);
      if (controller.isLoading.value && controller.deptOprations.isEmpty) return AppDropdown<String>(hint: const Text('Loading..', style: TextStyle(fontSize: 14, color: Colors.grey)), value: null, items: [], onChanged: null, enabled: false);
      return AppDropdown<String>(hint: const Text('Select Category', style: TextStyle(fontSize: 14, color: Colors.black54)), value: selectedOperationName.value, items: controller.deptOprations.map((m) { final n = (m['OperationName'] ?? '').toString(); final id = (m['OperationID'] ?? '').toString(); return DropdownMenuItem<String>(value: id, child: Text(n)); }).toList(), onChanged: (val) => selectedOperationName.value = val);
    });
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(width: double.infinity, child: CustomButton(text: 'Submit', onPressed: () { if (!controller.creating.value) _submitTicket(); }, backgroundColor: AppColors.primaryColor, isLoading: controller.creating.value)));
  }
}