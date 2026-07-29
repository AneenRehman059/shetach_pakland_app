import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pakland/bottom_app_bar/bottom_app_bar.dart';
import 'package:pakland/user_files_screen.dart';
import '../../colors.dart';
import '../../controllers/get_customer_portal_controller.dart';
import '../../function/screen_helper.dart';
import '../../payment_plan_detail_screen.dart';
import 'online_payments_screen.dart';class CustomerPortalScreen extends StatefulWidget {
  @override
  State<CustomerPortalScreen> createState() => _CustomerPortalScreenState();
}

class _CustomerPortalScreenState extends State<CustomerPortalScreen> {
  final controller = Get.put(CustomerPortalController());
  final _storage = const FlutterSecureStorage();

  final userId = ''.obs;
  final userName = ''.obs;
  final userAddress = ''.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchCustomerData();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final id = await _storage.read(key: "user_id") ?? '';
      final name = await _storage.read(key: "user_name") ?? '';
      final address = await _storage.read(key: "address") ?? '';
      userId.value = id;
      userName.value = name;
      userAddress.value = address;
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  String formatNumber(String? number) {
    if (number == null || number.isEmpty) return "0";
    try {
      final value = double.tryParse(number) ?? 0;
      return NumberFormat("#,##0").format(value);
    } catch (e) {
      return number;
    }
  }

