import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  // Check current location permission status
  static Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await Geolocator.checkPermission();

      switch (permission) {
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.whileInUse;
        case LocationPermission.always:
          return LocationPermissionStatus.always;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unableToDetermine;
      }
    } catch (e) {
      print('Error checking location permission: $e');
      return LocationPermissionStatus.error;
    }
  }

  // Request location permission
  static Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      switch (permission) {
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.deniedForever;
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.whileInUse;
        case LocationPermission.always:
          return LocationPermissionStatus.always;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unableToDetermine;
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      return LocationPermissionStatus.error;
    }
  }

  // Check if permission is granted (either whileInUse or always)
  static Future<bool> isLocationPermissionGranted() async {
    final status = await checkLocationPermission();
    return status == LocationPermissionStatus.whileInUse ||
        status == LocationPermissionStatus.always;
  }

  // Open app settings - FIXED: Use the package's method directly
  static Future<void> openAppSettings() async {
    try {
      // Use the permission_handler package's method directly
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      // If that fails, try using geolocator's method
      try {
        await Geolocator.openAppSettings();
      } catch (e2) {
        print('Error opening app settings with geolocator: $e2');
      }
    }
  }

  // Get current position if permission is granted
  static Future<Position?> getCurrentPosition() async {
    try {
      if (await isLocationPermissionGranted()) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
      return null;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }
}

// Enum for location permission status
enum LocationPermissionStatus {
  denied,
  deniedForever,
  whileInUse,
  always,
  serviceDisabled,
  unableToDetermine,
  error
}

// Extension for better readability
extension LocationPermissionStatusExtension on LocationPermissionStatus {
  bool get isGranted {
    return this == LocationPermissionStatus.whileInUse ||
        this == LocationPermissionStatus.always;
  }

  bool get isDenied {
    return this == LocationPermissionStatus.denied ||
        this == LocationPermissionStatus.deniedForever;
  }

  bool get canRequestAgain {
    return this == LocationPermissionStatus.denied;
  }

  String get description {
    switch (this) {
      case LocationPermissionStatus.denied:
        return 'Location permission denied. You can request again.';
      case LocationPermissionStatus.deniedForever:
        return 'Location permission permanently denied. Please enable from app settings.';
      case LocationPermissionStatus.whileInUse:
        return 'Location permission granted while using the app.';
      case LocationPermissionStatus.always:
        return 'Location permission always granted.';
      case LocationPermissionStatus.serviceDisabled:
        return 'Location services are disabled. Please enable location services.';
      case LocationPermissionStatus.unableToDetermine:
        return 'Unable to determine location permission status.';
      case LocationPermissionStatus.error:
        return 'Error checking location permission.';
    }
  }
}