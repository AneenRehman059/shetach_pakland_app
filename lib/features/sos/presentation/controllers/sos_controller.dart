import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart';
import 'package:vibration/vibration.dart';
import 'package:location/location.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/sos/data/repositories/sos_repo.dart';
import 'package:pakland/features/tickets/data/repositories/ticket_repo.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/sos/data/models/sos_models.dart';
import 'package:pakland/core/network/httpMassageMapper.dart';

class SOSController extends GetxController {
  final SOSRepository _sosRepository = SOSRepository();
  final TicketRepository _ticketRepository = TicketRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Location _location = Location();

  // SOS State Variables
  var isSOSActive = false.obs;
  var isHolding = false.obs;
  var holdProgress = 0.0.obs;
  var countdown = 0.obs;
  var creating = false.obs;
  var isAlarmPlaying = false.obs;
  var lastSOSTicketId = ''.obs;
  var brnCode = ''.obs;

  // Timers
  Timer? _holdTimer;
  Timer? _countdownTimer;
  Timer? _alarmTimer;

  // Constants
  static const int HOLD_DURATION_SECONDS = 3;
  static const int COUNTDOWN_DURATION_SECONDS = 5;
  static const int ALARM_DURATION_MINUTES = 10;

  @override
  void onInit() {
    super.onInit();
    _initializeAlarm();
    _initializeLocation();
  }

