import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PakistanDateHelper {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _lastValidTimeKey = 'last_valid_time';
  static const String _timeCheckHistoryKey = 'time_check_history';
  static const String _appInstallTimeKey = 'app_install_time';

  static bool _isInitialized = false;

  static DateTime get nowInPakistan {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: 5));
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _ensureInstallTimeRecorded();
      _isInitialized = true;
      debugPrint('PakistanDateHelper initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize PakistanDateHelper: $e');
      _isInitialized = true;
    }
  }

  static Future<void> _ensureInstallTimeRecorded() async {
    try {
      final installTime = await _storage.read(key: _appInstallTimeKey);
      if (installTime == null) {
        final now = nowInPakistan;
        await _storage.write(
          key: _appInstallTimeKey,
          value: now.toIso8601String(),
        );
        debugPrint('App install time recorded: ${now.toIso8601String()}');
      }
    } catch (e) {
      debugPrint('Error recording install time: $e');
    }
  }

  static Future<bool> isDueDateValid(DateTime dueDate) async {
    try {
      final isTimeManipulated = await _isTimeLikelyManipulated();

      if (isTimeManipulated) {
        return false;
      }

      return _isDueDateValidBasedOnLocal(dueDate);
    } catch (e) {
      debugPrint('Error in isDueDateValid: $e');
      return _isDueDateValidBasedOnLocal(dueDate);
    }
  }

  static bool _isDueDateValidBasedOnLocal(DateTime dueDate) {
    try {
      final pakistanNow = nowInPakistan;

      final dueDateAtMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final todayAtMidnight = DateTime(pakistanNow.year, pakistanNow.month, pakistanNow.day);

      return todayAtMidnight.isBefore(dueDateAtMidnight) ||
          todayAtMidnight.isAtSameMomentAs(dueDateAtMidnight);
    } catch (e) {
      debugPrint('Error in _isDueDateValidBasedOnLocal: $e');
      return false;
    }
  }

  static Future<bool> _isTimeLikelyManipulated() async {
    try {
      final currentTime = nowInPakistan;
      final lastValidTimeStr = await _storage.read(key: _lastValidTimeKey);

      if (lastValidTimeStr != null) {
        final lastValidTime = DateTime.parse(lastValidTimeStr);

        if (currentTime.isBefore(lastValidTime)) {
          await _logTimeManipulation('Time went backwards', lastValidTime, currentTime);
          return true;
        }

        final timeDifference = currentTime.difference(lastValidTime);
        if (timeDifference.inDays > 1) {
          await _logTimeManipulation('Large time jump forward', lastValidTime, currentTime);
          return true;
        }
      }

      await _storage.write(
        key: _lastValidTimeKey,
        value: currentTime.toIso8601String(),
      );

      return await _checkAgainstInstallTime(currentTime);

    } catch (e) {
      debugPrint('Error checking time manipulation: $e');
      return false;
    }
  }

  static Future<bool> _checkAgainstInstallTime(DateTime currentTime) async {
    try {
      final installTimeStr = await _storage.read(key: _appInstallTimeKey);
      if (installTimeStr != null) {
        final installTime = DateTime.parse(installTimeStr);

        if (currentTime.isBefore(installTime)) {
          await _logTimeManipulation('Time before app install', installTime, currentTime);
          return true;
        }

        final yearsSinceInstall = currentTime.difference(installTime).inDays / 365;
        if (yearsSinceInstall > 2) {
          await _logTimeManipulation('Suspiciously old time', installTime, currentTime);
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error in _checkAgainstInstallTime: $e');
      return false;
    }
  }

  static Future<void> _logTimeManipulation(
      String reason,
      DateTime expectedTime,
      DateTime actualTime
      ) async {
    try {
      final historyStr = await _storage.read(key: _timeCheckHistoryKey);
      List<Map<String, dynamic>> history = [];

      if (historyStr != null && historyStr.isNotEmpty) {
        try {
          final decoded = json.decode(historyStr);
          if (decoded is List) {
            history = List<Map<String, dynamic>>.from(decoded);
          }
        } catch (e) {
          debugPrint('Error decoding history: $e');
          history = [];
        }
      }

      history.add({
        'timestamp': nowInPakistan.toIso8601String(),
        'reason': reason,
        'expected': expectedTime.toIso8601String(),
        'actual': actualTime.toIso8601String(),
        'difference_hours': actualTime.difference(expectedTime).inHours,
      });

      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }

      await _storage.write(
        key: _timeCheckHistoryKey,
        value: json.encode(history),
      );
    } catch (e) {
      debugPrint('Error logging time manipulation: $e');
    }
  }

  static Future<DueDateValidationResult> validateDueDateWithDetails(DateTime dueDate) async {
    try {
      final currentTime = nowInPakistan;
      final isTimeManipulated = await _isTimeLikelyManipulated();

      if (isTimeManipulated) {
        return DueDateValidationResult(
          isValid: false,
          reason: 'Device time appears to be modified',
          currentTime: currentTime,
          dueDate: dueDate,
        );
      }

      final isDueDateValid = _isDueDateValidBasedOnLocal(dueDate);

      return DueDateValidationResult(
        isValid: isDueDateValid,
        reason: isDueDateValid ? 'Valid' : 'Due date has passed',
        currentTime: currentTime,
        dueDate: dueDate,
      );
    } catch (e) {
      debugPrint('Error in validateDueDateWithDetails: $e');
      final currentTime = nowInPakistan;
      final isDueDateValid = _isDueDateValidBasedOnLocal(dueDate);

      return DueDateValidationResult(
        isValid: isDueDateValid,
        reason: isDueDateValid ? 'Valid' : 'Due date has passed',
        currentTime: currentTime,
        dueDate: dueDate,
      );
    }
  }

  static String formatDateForDisplay(DateTime date) {
    try {
      final pakistanDate = DateTime.utc(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
      ).add(const Duration(hours: 5));

      return '${pakistanDate.day}/${pakistanDate.month}/${pakistanDate.year}';
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  static String getCurrentPakistanDateTime() {
    try {
      final now = nowInPakistan;
      return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')} PKT';
    } catch (e) {
      debugPrint('Error getting current Pakistan date: $e');
      return 'Date unavailable';
    }
  }

  static Future<void> clearTimeRecords() async {
    try {
      await _storage.delete(key: _lastValidTimeKey);
      await _storage.delete(key: _timeCheckHistoryKey);
      await _storage.delete(key: _appInstallTimeKey);
      debugPrint('Time records cleared');
    } catch (e) {
      debugPrint('Error clearing time records: $e');
    }
  }

  static bool get isInitialized => _isInitialized;
}

class DueDateValidationResult {
  final bool isValid;
  final String reason;
  final DateTime currentTime;
  final DateTime dueDate;

  DueDateValidationResult({
    required this.isValid,
    required this.reason,
    required this.currentTime,
    required this.dueDate,
  });

  String get formattedCurrentTime => PakistanDateHelper.formatDateForDisplay(currentTime);
  String get formattedDueDate => PakistanDateHelper.formatDateForDisplay(dueDate);
}