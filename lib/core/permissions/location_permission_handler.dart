import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pakland/core/permissions/location_permission.dart';

class LocationPermissionHandler extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;

  const LocationPermissionHandler({
    Key? key,
    required this.child,
    this.loadingWidget,
  }) : super(key: key);

  @override
  State<LocationPermissionHandler> createState() => _LocationPermissionHandlerState();
}

class _LocationPermissionHandlerState extends State<LocationPermissionHandler> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    setState(() {
      _isChecking = true;
    });

    final status = await LocationPermissionService.checkLocationPermission();

    if (!status.isGranted) {
      await LocationPermissionService.requestLocationPermission();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (!mounted) return;
    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return widget.loadingWidget ??
          Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLoader(),
                  SizedBox(height: 20),
                  Text('Checking location permission...'),
                ],
              ),
            ),
          );
    }

    return widget.child;
  }
}