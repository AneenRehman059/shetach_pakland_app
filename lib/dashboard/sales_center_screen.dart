import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/colors.dart';
import 'package:pakland/constants/image_constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../bottom_app_bar/bottom_app_bar.dart';
import '../controllers/get_company_controller.dart';
import '../controllers/social_controller.dart';
import '../customs/toast_message.dart';

class SalesCenterScreen extends StatefulWidget {
  const SalesCenterScreen({super.key});

  @override
  State<SalesCenterScreen> createState() => _SalesCenterScreenState();
}

class _SalesCenterScreenState extends State<SalesCenterScreen> {
  final SocialController socialController = Get.put(SocialController());
  final CompanyController companyController = Get.find<CompanyController>();

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.lightAppColor;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => MainWrapper());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sales Centers", style: TextStyle(color: AppColors.whiteBg)),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                child: Text(
                  'Main Offices',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (socialController.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitWave(
                            color: AppColors.appColor,
                            size: 50.0,
                          ),
                          Text('Loading',style: TextStyle(color: AppColors.appColor),),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    itemCount: socialController.branches.length,
                    itemBuilder: (context, index) {
                      final branch = socialController.branches[index];
                      final whatsapp = companyController.whatsappNumber.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          officeName(
                            title: branch['brn_name'] ?? '',
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          officeBlock(
                            themeColor,
                            address: _formatAddress(branch),
                            phone: branch['phone_no'] ?? '',
                            email: branch['email_address'] ?? '',
                            whatsapp: whatsapp,
                            latitude: branch['latitude'] ?? '',
                            longitude: branch['longitude'] ?? '',
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.025),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> branch) {
    List<String> addressParts = [];

    void addIfNotEmpty(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        addressParts.add(value.trim());
      }
    }

    addIfNotEmpty(branch['add_1']);
    addIfNotEmpty(branch['add_2']);
    addIfNotEmpty(branch['add_3']);
    addIfNotEmpty(branch['add_4']);

    return addressParts.join('\n');
  }

  Widget officeName({required String title, required double screenWidth}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightAppColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/building.png',
            height: screenWidth * 0.07,
            width: screenWidth * 0.07,
            color: Colors.white,
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Text(
              title.trim(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget officeBlock(
      Color themeColor, {
        required String address,
        required String phone,
        required String email,
        required String whatsapp,
        required double screenWidth,
        required String latitude,
        required String longitude,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        border: Border.all(color: themeColor),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openMaps(latitude, longitude, address),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: screenWidth * 0.06, color: AppColors.appColor),
                        SizedBox(width: screenWidth * 0.025),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Location navigation icon added here
                if (latitude.isNotEmpty && longitude.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openMaps(latitude, longitude, address),
                    child: Image.asset(ImageConstant.map,height: screenWidth * 0.08,width: screenWidth * 0.08,),
                  ),
              ],
            ),
          if (address.isNotEmpty) SizedBox(height: screenWidth * 0.03),

          if (phone.isNotEmpty)
            GestureDetector(
              onTap: () => _makePhoneCall(phone),
              child: Row(
                children: [
                  Icon(Icons.phone, size: screenWidth * 0.06, color: AppColors.appColor),
                  SizedBox(width: screenWidth * 0.025),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          if (phone.isNotEmpty) SizedBox(height: screenWidth * 0.03),

          if (email.isNotEmpty)
            GestureDetector(
              onTap: () => _sendEmail(email),
              child: Row(
                children: [
                  Icon(Icons.email,
                      size: screenWidth * 0.06, color: AppColors.appColor),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (whatsapp.isNotEmpty) SizedBox(height: screenWidth * 0.03),
          if (whatsapp.isNotEmpty)
            GestureDetector(
              onTap: () => _openWhatsApp(whatsapp),
              child: Row(
                children: [
                  Image.asset(ImageConstant.whatsapp, height: screenWidth * 0.06, width: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.025),
                  Text(
                    whatsapp,
                    style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.blue
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showTopSnackBar(
        context,
        'Cannot make phone call to $phoneNumber',
        Colors.red,
        title: 'Call Failed',
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showTopSnackBar(
        context,
        'Cannot open email app for $emailAddress',
        Colors.red,
        title: 'Email Failed',
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final phoneDigits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri.parse('https://wa.me/$phoneDigits');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      showTopSnackBar(
        context,
        'Cannot open WhatsApp for $phone',
        Colors.red,
        title: 'WhatsApp Failed',
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _openMaps(String latitude, String longitude, String address) async {
    if (latitude.isEmpty || longitude.isEmpty) {
      await _openMapsWithAddress(address);
      return;
    }

    final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
    );

    final Uri appleMapsUri = Uri.parse(
        'https://maps.apple.com/?ll=$latitude,$longitude&q=$address'
    );

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      }
      else if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      }
      else {
        await _openMapsWithAddress(address);
      }
    } catch (e) {
      await _openMapsWithAddress(address);
    }
  }

  Future<void> _openMapsWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);

    final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress'
    );

    final Uri appleMapsUri = Uri.parse(
        'https://maps.apple.com/?q=$encodedAddress'
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      showTopSnackBar(
        context,
        'Cannot open maps for this location',
        Colors.red,
        title: 'Maps Failed',
        icon: Icons.error_outline,
      );
    }
  }
}