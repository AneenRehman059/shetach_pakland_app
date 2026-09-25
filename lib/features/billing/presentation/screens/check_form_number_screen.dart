import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';

import 'package:pakland/features/billing/presentation/controllers/verify_form_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/utils/upper_case_keyboard.dart';

class VerifyFormNumberScreen extends StatefulWidget {
  const VerifyFormNumberScreen({super.key});

  @override
  State<VerifyFormNumberScreen> createState() =>
      _VerifyFormNumberScreenState();
}

class _VerifyFormNumberScreenState extends State<VerifyFormNumberScreen> {
  final VerifyFormController formController =
  Get.put(VerifyFormController());

  final TextEditingController formNoCtrl = TextEditingController();
  final Color appColor = const Color.fromRGBO(31, 75, 89, 1);

  @override
  void initState() {
    super.initState();
    formController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: appColor,
        title: const Text(
          "Form Validation",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Obx(() {
              // Show only input section when no form is verified
              if (!formController.isSuccess.value) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenW * 0.07,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Text(
                        "Verify Your Form",
                        style: TextStyle(
                          fontSize: screenW * 0.06,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// INPUT
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: TextField(
                          controller: formNoCtrl,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: InputDecoration(
                            hintText: "Enter Form Number",
                            hintStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.018,

                            ),
                            isDense: true,

                            contentPadding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.012,
                              horizontal: 12,
                            ),
                            prefixIcon: Icon(Icons.insert_drive_file,size: MediaQuery.of(context).size.height * 0.025,), // your icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:  BorderSide(color: AppColors.appColor, width: 2),
                            ),

                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                       // width: screenW * 0.6,
                        height: 40,
                        child: Obx(() {
                          return ElevatedButton(
                            onPressed: formController.isLoading.value
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              if (formNoCtrl.text.isEmpty) {
                                showTopSnackBar(
                                  context,
                                  "Please enter Form Number",
                                  Colors.red,
                                );
                                return;
                              }
                              formController.verifyForm(
                                context: context,
                                formNo: formNoCtrl.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              disabledBackgroundColor: appColor.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            child: formController.isLoading.value
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: SpinKitWave(
                                color: Colors.white,
                                size: 22,
                              ),
                            )
                                : const Text(
                              "Verify",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }

              // Show both sections when form is verified
              return Column(
                children: [
                  // Upper section with input and button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenW * 0.07,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        Text(
                          "Verify Your Form",
                          style: TextStyle(
                            fontSize: screenW * 0.06,
                            fontWeight: FontWeight.bold,
                            color: appColor,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// INPUT
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: TextField(
                            controller: formNoCtrl,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [UpperCaseTextFormatter()],
                            decoration: const InputDecoration(
                              hintText: "Enter Form Number",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.insert_drive_file),
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        SizedBox(
                          width: screenW * 0.6,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: formController.isLoading.value
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              if (formNoCtrl.text.isEmpty) {
                                showTopSnackBar(
                                  context,
                                  "Please enter Form Number",
                                  Colors.red,
                                );
                                return;
                              }
                              formController.verifyForm(
                                context: context,
                                formNo: formNoCtrl.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              disabledBackgroundColor: appColor.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            child: formController.isLoading.value
                                ? const SpinKitWave(
                              color: Colors.white,
                              size: 22,
                            )
                                : const Text(
                              "Verify",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                    height: 20,
                  ),

                  // Status card section (expands to fill remaining space)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenW * 0.04,
                        vertical: 10,
                      ),
                      child: statusCard(
                        screenW: screenW,
                        project: formController.branchName.value,
                        formNo: formController.formNumber.value,
                        formStatus: formController.formStatus.value,
                        formCurrency: formController.formCurrency.value,
                      ),
                    ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }

  // ================= STATUS CARD =================

  Widget statusCard({
    required double screenW,
    required String project,
    required String formNo,
    required String formStatus,
    required String formCurrency,
  }) {
    /// Get status details based on status code
    final statusDetails = _getStatusDetails(formStatus);

    /// HEADER TEXT
    final String headerText = statusDetails['title'] ?? "Unknown Status";

    /// HEADER COLOR
    final Color headerColor = statusDetails['color'] ?? Colors.grey;

    /// STATUS DETAIL TEXT
    final String statusDetail = statusDetails['description'] ?? "Status not recognized";

    /// STATUS DETAIL COLOR
    final Color statusColor = statusDetails['color'] ?? Colors.grey;

    /// Determine which image to show based on currency
    String getCurrencyImage() {
      if (formCurrency == "50") {
        return ImageConstant.rs50;
      }
      else if (formCurrency == "10") {
        return ImageConstant.rs10;
      }
      else if (formCurrency == "20") {
        return ImageConstant.rs20;
      }
      else if (formCurrency == "100") {
        return ImageConstant.rs100;
      } else if (formCurrency == "500") {
        return ImageConstant.rs500;
      } else if (formCurrency == "1000") {
        return ImageConstant.rs1000;
      } else if (formCurrency == "5000") {
        return ImageConstant.rs5000;
      } else {
        // Default image if currency is not recognized
        return ImageConstant.rs20;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Text(
              headerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _row("Project", project),

                const Divider(),

                _row(
                  "Status Detail",
                  statusDetail,
                  valueColor: statusColor,
                ),

                const SizedBox(height: 18),

                AspectRatio(
                  aspectRatio: 17 / 8,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Stack(
                      children: [
                        // Use the currency-based image
                        Image.asset(
                          getCurrencyImage(),
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                        ),

                        Positioned(
                          top: 5,
                          right: 5,
                          child: Text(
                            formNo,
                            style: TextStyle(
                              fontSize: screenW * 0.032,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 5,
                          left: 10,
                          child: Text(
                            formNo,
                            style: TextStyle(
                              fontSize: screenW * 0.032,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
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

  // Helper function to get status details
  Map<String, dynamic> _getStatusDetails(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'I':
        return {
          'title': "Normal / Ready",
          'description': "Normal - Ready for buying and selling",
          'color': Colors.green, // bg-success-custom equivalent
        };
      case 'R':
        return {
          'title': "Active / Not Ready",
          'description': "Normal - Not ready for buying and selling",
          'color': Colors.orange, // bg-warning-custom equivalent
        };
      case 'C':
        return {
          'title': "Cancelled",
          'description': "Cancelled - This form has been cancelled",
          'color': Colors.red, // bg-danger-custom equivalent
        };
      case 'A':
        return {
          'title': "Adjusted",
          'description': "Adjusted - Not ready for buying and selling",
          'color': Colors.blue, // bg-info-custom equivalent
        };
      default:
        return {
          'title': "Unknown Status",
          'description': "Status code not recognized",
          'color': Colors.grey, // bg-secondary equivalent
        };
    }
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}