import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/constants/image_url_helper.dart';
import 'package:pakland/features/company/data/repositories/company_repo.dart';
import 'package:pakland/core/constants/api_constant.dart';

class CompanyController extends GetxController {
  final CompanyRepository _companyRepo = CompanyRepository();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  var socialLinks = <Map<String, dynamic>>[].obs;
  var mobileSOPs = <Map<String, dynamic>>[].obs;
  var mobileDocuments = <Map<String, dynamic>>[].obs;
  var sliders = <Map<String, dynamic>>[].obs;
  var mobileTabs = <Map<String, dynamic>>[].obs;
  var activeMobileTabs = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var privacyPolicy = ''.obs;
  var whatsappNumber = ''.obs;
  var isShowCloseStatus = false.obs;
  var alterMessage = ''.obs; // Added this

  var baseUrl = ''.obs;
  bool _dataLoaded = false;

  @override
  void onInit() {
    super.onInit();
    loadCompanyDataFromStorage();
  }

  void _filterActiveTabs() {
    activeMobileTabs.value = mobileTabs.where((tab) {
      final isActive = tab['isActive'];
      return isActive == true || isActive == 'true' || isActive == 1;
    }).toList();

    debugPrint('✅ Filtered ${mobileTabs.length} tabs to ${activeMobileTabs.length} active tabs');
  }

  Future<void> fetchAndStoreCompanyDetails(String compCode) async {
    try {
      isLoading.value = true;

      final companyData = await _companyRepo.fetchCompanyDetails(compCode);

      if (companyData["StatusCode"] == "200") {
        final companyObj = companyData["obj"];

        baseUrl.value = ApiConstants.baseUrl;

        final whats = (companyObj["whatsapp_number"] ?? '').toString();
        if (whats.isNotEmpty) {
          whatsappNumber.value = whats;
          await storage.write(key: "whatsapp_number", value: whats);
        }

        // Store is_show_close_status
        final showCloseStatus = companyObj["is_show_close_status"] ?? false;
        isShowCloseStatus.value = showCloseStatus;
        await storage.write(key: "is_show_close_status", value: showCloseStatus.toString());

        // Store alter_message
        final alterMsg = companyObj["alter_message"]?.toString() ??
            "This file is canceled/locked. Please contact support department for more details.";
        alterMessage.value = alterMsg;
        await storage.write(key: "alter_message", value: alterMsg);

        await storage.write(key: "company_data", value: jsonEncode(companyObj));
        await storage.write(
          key: "social_Links",
          value: jsonEncode(companyObj["social_Links"] ?? []),
        );
        await storage.write(
          key: "mobile_payment_plan",
          value: jsonEncode(companyObj["mobile_payment_plan"] ?? []),
        );
        await storage.write(
          key: "mobile_SOPs",
          value: jsonEncode(companyObj["mobile_SOPs"] ?? []),
        );
        await storage.write(
          key: "mobile_Documents",
          value: jsonEncode(companyObj["mobile_Documents"] ?? []),
        );
        await storage.write(
          key: "sliders",
          value: jsonEncode(companyObj["sliders"] ?? []),
        );
        await storage.write(
          key: "mobile_home_menu",
          value: jsonEncode(companyObj["mobile_home_menu"] ?? []),
        );
        await storage.write(
          key: "base_url",
          value: baseUrl.value,
        );

        if (companyObj["privacy_policy"] != null) {
          await storage.write(
            key: "privacy_policy",
            value: companyObj["privacy_policy"].toString(),
          );
          privacyPolicy.value = companyObj["privacy_policy"].toString();
        }

        // Update all observables
        socialLinks.value = List<Map<String, dynamic>>.from(companyObj["social_Links"] ?? []);
        mobileSOPs.value = List<Map<String, dynamic>>.from(companyObj["mobile_SOPs"] ?? []);
        mobileDocuments.value = List<Map<String, dynamic>>.from(companyObj["mobile_Documents"] ?? []);
        sliders.value = List<Map<String, dynamic>>.from(companyObj["sliders"] ?? []);
        mobileTabs.value = List<Map<String, dynamic>>.from(companyObj["mobile_home_menu"] ?? []);

        // Filter active tabs
        _filterActiveTabs();

        _dataLoaded = true;
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint("Error storing company details: $e");
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> loadCompanyDataFromStorage() async {
    final socialLinksJson = await storage.read(key: 'social_Links');
    final sopsJson = await storage.read(key: 'mobile_SOPs');
    final documentsJson = await storage.read(key: 'mobile_Documents');
    final slidersJson = await storage.read(key: 'sliders');
    final mobileTabsJson = await storage.read(key: 'mobile_home_menu');
    final baseUrlData = await storage.read(key: 'base_url');
    final privacyPolicyData = await storage.read(key: 'privacy_policy');
    final isShowCloseStatusData = await storage.read(key: 'is_show_close_status');
    final alterMessageData = await storage.read(key: 'alter_message'); // Added this

    final whatsapp = await storage.read(key: 'whatsapp_number');
    if (whatsapp != null && whatsapp.isNotEmpty) {
      whatsappNumber.value = whatsapp;
    }

    if (baseUrlData != null) {
      baseUrl.value = baseUrlData;
    } else {
      baseUrl.value = ApiConstants.baseUrl;
    }

    // Load is_show_close_status
    if (isShowCloseStatusData != null) {
      isShowCloseStatus.value = isShowCloseStatusData.toLowerCase() == 'true';
    }

    // Load alter_message
    if (alterMessageData != null) {
      alterMessage.value = alterMessageData;
    } else {
      alterMessage.value = "This file is canceled/locked. Please contact support department for more details.";
    }

    if (socialLinksJson != null) {
      socialLinks.value = List<Map<String, dynamic>>.from(jsonDecode(socialLinksJson));
    }

    if (sopsJson != null) {
      mobileSOPs.value = List<Map<String, dynamic>>.from(jsonDecode(sopsJson));
    }

    if (documentsJson != null) {
      mobileDocuments.value = List<Map<String, dynamic>>.from(jsonDecode(documentsJson));
    }

    if (slidersJson != null) {
      sliders.value = List<Map<String, dynamic>>.from(jsonDecode(slidersJson));
    }

    if (mobileTabsJson != null) {
      mobileTabs.value = List<Map<String, dynamic>>.from(jsonDecode(mobileTabsJson));
      // Filter active tabs
      _filterActiveTabs();
    }

    if (privacyPolicyData != null) {
      privacyPolicy.value = privacyPolicyData;
    }

    _dataLoaded = true;
    isLoading.value = false;
  }

  /// Resolves an image path coming from the API into a URL that
  /// Image.network can actually load (handles "/Upload/..." relative
  /// paths and Google Drive share links).
  String getFullImageUrl(String path) {
    return ImageUrlHelper.resolve(path, baseUrl.value);
  }

  bool get isDataLoaded => _dataLoaded;

  List<Map<String, dynamic>> getActiveMobileTabs() {
    return activeMobileTabs.toList();
  }

  Future<String?> getPrivacyPolicy() async {
    if (privacyPolicy.isNotEmpty) {
      return privacyPolicy.value;
    }

    final storedPolicy = await storage.read(key: 'privacy_policy');
    if (storedPolicy != null) {
      privacyPolicy.value = storedPolicy;
      return storedPolicy;
    }

    return null;
  }

  // Getter for isShowCloseStatus
  bool get showCloseStatus => isShowCloseStatus.value;

  // Getter for alterMessage
  String get alterMessageValue => alterMessage.value;
}