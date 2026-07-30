import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/features/billing/presentation/screens/online_payments_screen.dart';
import 'package:pakland/features/billing/presentation/screens/pay_now_screen.dart';
import 'package:pakland/features/profile/presentation/screens/user_files_screen.dart';
import 'package:pakland/features/billing/presentation/screens/view_bill_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/files_info_card_screen.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/billing/presentation/controllers/pay_online_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/customer_portal/presentation/screens/customer_portal_screen.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/billing/presentation/screens/get_account_statement_screen.dart';
import 'package:pakland/features/billing/presentation/screens/get_recipt_statment_screen.dart';
import 'package:pakland/features/profile/data/models/client_detail_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PayOnlineScreen extends StatefulWidget {
  final String brnCode;
  final String brnName;
  const PayOnlineScreen({super.key, required this.brnCode, required this.brnName});
  @override
  State<PayOnlineScreen> createState() => _PayOnlineScreenState();
}

class _PayOnlineScreenState extends State<PayOnlineScreen> {
  final _storage = const FlutterSecureStorage();
  String? userId;
  late final PayOnlineController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PayOnlineController>()
        ? Get.find<PayOnlineController>()
        : Get.put(PayOnlineController());
    _loadUserId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final id = await _storage.read(key: "user_id");
    if (id != null && id.isNotEmpty) {
      setState(() => userId = id);
      controller.fetchClientDetails(username: id, brnCode: "000000", blockNo: 'a', plotNo: '2');
    } else {
      showTopSnackBar(context, title: "Alert", "User ID not found", Colors.red.withOpacity(0.7), icon: Icons.warning);
    }
  }

  Future<void> _launchYouTubeVideo() async {
    const url = 'https://www.youtube.com/watch?v=wu6E1jvm14k';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: AppColors.appColor, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: Obx(() {
          if (controller.isLoading.value) return _buildLoadingState(size, padding);
          if (controller.clientDetailModel.value == null ||
              controller.clientDetailModel.value!.obj.clientDetailList == null ||
              controller.clientDetailModel.value!.obj.clientDetailList!.isEmpty) {
            return _buildNoDataState(size, padding);
          }
          return isTV
              ? _buildTVContent(size, padding, mediaQuery)
              : _buildMobileContent(size, padding, mediaQuery);
        }),
      ),
    );
  }

  Widget _buildLoadingState(Size size, EdgeInsets padding) {
    final bool isTV = ScreenHelper.isTV(context);
    return Column(children: [
      isTV ? _buildTVAppBar() : _buildHeader(size, padding),
      Expanded(child: Center(child: SpinKitWave(color: AppColors.appColor, size: isTV ? 50 : size.width * 0.12))),
    ]);
  }

  Widget _buildNoDataState(Size size, EdgeInsets padding) {
    final bool isTV = ScreenHelper.isTV(context);
    return Column(children: [
      isTV ? _buildTVAppBar() : _buildHeader(size, padding),
      Expanded(child: Center(child: Text('No data found', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: isTV ? 22 : size.width * 0.05)))),
    ]);
  }

  Widget _buildTVAppBar() {
    return Container(
      color: AppColors.appColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          // Back button — focusable
          _TVIconBtn(icon: Icons.arrow_back, onTap: () => Get.to(CustomerPortalScreen())),
          Expanded(child: Text('Pay Online', style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          // Home button — focusable
          _TVIconBtn(icon: Icons.home, onTap: () => Get.offAll(() => MainWrapper(initialIndex: 0))),
        ]),
      ),
    );
  }

  Widget _buildHeader(Size size, EdgeInsets padding) {
    return Container(
      height: size.height * 0.20,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.appColor, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
      child: SafeArea(child: Stack(children: [
        Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: size.width * 0.02, bottom: size.width * 0.07), child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white, size: size.width * 0.07), onPressed: () => Get.to(CustomerPortalScreen())))),
        Align(alignment: Alignment.center, child: Padding(padding: EdgeInsets.only(bottom: size.width * 0.07), child: Text('Pay Online', style: TextStyle(fontSize: size.width * 0.05, color: Colors.white, fontWeight: FontWeight.bold)))),
        Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 20), child: IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0))))),
      ])),
    );
  }

  // ─── TV Layout ─────────────────────────────────────────────────────────────
  Widget _buildTVContent(Size size, EdgeInsets padding, MediaQueryData mediaQuery) {
    final clientDetails = controller.clientDetailModel.value!.obj.clientDetailList!;

    return Column(children: [
      _buildTVAppBar(),
      Expanded(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: clientDetails.map((client) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile + Info cards side by side
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 5, child: _buildProfileCardTV(client)),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _buildInfoCardsTV(client)),
                  ]),
                  const SizedBox(height: 20),
                  _buildActionButtonsTV(client, mediaQuery),
                  const SizedBox(height: 20),
                  _buildVideoPreviewTV(),
                  const SizedBox(height: 30),
                ],
              )).toList(),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildProfileCardTV(ClientDetail client) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.appColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.whiteBg, width: 1), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(width: 60, height: 60, child: Image.asset('assets/images/logo.png')),
          const SizedBox(width: 12),
          Expanded(child: Text(client.brnName ?? widget.brnName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 2)),
        ]),
        const SizedBox(height: 16),
        _buildFormRowTV('Booking ID / Reg#', client.registrationNo ?? ''),
        _buildFormRowTV('File Status', _getRegistrationStatusText(client.registrationStatus)),
        _buildFormRowTV('Plot / Unit Size', client.paymentCode ?? ''),
        _buildFormRowTV('Customer Name', client.memberName ?? ''),
      ]),
    );
  }

  Widget _buildFormRowTV(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 160, child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 36, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)), child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87), overflow: TextOverflow.ellipsis))),
      ]),
    );
  }

  Widget _buildInfoCardsTV(ClientDetail client) {
    final totalOutstanding = _calculateTotalOutstanding(client);
    final totalOverDue = _calculateTotalOverDue(client);
    final totalReceived = _calculateTotalReceived(client);
    final totalAmount = double.tryParse(client.totDueAmt) ?? 0;
    const tvSize = Size(300, 600);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(children: [
        Row(children: [
          InfoCard(title: 'Total Price', amount: 'Rs. ${_formatAmount(totalAmount)}/-', percent: 100, size: tvSize),
          InfoCard(title: 'Total Received', amount: 'Rs.${_formatAmount(totalReceived)}/-', percent: _calculateTotalReceivedPercent(client, totalReceived), size: tvSize),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          InfoCard(title: 'Total Outstanding', amount: 'Rs.${_formatAmount(totalOutstanding)}/-', percent: _calculateTotalOSPercent(client, totalOutstanding), size: tvSize),
          InfoCard(title: 'Total Overdue', amount: 'Rs.${_formatAmount(totalOverDue)}/-', percent: _calculateTotalOverDuePercent(client, totalOverDue), size: tvSize),
        ]),
      ]),
    );
  }

  Widget _buildActionButtonsTV(ClientDetail client, MediaQueryData mediaQuery) {
    final companyController = Get.find<CompanyController>();
    return Row(children: [
      Expanded(child: _TVFocusButton(label: 'View Statement', onTap: () {
        if (_canNavigateToStatement(client, companyController)) {
          Get.to(() => AccountStatementScreen(registrationNo: client.registrationNo ?? '', brnCode: client.brnCode ?? '', plotType: client.plotType ?? 'Normal', idNo: client.cnic ?? ''));
        } else { _showCloseStatusAlert(context, client); }
      })),
      const SizedBox(width: 16),
      Expanded(child: _TVFocusButton(label: 'View Receipt', onTap: () {
        Get.to(() => ReceiptTableView(registrationNo: client.registrationNo ?? '', brnCode: client.brnCode ?? '', plotType: client.plotType ?? 'Normal', memberName: client.memberName ?? '', idNo: client.cnic));
      })),
      const SizedBox(width: 16),
      Expanded(child: _TVFocusButton(label: 'Pay Now', onTap: () {
        final totalOutstanding = _calculateTotalOutstanding(client);
        final totalOverDue = _calculateTotalOverDue(client);
        Get.to(() => PaymentScreen(registrationNo: client.registrationNo ?? '', paymentCode: client.paymentCode ?? '', brnCode: client.brnCode ?? '', brnName: client.brnName ?? '', memberName: client.memberName ?? '', overDueAmount: totalOverDue, totalOutstanding: totalOutstanding, formattedTotalOutstanding: _formatAmount(totalOutstanding), formattedTotalOverDue: _formatAmount(totalOverDue), clientId: client.cnic));
      })),
    ]);
  }

  Widget _buildVideoPreviewTV() {
    return _TVFocusContainer(
      onTap: _launchYouTubeVideo,
      child: Container(
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey[200]),
        child: Stack(alignment: Alignment.center, children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/images/she.png', fit: BoxFit.fill, width: double.infinity)),
          Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)), padding: const EdgeInsets.all(20), child: const Icon(Icons.play_arrow, color: Colors.white, size: 60)),
        ]),
      ),
    );
  }

  // ─── Mobile Layout ─────────────────────────────────────────────────────────
  Widget _buildMobileContent(Size size, EdgeInsets padding, MediaQueryData mediaQuery) {
    final clientDetails = controller.clientDetailModel.value!.obj.clientDetailList!;
    return Stack(children: [
      _buildHeader(size, padding),
      Padding(
        padding: EdgeInsets.only(top: size.height * 0.22 - size.height * 0.1, bottom: padding.bottom + size.height * 0.02),
        child: ListView.builder(
          padding: EdgeInsets.only(top: size.height * 0.01, bottom: padding.bottom + size.height * 0.02),
          itemCount: clientDetails.length,
          itemBuilder: (context, index) {
            final client = clientDetails[index];
            final isFirstItem = index == 0;
            return Column(children: [
              Transform.translate(offset: Offset(0, isFirstItem ? size.height * 0.01 : size.height * 0.025), child: _buildProfileCard(client, size)),
              Transform.translate(offset: Offset(0, isFirstItem ? size.height * 0.018 : size.height * 0.035), child: _buildInfoCardsMobile(client, size)),
              SizedBox(height: size.height * 0.01),
              Transform.translate(offset: Offset(0, isFirstItem ? 20 : 30), child: _buildActionButtons(client, mediaQuery)),
              SizedBox(height: size.height * 0.01),
              Transform.translate(offset: Offset(0, isFirstItem ? size.height * 0.035 : size.height * 0.045), child: _buildVideoPreview(size)),
              SizedBox(height: size.height * 0.05),
            ]);
          },
        ),
      ),
    ]);
  }

  Widget _buildProfileCard(ClientDetail client, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(color: AppColors.appColor, borderRadius: BorderRadius.circular(size.width * 0.03), border: Border.all(color: AppColors.whiteBg, width: 1), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(width: size.width * 0.14, height: size.width * 0.14, child: Image.asset('assets/images/logo.png')),
          Expanded(child: Center(child: Text(client.brnName ?? widget.brnName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.045, color: AppColors.whiteBg), overflow: TextOverflow.ellipsis, maxLines: 2))),
        ]),
        SizedBox(height: size.height * 0.01),
        _buildFormRow('Booking ID / Reg#', client.registrationNo ?? '', size),
        _buildFormRow('File Status:', _getRegistrationStatusText(client.registrationStatus), size),
        _buildFormRow('Plot / Unit Size:', client.paymentCode ?? '', size),
        _buildFormRow('Customer Name:', client.memberName ?? '', size),
      ]),
    );
  }

  Widget _buildFormRow(String label, String value, Size size) => Padding(
    padding: EdgeInsets.symmetric(vertical: size.height * 0.005),
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: size.width * 0.3, child: Text(label, style: TextStyle(fontSize: size.width * 0.035, color: AppColors.whiteBg, fontWeight: FontWeight.bold))),
      Expanded(child: Container(height: size.height * 0.035, alignment: Alignment.centerLeft, padding: EdgeInsets.symmetric(horizontal: size.width * 0.03), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(size.width * 0.05)), child: Text(value, style: TextStyle(fontSize: size.width * 0.035, color: Colors.black87), overflow: TextOverflow.ellipsis))),
    ]),
  );

  Widget _buildInfoCardsMobile(ClientDetail client, Size size) {
    final totalOutstanding = _calculateTotalOutstanding(client);
    final totalOverDue = _calculateTotalOverDue(client);
    final totalReceived = _calculateTotalReceived(client);
    final totalAmount = double.tryParse(client.totDueAmt) ?? 0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(size.width * 0.03), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        InfoCard(title: 'Total Price', amount: 'Rs. ${_formatAmount(totalAmount)}/-', percent: 100, size: size),
        InfoCard(title: 'Total Received', amount: 'Rs.${_formatAmount(totalReceived)}/-', percent: _calculateTotalReceivedPercent(client, totalReceived), size: size),
        InfoCard(title: 'Total Outstanding', amount: 'Rs.${_formatAmount(totalOutstanding)}/-', percent: _calculateTotalOSPercent(client, totalOutstanding), size: size),
        InfoCard(title: 'Total Overdue', amount: 'Rs.${_formatAmount(totalOverDue)}/-', percent: _calculateTotalOverDuePercent(client, totalOverDue), size: size),
      ]),
    );
  }

  Widget _buildActionButtons(ClientDetail client, MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final isSmallScreen = size.width < 360;
    final companyController = Get.find<CompanyController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(children: [
        Row(children: [
          Expanded(child: _buildButton('View Statement', size: size, onPressed: () {
            if (_canNavigateToStatement(client, companyController)) {
              Get.to(() => AccountStatementScreen(registrationNo: client.registrationNo ?? '', brnCode: client.brnCode ?? '', plotType: client.plotType ?? 'Normal', idNo: client.cnic ?? ''));
            } else { _showCloseStatusAlert(context, client); }
          })),
          SizedBox(width: isSmallScreen ? size.width * 0.03 : size.width * 0.04),
          Expanded(child: _buildButton('View Receipt', size: size, onPressed: () {
            Get.to(() => ReceiptTableView(registrationNo: client.registrationNo ?? '', brnCode: client.brnCode ?? '', plotType: client.plotType ?? 'Normal', memberName: client.memberName ?? '', idNo: client.cnic));
          })),
        ]),
        SizedBox(height: size.height * 0.015),
        Row(children: [
          Expanded(child: Container()),
          Expanded(flex: isSmallScreen ? 3 : 2, child: _buildButton('Pay Now', size: size, onPressed: () {
            final totalOutstanding = _calculateTotalOutstanding(client);
            final totalOverDue = _calculateTotalOverDue(client);
            Get.to(() => PaymentScreen(registrationNo: client.registrationNo ?? '', paymentCode: client.paymentCode ?? '', brnCode: client.brnCode ?? '', brnName: client.brnName ?? '', memberName: client.memberName ?? '', overDueAmount: totalOverDue, totalOutstanding: totalOutstanding, formattedTotalOutstanding: _formatAmount(totalOutstanding), formattedTotalOverDue: _formatAmount(totalOverDue), clientId: client.cnic));
          })),
          Expanded(child: Container()),
        ]),
      ]),
    );
  }

  bool _canNavigateToStatement(ClientDetail client, CompanyController companyController) {
    if (!companyController.showCloseStatus) return true;
    return (client.registrationStatus?.toUpperCase() ?? '') == 'N';
  }

  void _showCloseStatusAlert(BuildContext context, ClientDetail client) {
    final companyController = Get.find<CompanyController>();
    final alterMessage = companyController.alterMessage.value.isNotEmpty ? companyController.alterMessage.value : 'This file is canceled/locked. Please contact support.';
    showTopSnackBar(context, title: "Access Denied", "File Status: ${_getRegistrationStatusText(client.registrationStatus)}. $alterMessage", Colors.red.withOpacity(0.7), icon: Icons.warning);
  }

  Widget _buildButton(String text, {required Size size, VoidCallback? onPressed}) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.appColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.08)), padding: EdgeInsets.symmetric(vertical: size.height * 0.015, horizontal: size.width * 0.02), elevation: 4, shadowColor: Colors.black.withOpacity(0.2)),
    child: Text(text, style: TextStyle(color: AppColors.whiteBg, fontWeight: FontWeight.bold, fontSize: size.width * 0.04, letterSpacing: 0.3), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
  );

  Widget _buildVideoPreview(Size size) => Padding(
    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
    child: GestureDetector(
      onTap: _launchYouTubeVideo,
      child: Container(
        height: size.height * 0.22,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(size.width * 0.03), color: Colors.grey[200]),
        child: Stack(alignment: Alignment.center, children: [
          ClipRRect(borderRadius: BorderRadius.circular(size.width * 0.03), child: Image.asset('assets/images/she.png', fit: BoxFit.fill, width: double.infinity)),
          Container(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.5)), padding: EdgeInsets.all(size.width * 0.04), child: Icon(Icons.play_arrow, color: Colors.white, size: size.width * 0.1)),
        ]),
      ),
    ),
  );

  // ─── Calculations ──────────────────────────────────────────────────────────
  double _calculateTotalOutstanding(ClientDetail client) {
    try { final a = double.tryParse(client.totDueAmt) ?? 0; final b = double.tryParse(client.totRecievedAmt) ?? 0; final c = double.tryParse(client.totRebatAmt) ?? 0; return a - b - c; } catch (e) { return 0; }
  }
  double _calculateTotalOverDue(ClientDetail client) { try { return client.overDueAmount.toDouble(); } catch (e) { return 0; } }
  double _calculateTotalReceived(ClientDetail client) { try { return double.tryParse(client.totRecievedAmt) ?? 0; } catch (e) { return 0; } }
  int _calculateTotalReceivedPercent(ClientDetail client, double totalReceived) {
    try { final n = client.netPrice.toDouble(); final o = client.osAmount.toDouble(); if (n + o == 0) return 0; return ((totalReceived / (n + o)) * 100).round().clamp(0, 100); } catch (e) { return 0; }
  }
  int _calculateTotalOSPercent(ClientDetail client, double totalOutstanding) {
    try { final d = double.tryParse(client.totDueAmt) ?? 0; if (d == 0) return 0; return ((totalOutstanding / d) * 100).round().clamp(0, 100); } catch (e) { return 0; }
  }
  int _calculateTotalOverDuePercent(ClientDetail client, double totalOverDue) {
    try { final d = double.tryParse(client.dueTillToday) ?? 0; if (d == 0) return 0; return ((totalOverDue / d) * 100).round().clamp(0, 100); } catch (e) { return 0; }
  }
  String _formatAmount(double amount) => amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  String _getRegistrationStatusText(String? s) {
    switch (s?.toUpperCase()) {
      case 'N': return 'Active'; case 'L': return 'Locked'; case 'C': return 'Cancelled';
      case 'D': return 'Division'; case 'F': return 'Refunded'; case 'G': return 'Amalgamation';
      case 'M': return 'Merged'; case 'NC': return 'Normal+Cancel'; case 'NLC': return 'Normal+Lock+Cancel';
      case 'P': return 'Purchased'; case 'A': return 'ALL'; case 'ALL': return 'ALL';
      case 'R': return 'Mark Refunded'; default: return s ?? 'Unknown';
    }
  }
}

