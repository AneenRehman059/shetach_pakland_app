import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/billing/presentation/screens/user_files_screen.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/customer_portal/presentation/controllers/get_customer_portal_controller.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/billing/presentation/screens/payment_plan_detail_screen.dart';
import 'package:pakland/features/billing/presentation/screens/online_payments_screen.dart';

class CustomerPortalScreen extends StatefulWidget {
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

  Future<void> _refresh() async {
    await Future.wait([
      controller.fetchCustomerData(),
      _loadUserData(),
    ]);
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

  int _percent(double part, double whole) {
    if (whole <= 0) return 0;
    final p = (part / whole) * 100;
    return p.round().clamp(0, 100);
  }

  double _asDouble(String? value) => double.tryParse(value ?? '') ?? 0;

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => MainWrapper(initialIndex: 0));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState(context, isTV);
          }
          return isTV ? _buildTVLayout(context) : _buildMobileLayout(context);
        }),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isTV) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        isTV ? _buildTVAppBar(context) : _buildHeader(context, size),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/images/loading.json',
                  width: isTV ? 180 : 150,
                  height: isTV ? 180 : 150,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading your portal…',
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                    fontSize: isTV ? 20 : size.width * 0.033,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _headerHeight(Size size) => math.max(size.height * 0.20, size.width * 0.24);

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      height: _headerHeight(size),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, Color.lerp(AppColors.appColor, Colors.black, 0.28)!],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.25,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.03, bottom: size.width * 0.07),
                    child: _buildHeaderIconButton(
                      icon: Icons.arrow_back,
                      size: size,
                      onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: size.width * 0.07),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Customer Portal',
                            style: TextStyle(
                              fontSize: size.width * 0.054,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: size.height * 0.003),
                          Text(
                            'Your account at a glance',
                            style: TextStyle(
                              fontSize: size.width * 0.028,
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: size.width * 0.03, bottom: size.width * 0.07),
                    child: _buildHeaderIconButton(
                      icon: Icons.refresh_rounded,
                      size: size,
                      onPressed: _refresh,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Size size,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.022),
          child: Icon(icon, color: Colors.white, size: size.width * 0.055),
        ),
      ),
    );
  }

  Widget _sectionLabel({required String title, required IconData icon, required Size size}) {
    return Padding(
      padding: EdgeInsets.only(left: size.width * 0.02, bottom: size.height * 0.01),
      child: Row(
        children: [
          Icon(icon, size: size.width * 0.045, color: AppColors.appColor),
          SizedBox(width: size.width * 0.018),
          Text(
            title,
            style: TextStyle(
              fontSize: size.width * 0.036,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, String value, Size size, {bool isAddress = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.004),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.24,
            child: Text(
              label,
              style: TextStyle(
                fontSize: size.width * 0.032,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: size.width * 0.034,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: isAddress ? TextOverflow.visible : TextOverflow.ellipsis,
              maxLines: isAddress ? 3 : 1,
            ),
          ),
        ],
      ),
    );
  }

  static const double _kTabletRefHeight = 900;

  Widget _buildMobileLayout(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final bool isWide = screen.shortestSide >= 600;
    final bool twoCol = isWide && screen.width > screen.height;

    final double refH = isWide ? math.min(screen.height, _kTabletRefHeight) : screen.height;
    final double contentW = screen.width;
    final double cardW = twoCol ? contentW / 2 : contentW;

    final Size headerSize = isWide ? Size(math.min(screen.width, 600.0), refH) : screen;
    final double topPad = _headerHeight(headerSize) * 0.75;

    final double gap = isWide ? 16.0 : refH * 0.014;

    final bool landscapePhone = !isWide && screen.width > screen.height;
    final double availH = screen.height - topPad - bottomPadding - gap;
    final double needK = twoCol ? 1.2 : 1.7;
    final double designW =
    landscapePhone ? cardW : math.min(cardW, math.max(availH, 0) / needK);
    final size = Size(designW, refH);

    Widget cards() => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileCard(context, size),
        SizedBox(height: gap),
        _buildFileStatusCard(context, size),
        SizedBox(height: gap),
        _buildPaymentDetailsCard(context, size),
      ],
    );

    Widget twoColumns() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileCard(context, size),
              SizedBox(height: gap),
              _buildFileStatusCard(context, size),
            ],
          ),
        ),
        Expanded(child: _buildPaymentDetailsCard(context, size)),
      ],
    );

    return Stack(
      children: [
        _buildHeader(context, headerSize),
        Padding(
          padding: EdgeInsets.only(top: topPad),
          child: RefreshIndicator(
            color: AppColors.appColor,
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding + gap),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: contentW,
                          child: twoCol ? twoColumns() : cards(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, Size size) {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.038),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.88)],
        ),
        borderRadius: BorderRadius.circular(size.width * 0.045),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.135,
                height: size.width * 0.135,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(Icons.person_rounded, color: AppColors.appColor, size: size.width * 0.075),
              ),
              SizedBox(width: size.width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.value.isNotEmpty ? userName.value : 'Customer',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: size.width * 0.048,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: size.height * 0.007),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.028,
                        vertical: size.height * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_copy_outlined, size: size.width * 0.032, color: Colors.white),
                          SizedBox(width: size.width * 0.014),
                          Text(
                            '${controller.customerObj.value?.totalFiles ?? 0} File(s)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: size.width * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.032, vertical: size.height * 0.005),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size.width * 0.035),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                _buildFormRow('CNIC', userId.value, size),
                Divider(height: size.height * 0.012, color: Colors.white.withOpacity(0.12)),
                _buildFormRow(
                  'Address',
                  _getCombinedAddress(
                    controller.customerObj.value?.address1 ?? "",
                    controller.customerObj.value?.address2 ?? "",
                    controller.customerObj.value?.address3 ?? "",
                  ),
                  size,
                  isAddress: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildFileStatusCard(BuildContext context, Size size) {
    const ink = Color(0xFF1B2733);
    const muted = Color(0xFF6B7785);
    final w = size.width;

    return Obx(() {
      final obj = controller.customerObj.value;
      final total = obj?.total ?? 0;
      final active = obj?.active ?? 0;
      final locked = obj?.reserve ?? 0;
      final canceled = obj?.canceled ?? 0;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: w * 0.04),
        padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.035, w * 0.04, w * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.05),
          border: Border.all(color: const Color(0xFFE8ECF4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(w * 0.022),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                  child: Icon(Icons.folder_copy_outlined, size: w * 0.048, color: AppColors.appColor),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Units/Files Detail',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: w * 0.04, color: ink),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.appColor,
                  borderRadius: BorderRadius.circular(w * 0.05),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(w * 0.05),
                    onTap: () => Get.to(() => PayOnlineScreen(brnCode: '', brnName: '')),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.032, vertical: w * 0.02),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: w * 0.03,
                            ),
                          ),
                          SizedBox(width: w * 0.01),
                          Icon(Icons.arrow_forward_rounded, size: w * 0.038, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: w * 0.035),

            _buildStatusDistributionBar(
              w: w,
              active: active,
              locked: locked,
              canceled: canceled,
            ),
            SizedBox(height: w * 0.035),

            Row(
              children: [
                Expanded(
                  child: _buildStatusTile(
                    w: w,
                    label: 'Total',
                    value: total,
                    total: total,
                    color: const Color(0xFF1E4D60),
                    icon: Icons.layers_rounded,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: _buildStatusTile(
                    w: w,
                    label: 'Active',
                    value: active,
                    total: total,
                    color: const Color(0xFF2E7D32),
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: w * 0.03),
            Row(
              children: [
                Expanded(
                  child: _buildStatusTile(
                    w: w,
                    label: 'Locked',
                    value: locked,
                    total: total,
                    color: const Color(0xFFD08A00),
                    icon: Icons.lock_rounded,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: _buildStatusTile(
                    w: w,
                    label: 'Canceled',
                    value: canceled,
                    total: total,
                    color: const Color(0xFFD32F2F),
                    icon: Icons.cancel_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusDistributionBar({
    required double w,
    required int active,
    required int locked,
    required int canceled,
  }) {
    final sum = active + locked + canceled;
    final radius = BorderRadius.circular(20);

    if (sum <= 0) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(height: w * 0.02, color: const Color(0xFFE8ECF4)),
      );
    }

    Widget seg(int value, Color color) => value <= 0
        ? const SizedBox.shrink()
        : Expanded(flex: value, child: Container(color: color));

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: w * 0.02,
        child: Row(
          children: [
            seg(active, const Color(0xFF2E7D32)),
            seg(locked, const Color(0xFFD08A00)),
            seg(canceled, const Color(0xFFD32F2F)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile({
    required double w,
    required String label,
    required int value,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    final share = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.028),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.095,
            height: w * 0.095,
            decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle),
            child: Icon(icon, size: w * 0.05, color: color),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: w * 0.055,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2733),
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: w * 0.03,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7785),
                  ),
                ),
                SizedBox(height: w * 0.012),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: w * 0.01,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(BuildContext context, Size size) {
    return Obx(() {
      final totalAmount = _asDouble(controller.customerObj.value?.totalAmount?.toString());
      final totalReceived = _asDouble(controller.customerObj.value?.totalReceived?.toString());
      final balance = _asDouble(controller.customerObj.value?.totalOS?.toString());
      final overdue = _asDouble(controller.customerObj.value?.totalOverdue?.toString());
      final receivedPercent = _percent(totalReceived, totalAmount);

      return Container(
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.86)],
          ),
          borderRadius: BorderRadius.circular(size.width * 0.045),
          boxShadow: [
            BoxShadow(color: AppColors.appColor.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(size.width * 0.022),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                  child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: size.width * 0.05),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Details',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: size.width * 0.04, color: Colors.white)),
                      Text('Your account financial summary',
                          style: TextStyle(fontSize: size.width * 0.028, color: Colors.white70, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.014),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount Received',
                    style: TextStyle(color: Colors.white70, fontSize: size.width * 0.03, fontWeight: FontWeight.w600)),
                Text('$receivedPercent%',
                    style: TextStyle(color: Colors.white, fontSize: size.width * 0.034, fontWeight: FontWeight.w800)),
              ],
            ),
            SizedBox(height: size.height * 0.008),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(height: size.height * 0.012, color: Colors.white.withOpacity(0.16)),
                  FractionallySizedBox(
                    widthFactor: receivedPercent / 100,
                    child: Container(
                      height: size.height * 0.012,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.75)]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.014),

            Row(
              children: [
                Expanded(
                  child: _buildPaymentStat(
                    icon: Icons.request_quote_outlined,
                    label: 'Total Amount',
                    value: formatNumber(totalAmount.toStringAsFixed(0)),
                    size: size,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: _buildPaymentStat(
                    icon: Icons.task_alt_rounded,
                    label: 'Received',
                    value: formatNumber(totalReceived.toStringAsFixed(0)),
                    size: size,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentStat(
                    icon: Icons.account_balance_outlined,
                    label: 'Balance',
                    value: formatNumber(balance.toStringAsFixed(0)),
                    size: size,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: _buildPaymentStat(
                    icon: Icons.warning_amber_rounded,
                    label: 'OverDue',
                    value: formatNumber(overdue.toStringAsFixed(0)),
                    size: size,
                    isWarning: overdue > 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentStat({
    required IconData icon,
    required String label,
    required String value,
    required Size size,
    bool isWarning = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.014),
      decoration: BoxDecoration(
        color: isWarning ? null : Colors.white.withOpacity(0.12),
        gradient: isWarning
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        )
            : null,
        boxShadow: isWarning
            ? [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
        borderRadius: BorderRadius.circular(size.width * 0.035),
        border: Border.all(color: isWarning ? const Color(0xFFFFCDD2).withOpacity(0.55) : Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.018),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isWarning ? 0.22 : 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: size.width * 0.04, color: Colors.white),
          ),
          SizedBox(width: size.width * 0.022),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: isWarning ? Colors.white : Colors.white70, fontSize: size.width * 0.026, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rs. $value',
                    style: TextStyle(color: Colors.white, fontSize: size.width * 0.032, fontWeight: FontWeight.w800),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTVAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, Color.lerp(AppColors.appColor, Colors.black, 0.28)!],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          _TVIconButton(icon: Icons.arrow_back, onTap: () => Get.offAll(() => MainWrapper(initialIndex: 0))),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Customer Portal',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Your account at a glance',
                  style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _TVIconButton(icon: Icons.refresh_rounded, onTap: _refresh),
        ]),
      ),
    );
  }

  Widget _buildTVLayout(BuildContext context) {
    return Column(
      children: [
        _buildTVAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Obx(() => Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildProfileCardTV(context)),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: _buildFileStatusCardTV(context)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPaymentDetailsCardTV(context),
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCardTV(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.88)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.person_rounded, color: AppColors.appColor, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.value.isNotEmpty ? userName.value : 'Customer',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: 0.2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.folder_copy_outlined, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('${controller.customerObj.value?.totalFiles ?? 0} File(s)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ]),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(children: [
            _buildFormRowTV('CNIC', userId.value),
            Divider(height: 16, color: Colors.white.withOpacity(0.12)),
            _buildFormRowTV(
              'Address',
              _getCombinedAddress(
                controller.customerObj.value?.address1 ?? "",
                controller.customerObj.value?.address2 ?? "",
                controller.customerObj.value?.address3 ?? "",
              ),
              isAddress: true,
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFormRowTV(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600))),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            overflow: isAddress ? TextOverflow.visible : TextOverflow.ellipsis,
            maxLines: isAddress ? 3 : 1,
          ),
        ),
      ]),
    );
  }

  Widget _buildFileStatusCardTV(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Icon(Icons.dashboard_customize_outlined, size: 18, color: Colors.black87),
              SizedBox(width: 8),
              Text('File Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
            ]),
          ),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(child: _buildStatusItem("Total", controller.customerObj.value?.total.toString() ?? "0", context)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusItem("Active", controller.customerObj.value?.active.toString() ?? "0", context)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusItem("Locked", controller.customerObj.value?.reserve.toString() ?? "0", context)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusItem("Canceled", controller.customerObj.value?.canceled.toString() ?? "0", context)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _TVActionButton(
              label: 'View Details',
              icon: Icons.arrow_forward_rounded,
              isPrimary: true,
              onTap: () => Get.to(() => PayOnlineScreen(brnCode: '', brnName: '')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCardTV(BuildContext context) {
    final totalAmount = _asDouble(controller.customerObj.value?.totalAmount?.toString());
    final totalReceived = _asDouble(controller.customerObj.value?.totalReceived?.toString());
    final balance = _asDouble(controller.customerObj.value?.totalOS?.toString());
    final overdue = _asDouble(controller.customerObj.value?.totalOverdue?.toString());
    final receivedPercent = _percent(totalReceived, totalAmount);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.86)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white)),
                    Text('Your account financial summary',
                        style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text('$receivedPercent% Received',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(height: 10, color: Colors.white.withOpacity(0.16)),
                FractionallySizedBox(
                  widthFactor: receivedPercent / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.75)]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildPaymentStatTV(
                  icon: Icons.request_quote_outlined,
                  label: 'Total Amount',
                  value: formatNumber(totalAmount.toStringAsFixed(0)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPaymentStatTV(
                  icon: Icons.task_alt_rounded,
                  label: 'Received',
                  value: formatNumber(totalReceived.toStringAsFixed(0)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPaymentStatTV(
                  icon: Icons.account_balance_outlined,
                  label: 'Balance',
                  value: formatNumber(balance.toStringAsFixed(0)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildPaymentStatTV(
                  icon: Icons.warning_amber_rounded,
                  label: 'OverDue',
                  value: formatNumber(overdue.toStringAsFixed(0)),
                  isWarning: overdue > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatTV({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isWarning ? null : Colors.white.withOpacity(0.12),
        gradient: isWarning
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        )
            : null,
        boxShadow: isWarning
            ? [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isWarning ? const Color(0xFFFFCDD2).withOpacity(0.55) : Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isWarning ? 0.22 : 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: TextStyle(color: isWarning ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Rs. $value',
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }


  Widget _buildButton(
      String text, {
        required Size size,
        IconData? icon,
        bool isPrimary = true,
        bool fullWidth = false,
        VoidCallback? onPressed,
      }) {
    final borderRadius = BorderRadius.circular(size.width * 0.05);

    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.75)],
          ),
          boxShadow: [
            BoxShadow(color: AppColors.appColor.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.019, horizontal: size.width * 0.04),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: size.width * 0.05, color: Colors.white),
                    SizedBox(width: size.width * 0.02),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: size.width * 0.04,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.appColor.withOpacity(0.35), width: 1.3),
          ),
          padding: EdgeInsets.symmetric(vertical: size.height * 0.016, horizontal: size.width * 0.02),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.036, color: AppColors.appColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
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
              top: cardH * 0.1,
              left: 0,
              right: 0,
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
              top: 0,
              left: 0,
              child: SizedBox(
                height: cardH,
                width: cardW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: cardW * 0.65,
                      height: cardH * 0.30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(cardW * 0.15),
                          bottomRight: Radius.circular(cardW * 0.35),
                          topRight: Radius.circular(cardW * 0.15),
                        ),
                      ),
                      child: Center(
                          child: Text(value,
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

class _TVIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TVIconButton({required this.icon, required this.onTap});

  @override
  State<_TVIconButton> createState() => _TVIconButtonState();
}

class _TVIconButtonState extends State<_TVIconButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _isFocused ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _TVActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _TVActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = false,
  });

  @override
  State<_TVActionButton> createState() => _TVActionButtonState();
}

class _TVActionButtonState extends State<_TVActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final fgColor = widget.isPrimary ? Colors.white : (_isFocused ? Colors.white : AppColors.appColor);

    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.75)])
                : null,
            color: widget.isPrimary ? null : (_isFocused ? AppColors.appColor : Colors.white),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: _isFocused ? AppColors.appColor.withOpacity(0.5) : Colors.black.withOpacity(0.15),
                blurRadius: _isFocused ? 14 : 6,
                offset: const Offset(2, 2),
              )
            ],
            border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: TextStyle(fontWeight: FontWeight.bold, color: fgColor, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}