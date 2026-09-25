import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/feedback/presentation/controllers/add_feedback_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/widgets/message_field.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/screens/profile_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackController _controller = Get.put(FeedbackController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  final TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  Future<void> _handleSend() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty && email.isEmpty && phone.isEmpty && message.isEmpty) {
      showTopSnackBar(context, title: "Alert","All fields are required.", Colors.red.withOpacity(0.7),  icon: Icons.warning);
      return;
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      showTopSnackBar(context, title: "Alert","Please enter a valid email address.", Colors.red.withOpacity(0.7),  icon: Icons.warning);
      return;
    }

    final success = await _controller.sendFeedback(
      context: context,
      name: name,
      email: email,
      phone: phone,
      message: message,
    );

    if (success) {
      Navigator.pop(context);
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
          title: Text("Feedback",style: TextStyle(color: AppColors.whiteBg),),
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:  EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20,),
                          CustomTextField(
                            label: "Name*",
                            labelStyle: labelStyle,
                            hintText: "Enter Name",
                            controller: _nameController,
                            isSignUpStyle: true,
                            imagePath: ImageConstant.user,
                          ),
                           SizedBox(height: 16),

                          CustomTextField(
                            label: "Phone No.*",
                            labelStyle: labelStyle,
                            hintText: "xxxxxxxxxx",
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            imagePath: ImageConstant.cell,
                            isSignUpStyle: true,
                          ),
                          SizedBox(height: 16),

                          CustomTextField(
                            label: "Email*",
                            labelStyle: labelStyle,
                            hintText: "Enter Email",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            isSignUpStyle: true,
                            imagePath: ImageConstant.mail,
                          ),
                          const SizedBox(height: 16),

                          MessageTextField(
                            label: "Message*",
                            labelStyle: labelStyle,
                            hintText: "Your message...",
                            controller: _messageController,
                          ),
                          SizedBox(height: 20,),
                          Obx(
                                () => CustomButton(
                              text: "SEND",
                              onPressed: _handleSend,
                              isLoading: _controller.isLoading.value,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}