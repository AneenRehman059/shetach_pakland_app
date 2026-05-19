import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'bottom_app_bar/bottom_app_bar.dart';
import 'colors.dart';
import 'controllers/payment_controller.dart';
import 'customs/custom_fields.dart';

class PaymentScreen extends StatefulWidget {
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

  const PaymentScreen({
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
    required this.clientId
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isTermsAccepted = false;
  final TextEditingController _amountController = TextEditingController();
  final PaymentController _paymentController = Get.put(PaymentController());

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handlePayment() async {
    if (!_isValidAmount() || !_isTermsAccepted) return;

    final cleanAmount = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(cleanAmount);

    if (amount == null) return;

    try {
      await _paymentController.processPayment(
        amount: amount,
        registrationNo: widget.registrationNo,
        paymentCode: widget.paymentCode,
        memberName: widget.memberName, context: context,
        brnCode: widget.brnCode,
        brnName: widget.brnName,
        clientId: widget.clientId,
          paymentType: ""
      );
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Payment Error',
          _paymentController.errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final padding = width * 0.04;
    final borderRadius = width * 0.02;
    final buttonHeight = height * 0.06;
    final containerPadding = width * 0.02;
    final spacing = height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
          child: Column(
            children: [
              _buildInfoContainer(width, borderRadius, containerPadding),
              SizedBox(height: spacing),
              _buildAmountContainer(width, borderRadius, containerPadding, height),
              SizedBox(height: spacing),
              _buildTermsContainer(width, borderRadius, containerPadding),
              SizedBox(height: spacing),
              _buildLoadingIndicator(),
              SizedBox(height: spacing),
              _buildPayButton(buttonHeight, width * 0.30, width),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(double width, double borderRadius, double padding) {
    final infoItems = [
      ['Booking ID / Reg#', widget.registrationNo],
      ['Customer Name', widget.memberName],
      ['Outstanding Amount', 'Rs. ${_formatAmount(widget.totalOutstanding)}/-'],
      ['Overdue Amount', 'Rs. ${widget.formattedTotalOverDue}/-'],
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          for (int i = 0; i < infoItems.length; i++) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: i < infoItems.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade300)) : null,
              ),
              child: Row(
                children: [
                  Text(
                    infoItems[i][0],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: width * 0.038,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    infoItems[i][1],
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: width * 0.035,
                      color: i == 3 ? Colors.red : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountContainer(double width, double borderRadius, double padding, double height) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Text(
              'Payment Amount',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: width * 0.038,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                CustomTextField(
                  label: 'Enter Amount (Pkr)',
                  hintText: '0.00',
                  borderRadius: 30,
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => setState(() {}),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: width * 0.035,

                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
                  isSignUpStyle: true,
                ),
                _buildAmountValidationText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContainer(double width, double borderRadius, double padding) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Text(
              'Terms & Conditions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: width * 0.038,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isTermsAccepted = !_isTermsAccepted),
                  child: Container(
                    width: width * 0.05,
                    height: width * 0.05,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isTermsAccepted ? AppColors.appColor : Colors.grey.shade400,
                        width: _isTermsAccepted ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(borderRadius * 0.5),
                      color: _isTermsAccepted ? AppColors.appColor : Colors.transparent,
                    ),
                    child: _isTermsAccepted
                        ? Icon(Icons.check, size: width * 0.04, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isTermsAccepted = !_isTermsAccepted),
                    child: Text(
                      'I accept the terms & conditions',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        fontSize: width * 0.035,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showTermsAndConditions,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Read',
                        style: TextStyle(
                          color: AppColors.appColor,
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.035,
                        ),
                      ),
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

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (_paymentController.isLoading.value) {
        return Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          child: Column(
            children: [
              Text(
                'Processing Payment...',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildPayButton(double buttonHeight, double borderRadius, double width) {
    return Obx(() {
      final isLoading = _paymentController.isLoading.value;
      return SizedBox(
       // width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: _isTermsAccepted && _isValidAmount() && !isLoading ? _handlePayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isTermsAccepted && _isValidAmount() && !isLoading
                ? AppColors.appColor
                : Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          child: isLoading
              ? SpinKitWave(color: Colors.white, size: width * 0.06)
              : Text(
            'PAY NOW',
            style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w600),
          ),
        ),
      );
    });
  }

  Widget _buildAmountValidationText() {
    if (_amountController.text.isEmpty) return const SizedBox.shrink();

    final cleanText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(cleanText) ?? 0.0;
    final width = MediaQuery.of(context).size.width;

    if (amount <= 0) {
      return _buildValidationMessage('Please enter a valid amount greater than 0', Colors.red, width);
    }

    if (amount > widget.totalOutstanding) {
      return _buildValidationMessage(
        'Amount cannot exceed outstanding amount (Rs. ${widget.formattedTotalOutstanding})',
        Colors.orange,
        width,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildValidationMessage(String text, Color color, double width) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: width * 0.032, fontWeight: FontWeight.w500),
      ),
    );
  }

  bool _isValidAmount() {
    if (_amountController.text.isEmpty) return false;
    final cleanText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(cleanText);
    return amount != null && amount > 0 && amount <= widget.totalOutstanding;
  }

  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Terms Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          TextSpan(text: 'All payments are processed securely through our trusted payment gateway.\n\n', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                     RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          TextSpan(text: 'Users are responsible for providing accurate payment information.\n\n', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                     RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          TextSpan(text: 'Refunds, if applicable, will be processed according to our refund policy.\n\n', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                     RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          TextSpan(text: 'Unauthorized transactions must be reported immediately to our support team.\n\n', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                     RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          TextSpan(text: 'By making a payment, you agree to comply with our terms and privacy policy.', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,       // ❗ Button background color
                foregroundColor: Colors.white,      // ❗ Text color
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Close'),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(\.\d{2})?$)'),
          (Match m) => '${m[1]},',
    );
  }


}