  String _getCombinedAddress(String a1, String a2, String a3) {
    return [a1, a2, a3].where((s) => s.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => MainWrapper(initialIndex: 0));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Customer Portal',
              style: TextStyle(color: Colors.white, fontSize: isTV ? 22 : 16)),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: AppColors.whiteBg),
          toolbarHeight: isTV ? 70 : kToolbarHeight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: isTV ? 30 : 24),
            onPressed: () => Get.offAll(MainWrapper()),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(color: AppColors.appColor, size: 50.0),
                  Text('Loading', style: TextStyle(color: AppColors.appColor)),
                ],
              ),
            );
          }
          return isTV ? _buildTVLayout(context) : _buildMobileLayout(context);
        }),
      ),
    );
  }

  // ─────────────────────────────────────────
  // MOBILE LAYOUT — original code same as before
  // ─────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;

    final headerHeight = availableHeight * 0.10;
    final personalInfoHeight = availableHeight * 0.24;
    final fileStatusHeight = availableHeight * 0.37;
    final paymentDetailsHeight = availableHeight * 0.23;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight),
        child: Column(
          children: [
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                color: AppColors.appColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),

            // Personal Info
            Transform.translate(
              offset: Offset(0, -headerHeight * 0.8),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: personalInfoHeight,
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Personal Info"),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoRow("Name", userName.value, personalInfoHeight),
                            _buildInfoRow("CNIC", userId.value, personalInfoHeight),
                            _buildInfoRow("Total Files",
                                controller.customerObj.value?.totalFiles.toString() ?? "0",
                                personalInfoHeight),
                            _buildInfoRow("Address",
                                _getCombinedAddress(
                                  controller.customerObj.value?.address1 ?? "",
                                  controller.customerObj.value?.address2 ?? "",
                                  controller.customerObj.value?.address3 ?? "",
                                ),
                                personalInfoHeight),
                          ],
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // File Status — original mobile layout
            Transform.translate(
              offset: Offset(0, -headerHeight * 0.6),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: fileStatusHeight,
                decoration: _whiteCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02,
                        top: MediaQuery.of(context).size.width * 0.02,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("File Status",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.appColor,
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.04,
                          right: MediaQuery.of(context).size.width * 0.04,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final itemW = (constraints.maxWidth - constraints.maxWidth * 0.18) / 2;

                            return Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: itemW,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: constraints.maxHeight * 0.04,
                                            right: constraints.maxWidth * 0.02,
                                            bottom: constraints.maxHeight * 0.02,
                                          ),
                                          child: _buildStatusItem("Total",
                                              controller.customerObj.value?.total.toString() ?? "0",
                                              context),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemW,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: constraints.maxHeight * 0.04,
                                            left: constraints.maxWidth * 0.02,
                                            bottom: constraints.maxHeight * 0.02,
                                          ),
                                          child: _buildStatusItem("Active",
                                              controller.customerObj.value?.active.toString() ?? "0",
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: itemW,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: constraints.maxHeight * 0.04,
                                            right: constraints.maxWidth * 0.02,
                                            bottom: constraints.maxHeight * 0.02,
                                          ),
                                          child: _buildStatusItem("Locked",
                                              controller.customerObj.value?.reserve.toString() ?? "0",
                                              context),
                                        ),
                                      ),
                                      SizedBox(
                                        width: itemW,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: constraints.maxHeight * 0.04,
                                            left: constraints.maxWidth * 0.02,
                                            bottom: constraints.maxHeight * 0.02,
                                          ),
                                          child: _buildStatusItem("Canceled",
                                              controller.customerObj.value?.canceled.toString() ?? "0",
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.appColor,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () => Get.to(PayOnlineScreen(brnCode: '', brnName: '')),
                          child: Padding(
                            padding: EdgeInsets.only(right: 15, bottom: 5, top: 5, left: 15),
                            child: Text('Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 6,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Payment Details
            Transform.translate(
              offset: Offset(0, -headerHeight * 0.5),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                height: paymentDetailsHeight,
                decoration: _cardDecoration(color: AppColors.appColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Payment Details"),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPaymentInfoRow("Total Amount",
                                formatNumber(controller.customerObj.value?.totalAmount.toString()),
                                paymentDetailsHeight),
                            _buildPaymentInfoRow("Total Received",
                                formatNumber(controller.customerObj.value?.totalReceived.toString()),
                                paymentDetailsHeight),
                            _buildPaymentInfoRow("Balance Amount",
                                formatNumber(controller.customerObj.value?.totalOS.toString()),
                                paymentDetailsHeight),
                            _buildPaymentInfoRow("Total OverDue",
                                formatNumber(controller.customerObj.value?.totalOverdue.toString()),
                                paymentDetailsHeight,
                                valueColor: Colors.white,
                                textColor: Colors.black),
                          ],
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // TV LAYOUT — side by side
  // ─────────────────────────────────────────
  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.025),
      child: Obx(() => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader("Personal Info", fontSize: 18),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTVInfoRow("Name", userName.value),
                            SizedBox(height: 12),
                            _buildTVInfoRow("CNIC", userId.value),
                            SizedBox(height: 12),
                            _buildTVInfoRow("Total Files",
                                controller.customerObj.value?.totalFiles.toString() ?? "0"),
                            SizedBox(height: 12),
                            _buildTVInfoRow("Address",
                                _getCombinedAddress(
                                  controller.customerObj.value?.address1 ?? "",
                                  controller.customerObj.value?.address2 ?? "",
                                  controller.customerObj.value?.address3 ?? "",
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.02),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: _whiteCardDecoration(),
                  child: _buildTVFileStatus(context),
                ),
              ),
            ],
          ),
          SizedBox(height: size.width * 0.02),
          Container(
            decoration: _cardDecoration(color: AppColors.appColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader("Payment Details", fontSize: 18),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildTVPaymentRow("Total Amount",
                          formatNumber(controller.customerObj.value?.totalAmount.toString()))),
                      SizedBox(width: 16),
                      Expanded(child: _buildTVPaymentRow("Total Received",
                          formatNumber(controller.customerObj.value?.totalReceived.toString()))),
                      SizedBox(width: 16),
                      Expanded(child: _buildTVPaymentRow("Balance Amount",
                          formatNumber(controller.customerObj.value?.totalOS.toString()))),
                      SizedBox(width: 16),
                      Expanded(child: _buildTVPaymentRow("Total OverDue",
                          formatNumber(controller.customerObj.value?.totalOverdue.toString()),
                          valueColor: Colors.white,
                          textColor: Colors.red[900]!)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTVFileStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12, top: 12),
          child: Text("File Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.appColor)),
        ),
        Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: _buildStatusItem("Total",
                    controller.customerObj.value?.total.toString() ?? "0", context)),
                SizedBox(width: 8),
                Expanded(child: _buildStatusItem("Active",
                    controller.customerObj.value?.active.toString() ?? "0", context)),
                SizedBox(width: 8),
                Expanded(child: _buildStatusItem("Locked",
                    controller.customerObj.value?.reserve.toString() ?? "0", context)),
                SizedBox(width: 8),
                Expanded(child: _buildStatusItem("Canceled",
                    controller.customerObj.value?.canceled.toString() ?? "0", context)),
              ],
            ),
          ),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: _TVDetailsButton(
              onTap: () => Get.to(PayOnlineScreen(brnCode: '', brnName: '')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTVInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.whiteBg, borderRadius: BorderRadius.circular(20)),
            child: Text(value,
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTVPaymentRow(String label, String value, {Color? valueColor, Color? textColor}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: valueColor ?? AppColors.whiteBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: valueColor != null ? Colors.black54 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: textColor ?? AppColors.appColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Mobile helpers — original
  Widget _buildInfoRow(String label, String value, double containerHeight) {
    final isAddress = label == "Address";
    final rowHeight = containerHeight * 0.15;
    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
            ),
          ),
          Expanded(
            child: Container(
              height: rowHeight,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.whiteBg),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: isAddress
                    ? SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Text(value,
                        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)))
                    : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(String label, String value, double containerHeight,
      {Color? valueColor, Color? textColor}) {
    final rowHeight = containerHeight * 0.18;
    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: valueColor ?? AppColors.whiteBg),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(value,
                      style: TextStyle(
                          color: textColor ?? Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.appColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.whiteBg, strokeAlign: 1),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.whiteBg, width: 1),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
    );
  }

  Widget _sectionHeader(String title, {double fontSize = 14}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.appColor.withOpacity(0.8),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Text(title,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildStatusItem(String label, String value, BuildContext context) {
    List<Color> gradientColors;
    IconData icon;
    Color curveColor;

    switch (label) {
      case "Total":
        gradientColors = [Color(0xFF006064), Color(0xFF4DD0E1)];
        icon = Icons.list_alt_rounded;
        curveColor = Color(0xFF006064);
        break;
      case "Active":
        gradientColors = [Color(0xFF2E7D32), Color(0xFF66BB6A)];
        icon = Icons.check_circle_outline_rounded;
        curveColor = Color(0xFF2E7D32);
        break;
      case "Locked":
        gradientColors = [Color(0xFFB28704), Color(0xFFFFC857)];
        icon = Icons.lock_outline_rounded;
        curveColor = Color(0xFFB28704);
        break;
      case "Canceled":
        gradientColors = [Color(0xFFD32F2F), Color(0xFFFF6B6B)];
        icon = Icons.cancel_outlined;
        curveColor = Color(0xFFD32F2F);
        break;
      default:
        gradientColors = [Color(0xFF1565C0), Color(0xFF4A90D9)];
        icon = Icons.info_outline;
        curveColor = Color(0xFF1565C0);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final cardW = constraints.maxWidth;
      final cardH = constraints.maxHeight.isInfinite ? 120.0 : constraints.maxHeight;

      return SizedBox(
        height: cardH,
        child: Stack(
          children: [
            Positioned(
              top: cardH * 0.1, left: 0, right: 0,
              child: Container(
                height: cardH * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(cardW * 0.15),
                    topLeft: Radius.circular(cardW * 0.15),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 7, offset: Offset(0, 10))],
                ),
                child: Row(children: [Container(height: 90, width: 30, color: curveColor)]),
              ),
            ),
            Positioned(
              top: 0, left: 0,
              child: SizedBox(
                height: cardH, width: cardW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: cardW * 0.65, height: cardH * 0.30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(cardW * 0.15),
                          bottomRight: Radius.circular(cardW * 0.35),
                          topRight: Radius.circular(cardW * 0.15),
                        ),
                      ),
                      child: Center(child: Text(value,
                          style: TextStyle(color: Colors.white, fontSize: cardW * 0.12, fontWeight: FontWeight.bold))),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cardW * 0.15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 7, offset: Offset(0, 10))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: cardW * 0.15, color: gradientColors[0]),
                            SizedBox(height: 6),
                            Text(label, style: TextStyle(fontSize: cardW * 0.09, fontWeight: FontWeight.w600, color: gradientColors[0])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// TV Details Button with focus
class _TVDetailsButton extends StatefulWidget {
  final VoidCallback onTap;
  const _TVDetailsButton({required this.onTap});

  @override
  State<_TVDetailsButton> createState() => _TVDetailsButtonState();
}

class _TVDetailsButtonState extends State<_TVDetailsButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
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
          duration: Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: _isFocused ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.6),
                blurRadius: _isFocused ? 12 : 6,
                offset: Offset(2, 2),
              )
            ],
            border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
          ),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          child: Text('Details',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

