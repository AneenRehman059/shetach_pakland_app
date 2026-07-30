import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/social/presentation/controllers/social_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/utils/screen_helper.dart';

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
    final bool isTV = ScreenHelper.isTV(context);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async { Get.offAll(() => MainWrapper()); return false; },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sales Centers", style: TextStyle(color: AppColors.whiteBg, fontSize: isTV ? 22 : 16)),
          centerTitle: true, backgroundColor: AppColors.appColor,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: isTV ? 70 : kToolbarHeight,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.015),
                child: Text('Main Offices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTV ? 24 : w * 0.045)),
              ),
              Expanded(
                child: Obx(() {
                  if (socialController.isLoading.value) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SpinKitWave(color: AppColors.appColor, size: 50.0),
                      Text('Loading', style: TextStyle(color: AppColors.appColor)),
                    ]));
                  }

                  if (isTV) {
                    // TV — 2 column grid with full detail cards
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: w * 0.03,
                        mainAxisSpacing: h * 0.02,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: socialController.branches.length,
                      itemBuilder: (context, index) {
                        final branch = socialController.branches[index];
                        final whatsapp = companyController.whatsappNumber.value;
                        return _TVBranchCard(
                          branch: branch, whatsapp: whatsapp,
                          onCall: () => _makePhoneCall(branch['phone_no'] ?? ''),
                          onEmail: () => _sendEmail(branch['email_address'] ?? ''),
                          onWhatsApp: () => _openWhatsApp(whatsapp),
                          onMap: () => _openMaps(branch['latitude'] ?? '', branch['longitude'] ?? '', _formatAddress(branch)),
                        );
                      },
                    );
                  }

                  // Mobile — same as before
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
                    itemCount: socialController.branches.length,
                    itemBuilder: (context, index) {
                      final branch = socialController.branches[index];
                      final whatsapp = companyController.whatsappNumber.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _officeName(title: branch['brn_name'] ?? '', screenWidth: w),
                          SizedBox(height: h * 0.015),
                          _officeBlock(AppColors.lightAppColor,
                            address: _formatAddress(branch),
                            phone: branch['phone_no'] ?? '',
                            email: branch['email_address'] ?? '',
                            whatsapp: whatsapp,
                            latitude: branch['latitude'] ?? '',
                            longitude: branch['longitude'] ?? '',
                            screenWidth: w,
                          ),
                          SizedBox(height: h * 0.025),
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
    List<String> parts = [];
    void add(String? v) { if (v != null && v.trim().isNotEmpty) parts.add(v.trim()); }
    add(branch['add_1']); add(branch['add_2']); add(branch['add_3']); add(branch['add_4']);
    return parts.join(', ');
  }

  Widget _officeName({required String title, required double screenWidth}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.04),
      decoration: BoxDecoration(color: AppColors.lightAppColor, borderRadius: BorderRadius.circular(screenWidth * 0.02)),
      child: Row(children: [
        Image.asset('assets/images/building.png', height: screenWidth * 0.07, width: screenWidth * 0.07, color: Colors.white),
        SizedBox(width: screenWidth * 0.025),
        Expanded(child: Text(title.trim(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04))),
      ]),
    );
  }

  Widget _officeBlock(Color themeColor, {
    required String address, required String phone, required String email,
    required String whatsapp, required double screenWidth,
    required String latitude, required String longitude,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), border: Border.all(color: themeColor), borderRadius: BorderRadius.circular(screenWidth * 0.02)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (address.isNotEmpty) ...[
          GestureDetector(
            onTap: () => _openMaps(latitude, longitude, address),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.location_on, size: screenWidth * 0.06, color: AppColors.appColor),
              SizedBox(width: screenWidth * 0.025),
              Expanded(child: Text(address, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.blue))),
              if (latitude.isNotEmpty) Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(color: AppColors.appColor.withOpacity(0.1), borderRadius: BorderRadius.circular(screenWidth * 0.02)),
                child: Icon(Icons.navigation, color: AppColors.appColor, size: screenWidth * 0.06),
              ),
            ]),
          ),
          SizedBox(height: screenWidth * 0.03),
        ],
        if (phone.isNotEmpty) ...[
          GestureDetector(onTap: () => _makePhoneCall(phone), child: Row(children: [
            Icon(Icons.phone, size: screenWidth * 0.06, color: AppColors.appColor),
            SizedBox(width: screenWidth * 0.025),
            Text(phone, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.blue)),
          ])),
          SizedBox(height: screenWidth * 0.03),
        ],
        if (email.isNotEmpty) GestureDetector(onTap: () => _sendEmail(email), child: Row(children: [
          Icon(Icons.email, size: screenWidth * 0.06, color: AppColors.appColor),
          SizedBox(width: screenWidth * 0.025),
          Expanded(child: Text(email, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.blue))),
        ])),
        if (whatsapp.isNotEmpty) ...[
          SizedBox(height: screenWidth * 0.03),
          GestureDetector(onTap: () => _openWhatsApp(whatsapp), child: Row(children: [
            Image.asset(ImageConstant.whatsapp, height: screenWidth * 0.06, width: screenWidth * 0.06),
            SizedBox(width: screenWidth * 0.025),
            Text(whatsapp, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.blue)),
          ])),
        ],
      ]),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMaps(String lat, String lng, String address) async {
    if (lat.isEmpty || lng.isEmpty) { await _openMapsAddr(address); return; }
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    else await _openMapsAddr(address);
  }

  Future<void> _openMapsAddr(String address) async {
    final enc = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$enc');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// TV Branch Card with focus + full details
class _TVBranchCard extends StatefulWidget {
  final Map<String, dynamic> branch;
  final String whatsapp;
  final VoidCallback onCall, onEmail, onWhatsApp, onMap;

  const _TVBranchCard({required this.branch, required this.whatsapp, required this.onCall, required this.onEmail, required this.onWhatsApp, required this.onMap});

  @override
  State<_TVBranchCard> createState() => _TVBranchCardState();
}

class _TVBranchCardState extends State<_TVBranchCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.branch['brn_name'] ?? '';
    final phone = widget.branch['phone_no'] ?? '';
    final email = widget.branch['email_address'] ?? '';
    final address = [widget.branch['add_1'], widget.branch['add_2'], widget.branch['add_3'], widget.branch['add_4']]
        .where((v) => v != null && v.toString().trim().isNotEmpty).join(', ');

    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) => KeyEventResult.ignored,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isFocused ? AppColors.appColor : AppColors.lightAppColor, width: _isFocused ? 2.5 : 1),
          boxShadow: _isFocused ? [BoxShadow(color: AppColors.appColor.withOpacity(0.25), blurRadius: 16, spreadRadius: 2)] : [],
        ),
        padding: EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: AppColors.lightAppColor, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Image.asset('assets/images/building.png', height: 22, width: 22, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
          SizedBox(height: 10),
          // Address
          if (address.isNotEmpty)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.location_on, size: 18, color: AppColors.appColor),
              SizedBox(width: 6),
              Expanded(child: Text(address, style: TextStyle(fontSize: 12, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          Spacer(),
          // Action buttons
          Row(children: [
            if (phone.isNotEmpty) _btn(Icons.phone, 'Call', widget.onCall),
            if (phone.isNotEmpty) SizedBox(width: 6),
            if (email.isNotEmpty) _btn(Icons.email, 'Email', widget.onEmail),
            if (email.isNotEmpty) SizedBox(width: 6),
            if (widget.whatsapp.isNotEmpty) _btn(Icons.message, 'WA', widget.onWhatsApp),
            if (widget.whatsapp.isNotEmpty) SizedBox(width: 6),
            _btn(Icons.navigation, 'Map', widget.onMap),
          ]),
        ]),
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.appColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppColors.appColor, size: 18),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.appColor, fontWeight: FontWeight.bold)),
        ]),
      ),
    ));
  }
}