
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/tickets/data/repositories/ticket_repo.dart';
RemoteMessage? initialNotificationMessage;
String? pendingKillStateTicketId;
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message received: ${message.messageId}');
  await _showBackgroundNotification(message);
}

Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@mipmap/logo');
  await plugin.initialize(const InitializationSettings(android: androidInit));

  final String title =
      message.data['title'] ?? message.notification?.title ?? 'Notification';

  String body = message.data['body'] ?? message.notification?.body ?? '';
  body = body.replaceFirst('User ', '');

  final String ticketId = message.data['ticketId'] ?? '';


  const androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  await plugin.show(
    ticketId.hashCode,
    title,
    body,
    const NotificationDetails(android: androidDetails),
    payload: ticketId,
  );
}

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
  FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final Set<String> _shownTicketIds = {};
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isNavigating = false;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await _initLocalNotifications();

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

    _fetchFcmTokenSafely(messaging);

    messaging.onTokenRefresh.listen((newToken) {
      print('📲 FCM Token refreshed: $newToken');
    });


    _setupForegroundListener();
    _setupNotificationClickListener();

  }



  Future<void> _fetchFcmTokenSafely(FirebaseMessaging messaging) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final String? token = await messaging.getToken();
        print('📲 FCM Token: $token');
        return;
      } catch (e) {
        print('⚠️ FCM getToken failed (attempt $attempt/3): $e');
        await Future.delayed(Duration(seconds: 5 * attempt));
      }
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/logo');

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String ticketId = response.payload ?? '';
        if (ticketId.isNotEmpty && !_isNavigating) {
          print('🔔 Local notification tap. TicketId: $ticketId');
          _isNavigating = true;
          _openTicketDetail(ticketId);
          Future.delayed(const Duration(seconds: 2), () {
            _isNavigating = false;
          });
        }
      },
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    final String title =
        message.data['title'] ?? message.notification?.title ?? 'Notification';

    String body = message.data['body'] ?? message.notification?.body ?? '';
    body = body.replaceFirst('User ', '');

    final String ticketId = message.data['ticketId'] ?? '';
    final String createdBy = message.data['createdBy'] ?? '';
    final String formattedBody = '$body';

    print('🔔 Title: $title');
    print('🔔 Body: $body');
    print('🔔 TicketId: $ticketId');

    if (ticketId.isNotEmpty && _shownTicketIds.contains(ticketId)) {
      print('⚠️ Duplicate notification skipped for ticketId: $ticketId');
      return;
    }

    if (ticketId.isNotEmpty) {
      _shownTicketIds.add(ticketId);
    }

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin.show(
      ticketId.hashCode,
      title,
      formattedBody,
      const NotificationDetails(android: androidDetails),
      payload: ticketId,
    );
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showNotification(message);

      final String type = message.data['type'] ?? '';
      final String action = message.data['action'] ?? '';
      final String ticketId = message.data['ticketId'] ?? '';

      if (type == 'SOS_EMERGENCY' &&
          action == 'SOS_NOTIFICATION' &&
          !_isNavigating) {
        _isNavigating = true;
        final ticket = await TicketRepository().getTicket(ticketId);
        if (ticket != null) {
          _handleSOSNavigation(ticket);
        }
        Future.delayed(const Duration(seconds: 2), () {
          _isNavigating = false;
        });
      }
    });
  }

  void _setupNotificationClickListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final String? ticketId = message.data['ticketId'];

      if (ticketId != null && ticketId.isNotEmpty && !_isNavigating) {
        _isNavigating = true;
        final String type = message.data['type'] ?? '';
        final String action = message.data['action'] ?? '';

        if (type == 'SOS_EMERGENCY' && action == 'SOS_NOTIFICATION') {
          final ticket = await TicketRepository().getTicket(ticketId);
          if (ticket != null) {
            _handleSOSNavigation(ticket);
          }
        } else {
          await _openTicketDetail(ticketId);
        }

        Future.delayed(const Duration(seconds: 2), () {
          _isNavigating = false;
        });
      }
    });
  }

  void triggerSOSNavigation(TicketModel ticket) {
    _handleSOSNavigation(ticket);
  }

  void _handleSOSNavigation(TicketModel ticket) {
    try {
      final SOSController sos = Get.find<SOSController>();
      if (!sos.isAlarmPlaying.value) {
        sos.startAlarmSystem();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            '/SOSAlarm',
            arguments: {'ticket': ticket},
          );
        } else {
          Get.to('/SOSAlarm', arguments: {'ticket': ticket});
        }
      });
    } catch (e) {
      print('❌ SOS navigation error: $e');
      _isNavigating = false;
    }
  }

  Future<void> _openTicketDetail(String ticketId) async {
    try {
      print('🎯 Opening ticket detail: $ticketId');

      final TicketRepository repo = TicketRepository();
      final ticket = await repo.getTicket(ticketId);

      print('🎫 Ticket fetched: $ticket');

      if (ticket != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentContext != null) {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) => TicketDetailView(ticket: ticket),
              ),
            );
          } else {
            Get.to(() => TicketDetailView(ticket: ticket));
          }
        });
      } else {
        print('⚠️ Ticket null for ticketId: $ticketId');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              const SnackBar(
                content: Text('Ticket not found'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            Get.snackbar(
              'Error',
              'Ticket not found',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error opening ticket detail: $e');
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isNavigating = false;
      });
    }
  }
}