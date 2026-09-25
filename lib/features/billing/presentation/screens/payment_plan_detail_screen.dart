import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/billing/presentation/screens/online_payments_screen.dart';
import 'package:pakland/features/billing/presentation/screens/pay_now_screen.dart';
import 'package:pakland/features/billing/presentation/screens/user_files_screen.dart';
import 'package:pakland/features/billing/presentation/screens/view_bill_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/files_info_card_screen.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/billing/presentation/controllers/pay_online_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/customer_portal/presentation/screens/customer_portal_screen.dart';
import 'package:pakland/features/billing/presentation/screens/get_account_statement_screen.dart';
import 'package:pakland/features/billing/presentation/screens/get_recipt_statment_screen.dart';
import 'package:pakland/features/profile/data/models/client_detail_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PayOnlineScreen extends StatefulWidget {
  final String brnCode;
  final String brnName;
  const PayOnlineScreen({
    super.key,
    required this.brnCode,
    required this.brnName,
  });

  @override
  State<PayOnlineScreen> createState() => _PayOnlineScreenState();
}

class _PayOnlineScreenState extends State<PayOnlineScreen> {
  final _storage = const FlutterSecureStorage();
  String? userId;
  late final PayOnlineController controller;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PayOnlineController>()) {
      controller = Get.find<PayOnlineController>();
    } else {
      controller = Get.put(PayOnlineController());
    }
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await _storage.read(key: "user_id");
    if (id != null && id.isNotEmpty) {
      setState(() {
        userId = id;
      });

      controller.fetchClientDetails(
        username: id,
        brnCode: "000000",
        blockNo: 'a',
        plotNo: '2',
      );
    } else {
      showTopSnackBar(
          context,
          title: "Alert",
          "User ID not found",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning
      );
    }
  }

  Future<void> _launchYouTubeVideo() async {
    const url = 'https://www.youtube.com/watch?v=wu6E1jvm14k';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;
    final textScaleFactor = mediaQuery.textScaleFactor;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.appColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState(size, padding);
          }

          if (controller.clientDetailModel.value == null ||
              controller.clientDetailModel.value!.obj.clientDetailList == null ||
              controller.clientDetailModel.value!.obj.clientDetailList!.isEmpty) {
            return _buildNoDataState(size, padding);
          }

          return _buildContent(size, padding, textScaleFactor, mediaQuery);
        }),
      ),
    );
  }

  Widget _buildLoadingState(Size size, EdgeInsets padding) {
    return Stack(
      children: [
        _buildHeader(size, padding),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitWave(
                color: AppColors.appColor,
                size: size.width * 0.12,
              ),
              // SizedBox(height: size.height * 0.02),
              // Text(
              //   'Loading',
              //   style: TextStyle(
              //     color: AppColors.appColor,
              //     fontWeight: FontWeight.bold,
              //     fontSize: size.width * 0.045,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataState(Size size, EdgeInsets padding) {
    return Stack(
      children: [
        _buildHeader(size, padding),
        Center(
          child: Text(
            'No data found',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Size size, EdgeInsets padding, double textScaleFactor, MediaQueryData mediaQuery) {
    final clientDetails = controller.clientDetailModel.value!.obj.clientDetailList!;

    return Stack(
      children: [
        // Fixed Header
        _buildHeader(size, padding),

        // Scrollable Content
        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.22 - size.height * 0.1,
            bottom: padding.bottom + size.height * 0.02,
          ),
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: size.height * 0.01,
              bottom: padding.bottom + size.height * 0.02,
            ),
            itemCount: clientDetails.length,
            itemBuilder: (context, index) {
              final client = clientDetails[index];
              final isFirstItem = index == 0;

              return Column(
                children: [
                  Transform.translate(
                    offset: Offset(0, isFirstItem ? size.height * 0.01 : size.height * 0.025),
                    child: _buildProfileCard(client, size),
                  ),
                  Transform.translate(
                    offset: Offset(0, isFirstItem ? size.height * 0.018 : size.height * 0.035),
                    child: _buildInfoCards(client, size),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Transform.translate(
                    offset: Offset(0, isFirstItem ? 20 : 30),
                    child: _buildActionButtons(client, mediaQuery),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Transform.translate(
                    offset: Offset(0, isFirstItem ? size.height * 0.035 : size.height * 0.045),
                    child: _buildVideoPreview(size),
                  ),
                  SizedBox(height: size.height * 0.05),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size size, EdgeInsets padding) {
    return Container(
      height: size.height * 0.20,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: size.width * 0.02,bottom: size.width * 0.07),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: size.width * 0.07,
                  ),
                  onPressed: () => Get.to(CustomerPortalScreen()),
                ),
              ),
            ),
            // Center Title
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom:size.width * 0.07),
                child: Text(
                  'Pay Online',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: IconButton(
                  icon: Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Get.offAll(() => MainWrapper(initialIndex: 0));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileCard(ClientDetail client, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.appColor,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        border: Border.all(color: AppColors.whiteBg, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Container(
                width: size.width * 0.14,
                height: size.width * 0.14,
                child: Image.asset(ImageConstant.logo),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    client.brnName ?? widget.brnName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.045,
                      color: AppColors.whiteBg,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
      ],
          ),
          SizedBox(height: size.height * 0.01),
          _buildFormRow('Booking ID / Reg#', client.registrationNo ?? '', size),
          _buildFormRow('File Status:', _getRegistrationStatusText(client.registrationStatus), size),
          _buildFormRow('Plot / Unit Size:', client.paymentCode ?? '', size),
          _buildFormRow('Customer Name:', client.memberName ?? '', size),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, String value, Size size) => Padding(
    padding: EdgeInsets.symmetric(vertical: size.height * 0.005),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size.width * 0.3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: AppColors.whiteBg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: size.height * 0.035,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(size.width * 0.05),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildInfoCards(ClientDetail client, Size size) {
    final totalOutstanding = _calculateTotalOutstanding(client);
    final totalOverDue = _calculateTotalOverDue(client);
    final totalReceived = _calculateTotalReceived(client);
    final totalAmount = double.tryParse(client.totDueAmt) ?? 0;

    final totalReceivedPercent = _calculateTotalReceivedPercent(client, totalReceived);
    final totalOSPercent = _calculateTotalOSPercent(client, totalOutstanding);
    final totalOverDuePercent = _calculateTotalOverDuePercent(client, totalOverDue);
    final totalPercent = 100;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(size.width * 0.03),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InfoCard(
            title: 'Total Price',
            amount: 'Rs. ${_formatAmount(totalAmount)}/-',
            percent: totalPercent,
            size: size,
          ),
          InfoCard(
            title: 'Total Received',
            amount: 'Rs.${_formatAmount(totalReceived)}/-',
            percent: totalReceivedPercent,
            size: size,
          ),
          InfoCard(
            title: 'Total Outstanding',
            amount: 'Rs.${_formatAmount(totalOutstanding)}/-',
            percent: totalOSPercent,
            size: size,
          ),
          InfoCard(
            title: 'Total Overdue',
            amount: 'Rs.${_formatAmount(totalOverDue)}/-',
            percent: totalOverDuePercent,
            size: size,
          ),
        ],
      ),
    );
  }

  // Calculate actual amounts
  double _calculateTotalOutstanding(ClientDetail client) {
    try {
      final totDueAmt = double.tryParse(client.totDueAmt) ?? 0;
      final totRecievedAmt = double.tryParse(client.totRecievedAmt) ?? 0;
      final totRebatAmt = double.tryParse(client.totRebatAmt) ?? 0;

      return totDueAmt - totRecievedAmt - totRebatAmt;
    } catch (e) {
      return 0;
    }
  }

  double _calculateTotalOverDue(ClientDetail client) {
    try {
      // Use the overDueAmount from the model (integer field)
      return client.overDueAmount.toDouble();
    } catch (e) {
      return 0;
    }
  }

  double _calculateTotalReceived(ClientDetail client) {
    try {
      // Use the amountReceived from the model (integer field)
      final totRecievedAmt = double.tryParse(client.totRecievedAmt) ?? 0;
      return totRecievedAmt;
    } catch (e) {
      return 0;
    }
  }

  // Update percentage calculation methods to use the actual amounts
  int _calculateTotalReceivedPercent(ClientDetail client, double totalReceived) {
    try {
      final netPrice = client.netPrice.toDouble();
      final osAmount = client.osAmount.toDouble();

      if (netPrice + osAmount == 0) return 0;

      final percent = (totalReceived / (netPrice + osAmount)) * 100;
      return percent.round().clamp(0, 100);
    } catch (e) {
      return 0;
    }
  }

  int _calculateTotalOSPercent(ClientDetail client, double totalOutstanding) {
    try {
      final dueAmt = double.tryParse(client.totDueAmt) ?? 0;

      if (dueAmt == 0) return 0;

      final percent = (totalOutstanding / dueAmt) * 100;
      return percent.round().clamp(0, 100);
    } catch (e) {
      return 0;
    }
  }

  int _calculateTotalOverDuePercent(ClientDetail client, double totalOverDue) {
    try {
      final dueTillToday = double.tryParse(client.dueTillToday) ?? 0;

      if (dueTillToday == 0) return 0;

      final percent = (totalOverDue / dueTillToday) * 100;
      return percent.round().clamp(0, 100);
    } catch (e) {
      return 0;
    }
  }

  // Format amount with commas for better readability
  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Widget _buildActionButtons(ClientDetail client, MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final isSmallScreen = size.width < 360;

    // Get the CompanyController to access is_show_close_status
    final companyController = Get.find<CompanyController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        children: [
          // First row
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'View Statement',
                  size: size,
                  onPressed: () {
                    // Check if navigation is allowed
                    if (_canNavigateToStatement(client, companyController)) {
                      Get.to(() => AccountStatementScreen(
                        registrationNo: client.registrationNo ?? '',
                        brnCode: client.brnCode ?? '',
                        plotType: client.plotType ?? 'Normal',
                        idNo: client.cnic ?? '',
                      ));
                    } else {
                      // Show alert message
                      _showCloseStatusAlert(context, client);
                    }
                  },
                ),
              ),
              SizedBox(width: isSmallScreen ? size.width * 0.03 : size.width * 0.04),
              Expanded(
                child: _buildButton(
                  'View Receipt',
                  size: size,
                  onPressed: () {
                    Get.to(() => ReceiptTableView(
                      registrationNo: client.registrationNo ?? '',
                      brnCode: client.brnCode ?? '',
                      plotType: client.plotType ?? 'Normal',
                      memberName: client.memberName ?? '',
                      idNo: client.cnic,
                    ));
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),

          // Second row - Pay Now button centered
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: isSmallScreen ? 3 : 2,
                child: _buildButton(
                  'Pay Now',
                  size: size,
                  onPressed: () {
                    final totalOutstanding = _calculateTotalOutstanding(client);
                    final totalOverDue = _calculateTotalOverDue(client);

                    Get.to(() => PaymentScreen(
                      registrationNo: client.registrationNo ?? '',
                      paymentCode: client.paymentCode ?? '',
                      brnCode: client.brnCode ?? '',
                      brnName: client.brnName ?? '',
                      memberName: client.memberName ?? '',
                      overDueAmount: totalOverDue,
                      totalOutstanding: totalOutstanding,
                      formattedTotalOutstanding: _formatAmount(totalOutstanding),
                      formattedTotalOverDue: _formatAmount(totalOverDue),
                      clientId: client.cnic,
                    ));
                  },
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  bool _canNavigateToStatement(ClientDetail client, CompanyController companyController) {
    if (!companyController.showCloseStatus) {
      return true;
    }

    final status = client.registrationStatus?.toUpperCase() ?? '';
    return status == 'N';
  }
  void _showCloseStatusAlert(BuildContext context, ClientDetail client) {
    final companyController = Get.find<CompanyController>();
    final alterMessage = companyController.alterMessage.value.isNotEmpty
        ? companyController.alterMessage.value
        : 'This file is canceled/locked. Please contact support department for more details.';

    showTopSnackBar(
      context,
      title: "Access Denied",
      "File Status: ${_getRegistrationStatusText(client.registrationStatus)}. $alterMessage",
      Colors.red.withOpacity(0.7),
      icon: Icons.warning,
    );
  }

  Widget _buildButton(String text, {required Size size, VoidCallback? onPressed}) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.appColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.08),
      ),
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.02,
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.whiteBg,
        fontWeight: FontWeight.bold,
        fontSize: size.width * 0.04,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _buildVideoPreview(Size size) => Padding(
    padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
    child: GestureDetector(
      onTap: _launchYouTubeVideo,
      child: Container(
        height: size.height * 0.22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.03),
          color: Colors.grey[200],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              child: Image.asset(
                ImageConstant.she,
                fit: BoxFit.fill,
                width: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              padding: EdgeInsets.all(size.width * 0.04),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: size.width * 0.1,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _getRegistrationStatusText(String? statusCode) {
    switch (statusCode?.toUpperCase()) {
      case 'N':
        return 'Active';
      case 'L':
        return 'Locked';
      case 'C':
        return 'Cancelled';
      case 'D':
        return 'Division';
      case 'F':
        return 'Refunded';
      case 'G':
        return 'Amalgamation';
      case 'M':
        return 'Merged';
      case 'NC':
        return 'Normal+Cancel';
      case 'NLC':
        return 'Normal+Lock+Cancel';
      case 'P':
        return 'Purchased';
      case 'A':
        return 'ALL';
      case 'ALL':
        return 'ALL';
      case 'R':
        return 'Mark Refunded';
      default:
        return statusCode ?? 'Unknown';
    }
  }
}