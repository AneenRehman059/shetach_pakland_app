import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

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

  static Future<bool> isLocationPermissionGranted() async {
    final status = await checkLocationPermission();
    return status == LocationPermissionStatus.whileInUse ||
        status == LocationPermissionStatus.always;
  }

  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
      try {
        await Geolocator.openAppSettings();
      } catch (e2) {
        print('Error opening app settings with geolocator: $e2');
      }
    }
  }

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

enum LocationPermissionStatus {
  denied,
  deniedForever,
  whileInUse,
  always,
  serviceDisabled,
  unableToDetermine,
  error
}

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