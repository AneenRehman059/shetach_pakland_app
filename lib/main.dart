import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/core/services/video_background_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pakland/features/sos/presentation/screens/emergency_request_screen.dart';
import 'package:pakland/features/profile/presentation/screens/personal_detail_screen.dart';
import 'package:pakland/core/services/server_date.dart';
import 'package:pakland/core/services/fcm_notification_service.dart';
import 'package:pakland/features/splash/presentation/screens/splash_screen.dart';
import 'package:pakland/core/permissions/microphone_permission_handler.dart';
import 'package:pakland/core/permissions/location_permission_handler.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/features/auth/presentation/screens/change_password_screen.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/core/controllers/internet_connectivity_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/login_controller.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/core/controllers/theme_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/features/dashboard/presentation/screens/about_us_screen.dart';
import 'package:pakland/features/cms/presentation/screens/admin_dashboard.dart';
import 'package:pakland/features/cms/presentation/screens/admin_main_dashboard.dart';
import 'package:pakland/features/cms/presentation/screens/client_dashboard.dart';
import 'package:pakland/features/cms/presentation/screens/cms_dashboard_screen.dart';
import 'package:pakland/features/feedback/presentation/screens/cms_feedback_screen.dart';
import 'package:pakland/features/sos/presentation/screens/sos_alarm_screen.dart';
import 'package:pakland/features/sos/presentation/screens/sos_list_screen.dart';
import 'package:pakland/features/sos/presentation/screens/sos_screen.dart';
import 'package:pakland/features/tickets/presentation/screens/ticket_create_screen.dart';
import 'package:pakland/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:pakland/features/tickets/presentation/screens/ticket_list_view.dart';
import 'package:pakland/features/help_support/presentation/screens/help_support_screen.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

const String kAppFontFamily = 'Poppins';

