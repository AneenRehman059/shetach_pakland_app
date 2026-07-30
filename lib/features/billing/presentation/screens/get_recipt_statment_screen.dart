import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/billing/data/statment.dart';

import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/billing/presentation/controllers/account_recipt_controller.dart';
import 'package:pakland/features/billing/presentation/controllers/get_account_statement_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/billing/data/models/recipt_model.dart';

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
    final shortestSide = MediaQuery.of(Get.context!).size.shortestSide;
    return shortestSide > 600;
  }

  Future<void> _viewReceiptStatement(Receipt receipt) async {
    setState(() {
      _loadingReceipts.add(receipt.receiptNo);
    });

    try {
      final tempController = Get.put(
        AccountStatementController(),
        tag: 'receipt_${receipt.receiptNo}',
      );

      // Define the copies array
      final List<String> copies = ["Client", "Office", "Account"];

      await tempController.fetchReceiptStatement(
        brnCode: widget.brnCode,
        registrationNo: widget.registrationNo,
        idNo: widget.idNo,
        userName: widget.idNo,
        reportId: 101591,
        receiptNo: receipt.receiptNo.toString(),
        copies: copies,
      );

      if (tempController.accountStatement.value?.reportUrl != null &&
          tempController.accountStatement.value!.reportUrl!.isNotEmpty) {
        final reportUrl = tempController.accountStatement.value!.reportUrl!;
        await Get.to(() => PrintWebViewScreen(url: reportUrl));
        await Get.delete<AccountStatementController>(tag: 'receipt_${receipt.receiptNo}');
      } else {
        showTopSnackBar(
          context,
          "Failed to generate statement. Please try again.",
          Colors.red.withOpacity(0.7),
          icon: Icons.error,
        );
      }
    } catch (e) {
      debugPrint("Error fetching receipt statement: $e");
      showTopSnackBar(
        context,
        "Error loading statement: ${e.toString()}",
        Colors.red.withOpacity(0.7),
        icon: Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingReceipts.remove(receipt.receiptNo);
        });
      }
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

    return Scaffold(
      appBar: AppBar(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAll(() => MainWrapper(initialIndex: 0));
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SpinKitWave(
              color: AppColors.appColor,
              size: 50.0,
            ),
          );
        }

        _receipts = controller.receiptList;
        if (_receipts.isEmpty) {
          return const Center(child: Text("No receipts available"));
        }

        return Padding(
          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 55),
          child: _buildReceiptTable(_receipts),
        );
      }),
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
            0: const FixedColumnWidth(120),
            1: const FixedColumnWidth(140),
            2: const FixedColumnWidth(120),
            3: const FixedColumnWidth(140),
            4: const FixedColumnWidth(100),
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
            0: const FixedColumnWidth(100),
            1: const FixedColumnWidth(120),
            2: const FixedColumnWidth(100),
            3: const FixedColumnWidth(120),
            4: const FixedColumnWidth(80),
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
      return Table(
        border: TableBorder.all(
          color: Colors.grey[400]!,
          width: 1.0,
        ),
        columnWidths: getColumnWidths(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header Row
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
              _buildHeaderCell('Amount'),
              _buildHeaderCell('View'),
            ],
          ),
          // Data Rows
          ...receipts.map((receipt) => TableRow(
            decoration: BoxDecoration(
              color: receipts.indexOf(receipt) % 2 == 0
                  ? Colors.grey[50]
                  : Colors.white,
            ),
            children: [
              _buildDataCell(
                receipt.receiptNo.toString(),
                TextAlign.center,
                useTabletLayout,
              ),
              _buildDataCell(
                receipt.formattedDate,
                TextAlign.center,
                useTabletLayout,
              ),
              _buildDataCell(
                receipt.paymentMode,
                TextAlign.center,
                useTabletLayout,
              ),
              _buildDataCell(
                _formatCurrency(receipt.paidAmt),
                TextAlign.right,
                useTabletLayout,
                isAmount: true,
              ),
              _buildViewIconCell(receipt, useTabletLayout),
            ],
          )).toList(),
          // Grand Total Row
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
              TableCell(
                child: Container(),
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
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoItem('Registration No:', widget.registrationNo, true),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildInfoItem('Member Name:', widget.memberName, true),
                ),
                if (widget.plotType.isNotEmpty)
                  Expanded(
                    child: _buildInfoItem('Plot Type:', widget.plotType, true),
                  ),
              ],
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
      ),
    );
  }

  Widget _buildViewIconCell(Receipt receipt, bool isTabletDevice) {
    final isLoading = _loadingReceipts.contains(receipt.receiptNo);

    return Container(
      padding: EdgeInsets.all(isTabletDevice ? 8 : 6),
      child: Center(
        child: isLoading
            ? SizedBox(
          width: isTabletDevice ? 24 : 20,
          height: isTabletDevice ? 24 : 20,
          child: SpinKitRipple(
            color: AppColors.appColor,
          ),
        )
            : InkWell(
          onTap: () => _viewReceiptStatement(receipt),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(isTabletDevice ? 8 : 6),
            decoration: BoxDecoration(
              color: AppColors.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.visibility,
              color: AppColors.appColor,
              size: isTabletDevice ? 22 : 18,
            ),
          ),
        ),
      ),
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

  Widget _buildDataCell(
      String text,
      TextAlign align,
      bool isTabletDevice, {
        bool isAmount = false,
      }) {
    return Padding(
      padding: isTabletDevice ? const EdgeInsets.all(12) : const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isTabletDevice ? 14 : 13,
          fontWeight: isAmount ? FontWeight.w600 : FontWeight.normal,
          color: isAmount ? Colors.green[800] : Colors.black,
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