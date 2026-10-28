import 'package:pakland/core/widgets/loader.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';

import 'package:pakland/features/billing/presentation/controllers/verify_form_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/utils/upper_case_keyboard.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class VerifyFormNumberScreen extends StatefulWidget {
  const VerifyFormNumberScreen({super.key});

  @override
  State<VerifyFormNumberScreen> createState() => _VerifyFormNumberScreenState();
}

class _VerifyFormNumberScreenState extends State<VerifyFormNumberScreen> {
  final VerifyFormController formController = Get.put(VerifyFormController());

  final TextEditingController formNoCtrl = TextEditingController();

  static const Color _pageBg = Color(0xFFF4F7FA);
  static const Color _fieldBg = Color(0xFFF7F9FC);
  static const Color _fieldBorder = Color(0xFFDCE3EC);

  @override
  void initState() {
    super.initState();
    formController.reset();
  }

  @override
  void dispose() {
    formNoCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    if (formNoCtrl.text.trim().isEmpty) {
      showTopSnackBar(context, "Please enter Form Number", Colors.red);
      return;
    }
    formController.verifyForm(
      context: context,
      formNo: formNoCtrl.text.trim(),
    );
  }


  static const double _minHeightIdle = 350;
  static const double _minHeightResult = 480;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppHeaderBar(
        title: const Text("Form Validation"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ResponsiveBody(
            maxWidth: 600,
            child: LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(() {
                    final success = formController.isSuccess.value;
                    final needed = success ? _minHeightResult : _minHeightIdle;

                    final fits = constraints.maxHeight >= needed;

                    final children = <Widget>[
                      _buildInputCard(compact: success),
                      if (success) ...[
                        const SizedBox(height: 14),
                        _wrapResult(
                          fits,
                          statusCard(
                            screenW: screenW,
                            project: formController.branchName.value,
                            formNo: formController.formNumber.value,
                            formStatus: formController.formStatus.value,
                            formCurrency: formController.formCurrency.value,
                            fill: fits,
                          ),
                        ),
                      ],
                    ];

                    if (fits) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Column(
                          mainAxisAlignment: success
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    );
                  });
                },
              ),
          ),
        ),
      ),
    );
  }

  Widget _wrapResult(bool fits, Widget card) =>
      fits ? Expanded(child: card) : card;


  Widget _buildInputCard({required bool compact}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    final loading = formController.isLoading.value;

    final field = TextField(
      controller: formNoCtrl,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [UpperCaseTextFormatter()],
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => loading ? null : _verify(),
      cursorColor: AppColors.appColor,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: "e.g. ABC12345",
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(Icons.description_outlined,
            size: 21, color: Colors.grey.shade500),
        filled: true,
        fillColor: _fieldBg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: border(_fieldBorder),
        enabledBorder: border(_fieldBorder),
        focusedBorder: border(AppColors.appColor, 1.6),
      ),
    );

    const label = Padding(
      padding: EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        "Form Number",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2B3A42),
        ),
      ),
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: field),
                      const SizedBox(width: 10),
                      _verifyButton(loading: loading, compact: true),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.appColor, AppColors.lightAppColor],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.appColor.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.fact_check_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Verify Your Form",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.appColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Enter your form number below to check its current status.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, height: 1.4, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  label,
                  field,
                  const SizedBox(height: 14),
                  _verifyButton(loading: loading, compact: false),
                ],
              ),
      ),
    );
  }

  Widget _verifyButton({required bool loading, required bool compact}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      width: compact ? 56 : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: loading
              ? [Colors.grey.shade400, Colors.grey.shade400]
              : [AppColors.appColor, AppColors.lightAppColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: loading
            ? []
            : [
                BoxShadow(
                  color: AppColors.appColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : _verify,
          child: Center(
            child: loading
                ? const AppLoader(size: 22)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 20),
                      if (!compact) ...[
                        const SizedBox(width: 8),
                        const Text(
                          "Verify",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }


  Widget statusCard({
    required double screenW,
    required String project,
    required String formNo,
    required String formStatus,
    required String formCurrency,
    bool fill = false,
  }) {
    final statusDetails = _getStatusDetails(formStatus);

    final String headerText = statusDetails['title'] as String;
    final Color statusColor = statusDetails['color'] as Color;
    final String statusDetail = statusDetails['description'] as String;
    final IconData statusIcon = statusDetails['icon'] as IconData;

    String getCurrencyImage() {
      switch (formCurrency) {
        case "10":
          return ImageConstant.rs10;
        case "20":
          return ImageConstant.rs20;
        case "50":
          return ImageConstant.rs50;
        case "100":
          return ImageConstant.rs100;
        case "500":
          return ImageConstant.rs500;
        case "1000":
          return ImageConstant.rs1000;
        case "5000":
          return ImageConstant.rs5000;
        default:
          return "assets/images/20.png";
      }
    }

    Widget currencyNote() {
      final textStyle = TextStyle(
        fontSize: (screenW * 0.032).clamp(11.0, 16.0),
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: 1,
      );
      return AspectRatio(
        aspectRatio: 17 / 8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(getCurrencyImage(), fit: BoxFit.fill),
                ),
                Positioned(top: 6, right: 8, child: Text(formNo, style: textStyle)),
                Positioned(bottom: 6, left: 10, child: Text(formNo, style: textStyle)),
              ],
            ),
          ),
        ),
      );
    }

    final body = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoTile(Icons.apartment_rounded, "Project", project),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoTile(
                    Icons.confirmation_number_outlined, "Form No.", formNo),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoTile(
            Icons.info_outline_rounded,
            "Status Detail",
            statusDetail,
            valueColor: statusColor,
          ),
          const SizedBox(height: 12),
          if (fill)
            Expanded(child: Center(child: currencyNote()))
          else
            currencyNote(),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [statusColor, statusColor.withOpacity(0.8)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "FORM STATUS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        headerText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (fill) Expanded(child: body) else body,
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusDetails(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'I':
        return {
          'title': "Normal / Ready",
          'description': "Normal - Ready for buying and selling",
          'color': const Color(0xFF2E9E5B),
          'icon': Icons.check_circle_rounded,
        };
      case 'R':
        return {
          'title': "Active / Not Ready",
          'description': "Normal - Not ready for buying and selling",
          'color': const Color(0xFFE08A12),
          'icon': Icons.schedule_rounded,
        };
      case 'C':
        return {
          'title': "Cancelled",
          'description': "Cancelled - This form has been cancelled",
          'color': const Color(0xFFD64545),
          'icon': Icons.cancel_rounded,
        };
      case 'A':
        return {
          'title': "Adjusted",
          'description': "Adjusted - Not ready for buying and selling",
          'color': const Color(0xFF2F7DD1),
          'icon': Icons.sync_alt_rounded,
        };
      default:
        return {
          'title': "Unknown Status",
          'description': "Status code not recognized",
          'color': Colors.grey.shade600,
          'icon': Icons.help_rounded,
        };
    }
  }

  Widget _infoTile(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.appColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "-" : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: valueColor ?? const Color(0xFF2B3A42),
            ),
          ),
        ],
      ),
    );
  }
}
