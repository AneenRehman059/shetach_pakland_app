import 'package:flutter/material.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pakland/features/billing/presentation/screens/show_receipt_attachment_screen.dart';
import 'package:pakland/features/billing/presentation/screens/statement_screen.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/billing/presentation/controllers/account_receipt_controller.dart';
import 'package:pakland/features/billing/presentation/controllers/get_account_statement_controller.dart';
import 'package:pakland/features/billing/data/models/receipt_model.dart';

class ReceiptTableView extends StatefulWidget {
  final String registrationNo;
  final String brnCode;
  final String plotType;
  final String memberName;
  final String idNo;

  const ReceiptTableView({
    super.key,
    required this.registrationNo,
    required this.brnCode,
    required this.plotType,
    required this.memberName,
    required this.idNo,
  });

  @override
  State<ReceiptTableView> createState() => _ReceiptTableViewState();
}

class _ReceiptTableViewState extends State<ReceiptTableView> {
  late List<Receipt> _receipts;
  final Set<int> _loadingReceipts = {};

  static const Color _ink = Color(0xFF1F2430);
  static const Color _slate = Color(0xFF64748B);
  static const Color _hairline = Color(0xFFE4E7EC);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _canvas = Color(0xFFF7F8FA);
  static const Color _rowAlt = Color(0xFFFAFBFC);

  bool get isTablet {
    final shortestSide = MediaQuery.of(Get.context!).size.shortestSide;
    return ScreenHelper.isTablet(context);
  }

