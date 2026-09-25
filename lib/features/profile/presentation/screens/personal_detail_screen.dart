import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/customer_portal/presentation/controllers/get_customer_portal_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/widgets/message_field.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/controllers/update_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _storage = const FlutterSecureStorage();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _hintName;
  String? _hintMobile;
  String? _hintEmail;
  String? _hintAddress;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _storage.read(key: "user_name") ?? "";
      final mobile = await _storage.read(key: "mobile_no1") ?? "";
      final email = await _storage.read(key: "email_no1") ?? "";
      final address = await _storage.read(key: "address") ?? "";
      final profileImagePath = await _storage.read(key: "profile_image_path") ?? "";
      final customerAddress = await _storage.read(key: "customer_address") ?? "";

      setState(() {
        _hintName = name.isNotEmpty ? name : "Enter your name";
        _hintMobile = mobile.isNotEmpty ? mobile : "Enter your mobile number";
        _hintEmail = email.isNotEmpty ? email : "Enter your email";

        // Use customer address if available, otherwise use regular address or default hint
        final displayAddress = customerAddress.isNotEmpty
            ? customerAddress
            : (address.isNotEmpty ? address : "Enter your address");

        _hintAddress = displayAddress;
      });

      setState(() {
        nameController.text = name;
        mobileController.text = mobile;
        emailController.text = email;

        // Use customer address if available, otherwise use regular address
        addressController.text = customerAddress.isNotEmpty
            ? customerAddress
            : address;

        _profileImagePath = profileImagePath;
      });
    } catch (e) {
      setState(() {
        nameController.text = "";
        mobileController.text = "";
        emailController.text = "";
        addressController.text = "";
        _hintAddress = "Enter your address";
        _profileImagePath = null;
      });
    }
  }

  String _getProfileImageUrl() {
    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      return '';
    }

    if (_profileImagePath!.startsWith('http')) {
      return _profileImagePath!;
    }

    return '${ApiConstants.baseUrl}/${_profileImagePath!.replaceAll('\\', '/')}';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("View Profile",style: TextStyle(color: AppColors.whiteBg),),
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            _buildProfileImage(),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              "Profile Photo",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      CustomTextField(
                        label: "Name*",
                        hintText: _hintName ?? "Enter your name",
                        controller: nameController,
                        isSignUpStyle: true,
                        imagePath: ImageConstant.user,
                        readOnly: true,
                        borderRadius: 30,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        label: "Mobile No.*",
                        hintText: _hintMobile ?? "Enter your mobile number",
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        isSignUpStyle: true,
                        imagePath: ImageConstant.cell,
                        readOnly: true, borderRadius: 30,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                      SizedBox(height: screenHeight * 0.01),
                      CustomTextField(
                        label: "Email*",
                        hintText: _hintEmail ?? "Enter your email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        isSignUpStyle: true,
                        imagePath: ImageConstant.mail,
                       readOnly: true,
                        borderRadius: 30,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      MessageTextField(
                        label: "Address",
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        hintText: _hintAddress ?? "Enter your address",
                        controller: addressController,
                       readOnly: true,
                        borderRadius: 30,
                      ),
                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImageUrl = _getProfileImageUrl();
    final screenWidth = MediaQuery.of(context).size.width;

    if (profileImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        child: Image.network(
          profileImageUrl,
          width: screenWidth * 0.35,
          height: screenWidth * 0.35,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              ImageConstant.user_profile,
              width: screenWidth * 0.35,
              height: screenWidth * 0.35,
              fit: BoxFit.cover,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: screenWidth * 0.35,
              height: screenWidth * 0.35,
              alignment: Alignment.center,
              child: SpinKitWave(
                color: AppColors.appColor,
                size: screenWidth * 0.05,
              ),
            );
          },
        ),
      );
    } else {
      return Image.asset(
        ImageConstant.user_profile,
        width: screenWidth * 0.35,
        height: screenWidth * 0.35,
        fit: BoxFit.cover,
      );
    }
  }
}