  // ✅ Helper method to show success message
  void _showSuccessMessage(String operation) {
    final message = HttpMessageMapper.getSuccessMessage(operation);
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
    );
    showTopSnackBar(Get.context!, message,Colors.green.withOpacity(0.7), icon: Icons.check_circle);
  }

  // ✅ Helper method to show error message
  void _showErrorMessage(dynamic response, dynamic error, {String customMessage = ''}) {
    final statusCode = _getStatusCode(response, error);
    final message = customMessage.isNotEmpty ? customMessage : HttpMessageMapper.getMessage(statusCode);
    // Get.snackbar(
    //   'Error',
    //   message,
    //   backgroundColor: Colors.red,
    //   colorText: Colors.white,
    //   snackPosition: SnackPosition.TOP,
    //   duration: Duration(seconds: 4),
    // );
  }

  // ✅ Helper method to show info message
  // void _showInfoMessage(String message) {
  //   Get.snackbar(
  //     'Info',
  //     message,
  //     backgroundColor: Colors.blue,
  //     colorText: Colors.white,
  //     snackPosition: SnackPosition.TOP,
  //     duration: Duration(seconds: 3),
  //   );
  // }

  // ✅ Helper method to extract status code
  int _getStatusCode(dynamic response, dynamic error) {
    try {
      if (response is Map<String, dynamic>) {
        final statusCode = response['StatusCode']?.toString();
        if (statusCode != null) {
          return int.tryParse(statusCode) ?? 500;
        }
      }
      return 500;
    } catch (e) {
      return 500;
    }
  }

  // Initialize alarm settings
  void _initializeAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(AssetSource('sounds/sos_alarm.mp3'));
    } catch (e) {
      print('Alarm sound preload error: $e');
    }
  }

  // Initialize location service
  void _initializeLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
      }
    } catch (e) {
      print('Location initialization error: $e');
    }
  }

  // ========== MAIN SOS FLOW ========== //

  // Start holding SOS button
  void startHolding() {
    if (isSOSActive.value || isAlarmPlaying.value) return;

    isHolding.value = true;
    holdProgress.value = 0.0;

    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      holdProgress.value += 0.033;
      if (holdProgress.value >= 1.0) {
        timer.cancel();
        _activateEmergencySOS();
      }
    });
  }

  // Stop holding SOS button
  void stopHolding() {
    _holdTimer?.cancel();
    isHolding.value = false;
    holdProgress.value = 0.0;
  }

  // Activate emergency SOS with countdown
  void _activateEmergencySOS() {
    isSOSActive.value = true;
    isHolding.value = false;
    countdown.value = COUNTDOWN_DURATION_SECONDS;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown.value--;
      if (countdown.value <= 0) {
        timer.cancel();
        _executeSOSEmergency();
      }
    });

    // _showInfoMessage('Emergency alert will be sent in $COUNTDOWN_DURATION_SECONDS seconds');
  }

  void _executeSOSEmergency() async {
    try {
      creating.value = true;

      final userInfo = await _getUserInfo();
      final location = await _getCurrentLocation();
      final ticketResult = await _createSOSTicket(userInfo, location);

      if (ticketResult['success'] == true) {
        final ticketId = ticketResult['ticketId'];
        lastSOSTicketId.value = ticketId;

        await _notifyAdmins(userInfo, location, ticketId);
        // _showSuccessAndNavigate(ticketId, Get.context!);
        Get.toNamed('/emergencyScreen', arguments: {'ticket_id': ticketId});
        _showSuccessMessage('sos_emergency');
      } else {
        _showErrorMessage(null, null, customMessage: ticketResult['message']);
      }
    } catch (e) {
      _showErrorMessage(null, e, customMessage: 'SOS emergency failed');
    } finally {
      creating.value = false;
      resetSOSState();
    }
  }

  // ========== CORE SOS METHODS ========== //

  // Get user information
  Future<Map<String, String>> _getUserInfo() async {
    try {
      return {
        'user_id': await _storage.read(key: 'user_id') ?? 'Unknown',
        'user_name': await _storage.read(key: 'user_name') ?? 'Unknown User',
        'mobile_no1': await _storage.read(key: 'mobile_no1') ?? 'Not available',
        'user_email': await _storage.read(key: 'user_email') ?? 'Not available',
      };
    } catch (e) {
      print('Error getting user info: $e');
      return {
        'user_id': 'Unknown',
        'user_name': 'Unknown User',
        'mobile_no1': 'Not available',
        'user_email': 'Not available',
      };
    }
  }

  // Get current location
  Future<Map<String, double>?> _getCurrentLocation() async {
    try {
      LocationData locationData = await _location.getLocation();
      return {
        'latitude': locationData.latitude ?? 0.0,
        'longitude': locationData.longitude ?? 0.0,
      };
    } catch (e) {
      print('Location error: $e');
      return null;
    }
  }

  // Create SOS ticket
  Future<Map<String, dynamic>> _createSOSTicket(
      Map<String, String> userInfo,
      Map<String, double>? location) async {
    try {
      final description = _buildSOSDescription(userInfo, location);

      final result = await _ticketRepository.createTicket(
        CreateTicketRequest(
          title: 'SOS',
          brn_code: brnCode.value,
          description: description,
          userId: userInfo['user_id']!,
          oprationID: 'SOS',
          ticketPriority: 'High',
          latitude: location?['latitude'],
          longitude: location?['longitude'],
        ),
      );

      if (result is Map<String, dynamic> && result['StatusCode'] == '200' && result['obj'] != null) {
        final ticketId = result['obj']['TicketId']?.toString() ?? 'Unknown';
        return {
          'success': true,
          'ticketId': ticketId,
          'message': 'SOS ticket created successfully'
        };
      } else {
        final message = result['Message'] ?? 'Failed to create SOS ticket';
        return {
          'success': false,
          'message': message
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Ticket creation error: $e'
      };
    }
  }

  // Build SOS description
  String _buildSOSDescription(Map<String, String> userInfo, Map<String, double>? location) {
    return '''
EMERGENCY REQUEST!

USER DETAILS:
• Name: ${userInfo['user_name']}
• Phone: ${userInfo['mobile_no1']}
• Email: ${userInfo['user_email']}

PLEASE RESPOND IMMEDIATELY!
''';
  }

  // ========== ALARM SYSTEM ========== //

  // Start alarm system
  Future<void> startAlarmSystem() async {
    if (isAlarmPlaying.value) return;

    try {
      isAlarmPlaying.value = true;

      await _audioPlayer.play(
        AssetSource('sounds/sos_alarm.mp3'),
        // volume: 1.0,
      );

      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 1000, 500, 2000],
          repeat: 0,
        );
      }

      _alarmTimer = Timer(const Duration(minutes: ALARM_DURATION_MINUTES), () {
        if (isAlarmPlaying.value) {
          stopAlarm();
          // _showInfoMessage('Alarm stopped after $ALARM_DURATION_MINUTES minutes');
        }
      });

    } catch (e) {
      print('Alarm start error: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to start alarm');
    }
  }

  // Stop alarm system (for user)
  Future<void> stopAlarm() async {
    if (!isAlarmPlaying.value) return;

    try {
      isAlarmPlaying.value = false;

      await _audioPlayer.stop();
      await _audioPlayer.release(); // important

      Vibration.cancel();

      _alarmTimer?.cancel();
      _alarmTimer = null;

      if (lastSOSTicketId.isNotEmpty) {
        final userId = await _storage.read(key: 'user_id') ?? '';
        if (userId.isNotEmpty) {
          await _ticketRepository.updateStatusAndPriority(
            ticketId: lastSOSTicketId.value,
            status: 'In Progress',
            priority: 'High',
            remarks: 'SOS alarm stopped',
            userId: userId,
          );
        }
      }

      _showSuccessMessage('stop_alarm');
    } catch (e) {
      print('Alarm stop error: $e');
      _showErrorMessage(null, e, customMessage: 'Failed to stop alarm');
    }
  }

  // Stop alarm for Admin/Team (no status update)
  Future<void> stopAdminAlarm() async {
    try {
      isAlarmPlaying.value = false;

      await _audioPlayer.stop();
      await _audioPlayer.release(); // important

      Vibration.cancel();

      _alarmTimer?.cancel();
      _alarmTimer = null;

      print('✅ Admin alarm stopped');
    } catch (e) {
      print('❌ Admin alarm stop error: $e');
    }
  }

  // Respond to SOS (Go & Respond)
  Future<bool> respondToSOS({
    required String ticketId,
    required String responderUserId,
    required String responderName,
  }) async {
    try {
      final response = await _sosRepository.respondToSOS(
        ticketId: ticketId,
        responderUserId: responderUserId,
        responderName: responderName,
        remarks: 'Team responding to SOS',
      );

      if (response is Map<String, dynamic> && response['StatusCode'] == '200') {
        _showSuccessMessage('respond_sos');
        return true;
      } else {
        final message = response['Message'] ?? 'Failed to respond to SOS';
        _showErrorMessage(response, null, customMessage: message);
        return false;
      }
    } catch (e) {
      _showErrorMessage(null, e, customMessage: 'Error responding to SOS');
      return false;
    }
  }

  // ========== NOTIFICATION SYSTEM ========== //

  // Notify admins about SOS
  Future<void> _notifyAdmins(
      Map<String, String> userInfo,
      Map<String, double>? location,
      String ticketId
      ) async {
    try {
      final sosResponse = await _sosRepository.sendSOSNotification(
        SOSNotificationRequest(
          ticketId: ticketId,
          userName: userInfo['user_name']!,
          userId: userInfo['user_id']!,
          phoneNumber: userInfo['mobile_no1']!,
          latitude: location?['latitude'],
          longitude: location?['longitude'],
          timestamp: DateTime.now().toIso8601String(),
          message: 'SOS Emergency Alert',
          emergencyType: 'Immediate Assistance',
          department: 'SOS',
          brnCode: brnCode.value,
        ),
      );

      if (sosResponse is Map<String, dynamic> && sosResponse['StatusCode'] == '200') {
        print('✅ Backend sent SOS notifications successfully');
      } else {
        final message = sosResponse['Message'] ?? 'Failed to send SOS notifications';
        print('⚠️ SOS notification: $message');
      }
    } catch (e) {
      print('❌ Error notifying admins via backend: $e');
    }
  }

  // ========== UI METHODS ========== //

  // Show success and navigate
  void _showSuccessAndNavigate(String ticketId, BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Center(child: const Text('Emergency Alert Sent!')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),

            const SizedBox(height: 8),
            Text(
              'Ticket ID: $ticketId',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Help is on the way! Emergency services have been notified and will respond shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Cancel emergency SOS
  void cancelEmergencySOS() {
    _countdownTimer?.cancel();
    resetSOSState();
    // _showInfoMessage('Emergency alert has been cancelled');
  }

  // Reset SOS state
  void resetSOSState() {
    isSOSActive.value = false;
    isHolding.value = false;
    holdProgress.value = 0.0;
    countdown.value = 0;
    _holdTimer?.cancel();
    _countdownTimer?.cancel();
  }

  // ========== PUBLIC METHODS ========== //

  // Get current SOS status
  String get sosStatus {
    if (isAlarmPlaying.value) return 'Alarm Active';
    if (isSOSActive.value) return 'SOS Activated';
    if (isHolding.value) return 'Holding Button';
    return 'Ready';
  }

  // Check if SOS is in progress
  bool get isSOSInProgress {
    return isSOSActive.value || isAlarmPlaying.value || isHolding.value;
  }

  @override
  void onClose() {
    _holdTimer?.cancel();
    _countdownTimer?.cancel();
    _alarmTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }
}