// ─── TV Focus Button ───────────────────────────────────────────────────────
class _TVFocusButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _TVFocusButton({required this.label, required this.onTap});
  @override
  State<_TVFocusButton> createState() => _TVFocusButtonState();
}

class _TVFocusButtonState extends State<_TVFocusButton> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap(); return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 60,
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white : AppColors.appColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isFocused ? AppColors.appColor : Colors.white24, width: 2),
            boxShadow: _isFocused ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)] : [],
          ),
          child: Center(child: Text(widget.label,
            style: TextStyle(color: _isFocused ? AppColors.appColor : Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          )),
        ),
      ),
    );
  }
}

// ─── TV Focus Container (for video preview) ────────────────────────────────
class _TVFocusContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TVFocusContainer({required this.child, required this.onTap});
  @override
  State<_TVFocusContainer> createState() => _TVFocusContainerState();
}

class _TVFocusContainerState extends State<_TVFocusContainer> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap(); return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isFocused ? Colors.white : Colors.transparent, width: 3),
            boxShadow: _isFocused ? [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 12)] : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── TV Icon Button (AppBar) ───────────────────────────────────────────────
class _TVIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TVIconBtn({required this.icon, required this.onTap});
  @override
  State<_TVIconBtn> createState() => _TVIconBtnState();
}

class _TVIconBtnState extends State<_TVIconBtn> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap(); return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _isFocused ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}