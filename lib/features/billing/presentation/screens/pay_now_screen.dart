import 'package:pakland/core/widgets/loader.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/billing/presentation/controllers/payment_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class _Tokens {
  final double u;
  final double s4, s8, s12, s16, s20, s24;
  final double radiusSm, radiusMd, radiusLg;
  final double fontXs, fontSm, fontMd, fontLg, fontXl;
  final double buttonHeight;

  factory _Tokens(double contentWidth, {double? availableHeight, double needHeight = 690}) {
    var u = contentWidth / 360;
    if (availableHeight != null && availableHeight > 0) {
      u = math.min(u, availableHeight / needHeight);
    }
    return _Tokens._(u.clamp(0.7, 1.8).toDouble());
  }

  _Tokens._(this.u)
      : s4 = 4 * u,
        s8 = 8 * u,
        s12 = 12 * u,
        s16 = 16 * u,
        s20 = 20 * u,
        s24 = 24 * u,
        radiusSm = 10 * u,
        radiusMd = 14 * u,
        radiusLg = 20 * u,
        fontXs = 11.5 * u,
        fontSm = 13.5 * u,
        fontMd = 15.5 * u,
        fontLg = 18 * u,
        fontXl = 22 * u,
        buttonHeight = 52 * u;
}

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
  final String blockNo;
  final String unitNo;

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
    required this.clientId,
    this.blockNo = '',
    this.unitNo = '',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const double _columnGap = 24;

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

    FocusScope.of(context).unfocus();

    try {
      await _paymentController.processPayment(
        amount: amount,
        registrationNo: widget.registrationNo,
        paymentCode: widget.paymentCode,
        memberName: widget.memberName,
        context: context,
        brnCode: widget.brnCode,
        brnName: widget.brnName,
        clientId: widget.clientId,
        paymentType: "",
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
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppHeaderBar(
        title: const Text(
          'Payment Confirmation',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.appColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              Get.offAll(() => MainWrapper(initialIndex: 0));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                final twoCol = w >= 640 && w > h * 1.1;
                final contentWidth = w;

                final shortScreen = h < 480;
                final compact = keyboardOpen || h < 420;

                final columnWidth =
                twoCol ? (contentWidth - _columnGap) / 2 : contentWidth;
                final needHeight = twoCol
                    ? ((compact || shortScreen) ? 420.0 : 450.0)
                    : (compact ? 540.0 : 690.0);
                final t = _Tokens(columnWidth,
                    availableHeight: h, needHeight: needHeight);

                final summary = _buildSummaryCard(t, compact: compact);
                final amount = _buildAmountCard(t);

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Column(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: const Alignment(0, -0.2),
                          child: SizedBox(
                            width: contentWidth,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(t.s16, t.s16, t.s16, t.s12),
                              child: twoCol
                                  ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: summary),
                                  const SizedBox(width: _columnGap),
                                  Expanded(child: amount),
                                ],
                              )
                                  : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  summary,
                                  SizedBox(height: t.s16),
                                  amount,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildBottomBar(
                        t,
                        contentWidth,
                        keyboardOpen || shortScreen,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(_Tokens t, {required bool compact}) {
    final hasOverdue = widget.overDueAmount > 0;
    final block = widget.blockNo.trim();
    final unit = widget.unitNo.trim();
    final pills = <Widget>[
      if (block.isNotEmpty)
        _buildLocationPill(t, Icons.grid_view_rounded, 'Block', block),
      if (unit.isNotEmpty)
        _buildLocationPill(t, Icons.home_work_outlined, 'Unit No', unit),
    ];

    return Container(
      padding: EdgeInsets.all(t.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
          ],
        ),
        borderRadius: BorderRadius.circular(t.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(t.s8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: t.fontLg),
                ),
                SizedBox(width: t.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.memberName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: t.fontMd,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: t.s4 * 0.5),
                      Text(
                        'Reg # ${widget.registrationNo}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: t.fontXs,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (pills.isNotEmpty) ...[
              SizedBox(height: t.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < pills.length; i++) ...[
                    if (i > 0) SizedBox(width: t.s12),
                    Expanded(child: pills[i]),
                  ],
                ],
              ),
            ],
            SizedBox(height: t.s12),
            Divider(height: 1, color: Colors.white.withOpacity(0.16)),
            SizedBox(height: t.s12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStatTile(
                  t,
                  label: 'Outstanding Amount',
                  value: 'Rs. ${_formatAmount(widget.totalOutstanding)}/-',
                ),
              ),
              SizedBox(width: t.s12),
              Expanded(
                child: _buildStatTile(
                  t,
                  label: 'Overdue Amount',
                  value: 'Rs. ${widget.formattedTotalOverDue}/-',
                  warn: hasOverdue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPill(
      _Tokens t, IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.s12, vertical: t.s8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(t.s8 * 0.8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: t.fontSm, color: Colors.white),
          ),
          SizedBox(width: t.s8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: t.fontXs * 0.88,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: t.fontMd,
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

  Widget _buildStatTile(
      _Tokens t, {
        required String label,
        required String value,
        bool warn = false,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.s12, vertical: t.s12),
      decoration: BoxDecoration(
        color: warn
            ? const Color(0xFFFF5A5F).withOpacity(0.30)
            : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: t.fontXs,
              ),
            ),
          ),
          SizedBox(height: t.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: t.fontLg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(_Tokens t) {
    return _Card(
      radius: t.radiusLg,
      child: Padding(
        padding: EdgeInsets.all(t.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(t.s8),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(t.radiusSm),
                  ),
                  child: Icon(Icons.payments_outlined,
                      size: t.fontLg, color: AppColors.appColor),
                ),
                SizedBox(width: t.s12),
                Text(
                  'Amount To Pay',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF22262E),
                    fontSize: t.fontMd,
                  ),
                ),
              ],
            ),
            SizedBox(height: t.s16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) => FocusScope.of(context).unfocus(),
              cursorColor: AppColors.appColor,
              style: TextStyle(
                fontSize: t.fontXl,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF22262E),
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.black26,
                  fontSize: t.fontXl,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: const Color(0xFFF6F7FA),
                isDense: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: t.s16, right: t.s8),
                  child: Text(
                    'Rs.',
                    style: TextStyle(
                      fontSize: t.fontMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appColor,
                    ),
                  ),
                ),
                prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: t.s16, vertical: t.s12 + 2 * t.u),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  borderSide: BorderSide(color: AppColors.appColor, width: 1.6),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: t.fontXs * 1.4 + t.s8),
              child: _buildAmountValidationText(t),
            ),
            SizedBox(height: t.s8),
            Text(
              'QUICK SELECT',
              style: TextStyle(
                fontSize: t.fontXs * 0.88,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: t.s8),
            _buildAmountSelector(t),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSelector(_Tokens t) {
    final current = _parsedAmount();
    final options = <List<Object>>[
      ['Full Outstanding', widget.totalOutstanding, Icons.account_balance_wallet_outlined],
      if (widget.overDueAmount > 0)
        ['Overdue Only', widget.overDueAmount, Icons.schedule_rounded],
    ];

    int selectedIndex = -1;
    if (current != null) {
      for (var i = 0; i < options.length; i++) {
        if (((options[i][1] as double) - current).abs() < 0.005) {
          selectedIndex = i;
          break;
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: t.s12),
          Expanded(
            child: _AmountOptionTile(
              title: options[i][0] as String,
              amountText: 'Rs. ${_formatAmount(options[i][1] as double)}',
              icon: options[i][2] as IconData,
              selected: i == selectedIndex,
              t: t,
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  _amountController.text =
                      (options[i][1] as double).toStringAsFixed(2);
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountValidationText(_Tokens t) {
    if (_amountController.text.isEmpty) return const SizedBox.shrink();

    final cleanText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(cleanText) ?? 0.0;

    if (amount <= 0) {
      return _ValidationMessage(
        text: 'Please enter a valid amount greater than 0',
        color: Colors.red,
        icon: Icons.error_outline,
        t: t,
      );
    }

    if (amount > widget.totalOutstanding) {
      return _ValidationMessage(
        text:
        'Amount cannot exceed outstanding amount (Rs. ${widget.formattedTotalOutstanding})',
        color: Colors.orange[800]!,
        icon: Icons.warning_amber_rounded,
        t: t,
      );
    }

    return _ValidationMessage(
      text: 'Amount looks good',
      color: Colors.green[700]!,
      icon: Icons.check_circle_outline,
      t: t,
    );
  }

  Widget _buildBottomBar(_Tokens t, double contentWidth, bool keyboardOpen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusLg)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(t.s16, t.s12, t.s16, t.s12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTermsRow(t),
                SizedBox(height: t.s12),
                _buildPayButton(t),
                if (!keyboardOpen) ...[
                  SizedBox(height: t.s8),
                  _buildSecureNote(t),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsRow(_Tokens t) {
    final boxSize = t.fontLg + 2 * t.u;

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isTermsAccepted = !_isTermsAccepted),
          child: Padding(
            padding: EdgeInsets.all(t.s4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isTermsAccepted
                      ? AppColors.appColor
                      : Colors.grey.shade400,
                  width: 1.6,
                ),
                borderRadius: BorderRadius.circular(t.radiusSm * 0.55),
                color:
                _isTermsAccepted ? AppColors.appColor : Colors.transparent,
              ),
              child: _isTermsAccepted
                  ? Icon(Icons.check, size: t.fontSm, color: Colors.white)
                  : null,
            ),
          ),
        ),
        SizedBox(width: t.s8),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _isTermsAccepted = !_isTermsAccepted),
            child: Text(
              'I accept the terms & conditions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: t.fontSm,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: _showTermsAndConditions,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.appColor,
            padding: EdgeInsets.symmetric(horizontal: t.s12, vertical: t.s4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.radiusLg),
            ),
          ),
          child: Text(
            'Read',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: t.fontSm,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(_Tokens t) {
    return Obx(() {
      final isLoading = _paymentController.isLoading.value;
      final enabled = _isTermsAccepted && _isValidAmount() && !isLoading;
      final amount = _parsedAmount();
      final label = (_isValidAmount() && amount != null)
          ? 'PAY  Rs. ${_formatAmount(amount)}'
          : 'PAY NOW';

      return SizedBox(
        width: double.infinity,
        height: t.buttonHeight,
        child: ElevatedButton(
          onPressed: enabled ? _handlePayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appColor,
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.grey.shade500,
            elevation: enabled ? 3 : 0,
            shadowColor: AppColors.appColor.withOpacity(0.4),
            padding: EdgeInsets.symmetric(horizontal: t.s16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
          ),
          child: isLoading
              ? SizedBox(
            width: t.fontMd,
            height: t.fontMd,
            child: const AppLoader(),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: t.fontMd),
              SizedBox(width: t.s8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: t.fontMd,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSecureNote(_Tokens t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined,
            size: t.fontXs + 1, color: Colors.grey[500]),
        SizedBox(width: t.s4),
        Text(
          'Your payment is processed securely',
          style: TextStyle(fontSize: t.fontXs, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Obx(() {
      if (!_paymentController.isLoading.value) return const SizedBox.shrink();
      return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.35),
          alignment: Alignment.center,
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/images/loading.json',
                  width: 110,
                  height: 110,
                ),
                const SizedBox(height: 4),
                Text(
                  'Processing Payment...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please do not close this screen',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showTermsAndConditions() {
    final terms = <String>[
      'All payments are processed securely through our trusted payment gateway.',
      'Users are responsible for providing accurate payment information.',
      'Refunds, if applicable, will be processed according to our refund policy.',
      'Unauthorized transactions must be reported immediately to our support team.',
      'By making a payment, you agree to comply with our terms and privacy policy.',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.gavel_outlined, color: AppColors.appColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: terms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          size: 18, color: AppColors.appColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          terms[index],
                          style: const TextStyle(
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _parsedAmount() {
    final cleanText = _amountController.text.replaceAll(',', '');
    if (cleanText.isEmpty) return null;
    return double.tryParse(cleanText);
  }

  bool _isValidAmount() {
    final amount = _parsedAmount();
    return amount != null && amount > 0 && amount <= widget.totalOutstanding;
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(\.\d{2})?$)'),
          (Match m) => '${m[1]},',
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final double radius;
  const _Card({required this.child, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _ValidationMessage extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final _Tokens t;

  const _ValidationMessage(
      {required this.text,
        required this.color,
        required this.icon,
        required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: t.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: t.fontXs + 2, color: color),
          SizedBox(width: t.s4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: t.fontXs,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountOptionTile extends StatelessWidget {
  final String title;
  final String amountText;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final _Tokens t;

  const _AmountOptionTile({
    required this.title,
    required this.amountText,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final radio = t.fontLg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: t.s12, vertical: t.s12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.appColor.withOpacity(0.08)
                : const Color(0xFFF6F7FA),
            borderRadius: BorderRadius.circular(t.radiusMd),
            border: Border.all(
              color: selected ? AppColors.appColor : Colors.grey.shade300,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: radio,
                height: radio,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.appColor : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.appColor : Colors.grey.shade400,
                    width: 1.6,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, size: radio * 0.68, color: Colors.white)
                    : null,
              ),
              SizedBox(width: t.s8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: t.fontXs,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.appColor
                              : const Color(0xFF5B6270),
                        ),
                      ),
                    ),
                    SizedBox(height: t.s4 * 0.5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amountText,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: t.fontSm,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF22262E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}