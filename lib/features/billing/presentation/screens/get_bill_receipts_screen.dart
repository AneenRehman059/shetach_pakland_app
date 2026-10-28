import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';

import 'package:pakland/features/billing/presentation/controllers/bill_receipt_controller.dart';
import 'package:pakland/features/billing/data/models/bill_receipt_model.dart';
import 'package:pakland/features/billing/presentation/screens/view_bill_receipt_screen.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class GetBillReceiptsScreen extends StatefulWidget {
  final String registrationNo;
  final String brnCode;
  final String plotType;
  final String memberName;
  final String userId;

  const GetBillReceiptsScreen({
    super.key,
    required this.registrationNo,
    required this.brnCode,
    required this.plotType,
    required this.memberName,
    required this.userId,
  });

  @override
  State<GetBillReceiptsScreen> createState() => _GetBillReceiptsScreenState();
}

class _GetBillReceiptsScreenState extends State<GetBillReceiptsScreen> {
  late List<BillReceipt> _receipts;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  bool get isTablet {
    final context = Get.context;
    if (context == null) return false;

    return ScreenHelper.isTablet(context);
  }

  void _navigateToViewBillReceiptScreen(BillReceipt receipt) {
    print("Receipt No is: ${receipt.receiptNo.toString()}");
    Get.to(() => ViewBillReceiptScreen(
      receiptNo: receipt.receiptNo.toString(),
      registrationNo: widget.registrationNo,
      brnCode: widget.brnCode,
      plotType: '',
      idNo: '',
      billNo: 1,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      BillReceiptController(
        registrationNo: widget.registrationNo,
        brnCode: widget.brnCode,
      ),
    );

    return Scaffold(
      appBar: AppHeaderBar(
        backgroundColor: AppColors.appColor,
        title: const Text(
          "Receipts",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: AppLoader(size: 100),
          );
        }

        _receipts = controller.receiptList.cast<BillReceipt>();
        if (_receipts.isEmpty) {
          return const Center(child: Text("No receipts available"));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
          child: _buildReceiptTable(_receipts),
        );
      }),
    );
  }

  Widget _buildReceiptTable(List<BillReceipt> receipts) {
    final double grandTotal = receipts.fold(0.0, (double sum, BillReceipt r) => sum + r.receivedAmt);

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final useTabletLayout = isTablet;

    Map<int, TableColumnWidth> getColumnWidths() {
      if (useTabletLayout) {
        if (isPortrait) {
          return {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(100),
            3: FixedColumnWidth(140),
            4: FixedColumnWidth(140),
          };
        } else {
          return {
            0: FlexColumnWidth(1.0),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1.0),
            3: FlexColumnWidth(1.3),
            4: FlexColumnWidth(1.2),
          };
        }
      } else {
        if (isPortrait) {
          return {
            0: FixedColumnWidth(90),
            1: FixedColumnWidth(110),
            2: FixedColumnWidth(80),
            3: FixedColumnWidth(110),
            4: FixedColumnWidth(120),
          };
        } else {
          return {
            0: FlexColumnWidth(0.8),
            1: FlexColumnWidth(1.0),
            2: FlexColumnWidth(0.8),
            3: FlexColumnWidth(1.1),
            4: FlexColumnWidth(1.0),
          };
        }
      }
    }

    Widget buildCompleteTable() {
      return Table(
        border: TableBorder.all(
          color: Colors.grey[400]!,
          width: 1.0,
        ),
        columnWidths: getColumnWidths(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.appColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            children: [
              _buildHeaderCell('Receipt No'),
              _buildHeaderCell('Date'),
              _buildHeaderCell('Mode'),
              _buildHeaderCell('Instrument No'),
              _buildHeaderCell('Amount'),
            ],
          ),

          ...receipts.map((receipt) {
            return TableRow(
              decoration: BoxDecoration(
                color: receipts.indexOf(receipt) % 2 == 0
                    ? Colors.grey[50]
                    : Colors.white,
              ),
              children: [
                TableCell(
                  child: GestureDetector(
                    onTap: () => _navigateToViewBillReceiptScreen(receipt),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        color: Colors.transparent,
                        padding: useTabletLayout
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.all(10),
                        child: Text(
                          receipt.receiptNo.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: useTabletLayout ? 14 : 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                TableCell(
                  child: GestureDetector(
                    onTap: () => _navigateToViewBillReceiptScreen(receipt),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        color: Colors.transparent,
                        padding: useTabletLayout
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.all(10),
                        child: Text(
                          receipt.displayDate,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: useTabletLayout ? 14 : 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                TableCell(
                  child: GestureDetector(
                    onTap: () => _navigateToViewBillReceiptScreen(receipt),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        color: Colors.transparent,
                        padding: useTabletLayout
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.all(10),
                        child: Text(
                          receipt.paymentMode,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: useTabletLayout ? 14 : 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                TableCell(
                  child: GestureDetector(
                    onTap: () => _navigateToViewBillReceiptScreen(receipt),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        color: Colors.transparent,
                        padding: useTabletLayout
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.all(10),
                        child: Text(
                          receipt.instrumentNo?.isNotEmpty == true
                              ? receipt.instrumentNo!
                              : '-',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: useTabletLayout ? 14 : 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                TableCell(
                  child: GestureDetector(
                    onTap: () => _navigateToViewBillReceiptScreen(receipt),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        color: Colors.transparent,
                        padding: useTabletLayout
                            ? const EdgeInsets.all(12)
                            : const EdgeInsets.all(10),
                        child: Text(
                          _formatCurrency(receipt.receivedAmt),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: useTabletLayout ? 14 : 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),

          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: const Border(
                top: BorderSide(width: 2.0, color: Colors.blue),
              ),
            ),
            children: [
              TableCell(
                child: Container(),
              ),
              TableCell(
                child: Container(),
              ),
              TableCell(
                child: Container(),
              ),
              TableCell(
                child: Container(
                  padding: useTabletLayout
                      ? const EdgeInsets.all(14)
                      : const EdgeInsets.all(10),
                  child: Text(
                    'Grand Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: useTabletLayout ? 14 : 12,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ),
              TableCell(
                child: Container(
                  padding: useTabletLayout
                      ? const EdgeInsets.all(14)
                      : const EdgeInsets.all(10),
                  child: Text(
                    _formatCurrency(grandTotal),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: useTabletLayout ? 14 : 12,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: useTabletLayout
                  ? const EdgeInsets.all(16.0)
                  : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: useTabletLayout
                  ? Center(
                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                    _buildInfoItem('Registration No:', widget.registrationNo, true),
                    _buildInfoItem('Member Name:', widget.memberName, true),

                                    ],
                                  ),
                  )
                  : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('Registration No:', widget.registrationNo, false),
                    _buildInfoItem('Member Name:', widget.memberName, false),
                  ],
                ),
              ),
            ),

            Expanded(
              child: useTabletLayout
                  ? SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height - 200,
                  ),
                  child: buildCompleteTable(),
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
                    child: buildCompleteTable(),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget _buildHeaderCell(String text) {
    return Center(
      child: Padding(
        padding: isTablet ? const EdgeInsets.all(14) : const EdgeInsets.all(10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: isTablet ? 15 : 13,
          ),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: TextStyle(
                color: AppColors.appColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ],
        ),
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