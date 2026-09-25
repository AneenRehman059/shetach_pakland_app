import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/feedback/presentation/controllers/add_feedback_controller.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/widgets/message_field.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/screens/profile_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final FeedbackController _feedbackController = Get.put(FeedbackController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();


  Future<void> _handleSend() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    // Validate required fields
    if (name.isEmpty || email.isEmpty || phone.isEmpty || message.isEmpty) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please fill all required fields.",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please enter a valid email address.",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    // Validate phone format
    if (!_isValidPhone(phone)) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please enter a valid phone number (10-15 digits).",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    final success = await _feedbackController.sendFeedback(
      context: context,
      name: name,
      email: email,
      phone: phone,
      message: message,
    );

    if (success) {
      // Clear all fields after successful submission
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();

      // Show success message
      showTopSnackBar(
        context,
        title: "Success",
        "Your message has been sent successfully!",
        Colors.green.withOpacity(0.7),
        icon: Icons.check_circle,
      );
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Help & Support",style: TextStyle(color: AppColors.whiteBg),),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Get.offAll(() => MainWrapper(initialIndex: 0));
              },
            ),
          ],
        ),
        body: _buildPortraitLayout(context),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final TextStyle labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Column(
      children: [
        SizedBox(height:screenHeight * 0.015,),
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  ImageConstant.supp,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.06,
                ),
                child: ListView(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Name*',
                      hintText: 'Enter Name',
                      borderRadius: 30,
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone No.*',
                      hintText: 'xxxxxxxxxxx',
                      keyboardType: TextInputType.number,  borderRadius: 30,
                    ),

                    SizedBox(height: screenHeight * 0.012),

                    CustomTextField(
                      controller: _emailController,
                      label: 'Email*',
                      hintText: 'Enter Email',
                      keyboardType: TextInputType.emailAddress,  borderRadius: 30,
                    ),

                    SizedBox(height: screenHeight * 0.012),
                    MessageTextField(
                      label: "Message*",
                      labelStyle: labelStyle,
                      hintText: "Your message...",
                      controller: _messageController,  borderRadius: 30,
                    ),

                    SizedBox(height: screenHeight * 0.02),
                    Obx(
                          () => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:  screenWidth * 0.26,
                            ),
                            child: CustomButton(
                                                    text: "SEND",
                                                    onPressed: _handleSend,
                                                    isLoading: _feedbackController.isLoading.value,
                                                    textColor: Colors.white,
                              borderRadius: 30,
                              autoWidth: true,
                                                  ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isValidPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanedPhone.length < 10 || cleanedPhone.length > 15) {
      return false;
    }
    return RegExp(r'^\d{10,15}$').hasMatch(cleanedPhone);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );
    return emailRegex.hasMatch(email);
  }

  Widget _buildContactInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String details,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.appColor, size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  details,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}