  Future<void> _viewReceiptStatement(Receipt receipt) async {
    setState(() {
      _loadingReceipts.add(receipt.receiptNo);
    });

    try {
      final statementController = Get.put(AccountStatementController());

      await statementController.fetchReceiptImage(
        brnCode: receipt.brnCode.toString(),
        receiptNo: receipt.receiptNo.toString(),
      );

      if (statementController.receiptImageError.value.isNotEmpty) {
        showTopSnackBar(
          context,
          'No attachment found for this receipt.',
          Colors.red.withOpacity(0.7),
          title: 'Attachment Unavailable',
          icon: Icons.error_outline,
        );
        return;
      }

      if (statementController.receiptImageUrl.value.isNotEmpty) {
        Get.to(() => ReceiptImageScreen(
          imageUrl: statementController.receiptImageUrl.value,
          receiptNo: receipt.receiptNo.toString(),
        ));
      }
    } finally {
      setState(() {
        _loadingReceipts.remove(receipt.receiptNo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AccountReciptController(
        registrationNo: widget.registrationNo,
        brnCode: widget.brnCode,
      ),
    );
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _canvas,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context, size);
        }

        _receipts = controller.receiptList;

        return Stack(
          children: [
            _buildHeader(context, size),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.15),
              child: _receipts.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                padding: const EdgeInsets.only(bottom: 55),
                child: _buildReceiptTable(_receipts),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context, Size size) {
    return Column(
      children: [
        _buildHeader(context, size),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  ImageConstant.lottieAnim,
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading receipts…',
                  style: TextStyle(
                    color: _slate,
                    fontWeight: FontWeight.w500,
                    fontSize: size.width * 0.033,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.20,
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
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: size.width * 0.07),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Receipts',
                          style: TextStyle(
                            fontSize: size.width * 0.054,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: size.height * 0.003),
                        Text(
                          'Your payment history',
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: size.width * 0.03, bottom: size.width * 0.07),
                    child: _buildHeaderIconButton(
                      icon: Icons.home_rounded,
                      size: size,
                      onPressed: () {
                        Get.offAll(() => MainWrapper(initialIndex: 0));
                      },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _canvas,
              shape: BoxShape.circle,
              border: Border.all(color: _hairline, width: 1),
            ),
            child: Icon(Icons.receipt_long_outlined, size: 28, color: _slate),
          ),
          const SizedBox(height: 14),
          Text(
            "No receipts available",
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: _slate),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTable(List<Receipt> receipts) {
    final double grandTotal = receipts.fold(0.0, (sum, r) => sum + r.paidAmt);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final useTabletLayout = isTablet;

    Map<int, TableColumnWidth> getColumnWidths() {
      if (useTabletLayout) {
        if (isPortrait) {
          return {
            0: const FixedColumnWidth(130),
            1: const FixedColumnWidth(140),
            2: const FixedColumnWidth(130),
            3: const FixedColumnWidth(150),
            4: const FixedColumnWidth(90),
          };
        } else {
          return {
            0: const FlexColumnWidth(1.2),
            1: const FlexColumnWidth(1.4),
            2: const FlexColumnWidth(1.2),
            3: const FlexColumnWidth(1.4),
            4: const FlexColumnWidth(0.8),
          };
        }
      } else {
        if (isPortrait) {
          return {
            0: const FixedColumnWidth(118),
            1: const FixedColumnWidth(122),
            2: const FixedColumnWidth(105),
            3: const FixedColumnWidth(125),
            4: const FixedColumnWidth(75),
          };
        } else {
          return {
            0: const FlexColumnWidth(0.9),
            1: const FlexColumnWidth(1.0),
            2: const FlexColumnWidth(0.9),
            3: const FlexColumnWidth(1.1),
            4: const FlexColumnWidth(0.6),
          };
        }
      }
    }

    Widget buildCompleteTable() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1),
            verticalInside: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          columnWidths: getColumnWidths(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.appColor,
                    AppColors.appColor.withOpacity(0.82),
                  ],
                ),
              ),
              children: [
                _buildHeaderCell('Receipt No.', Icons.confirmation_number_outlined),
                _buildHeaderCell('Date', Icons.calendar_today_outlined),
                _buildHeaderCell('Mode', Icons.credit_card_outlined),
                _buildHeaderCell('Amount', Icons.payments_outlined),
                _buildHeaderCell('Action', null),
              ],
            ),
            ...receipts.asMap().entries.map((entry) {
              final i = entry.key;
              final receipt = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: i % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                ),
                children: [
                  _buildDataCell(
                    receipt.receiptNo.toString(),
                    TextAlign.center,
                    useTabletLayout,
                    isEmphasis: true,
                  ),
                  _buildDataCell(
                    receipt.formattedDate,
                    TextAlign.center,
                    useTabletLayout,
                  ),
                  _buildModeCell(receipt.paymentMode, useTabletLayout),
                  _buildDataCell(
                    _formatCurrency(receipt.paidAmt),
                    TextAlign.right,
                    useTabletLayout,
                    isAmount: true,
                  ),
                  _buildViewIconCell(receipt, useTabletLayout),
                ],
              );
            }).toList(),
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.07),
                border: Border(
                  top: BorderSide(width: 1.5, color: AppColors.appColor.withOpacity(0.4)),
                ),
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: useTabletLayout ? const EdgeInsets.all(14) : const EdgeInsets.all(10),
                    child: Text(
                      'TOTAL',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: useTabletLayout ? 13 : 11.5,
                        color: AppColors.appColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const TableCell(child: SizedBox.shrink()),
                const TableCell(child: SizedBox.shrink()),
                TableCell(
                  child: Container(
                    padding: useTabletLayout
                        ? const EdgeInsets.all(14)
                        : const EdgeInsets.all(10),
                    child: Text(
                      _formatCurrency(grandTotal),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: useTabletLayout ? 15 : 13,
                        color: AppColors.appColor,
                      ),
                    ),
                  ),
                ),
                const TableCell(child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: _buildInfoCard(useTabletLayout),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: useTabletLayout
                  ? SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height - 260,
                  ),
                  child: _buildTableCard(buildCompleteTable()),
                ),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width > 600
                          ? MediaQuery.of(context).size.width
                          : 600,
                    ),
                    child: _buildTableCard(buildCompleteTable()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(Widget table) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: table,
    );
  }

  Widget _buildInfoCard(bool useTabletLayout) {
    final name = widget.memberName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '';

    final avatar = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, Color.lerp(AppColors.appColor, Colors.black, 0.28)!],
        ),
      ),
      child: initial.isEmpty
          ? const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22)
          : Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );

    final nameText = Text(
      name.isEmpty ? '-' : name,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink),
    );

    final chips = Wrap(
      alignment: useTabletLayout ? WrapAlignment.end : WrapAlignment.start,
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildInfoChip(Icons.badge_outlined, 'Reg No.', widget.registrationNo),
        if (widget.plotType.isNotEmpty)
          _buildInfoChip(Icons.category_outlined, 'Plot Type', widget.plotType),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _hairline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: useTabletLayout
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          const SizedBox(width: 12),
          Expanded(flex: 5, child: nameText),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Align(alignment: Alignment.centerRight, child: chips),
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                nameText,
                const SizedBox(height: 6),
                chips,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.appColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.appColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: const TextStyle(fontSize: 10.5, color: _slate, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewIconCell(Receipt receipt, bool isTabletDevice) {
    final isLoading = _loadingReceipts.contains(receipt.receiptNo);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTabletDevice ? 6 : 4, vertical: isTabletDevice ? 10 : 8),
      child: Center(
        child: isLoading
            ? SizedBox(
          width: isTabletDevice ? 22 : 18,
          height: isTabletDevice ? 22 : 18,
          child: Lottie.asset(
            'assets/images/loading.json',
            width: isTabletDevice ? 22 : 18,
            height: isTabletDevice ? 22 : 18,
          ),
        )
            : InkWell(
          onTap: () => _viewReceiptStatement(receipt),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.all(isTabletDevice ? 6 : 5),
            decoration: BoxDecoration(
              border: Border.all(color: _hairline, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.visibility_outlined,
              color: AppColors.appColor,
              size: isTabletDevice ? 18 : 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, IconData? icon) {
    return Center(
      child: Padding(
        padding: isTablet
            ? const EdgeInsets.all(14)
            : const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: Colors.white70),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(
      String text,
      TextAlign align,
      bool isTabletDevice, {
        bool isAmount = false,
        bool isEmphasis = false,
      }) {
    return Padding(
      padding: isTabletDevice
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isTabletDevice ? 13.5 : 12.5,
          fontWeight: isAmount || isEmphasis ? FontWeight.w600 : FontWeight.w400,
          color: _ink,
        ),
      ),
    );
  }

  Widget _buildModeCell(String mode, bool isTabletDevice) {
    return Padding(
      padding: isTabletDevice
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.appColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              mode,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTabletDevice ? 12.5 : 11.5,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double? amount) {
    if (amount == null) return 'Rs. 0';
    final amountStr = amount.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(amountStr[i]);
    }

    return 'Rs. ${buffer.toString()}';
  }
}