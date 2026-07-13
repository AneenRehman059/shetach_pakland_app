import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/constants/image_constant.dart';
import '../../bill_payment_screen.dart';
import '../../controllers/client_bill_controller.dart';
import '../../controllers/get_customer_portal_controller.dart';
import '../../controllers/get_company_controller.dart';
import '../../function/screen_helper.dart';
import '../../models/client_bill_model.dart';
import '../../server_date.dart';
import '../../view_bill_screen.dart';
import '../../constants/api_constant.dart';
import '../../get_bill_receipts_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});
  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final controller = Get.put(ClientBillController());
  final storage = const FlutterSecureStorage();
  final customerPortalController = Get.put(CustomerPortalController());
  final companyController = Get.put(CompanyController());

  final RxBool isLoadingUser = true.obs;
  final RxString userId = ''.obs;
  final RxString userName = ''.obs;
  final RxInt selectedMonth = 0.obs;
  final RxInt selectedYear = 0.obs;
  final months = List.generate(12, (i) => i + 1);
  final years = <int>[].obs;
  final RxString selectedMonthName = 'Select Month'.obs;
  final RxString selectedYearText = 'Select Year'.obs;
  final RxInt currentSliderIndex = 0.obs;
  final RxMap<String, bool> selectedBills = <String, bool>{}.obs;
  final RxDouble selectedTotalAmount = 0.0.obs;
  final RxList<String> selectedBillKeys = <String>[].obs;

  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _dataHorizontalController = ScrollController();
  final ScrollController _dataVerticalController = ScrollController();

  // ✅ CRASH FIX: isTablet as method, not getter using context
  bool _isTabletLayout(BuildContext context) {
    if (ScreenHelper.isTV(context)) return true;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600;
  }

  @override
  void initState() {
    super.initState();
    _initializeYears();
    _loadUserInfo();
    companyController.fetchAndStoreCompanyDetails("SHET");
    PakistanDateHelper.initialize();
    _headerHorizontalController.addListener(_syncHorizontalScroll);
    _dataHorizontalController.addListener(_syncHorizontalScroll);
  }

  void _syncHorizontalScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_headerHorizontalController.hasClients && _dataHorizontalController.hasClients) {
        if (_headerHorizontalController.position.hasContentDimensions && _dataHorizontalController.position.hasContentDimensions) {
          if (_dataHorizontalController.offset != _headerHorizontalController.offset) _headerHorizontalController.jumpTo(_dataHorizontalController.offset);
          if (_headerHorizontalController.offset != _dataHorizontalController.offset) _dataHorizontalController.jumpTo(_headerHorizontalController.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _headerHorizontalController.removeListener(_syncHorizontalScroll);
    _dataHorizontalController.removeListener(_syncHorizontalScroll);
    _headerHorizontalController.dispose();
    _dataHorizontalController.dispose();
    _dataVerticalController.dispose();
    super.dispose();
  }

  void _initializeYears() {
    final currentYear = DateTime.now().year;
    for (int i = 1; i >= -6; i--) years.add(currentYear + i);
    years.sort((a, b) => b.compareTo(a));
  }

  void _loadUserInfo() async {
    try {
      userId.value = await storage.read(key: "user_id") ?? '';
      userName.value = await storage.read(key: "user_name") ?? '';
      isLoadingUser.value = false;
      if (userId.value.isNotEmpty) {
        final now = DateTime.now();
        selectedMonth.value = now.month;
        selectedYear.value = now.year;
        selectedMonthName.value = getMonthName(now.month);
        selectedYearText.value = now.year.toString();
        _fetchClientBills(selectedMonth.value, selectedYear.value);
      }
    } catch (e) { isLoadingUser.value = false; }
  }

  void _fetchClientBills(int month, int year) {
    selectedBills.clear();
    selectedTotalAmount.value = 0.0;
    selectedBillKeys.clear();
    controller.fetchClientBills(brnCode: "SHE000", idNo: userId.value, fromMonth: month, toMonth: month, year: year);
  }

  void _onMonthChanged(int month) {
    selectedMonth.value = month;
    selectedMonthName.value = getMonthName(month);
    if (selectedYear.value > 0) _fetchClientBills(month, selectedYear.value);
  }

  void _onYearChanged(int year) {
    selectedYear.value = year;
    selectedYearText.value = year.toString();
    if (selectedMonth.value > 0) _fetchClientBills(selectedMonth.value, year);
  }

  void _navigateToViewBillScreen(String registrationNo, int billNo) {
    Get.to(() => ViewBillScreen(registrationNo: registrationNo, brnCode: "SHE000", billNo: billNo, plotType: "RESIDENTIAL", idNo: userId.value));
  }

  void _navigateToBillReceiptsScreen(String registrationNo, int billNo) {
    Get.to(() => GetBillReceiptsScreen(brnCode: "SHE000", registrationNo: registrationNo, plotType: '', memberName: userName.toString(), userId: ''));
  }

  void _onCheckboxChanged(Bill bill, bool? value) {
    if (value == null) return;
    final String key = bill.registrationNo;
    final bool isUnpaid = _isBillUnpaid(bill);
    if (!isUnpaid && value) return;
    selectedBills[key] = value;
    if (value) {
      selectedTotalAmount.value += _calculateTotalDueAmount(bill);
      if (!selectedBillKeys.contains(key)) selectedBillKeys.add(key);
    } else {
      selectedTotalAmount.value -= _calculateTotalDueAmount(bill);
      selectedBillKeys.remove(key);
    }
  }

  Future<void> _onPayButtonClicked() async {
    if (selectedBills.isEmpty || selectedBillKeys.isEmpty) {
      Get.snackbar('No Bills Selected', 'Please select at least one bill to pay', backgroundColor: Colors.orange, colorText: Colors.white, duration: const Duration(seconds: 2));
      return;
    }
    final timeValidation = await PakistanDateHelper.validateDueDateWithDetails(DateTime.now());
    if (!timeValidation.isValid && timeValidation.reason.contains('Device time appears to be modified')) {
      Get.snackbar('Time Manipulation Detected', 'Please set your device time to automatic and restart the app', backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
      return;
    }
    final billList = controller.clientBillModel.value?.bills ?? [];
    if (billList.isEmpty) { Get.snackbar('Error', 'No bills available for payment', backgroundColor: Colors.red, colorText: Colors.white); return; }
    List<Bill> selectedBillList = [];
    for (final key in selectedBillKeys) {
      try { selectedBillList.add(billList.firstWhere((b) => b.registrationNo == key)); } catch (e) {}
    }
    if (selectedBillList.isEmpty) { Get.snackbar('Error', 'Selected bills not found', backgroundColor: Colors.red, colorText: Colors.white); return; }
    double totalOverdue = 0.0, totalOutstanding = 0.0;
    for (final bill in selectedBillList) {
      totalOverdue += bill.rentArrears;
      totalOutstanding += _calculateTotalDueAmount(bill);
    }
    final firstBill = selectedBillList.first;
    final method = await _showPaymentMethodDialog();
    if (method == null) return;
    final String paymentCode = method == 'UBL' ? 'UBL' : 'JAZZCASH';
    Get.to(() => BillPaymentScreen(registrationNo: firstBill.registrationNo, paymentCode: paymentCode, brnCode: "SHE000", brnName: '', memberName: userName.value, overDueAmount: totalOverdue, totalOutstanding: totalOutstanding, formattedTotalOutstanding: _formatAmount(totalOutstanding), formattedTotalOverDue: _formatAmount(totalOverdue), clientId: userId.value));
  }

  String getMonthName(int month) => ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][month - 1];
  String _formatAmount(double amount) => amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  double _calculateTotalDueAmount(Bill bill) => bill.rentOsAmt;
  bool _isBillUnpaid(Bill bill) => _getPaymentStatus(bill) == 'Unpaid';
  String _getPaymentStatus(Bill bill) => bill.rentOsAmt == 0 ? 'Paid' : 'Unpaid';
  Color _getStatusColor(String status) => status.toLowerCase() == 'paid' ? Colors.green.shade700 : status.toLowerCase() == 'unpaid' ? Colors.red.shade700 : Colors.grey.shade700;

  Widget _buildSliderSection(double sliderHeight, Size size) {
    return Obx(() {
      if (companyController.sliders.isEmpty) return SizedBox(height: sliderHeight, child: Center(child: SpinKitWave(color: AppColors.appColor, size: 30.0)));
      return Stack(children: [
        CarouselSlider(
          items: companyController.sliders.map((e) {
            final url = "${ApiConstants.baseUrl}${e['image_path'] ?? ""}";
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))]),
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, fit: BoxFit.fill, width: size.width,
                loadingBuilder: (ctx, child, p) => p == null ? child : Center(child: SpinKitWave(color: AppColors.appColor, size: 30.0)),
                errorBuilder: (ctx, e, s) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
              )),
            );
          }).toList(),
          options: CarouselOptions(autoPlay: true, autoPlayAnimationDuration: const Duration(milliseconds: 800), autoPlayCurve: Curves.easeInOut, viewportFraction: 1.0, enlargeCenterPage: false, height: sliderHeight, onPageChanged: (index, reason) => currentSliderIndex.value = index),
        ),
        Positioned(bottom: 10, left: 0, right: 0, child: _buildIndicatorDots()),
      ]);
    });
  }

  Widget _buildIndicatorDots() {
    return Obx(() => Row(mainAxisAlignment: MainAxisAlignment.center,
      children: companyController.sliders.asMap().entries.map((entry) => Container(
        width: currentSliderIndex.value == entry.key ? 12 : 8, height: currentSliderIndex.value == entry.key ? 12 : 8,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(shape: BoxShape.circle, color: currentSliderIndex.value == entry.key ? AppColors.appColor : Colors.white.withOpacity(0.6)),
      )).toList(),
    ));
  }

  Widget _buildPersonalInfoSection(Size size, bool isTV) {
    // TV pe fixed compact height
    final height = isTV ? 120.0 : size.height * 0.15;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        height: height,
        decoration: BoxDecoration(color: AppColors.appColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.whiteBg, strokeAlign: 1), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildInfoRow("Name", userName.value, isTV),
            _buildInfoRow("CNIC", userId.value, isTV),
            _buildInfoRow("Address", _getCombinedAddress(), isTV),
          ]),
        ),
      ),
    );
  }

  String _getCombinedAddress() {
    final addr1 = customerPortalController.customerObj.value?.address1 ?? "";
    final addr2 = customerPortalController.customerObj.value?.address2 ?? "";
    final addr3 = customerPortalController.customerObj.value?.address3 ?? "";
    return [addr1, addr2, addr3].where((p) => p.isNotEmpty).join(', ');
  }

  Widget _buildInfoRow(String label, String value, bool isTV) {
    return SizedBox(
      height: isTV ? 28 : 30,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: isTV ? 120 : 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: isTV ? 13 : 12))),
        Expanded(child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.whiteBg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: label == "Address"
                ? SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(value, style: TextStyle(color: Colors.black, fontSize: isTV ? 13 : 12, fontWeight: FontWeight.bold), maxLines: 1)))
                : Align(alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: Colors.black, fontSize: isTV ? 13 : 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          ),
        )),
      ]),
    );
  }

  Widget _buildLoading(String text, Size size, double iconSize) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    SpinKitWave(color: AppColors.appColor, size: iconSize),
    SizedBox(height: size.height * 0.02),
    Text(text, style: TextStyle(fontSize: size.width < 600 ? 14 : 16, color: Colors.grey.shade700)),
  ]));

  Widget _buildEmptyState(Size size) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.receipt_long, size: size.width * 0.15, color: Colors.grey.shade400),
    SizedBox(height: size.height * 0.02),
    Obx(() => selectedMonth.value > 0 && selectedYear.value > 0
        ? Column(children: [const Text('No bills found', style: TextStyle(color: Colors.grey)), SizedBox(height: size.height * 0.01), Text('${getMonthName(selectedMonth.value)} ${selectedYear.value}', style: const TextStyle(color: Colors.grey))])
        : const Text('Please select a month and year', style: TextStyle(color: Colors.grey))),
  ]));

  Widget _buildDropdown(String label, List items, RxString selected, Function(int) onChanged, {bool isMonth = true, bool isTV = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]),
      child: DropdownButtonFormField<int>(
        value: isMonth ? (selectedMonth.value == 0 ? null : selectedMonth.value) : (selectedYear.value == 0 ? null : selectedYear.value),
        decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isTV ? 8 : 3), border: InputBorder.none, prefixIcon: Icon(isMonth ? Icons.calendar_month : Icons.calendar_today, color: AppColors.appColor, size: isTV ? 24 : 20), labelText: label, labelStyle: TextStyle(color: AppColors.appColor, fontSize: isTV ? 16 : 14)),
        items: [
          DropdownMenuItem<int>(value: 0, child: Text('Select ${isMonth ? 'Month' : 'Year'}', style: const TextStyle(color: Colors.grey))),
          ...items.map((item) => DropdownMenuItem<int>(value: item, child: Text(isMonth ? getMonthName(item) : item.toString(), style: TextStyle(color: AppColors.appColor, fontSize: isTV ? 16 : 14)))),
        ],
        onChanged: (value) => value != null && value > 0 ? onChanged(value) : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: AppColors.appColor),
        style: TextStyle(color: AppColors.appColor, fontSize: isTV ? 16 : 14),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align, bool isTabletDevice, {Color? color, bool isAmount = false, VoidCallback? onTap, Bill? bill, String? status}) {
    final bool isStatusCell = bill != null && status != null;
    Widget textWidget = Text(text, textAlign: align, style: TextStyle(fontSize: isTabletDevice ? 14 : 12, fontWeight: isAmount ? FontWeight.w600 : FontWeight.normal, color: color ?? Colors.black, decoration: (onTap != null || isStatusCell) ? TextDecoration.underline : TextDecoration.none, decorationColor: color ?? Colors.black));
    if (isStatusCell) return GestureDetector(onTap: () => _navigateToBillReceiptsScreen(bill!.registrationNo, bill.billNo), child: MouseRegion(cursor: SystemMouseCursors.click, child: Padding(padding: isTabletDevice ? const EdgeInsets.all(12) : const EdgeInsets.all(8), child: textWidget)));
    if (onTap != null) return GestureDetector(onTap: onTap, child: MouseRegion(cursor: SystemMouseCursors.click, child: Padding(padding: isTabletDevice ? const EdgeInsets.all(12) : const EdgeInsets.all(8), child: textWidget)));
    return Padding(padding: isTabletDevice ? const EdgeInsets.all(12) : const EdgeInsets.all(8), child: textWidget);
  }

  Widget _buildHeaderCell(String text, bool isTabletDevice) {
    return Center(child: Padding(padding: isTabletDevice ? const EdgeInsets.all(14) : const EdgeInsets.all(8), child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isTabletDevice ? 15 : 13))));
  }

  Widget _buildBillTable(List<Bill> bills, BuildContext context) {
    final bool useTabletLayout = _isTabletLayout(context);
    final double grandTotal = bills.fold(0.0, (sum, bill) => sum + _calculateTotalDueAmount(bill));
    final double selectedGrandTotal = selectedTotalAmount.value;
    final double tableWidth = 70 + 70 + 75 + 90 + 90 + 85 + 90 + 90 + 70 + 60 + 50 + 16;

    Map<int, TableColumnWidth> getColumnWidths() {
      if (useTabletLayout) {
        return {0: FlexColumnWidth(0.9), 1: FlexColumnWidth(0.7), 2: FlexColumnWidth(0.8), 3: FlexColumnWidth(1.2), 4: FlexColumnWidth(1.2), 5: FlexColumnWidth(1.0), 6: FlexColumnWidth(1.1), 7: FlexColumnWidth(1.3), 8: FlexColumnWidth(0.9), 9: FlexColumnWidth(0.7), 10: FlexColumnWidth(0.6)};
      } else {
        return {0: const FixedColumnWidth(70), 1: const FixedColumnWidth(70), 2: const FixedColumnWidth(75), 3: const FixedColumnWidth(90), 4: const FixedColumnWidth(90), 5: const FixedColumnWidth(85), 6: const FixedColumnWidth(90), 7: const FixedColumnWidth(90), 8: const FixedColumnWidth(70), 9: const FixedColumnWidth(60), 10: const FixedColumnWidth(50)};
      }
    }

    Widget buildHeaderRow() {
      return Container(
        decoration: BoxDecoration(color: AppColors.appColor, border: const Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
        child: Table(border: TableBorder.symmetric(inside: const BorderSide(color: Colors.grey, width: 1.0)), columnWidths: getColumnWidths(), defaultVerticalAlignment: TableCellVerticalAlignment.middle, children: [
          TableRow(children: [
            _buildHeaderCell('Reg No', useTabletLayout), _buildHeaderCell('Block', useTabletLayout), _buildHeaderCell('Plot', useTabletLayout),
            _buildHeaderCell('Meter No', useTabletLayout), _buildHeaderCell('Meter Type', useTabletLayout), _buildHeaderCell('Surcharge', useTabletLayout),
            _buildHeaderCell('Due Date', useTabletLayout), _buildHeaderCell('Amount', useTabletLayout), _buildHeaderCell('Status', useTabletLayout),
            _buildHeaderCell('View', useTabletLayout), _buildHeaderCell('', useTabletLayout),
          ])
        ]),
      );
    }

    Widget buildDataRows() {
      return Table(
        border: TableBorder.all(color: Colors.grey[400]!, width: 1.0),
        columnWidths: getColumnWidths(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          ...bills.asMap().entries.map((entry) {
            final index = entry.key;
            final bill = entry.value;
            final isUnpaid = _isBillUnpaid(bill);
            final status = _getPaymentStatus(bill);
            final statusColor = _getStatusColor(status);
            final dueAmount = _calculateTotalDueAmount(bill);
            final surchargeAmt = bill.surchargeAmt;
            final dueDate = '${bill.billDueDate.day}/${bill.billDueDate.month}/${bill.billDueDate.year}';
            return TableRow(
              decoration: BoxDecoration(color: index % 2 == 0 ? Colors.grey[50] : Colors.white),
              children: [
                _buildDataCell(bill.registrationNo, TextAlign.center, useTabletLayout, color: AppColors.appColor),
                _buildDataCell(bill.blockNo, TextAlign.center, useTabletLayout, color: Colors.deepPurple.shade700),
                _buildDataCell(bill.plotNo, TextAlign.center, useTabletLayout, color: AppColors.appColor),
                _buildDataCell(bill.meterNo.isEmpty ? 'N/A' : bill.meterNo, TextAlign.center, useTabletLayout, color: Colors.teal.shade700),
                _buildDataCell(bill.meterCategory.isEmpty ? 'N/A' : bill.meterCategory, TextAlign.center, useTabletLayout, color: Colors.indigo.shade700),
                _buildDataCell(surchargeAmt > 0 ? '${_formatAmount(surchargeAmt)}' : '-', TextAlign.right, useTabletLayout, color: surchargeAmt > 0 ? Colors.orange.shade700 : Colors.grey.shade600, isAmount: surchargeAmt > 0),
                _buildDataCell(dueDate, TextAlign.center, useTabletLayout, color: Colors.red.shade700),
                _buildDataCell('${_formatAmount(dueAmount)}', TextAlign.right, useTabletLayout, color: Colors.green.shade700, isAmount: true),
                _buildDataCell(status, TextAlign.center, useTabletLayout, color: statusColor, bill: bill, status: status),
                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Center(child: IconButton(onPressed: () => _navigateToViewBillScreen(bill.registrationNo, bill.billNo), icon: Icon(Icons.remove_red_eye_outlined, color: AppColors.appColor, size: useTabletLayout ? 28 : 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()))),
                TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Center(child: Obx(() => Checkbox(value: selectedBills[bill.registrationNo] ?? false, onChanged: isUnpaid ? (value) => _onCheckboxChanged(bill, value) : null, activeColor: AppColors.appColor, checkColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)))),
              ],
            );
          }).toList(),
          // Total Row
          TableRow(decoration: BoxDecoration(color: Colors.blue[50], border: const Border(top: BorderSide(width: 2.0, color: Colors.blue))), children: [
            TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()),
            TableCell(child: Container(padding: useTabletLayout ? const EdgeInsets.all(14) : const EdgeInsets.all(8), child: Text('Total:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: useTabletLayout ? 15 : 12, color: Colors.blue[900])))),
            TableCell(child: Container(padding: useTabletLayout ? const EdgeInsets.all(14) : const EdgeInsets.all(8), child: Text('${_formatAmount(grandTotal)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: useTabletLayout ? 15 : 12, color: Colors.green[900])))),
            TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()),
          ]),
          // Selected Row
          TableRow(decoration: BoxDecoration(color: Colors.orange[50]), children: [
            TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()), TableCell(child: Container()),
            TableCell(child: Text('Selected:', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: useTabletLayout ? 15 : 12, color: Colors.orange[900]))),
            TableCell(child: Container(padding: useTabletLayout ? const EdgeInsets.all(14) : const EdgeInsets.all(8), child: Text('${_formatAmount(selectedGrandTotal)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: useTabletLayout ? 15 : 12, color: selectedGrandTotal > 0 ? AppColors.appColor : Colors.grey.shade700)))),
            TableCell(child: Container()), TableCell(child: Container()),
            TableCell(child: Container(padding: useTabletLayout ? const EdgeInsets.all(10) : const EdgeInsets.all(6), child: Obx(() => ElevatedButton(
              onPressed: selectedBillKeys.isNotEmpty ? _onPayButtonClicked : null,
              style: ElevatedButton.styleFrom(backgroundColor: selectedBillKeys.isNotEmpty ? AppColors.appColor : Colors.grey.shade400, padding: EdgeInsets.symmetric(horizontal: useTabletLayout ? 13 : 8, vertical: useTabletLayout ? 12 : 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), minimumSize: Size.zero),
              child: Text('Pay', style: TextStyle(fontSize: useTabletLayout ? 13 : 11, fontWeight: FontWeight.w600, color: Colors.white)),
            )))),
          ]),
        ],
      );
    }

    // TV/Tablet layout — full width table with vertical scroll
    if (useTabletLayout) {
      return Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [
            Container(decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), color: AppColors.appColor), child: buildHeaderRow()),
            Expanded(child: SingleChildScrollView(controller: _dataVerticalController, physics: const AlwaysScrollableScrollPhysics(), child: buildDataRows())),
          ]),
        ),
      );
    }

    // Mobile layout — horizontal + vertical scroll
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(children: [
        Container(height: 1, width: double.infinity, color: Colors.white),
        SizedBox(height: 37, child: SingleChildScrollView(controller: _headerHorizontalController, scrollDirection: Axis.horizontal, physics: const AlwaysScrollableScrollPhysics(), child: SizedBox(width: tableWidth, child: buildHeaderRow()))),
        Expanded(child: SingleChildScrollView(controller: _dataVerticalController, scrollDirection: Axis.vertical, physics: const AlwaysScrollableScrollPhysics(), child: SingleChildScrollView(controller: _dataHorizontalController, scrollDirection: Axis.horizontal, physics: const AlwaysScrollableScrollPhysics(), child: SizedBox(width: tableWidth, child: buildDataRows())))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final titleFontSize = isTV ? 22.0 : (isSmallScreen ? 16.0 : 20.0);
    final loadingIconSize = isSmallScreen ? 30.0 : 50.0;
    final double sliderHeight = isTV ? size.height * 0.30 : size.height * 0.22;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
        child: AppBar(
          title: Text('Bills', style: TextStyle(color: AppColors.whiteBg, fontSize: titleFontSize, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: AppColors.whiteBg),
          centerTitle: true,
          elevation: 2,
        ),
      ),
      body: Obx(() => Column(children: [
        const SizedBox(height: 8),
        _buildSliderSection(sliderHeight, size),
        const SizedBox(height: 8),
        _buildPersonalInfoSection(size, isTV),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 5 : 16, vertical: isTV ? 12 : 8),
          color: AppColors.appColor,
          child: Row(children: [
            Expanded(child: _buildDropdown('Bill for this month', months, selectedMonthName, _onMonthChanged, isMonth: true, isTV: isTV)),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(child: _buildDropdown('Year', years, selectedYearText, _onYearChanged, isMonth: false, isTV: isTV)),
          ]),
        ),
        Expanded(child: Obx(() {
          if (controller.isLoading.value) return _buildLoading('Fetching bills...', size, loadingIconSize);
          final billList = controller.clientBillModel.value?.bills;
          if (billList == null || billList.isEmpty) return _buildEmptyState(size);
          // ✅ Pass context to _buildBillTable — no more isTablet getter crash
          return _buildBillTable(billList, context);
        })),
        const SizedBox(height: 40),
      ])),
    );
  }

  Future<String?> _showPaymentMethodDialog() async {
    final theme = Theme.of(context);
    return Get.dialog<String>(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.appColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.appColor, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Choose payment method', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Select how you want to pay the selected bills.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.2)),
                ])),
                IconButton(onPressed: () => Get.back(result: null), icon: const Icon(Icons.close), splashRadius: 18, tooltip: 'Close'),
              ]),
              const SizedBox(height: 14),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 14),
              _paymentMethodCard(title: 'UBL Bank Account', subtitle: 'Pay using your UBL account', assetPath: ImageConstant.ubl, onTap: () => Get.back(result: 'UBL')),
              const SizedBox(height: 12),
              _paymentMethodCard(title: 'JazzCash Wallet', subtitle: 'Pay using JazzCash mobile wallet', assetPath: ImageConstant.jazzcash, onTap: () => Get.back(result: 'JAZZCASH')),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text('You can change this later during payment.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45))),
                TextButton(onPressed: () => Get.back(result: null), child: const Text('Cancel')),
              ]),
            ]),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _paymentMethodCard({required String title, required String subtitle, required String assetPath, required VoidCallback onTap, Color? brandColor}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200, width: 1)),
        child: Row(children: [
          Image.asset(assetPath, fit: BoxFit.cover, height: 40, width: 40),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black45),
        ]),
      ),
    );
  }
}