import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../colors.dart';
import '../../controllers/pay_online_controller.dart';
import '../../controllers/social_controller.dart';

class SOSButtonClone extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  final List<Map<String, dynamic>> branches;
  final String username;

  const SOSButtonClone({
    Key? key,
    required this.isActive,
    required this.onTap,
    required this.branches,
    required this.username,
  }) : super(key: key);

  @override
  _SOSButtonCloneState createState() => _SOSButtonCloneState();
}

class _SOSButtonCloneState extends State<SOSButtonClone>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  final SocialController _socialController = Get.put(SocialController());
  final PayOnlineController _payOnlineController = Get.put(PayOnlineController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSOSTap() async {
    try {

      Get.dialog(
        Center(
          child: SpinKitRipple(
            color: AppColors.appColor,
          ),
        ),
        barrierDismissible: false,
      );
      final userId = await _storage.read(key: "user_id") ?? "";

      // Get all branches from SocialController
      final allBranches = _socialController.branches;

      if (allBranches.isEmpty) {
        Get.back(); // Close loading dialog
        _showNoBranchAvailableDialog();
        return;
      }

      // Get user's current location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.back(); // Close loading dialog
          Get.snackbar('Permission Denied', 'Location permission is required.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.back(); // Close loading dialog
        Get.snackbar('Permission Denied', 'Enable location from app settings.');
        return;
      }

      final Position userPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Track available branches with client data
      List<Map<String, dynamic>> availableBranches = [];
      Map<String, Map<String, dynamic>> branchLocationMap = {};

      // Prepare branch location map for quick lookup
      for (final branch in allBranches) {
        final brnCode = branch['brn_code']?.toString() ?? '';
        if (brnCode.isNotEmpty) {
          final latStr = branch['latitude']?.toString() ?? '';
          final lngStr = branch['longitude']?.toString() ?? '';

          if (latStr.isNotEmpty && lngStr.isNotEmpty) {
            final double? branchLat = double.tryParse(latStr);
            final double? branchLng = double.tryParse(lngStr);
            if (branchLat != null && branchLng != null) {
              branchLocationMap[brnCode] = {
                'latitude': branchLat,
                'longitude': branchLng,
                'branch': branch,
              };
            }
          }
        }
      }

      // Check each branch for client data
      for (final branch in allBranches) {
        final brnCode = branch['brn_code']?.toString() ?? '';

        if (brnCode.isEmpty) continue;

        // Fetch client details for this branch
        await _payOnlineController.fetchClientDetails(
          username: userId,
          brnCode: brnCode,
          blockNo: '',
          plotNo: '',
        );

        // Check if client detail list is not empty
        if (!_payOnlineController.isClientDetailListEmpty()) {
          // Get branch location
          final branchLocation = branchLocationMap[brnCode];

          if (branchLocation != null) {
            final double distance = Geolocator.distanceBetween(
              userPos.latitude,
              userPos.longitude,
              branchLocation['latitude'],
              branchLocation['longitude'],
            );

            availableBranches.add({
              'brn_code': brnCode,
              'brn_name': branch['brn_name']?.toString() ?? '',
              'distance': distance,
              'branch_data': branch,
              'client_details': _payOnlineController.clientDetailModel.value,
            });
          }
        }
      }

      Get.back(); // Close loading dialog

      // Find the nearest branch within 1000 meters
      Map<String, dynamic>? nearestBranch;
      double minDistance = double.infinity;

      for (final branch in availableBranches) {
        final distance = branch['distance'] as double;
        if (distance <= 1000 && distance < minDistance) {
          minDistance = distance;
          nearestBranch = branch;
        }
      }

      if (nearestBranch != null) {
        // Navigate to SOS page with nearest branch info
        Get.toNamed(
          '/UserSOS',
          arguments: {
            'brn_code': nearestBranch['brn_code'],
            'brn_name': nearestBranch['brn_name'],
            'distance': minDistance.toStringAsFixed(1),
          },
        );
      } else if (availableBranches.isEmpty) {
        _showNoBranchWithClientDataDialog();
      } else {
        _showOutOfRangeDialog();
      }

    } catch (e) {
      Get.back(); // Close loading dialog if open
      print('Error in SOS handler: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    }
  }

  void _showNoBranchAvailableDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Branches Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'No branches are currently available in the system. Please contact support.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showNoBranchWithClientDataDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Branch Association Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'You are not associated with any branch that has registered client data. Please contact your branch administrator.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showOutOfRangeDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SOS Unavailable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "You are currently outside branch service areas. The SOS feature is only available within branch premises for emergency assistance.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleSOSTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulseCircle(46, Colors.red.withOpacity(0.1), _pulseAnimation.value),
                    _buildPulseCircle(40, Colors.red.withOpacity(0.2), _pulseAnimation.value * 0.9),
                    _buildPulseCircle(34, Colors.red.withOpacity(0.3), _pulseAnimation.value * 0.8),
                  ],
                );
              },
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isActive ? Colors.orange : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isActive ? Colors.orange : Colors.red)
                        .withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.isActive ? Icons.warning : Icons.emergency,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseCircle(double size, Color color, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}