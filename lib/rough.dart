import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart'; // 🔽 ADD
import '../customs/toast_message.dart';
import '../repo/company_repo.dart';
import '../constants/api_constant.dart';
import 'dart:io';

import '../services/video_catch_helper.dart';

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
  var alterMessage = ''.obs;
  var advertiseVideoUrl = ''.obs;
  var cachedVideoFile = Rxn<File>();
  var isVideoDownloading = false.obs;
  String? _videoInitInFlightPath;

  // 🔽 ADD — pre-initialized, ready-to-render controller
  var welcomeVideoController = Rxn<VideoPlayerController>();
  var isWelcomeVideoReady = false.obs;
  String? _initializedVideoPath;
  bool _videoDownloadInFlight = false;

  var baseUrl = ''.obs;
  bool _dataLoaded = false;

  @override
  void onInit() {
    super.onInit();
    loadCompanyDataFromStorage();
  }

  @override
  void onClose() {
    welcomeVideoController.value?.dispose();
    super.onClose();
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

        _handleAdvertiseVideo(companyObj); // fire-and-forget, unchanged trigger point

        final whats = (companyObj["whatsapp_number"] ?? '').toString();
        if (whats.isNotEmpty) {
          whatsappNumber.value = whats;
          await storage.write(key: "whatsapp_number", value: whats);
        }

        final showCloseStatus = companyObj["is_show_close_status"] ?? false;
        isShowCloseStatus.value = showCloseStatus;
        await storage.write(key: "is_show_close_status", value: showCloseStatus.toString());

        final alterMsg = companyObj["alter_message"]?.toString() ??
            "This file is canceled/locked. Please contact support department for more details.";
        alterMessage.value = alterMsg;
        await storage.write(key: "alter_message", value: alterMsg);

        await storage.write(key: "company_data", value: jsonEncode(companyObj));
        await storage.write(key: "social_Links", value: jsonEncode(companyObj["social_Links"] ?? []));
        await storage.write(key: "mobile_payment_plan", value: jsonEncode(companyObj["mobile_payment_plan"] ?? []));
        await storage.write(key: "mobile_SOPs", value: jsonEncode(companyObj["mobile_SOPs"] ?? []));
        await storage.write(key: "mobile_Documents", value: jsonEncode(companyObj["mobile_Documents"] ?? []));
        await storage.write(key: "sliders", value: jsonEncode(companyObj["sliders"] ?? []));
        await storage.write(key: "mobile_home_menu", value: jsonEncode(companyObj["mobile_home_menu"] ?? []));
        await storage.write(key: "base_url", value: baseUrl.value);

        if (companyObj["privacy_policy"] != null) {
          await storage.write(key: "privacy_policy", value: companyObj["privacy_policy"].toString());
          privacyPolicy.value = companyObj["privacy_policy"].toString();
        }

        socialLinks.value = List<Map<String, dynamic>>.from(companyObj["social_Links"] ?? []);
        mobileSOPs.value = List<Map<String, dynamic>>.from(companyObj["mobile_SOPs"] ?? []);
        mobileDocuments.value = List<Map<String, dynamic>>.from(companyObj["mobile_Documents"] ?? []);
        sliders.value = List<Map<String, dynamic>>.from(companyObj["sliders"] ?? []);
        mobileTabs.value = List<Map<String, dynamic>>.from(companyObj["mobile_home_menu"] ?? []);

        _filterActiveTabs();

        _dataLoaded = true;
        isLoading.value = false;
      }
    } catch (e) {
      showTopSnackBar(
          Get.context!,
          title: "Alert",
          "Some technical fault occured! Try again later.",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning
      );
      debugPrint("Error storing company details: $e");
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> _handleAdvertiseVideo(Map<String, dynamic> companyObj) async {
    final rawPath = (companyObj["advertise_video"] ?? '').toString();
    if (rawPath.isEmpty) return;

    final normalizedPath = rawPath.replaceAll(r'\', '/');
    final fullUrl = getFullImageUrl(normalizedPath);
    advertiseVideoUrl.value = fullUrl;
    await storage.write(key: "advertise_video_url", value: fullUrl);

    final fileName = normalizedPath.split('/').last;

    // 1. Instant check — already cached from a previous run
    final existing = await VideoCacheHelper.getCachedFileIfExists(fileName);
    if (existing != null) {
      cachedVideoFile.value = existing;
      await _initializeVideoController(existing); // 🔽 pre-init here, not in the screen
      return;
    }

    // 2. Guard against duplicate concurrent downloads
    if (_videoDownloadInFlight) {
      debugPrint('⏭️ Video download already in progress, skipping duplicate call');
      return;
    }
    _videoDownloadInFlight = true;

    isVideoDownloading.value = true;
    final downloaded = await VideoCacheHelper.download(fullUrl, fileName);
    isVideoDownloading.value = false;
    _videoDownloadInFlight = false;

    if (downloaded != null) {
      cachedVideoFile.value = downloaded;
      await _initializeVideoController(downloaded); // 🔽 pre-init here too
    }
  }

  // 🔽 ADD — the whole point: controller is built + initialized here,
  // completely decoupled from WelcomeScreen's lifecycle
  Future<void> _initializeVideoController(File file) async {
    if (_initializedVideoPath == file.path && welcomeVideoController.value != null) {
      return; // already fully initialized for this file
    }
    if (_videoInitInFlightPath == file.path) {
      return; // another call is already initializing this exact file — bail out
    }
    _videoInitInFlightPath = file.path;

    final oldController = welcomeVideoController.value;
    final controller = VideoPlayerController.file(file);

    try {
      await controller.initialize();
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      welcomeVideoController.value = controller;
      isWelcomeVideoReady.value = true;
      _initializedVideoPath = file.path;

      await oldController?.dispose();
    } catch (e) {
      debugPrint('Failed to pre-initialize welcome video controller: $e');
      controller.dispose();
    } finally {
      if (_videoInitInFlightPath == file.path) {
        _videoInitInFlightPath = null;
      }
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
    final alterMessageData = await storage.read(key: 'alter_message');
    final companyDataJson = await storage.read(key: 'company_data');

    final whatsapp = await storage.read(key: 'whatsapp_number');
    if (whatsapp != null && whatsapp.isNotEmpty) {
      whatsappNumber.value = whatsapp;
    }

    if (baseUrlData != null) {
      baseUrl.value = baseUrlData;
    } else {
      baseUrl.value = ApiConstants.baseUrl;
    }

    if (isShowCloseStatusData != null) {
      isShowCloseStatus.value = isShowCloseStatusData.toLowerCase() == 'true';
    }

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
      _filterActiveTabs();
    }

    if (privacyPolicyData != null) {
      privacyPolicy.value = privacyPolicyData;
    }

    if (companyDataJson != null) {
      final companyObj = jsonDecode(companyDataJson);
      _handleAdvertiseVideo(companyObj); // early trigger, on GetxController creation
    }

    _dataLoaded = true;
    isLoading.value = false;
  }

  String getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${baseUrl.value}/$cleanPath';
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

  bool get showCloseStatus => isShowCloseStatus.value;
  String get alterMessageValue => alterMessage.value;
}