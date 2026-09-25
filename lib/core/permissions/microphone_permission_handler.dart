import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pakland/core/permissions/microphone_permisson.dart';

class MicrophonePermissionHandler extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;

  const MicrophonePermissionHandler({
    Key? key,
    required this.child,
    this.loadingWidget,
  }) : super(key: key);

  @override
  State<MicrophonePermissionHandler> createState() =>
      _MicrophonePermissionHandlerState();
}

class _MicrophonePermissionHandlerState
    extends State<MicrophonePermissionHandler> {
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

    // Check current permission status
    final status = await MicrophonePermissionService.checkMicrophonePermission();

    // If permission is not granted, directly request it
    if (!status.isGranted) {
      await MicrophonePermissionService.requestMicrophonePermission();
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
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
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Checking microphone permission...'),
                ],
              ),
            ),
          );
    }

    // Always return the child widget, regardless of permission status
    return widget.child;
  }
}