final notificationService = FirebaseNotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  HttpOverrides.global = MyHttpOverrides();

  try {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      ScreenHelper.isTvDevice =
          info.systemFeatures.contains('android.software.leanback');
    }
  } catch (_) {}

  final themeController = Get.put(ThemeController(), permanent: true);
  Get.put(InternetConnectivityController(), permanent: true);
  Get.put(LoginController(), permanent: true);
  Get.put(CompanyController(), permanent: true);
  Get.put(TicketController(), permanent: true);
  Get.put(SOSController(), permanent: true);

  themeController.updateStatusBar();

  if (kReleaseMode) {
    final context = SecurityContext.defaultContext;
    context.allowLegacyUnsafeRenegotiation = true;
  }

  await GetStorage.init();
  await PakistanDateHelper.initialize();
  await notificationService.initialize();

  initialNotificationMessage = await FirebaseMessaging.instance.getInitialMessage();
  print('📌 main() captured initialMessage: ${initialNotificationMessage?.data}');

  if (initialNotificationMessage == null) {
    final launchDetails = await notificationService
        .flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    print('📌 launchDetails: $launchDetails');
    print('📌 didNotificationLaunchApp: ${launchDetails?.didNotificationLaunchApp}');
    print('📌 payload: ${launchDetails?.notificationResponse?.payload}');

    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse?.payload != null) {

      final String ticketId = launchDetails.notificationResponse!.payload!;
      print('📌 Launch ticketId from local notification: $ticketId');

      pendingKillStateTicketId = ticketId;
    }
  }

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CompanyController _companyController = Get.find<CompanyController>();
  final String compCode = "SHET";
  Widget? _homeWidget;
  bool _isCheckingVersion = true;
  String _currentVersion = "1.0.0";
  String _requiredVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    try {
      try {
        await _companyController
            .fetchAndStoreCompanyDetails(compCode)
            .timeout(const Duration(seconds: 3));
      } on TimeoutException {
        debugPrint("Company info slow - continuing with stored data");
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;

      final companyDataJson = await _companyController.storage.read(key: "company_data");
      if (companyDataJson != null) {
        final companyData = jsonDecode(companyDataJson);
        _requiredVersion = companyData["app_version"] ?? "1.0.0";

        debugPrint("Current Version: $_currentVersion");
        debugPrint("Required Version: $_requiredVersion");

        if (_currentVersion != _requiredVersion) {
          setState(() {
            _homeWidget = _buildUpdateDialog();
            _isCheckingVersion = false;
          });
        } else {
          setState(() {
            _homeWidget = MicrophonePermissionHandler(
              loadingWidget: _buildLoadingScreen(''),
              child: LocationPermissionHandler(
                child: const SplashScreen(),
                loadingWidget: _buildLoadingScreen(''),
              ),
            );
            _isCheckingVersion = false;
          });
        }
      } else {
        setState(() {
          _homeWidget = MicrophonePermissionHandler(
            loadingWidget: _buildLoadingScreen(''),
            child: LocationPermissionHandler(
              child: const SplashScreen(),
              loadingWidget: _buildLoadingScreen(''),
            ),
          );
          _isCheckingVersion = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking app version: $e");

      setState(() {
        _homeWidget = MicrophonePermissionHandler(
          loadingWidget: _buildLoadingScreen(''),
          child: LocationPermissionHandler(
            child: const SplashScreen(),
            loadingWidget: _buildLoadingScreen(''),
          ),
        );
        _isCheckingVersion = false;
      });
    }
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          ],
        ),
      ),
    );
  }

  bool _isVersionLower(String currentVersion, String requiredVersion) {
    try {
      List<int> currentParts = currentVersion.split('.').map((e) => int.parse(e)).toList();
      List<int> requiredParts = requiredVersion.split('.').map((e) => int.parse(e)).toList();

      for (int i = 0; i < Math.max(currentParts.length, requiredParts.length); i++) {
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        int requiredPart = i < requiredParts.length ? requiredParts[i] : 0;

        if (currentPart < requiredPart) {
          return true;
        } else if (currentPart > requiredPart) {
          return false;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error comparing versions: $e");
      return false;
    }
  }

  Widget _buildUpdateDialog() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade800,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.system_update_alt,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Update Available",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "A new version is ready to be installed",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What's New:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildFeatureItem(Icons.bug_report, "Bug fixes & performance improvements"),
                      SizedBox(height: 8),
                      _buildFeatureItem(Icons.security, "Security updates"),
                      SizedBox(height: 8),
                      _buildFeatureItem(Icons.speed, "Enhanced user experience"),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Later",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                const url = 'https://shetechnologies.com';
                                try {
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                } catch (e) {
                                  debugPrint("Error launching URL: $e");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download, size: 20),
                                  SizedBox(width: 2),
                                  Text(
                                    "Update Now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.blue.shade600,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingVersion) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ],
            ),
          ),
        ),
      );
    }

    final themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        navigatorKey: notificationService.navigatorKey,
        navigatorObservers: [videoRouteObserver],
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.blue,
          textTheme: ThemeData.light().textTheme.apply(fontFamily: kAppFontFamily),
          primaryTextTheme:
          ThemeData.light().primaryTextTheme.apply(fontFamily: kAppFontFamily),
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.blue,
          textTheme: ThemeData.dark().textTheme.apply(fontFamily: kAppFontFamily),
          primaryTextTheme:
          ThemeData.dark().primaryTextTheme.apply(fontFamily: kAppFontFamily),
        ),
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/dashboard', page: () => const CMSDashboardScreen()),
          GetPage(name: '/mainDashboard', page: () {
            final ticketController = Get.find<TicketController>();
            return AdminMainDashboard(
              ticketController: ticketController,
              userId: ticketController.userId.value,
              userType: ticketController.userType.value,
            );
          },
              binding: BindingsBuilder(() {
                Get.put(TicketController());
              })
          ),
          GetPage(name: '/adminDashboard', page: () {
            final ticketController = Get.isRegistered<TicketController>()
                ? Get.find<TicketController>()
                : Get.put(TicketController());

            if (!ticketController.isInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ticketController.initializeController();
              });
            }

            return AdminDashboard(
              ticketController: ticketController,
              userType: ticketController.userType.value.isNotEmpty
                  ? ticketController.userType.value
                  : 'Admin',
            );
          }),
          GetPage(name: '/clintDashboard', page: () {
            final ticketController = Get.isRegistered<TicketController>()
                ? Get.find<TicketController>()
                : Get.put(TicketController());

            if (!ticketController.isInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ticketController.initializeController();
              });
            }

            return ClientDashboard(
                ticketController: ticketController
            );
          }),


          GetPage(name: '/tickets', page: () => TicketListView()),
          GetPage(name: '/emergencyScreen', page: () => EmergencyRequestScreen()),
          GetPage(
              name: '/tickets/create',
              page: () => const TicketCreateView(),
              binding: BindingsBuilder(() {
                Get.put(LoginController());
                Get.put(TicketController());
              })),
          GetPage(
              name: '/tickets/:id',
              page: () {
                final args = Get.arguments as Map<String, dynamic>;
                return TicketDetailView(ticket: args['ticket']);
              }),
          GetPage(name: '/main_screen', page: () => MainWrapper()),
          GetPage(name: '/UserSOS', page: () => const SOSView()),
          GetPage(
              name: '/SOSAlarm',
              page: () {
                final args =Get.arguments as Map<String,dynamic>;
                return SOSAlarmScreen(ticket: args['ticket']);
              }),
          GetPage(name: '/SOSListView', page: () => const SOSListView()),
        ],

        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        home: _homeWidget,
      );
    });
  }
}