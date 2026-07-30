import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/booking/presentation/controllers/get_projects_controller.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/widgets/toast_message.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedProject;
  String? selectedBlock;
  String? selectedPlotNatureCode;
  String? selectedPlotType;
  String? selectedPlotSize;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController plotNoController = TextEditingController();

  final BookingController bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    _resetForm();
  }

  void _resetForm() {
    selectedProject = null;
    selectedBlock = null;
    selectedPlotNatureCode = null;
    selectedPlotType = null;
    selectedPlotSize = null;

    nameController.clear();
    cnicController.clear();
    cityController.clear();
    contactController.clear();
    emailController.clear();
    plotNoController.clear();

    bookingController.selectedBranchName.value = "";
    bookingController.selectedBranchCode.value = "";
    bookingController.selectedBlockName.value = "";
    bookingController.selectedBlockCode.value = "";
    bookingController.blocks.clear();
    bookingController.plotSizes.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    final double defaultTextFieldHeight = screenHeight * 0.06;
    final double borderRadius = screenWidth * 0.07;
    final double dropdownHeight = screenHeight * 0.052;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Booking Form",
          style: TextStyle(
            color: AppColors.whiteBg,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: isSmallScreen ? 50 : kToolbarHeight,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/booking_bg.png'),
                    opacity: 0.1,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                child: Obx(() {
                  final double itemHeight = dropdownHeight; // same jo tum use kar rahe ho
                  final double maxVisibleItems = 5;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFieldWithHeader(
                            header: 'Project*',
                            screenWidth: screenWidth,
                            borderRadius: borderRadius,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  bookingController.isLoading.value
                                      ? "Loading projects..."
                                      : "Select Project",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: bookingController.isLoading.value
                                        ? Colors.black38
                                        : Colors.black54,
                                  ),
                                ),
                                items: bookingController.branches.length > 1
                                    ? bookingController.branches.sublist(1).map((branch) {
                                  return DropdownMenuItem<String>(
                                    value: branch["brn_name"]?.trim(),
                                    child: Text(
                                      branch["brn_name"]?.trim() ?? "",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  );
                                }).toList()
                                    : [],
                                value: selectedProject,
                                onChanged: bookingController.isLoading.value
                                    ? null
                                    : (value) {
                                  setState(() {
                                    selectedProject = value;
                                    selectedBlock = null;
                                  });
                                  bookingController.selectBranch(value ?? "");
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: dropdownHeight,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    border: Border.all(
                                      color: AppColors.appColor,
                                    ),
                                    color: AppColors.bgColor,
                                  ),
                                  elevation: 0,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: isSmallScreen ? 24 : 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: screenHeight * 0.35,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -5),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all<double>(6),
                                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: dropdownHeight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                            SizedBox(height: screenHeight * 0.012),
                          _buildFieldWithHeader(
                            header: 'Block/Floor*',
                            screenWidth: screenWidth,
                            borderRadius: borderRadius,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  bookingController.isLoading.value
                                      ? "Loading blocks/floor..."
                                      : "Select Block/Floor",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: bookingController.isLoading.value
                                        ? Colors.black38
                                        : Colors.black54,
                                  ),
                                ),
                                items: bookingController.blocks.map((block) {
                                  return DropdownMenuItem<String>(
                                    value: block["block_name"],
                                    child: Text(
                                      block["block_name"] ?? "",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: selectedBlock,
                                onChanged: bookingController.isLoading.value
                                    ? null
                                    : (value) {
                                  setState(() {
                                    selectedBlock = value;
                                  });
                                  bookingController.selectBlock(value ?? "");
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: dropdownHeight,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    border: Border.all(
                                      color: AppColors.appColor,
                                    ),
                                    color: AppColors.bgColor,
                                  ),
                                  elevation: 0,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: isSmallScreen ? 24 : 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: screenHeight * 0.35,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -5),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all<double>(6),
                                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: dropdownHeight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          _buildFieldWithHeader(
                            header: 'Plot/Unit Nature*',
                            screenWidth: screenWidth,
                            borderRadius: borderRadius,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  "Select Plot/Unit Nature",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: "Commercial",
                                    child: Text("Commercial"),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: "Residential",
                                    child: Text("Residential"),
                                  ),
                                ],
                                value: selectedPlotNatureCode,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPlotNatureCode = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: dropdownHeight,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    border: Border.all(
                                      color: AppColors.appColor,
                                    ),
                                    color: AppColors.bgColor,
                                  ),
                                  elevation: 0,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: isSmallScreen ? 24 : 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: screenHeight * 0.35,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -5),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all<double>(6),
                                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: dropdownHeight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          _buildFieldWithHeader(
                            header: 'Prefrence *',
                            screenWidth: screenWidth,
                            borderRadius: borderRadius,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  bookingController.isLoading.value
                                      ? "Loading Prefrence..."
                                      : "Select Prefrence",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: bookingController.isLoading.value
                                        ? Colors.black38
                                        : Colors.black54,
                                  ),
                                ),
                                items: bookingController.plotTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type["plot_type"],
                                    child: Text(
                                      type["plot_type_desc"] ?? "",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: selectedPlotType,
                                onChanged: bookingController.isLoading.value
                                    ? null
                                    : (value) {
                                  setState(() {
                                    selectedPlotType = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: dropdownHeight,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    border: Border.all(
                                      color: AppColors.appColor,
                                    ),
                                    color: AppColors.bgColor,
                                  ),
                                  elevation: 0,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: isSmallScreen ? 24 : 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: itemHeight * maxVisibleItems,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -5),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all<double>(6),
                                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: dropdownHeight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          _buildFieldWithHeader(
                            header: 'Plot/Unit Size*',
                            screenWidth: screenWidth,
                            borderRadius: borderRadius,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  "Select Plot/Unit Size",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                items: bookingController.plotSizes.map((plot) {
                                  return DropdownMenuItem<String>(
                                    value: plot["plot_size_code"],
                                    child: Text(
                                      plot["plot_size_code"] ?? "",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: selectedPlotSize,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPlotSize = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: dropdownHeight,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    border: Border.all(
                                      color: AppColors.appColor,
                                    ),
                                    color: AppColors.bgColor,
                                  ),
                                  elevation: 0,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: isSmallScreen ? 24 : 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: screenHeight * 0.35,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    color: Colors.white,
                                  ),
                                  offset: const Offset(0, -5),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all<double>(6),
                                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: dropdownHeight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          CustomTextField(
                            controller: plotNoController,
                            label: 'Plot/Unit No.',
                            labelStyle: TextStyle(fontWeight: FontWeight.w600,),
                            hintText: 'Add Plot/Unit No.',
                            isSignUpStyle: true,
                            borderRadius: screenWidth * 0.3,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(height: screenHeight * 0.012),

                          CustomTextField(
                            controller: nameController,
                            label: 'Name*',
                            labelStyle: TextStyle(fontWeight: FontWeight.w600,),
                            hintText: 'Add Name',
                            isSignUpStyle: true,
                            borderRadius: screenWidth * 0.3,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),

                          SizedBox(height: screenHeight * 0.012),
                          CustomTextField(
                            controller: contactController,
                            label: 'Mobile No.*',
                            labelStyle: TextStyle(fontWeight: FontWeight.w600,),
                            hintText: 'Add Mobile No.',
                            keyboardType: TextInputType.phone,
                            isSignUpStyle: true,
                            borderRadius: screenWidth * 0.3,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          // _buildFieldWithHeader(
                          //   header: 'Plot/Unit Nature*',
                          //   screenWidth: screenWidth,
                          //   borderRadius: borderRadius,
                          //   child: DropdownButtonHideUnderline(
                          //     child: DropdownButton2<String>(
                          //       isExpanded: true,
                          //       hint: Text(
                          //         bookingController.isLoading.value
                          //             ? "Loading plot/unit natures..."
                          //             : "Select Plot/Unit Nature",
                          //         style: TextStyle(
                          //           fontSize: isSmallScreen ? 12 : 14,
                          //           color: bookingController.isLoading.value
                          //               ? Colors.black38
                          //               : Colors.black54,
                          //         ),
                          //       ),
                          //       items: bookingController.plotNatures.map((nature) {
                          //         return DropdownMenuItem<String>(
                          //           value: nature["plot_nature"],
                          //           child: Text(
                          //             nature["plot_nature_desc"] ?? "",
                          //             style: TextStyle(
                          //               fontSize: isSmallScreen ? 12 : 14,
                          //             ),
                          //           ),
                          //         );
                          //       }).toList(),
                          //       value: selectedPlotNatureCode,
                          //       onChanged: bookingController.isLoading.value
                          //           ? null
                          //           : (value) {
                          //         setState(() {
                          //           selectedPlotNatureCode = value;
                          //         });
                          //       },
                          //       buttonStyleData: ButtonStyleData(
                          //         height: dropdownHeight,
                          //         width: double.infinity,
                          //         padding: EdgeInsets.symmetric(
                          //           horizontal: screenWidth * 0.04,
                          //         ),
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(borderRadius),
                          //           border: Border.all(
                          //             color: AppColors.appColor,
                          //           ),
                          //           color: AppColors.bgColor,
                          //         ),
                          //         elevation: 0,
                          //       ),
                          //       iconStyleData: IconStyleData(
                          //         icon: Icon(
                          //           Icons.arrow_drop_down,
                          //           color: Colors.black45,
                          //         ),
                          //         iconSize: isSmallScreen ? 24 : 30,
                          //       ),
                          //       dropdownStyleData: DropdownStyleData(
                          //         maxHeight: screenHeight * 0.35,
                          //         width: screenWidth * 0.9,
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(borderRadius),
                          //           color: Colors.white,
                          //         ),
                          //         offset: const Offset(0, -5),
                          //         scrollbarTheme: ScrollbarThemeData(
                          //           radius: const Radius.circular(40),
                          //           thickness: MaterialStateProperty.all<double>(6),
                          //           thumbVisibility: MaterialStateProperty.all<bool>(true),
                          //         ),
                          //       ),
                          //       menuItemStyleData: MenuItemStyleData(
                          //         height: dropdownHeight,
                          //         padding: EdgeInsets.symmetric(
                          //           horizontal: screenWidth * 0.04,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // SizedBox(height: screenHeight * 0.012),
                          // CustomTextField(
                          //   controller: cnicController,
                          //   label: 'CNIC',
                          //   labelStyle: TextStyle(fontWeight: FontWeight.w600,),
                          //   hintText: 'Add CNIC',
                          //   keyboardType: TextInputType.number,
                          //   isSignUpStyle: true,
                          // ),
                          SizedBox(height: screenHeight * 0.012),
                          CustomTextField(
                            controller: cityController,
                            label: 'City',
                            labelStyle: TextStyle(fontWeight: FontWeight.w600,),
                            hintText: 'Add City',
                            keyboardType: TextInputType.text,
                            isSignUpStyle: true,
                            borderRadius: screenWidth * 0.3,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          CustomTextField(
                            controller: emailController,
                            label: 'Email',
                            labelStyle: TextStyle(fontWeight: FontWeight.w600,),
                            hintText: 'Add Email',
                            keyboardType: TextInputType.emailAddress,
                            isSignUpStyle: true,
                            borderRadius: screenWidth * 0.3,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          bookingController.isLoading.value
                              ? Center(
                            child: SpinKitWave(
                              color: Colors.black87,
                              size: screenWidth * 0.07,
                            ),
                          )
                              : Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? screenWidth * 0.2 : 0,
                            ),
                            child: Center(
                              child: CustomButton(
                                text: 'Submit',
                                onPressed: _submitForm,
                                borderRadius: screenHeight * 0.03,
                                autoWidth: true,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWithHeader({
    required String header,
    required double screenWidth,
    required double borderRadius,
    TextEditingController? controller,
    TextInputType? keyboardType,
    Widget? child,
    bool isEmail = false,
  }) {
    final isSmallScreen = screenWidth < 360;

    // Responsive font sizes (matching CustomTextField)
    final double labelFontSize = screenWidth > 600 ? 14 : 13;
    final double labelSpacing = MediaQuery.of(context).size.height * 0.008;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.01, bottom: labelSpacing),
          child: Text(
            header,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (child != null) child,
        if (controller != null)
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth > 600 ? 15 : 14,
            ),
            validator: isEmail
                ? (value) {
              if (value == null || value.isEmpty) {
                return null;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            }
                : null,
            decoration: InputDecoration(
              hintText: 'Add ${header.replaceAll('*', '').trim()}',
              hintStyle: TextStyle(
                color: Colors.black38,
                fontSize: screenWidth > 600 ? 15 : 14,
              ),
              filled: true,
              fillColor: AppColors.bgColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.appColor),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.appColor),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.appColor, width: 2),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
            ),
          ),
      ],
    );
  }

  void _submitForm() {
    if (selectedProject == null ||
        selectedBlock == null ||
        selectedPlotType == null ||
        selectedPlotNatureCode == null ||
        selectedPlotSize == null ||
        nameController.text.isEmpty ||
        contactController.text.isEmpty) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please fill all required fields",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    if (emailController.text.isNotEmpty &&
        !RegExp(r'^[\w\.\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text)) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please enter a valid email address",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    bookingController.submitBooking(
      brnCode: bookingController.selectedBranchCode.value,
      // idNo: cnicController.text.trim(),
      contactName: nameController.text.trim(),
      contactNo: contactController.text.trim(),
      plotSizeCode: selectedPlotSize ?? "",
      plotNo: plotNoController.text.trim(),
      blockNo: bookingController.selectedBlockCode.value,
      email: emailController.text.trim(),
      plotNature: selectedPlotNatureCode ?? "",
      plotType: selectedPlotType ?? "",
      context: context,
    );
  }
}