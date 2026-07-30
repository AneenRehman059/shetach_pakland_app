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
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/widgets/message_field.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/controllers/update_profile_controller.dart';
import 'package:pakland/core/utils/screen_helper.dart';

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

  String? _hintName, _hintMobile, _hintEmail, _hintAddress, _profileImagePath;

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
      final displayAddress = customerAddress.isNotEmpty ? customerAddress : (address.isNotEmpty ? address : "Enter your address");

      setState(() {
        _hintName = name.isNotEmpty ? name : "Enter your name";
        _hintMobile = mobile.isNotEmpty ? mobile : "Enter your mobile number";
        _hintEmail = email.isNotEmpty ? email : "Enter your email";
        _hintAddress = displayAddress;
        nameController.text = name;
        mobileController.text = mobile;
        emailController.text = email;
        addressController.text = customerAddress.isNotEmpty ? customerAddress : address;
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
    if (_profileImagePath == null || _profileImagePath!.isEmpty) return '';
    if (_profileImagePath!.startsWith('http')) return _profileImagePath!;
    return '${ApiConstants.baseUrl}/${_profileImagePath!.replaceAll('\\', '/')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async { Get.off(() => MainWrapper(initialIndex: 1)); return false; },
      child: Scaffold(
        appBar: AppBar(
          title: Text("View Profile", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: isTV ? 70 : kToolbarHeight,
          actions: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: isTV ? 30 : 24),
              onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
            ),
          ],
        ),
        body: SafeArea(
          child: isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.02),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Column(children: [
            _buildProfileImage(context),
            SizedBox(height: size.height * 0.01),
            Text("Profile Photo", style: TextStyle(color: Colors.grey, fontSize: size.width * 0.04)),
          ])),
          SizedBox(height: size.height * 0.03),
          CustomTextField(label: "Name*", hintText: _hintName ?? "Enter your name", controller: nameController, isSignUpStyle: true, imagePath: 'assets/images/user.png', readOnly: true, borderRadius: 30, height: size.height * 0.05),
          SizedBox(height: size.height * 0.01),
          CustomTextField(label: "Mobile No.*", hintText: _hintMobile ?? "Enter your mobile number", controller: mobileController, keyboardType: TextInputType.phone, isSignUpStyle: true, imagePath: 'assets/images/cell.png', readOnly: true, borderRadius: 30, height: size.height * 0.05),
          SizedBox(height: size.height * 0.01),
          CustomTextField(label: "Email*", hintText: _hintEmail ?? "Enter your email", controller: emailController, keyboardType: TextInputType.emailAddress, isSignUpStyle: true, readOnly: true, imagePath: 'assets/images/mail.png', borderRadius: 30, height: size.height * 0.05),
          SizedBox(height: size.height * 0.01),
          MessageTextField(label: "Address", readOnly: true, labelStyle: TextStyle(fontSize: 14, color: Colors.black87), hintText: _hintAddress ?? "Enter your address", controller: addressController, borderRadius: 30),
          SizedBox(height: size.height * 0.04),
        ]),
      )),
    ]);
  }

  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: EdgeInsets.all(size.width * 0.03),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,children: [
        SizedBox(
          width: size.width * 0.3,
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildProfileImage(context, isTV: true),
            SizedBox(height: 16),
            Text("Profile Photo", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ])),
        ),
        SizedBox(height: 16),
        _tvField("Name", nameController.text),
        SizedBox(height: 16),
        _tvField("Mobile No.", mobileController.text),
        SizedBox(height: 16),
        _tvField("Email", emailController.text),
        SizedBox(height: 16),
        _tvField("Address", addressController.text, multiline: true),
      ]),
    );
  }

  Widget _tvField(String label, String value, {bool multiline = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
      SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: multiline ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(value.isNotEmpty ? value : "-", style: TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    ]);
  }

  Widget _buildProfileImage(BuildContext context, {bool isTV = false}) {
    final profileImageUrl = _getProfileImageUrl();
    final size = MediaQuery.of(context).size;
    final imgSize = isTV ? size.height * 0.25 : size.width * 0.35;

    if (profileImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(isTV ? 16 : size.width * 0.05),
        child: Image.network(profileImageUrl, width: imgSize, height: imgSize, fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Image.asset(ImageConstant.user_profile, width: imgSize, height: imgSize, fit: BoxFit.cover),
          loadingBuilder: (c, child, progress) {
            if (progress == null) return child;
            return Container(width: imgSize, height: imgSize, alignment: Alignment.center, child: SpinKitWave(color: AppColors.appColor, size: 30));
          },
        ),
      );
    }
    return Image.asset(ImageConstant.user_profile, width: imgSize, height: imgSize, fit: BoxFit.cover);
  }
}