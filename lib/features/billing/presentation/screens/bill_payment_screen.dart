import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/billing/presentation/controllers/payment_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class BillPaymentScreen extends StatefulWidget {
  final String registrationNo;
  final String paymentCode;
  final String brnCode;
  final String brnName;
  final String memberName;
  final double overDueAmount;
  final double totalOutstanding;
  final String formattedTotalOutstanding;
  final String formattedTotalOverDue;
  final String clientId;

  const BillPaymentScreen({
    super.key,
    required this.registrationNo,
    required this.paymentCode,
    required this.brnCode,
    required this.brnName,
    required this.memberName,
    required this.overDueAmount,
    required this.totalOutstanding,
    required this.formattedTotalOutstanding,
    required this.formattedTotalOverDue,
    required this.clientId,
  });

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  bool _isTermsAccepted = false;
  late final PaymentController _paymentController;

  @override
  void initState() {
    super.initState();
    _paymentController = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());
  }

  Future<void> _handlePayment() async {
    if (!_isTermsAccepted) {
      Get.snackbar(
        'Terms Required',
        'Please accept the terms & conditions to proceed.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      await _paymentController.billProcessPayment(
        amount: widget.totalOutstanding,
        registrationNo: widget.registrationNo,
        paymentCode: widget.paymentCode,
        memberName: widget.memberName,
        context: context,
        brnCode: widget.brnCode,
        brnName: widget.brnName,
        clientId: widget.clientId,
        paymentType: "Bill",
      );
    } catch (_) {
      if (!mounted) return;
      final error = _paymentController.errorMessage.value.isNotEmpty
          ? _paymentController.errorMessage.value
          : 'Something went wrong while processing the payment. Please try again.';

      Get.snackbar(
        'Payment Error',
        error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const horizontalPadding = 16.0;
    const verticalPadding = 16.0;

    final totalPayable = widget.totalOutstanding;

    return Scaffold(

      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppHeaderBar(
        elevation: 0,
        backgroundColor: AppColors.appColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Bill Payment',
          style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: AppColors.whiteBg
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAll(() => MainWrapper(initialIndex: 0));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _AmountHeaderCard(
                    registrationNo: widget.registrationNo,
                    memberName: widget.memberName,
                    totalPayable: totalPayable,
                    branch: '${widget.brnCode} - ${widget.brnName}',
                  ),
                  const SizedBox(height: 20),

                  _SectionCard(
                    title: 'Payment Summary',
                    titleIcon: Icons.receipt_long_outlined,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Outstanding Amount',
                            value:
                            'Rs. ${_formatAmount(widget.totalOutstanding)}',
                          ),

                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade300, height: 1),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Total Payable Today',
                            value: 'Rs. ${_formatAmount(totalPayable)}',
                            isTotal: true,
                            valueColor: AppColors.appColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  _SectionCard(
                    title: 'Terms & Conditions',
                    titleIcon: Icons.shield_outlined,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: _isTermsAccepted,
                            onChanged: (v) {
                              setState(() => _isTermsAccepted = v ?? false);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.appColor,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'I have read and agree to the terms and conditions.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            secondary: TextButton(
                              onPressed: _showTermsAndConditions,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.appColor,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                                textStyle:
                                theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('VIEW'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: Text(
                              'Your payment will be processed securely. Please verify the bill details before proceeding.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            final isLoading = _paymentController.isLoading.value;
            final enabled = _isTermsAccepted && !isLoading;

            return BottomActionBar(
              amountLabel: 'Total Payable',
              amountValue: 'Rs. ${_formatAmount(totalPayable)}',
              isLoading: isLoading,
              enabled: enabled,
              onPressed: enabled ? _handlePayment : null,
            );
          }),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;

        return SafeArea(
          top: false,
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security,
                          color: AppColors.appColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Terms & Conditions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: const [
                      _TermItem(
                        title: 'Secure Payment Processing',
                        description:
                        'All payments are processed securely through our trusted payment gateway partners.',
                      ),
                      SizedBox(height: 16),
                      _TermItem(
                        title: 'Payment Accuracy',
                        description:
                        'You are responsible for providing accurate account details. Please confirm all information before proceeding with the payment.',
                      ),
                      SizedBox(height: 16),
                      _TermItem(
                        title: 'Refund Policy',
                        description:
                        'Refunds, if applicable, will be processed within 5–7 business days in line with our refund policy.',
                      ),
                      SizedBox(height: 16),
                      _TermItem(
                        title: 'Transaction Security',
                        description:
                        'Any unauthorized or suspicious transactions should be reported to our support team immediately.',
                      ),
                      SizedBox(height: 16),
                      _TermItem(
                        title: 'Data Privacy',
                        description:
                        'Your personal and payment information is encrypted and handled in compliance with applicable data protection regulations.',
                      ),
                      SizedBox(height: 16),
                      _TermItem(
                        title: 'Agreement',
                        description:
                        'By making a payment, you confirm that you have read, understood, and agree to all terms, conditions, and our privacy policy.',
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'CLOSE',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(\.\d{2})?$)'),
          (Match m) => '${m[1]},',
    );
  }
}

class _AmountHeaderCard extends StatelessWidget {
  final String registrationNo;
  final String memberName;
  final double totalPayable;
  final String branch;

  const _AmountHeaderCard({
    required this.registrationNo,
    required this.memberName,
    required this.totalPayable,
    required this.branch,
  });

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(\.\d{2})?$)'),
          (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.appColor,
              AppColors.appColor.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'BILL PAYMENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Total Payable Today',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs. ${_formatAmount(totalPayable)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reg. No: $registrationNo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    memberName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(
                    titleIcon,
                    size: 18,
                    color: AppColors.appColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? Colors.grey[900] : Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? Colors.grey[900],
          ),
        ),
      ],
    );
  }
}

class _TermItem extends StatelessWidget {
  final String title;
  final String description;

  const _TermItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.appColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BottomActionBar extends StatelessWidget {
  final String amountLabel;
  final String amountValue;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  const BottomActionBar({
    required this.amountLabel,
    required this.amountValue,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 12,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.08),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amountLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amountValue,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.appColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isLoading
                              ? 'Processing payment securely...'
                              : 'Payments are processed over a secure connection.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appColor,
                  disabledBackgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: enabled ? 3 : 0,
                ),
                child: isLoading
                    ? AppLoader(size: 20)
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payment, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'PAY NOW',
                      style:
                      theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: Colors.white,
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
}