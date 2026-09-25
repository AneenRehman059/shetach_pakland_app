import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';

import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/widgets/app_bar2.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/tickets/data/repositories/ticket_repo.dart';

class SOSAlarmScreen extends StatelessWidget {
  final TicketModel ticket;

  const SOSAlarmScreen({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final SOSController sosController = Get.find<SOSController>();
    final storage = const FlutterSecureStorage();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.red[50],
        appBar: AppBar(title: Text("SOS",style: TextStyle(color: AppColors.whiteBg),),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
        iconTheme: IconThemeData(color: AppColors.whiteBg),
          automaticallyImplyLeading: false,),
        body: _buildAlarmView(context, sosController, storage),
      ),
    );
  }

  Widget _buildAlarmView(BuildContext context, SOSController sosController, FlutterSecureStorage storage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🚨 ", style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            )),
            const SizedBox(height: 30),
            Text(
              'EMERGENCY',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'User needs immediate assistance!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ticket ID: ${ticket.id}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 50),
            // Two buttons in a row
            Row(
              children: [
                // CANCEL Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _handleCancel(context, sosController);
                      Get.offNamed('/main_screen');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // ACCEPT Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _handleGoAndRespond(context, sosController, storage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ACCEPT',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Text(
            //   'Cancel: Just stop the alarm\nAccept: Stop alarm, update status, and notify user',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.grey[600],
            //     fontStyle: FontStyle.italic,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Option A: Cancel
  Future<void> _handleCancel(BuildContext context, SOSController sosController) async {
    try {
      await sosController.stopAdminAlarm();
      showTopSnackBar(
        context,
        'SOS alarm has been cancelled. Ticket status unchanged.',
        Colors.orange,
        title: '✅ Alarm Stopped',
        icon: Icons.check_circle,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      showTopSnackBar(
        context,
        'Something went wrong: $e',
        Colors.red,
        title: '❌ Error',
        icon: Icons.error,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Option B: GO & RESPOND
  Future<void> _handleGoAndRespond(
      BuildContext context,
      SOSController sosController,
      FlutterSecureStorage storage,
      ) async {
    // Prevent multiple taps
    if (Get.isDialogOpen ?? false) {
      return;
    }

    try {
      // Show loading indicator while checking status
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final ticketRepo = TicketRepository();
      final latestTicket = await ticketRepo.getTicket(ticket.id);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Check if ticket is already In Progress
      if (latestTicket != null && latestTicket.status == "In Progress") {
        // Stop the alarm
        await sosController.stopAdminAlarm();

        // Show warning message
        showTopSnackBar(
          context,
          'This ticket is already In Progress. Please refresh the list.',
          Colors.orange,
          title: '⚠️ Already Assigned',
          icon: Icons.warning,
          duration: const Duration(seconds: 3),
        );

        // Navigate back to main screen after a delay
        await Future.delayed(const Duration(milliseconds: 3500));
        if (Get.context != null) {
          Get.offAllNamed('/main_screen');
        }
        return;
      }

      // If ticket is not In Progress, proceed with assignment
      // Show loading indicator for assignment process
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get responder information
      final responderUserId = await storage.read(key: 'user_id') ?? '';
      final responderName = await storage.read(key: 'user_name') ?? 'Admin';

      // Stop the alarm
      await sosController.stopAdminAlarm();

      // Respond to SOS (updates status to "In Progress")
      final success = await sosController.respondToSOS(
        ticketId: ticket.id,
        responderUserId: responderUserId,
        responderName: responderName,
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Assign ticket
        final ticketController = TicketController();
        await ticketController.assignTicket(
          brn_code: ticket.brn_code,
          ticketId: ticket.id,
          departmentId: ticket.title,
          assignedToUserId: ticketController.userId.toString(),
          category: 'SOS',
          dueDate: DateTime.now(),
          remarks: "",
        );

        // Fetch updated ticket details
        final updatedTicket = await ticketRepo.getTicket(ticket.id);

        if (updatedTicket != null) {
          // Show success message
          showTopSnackBar(
            context,
            'Ticket status updated to In Progress. User has been notified.',
            Colors.green,
            title: 'Team Responding!',
            icon: Icons.check_circle,
            duration: const Duration(seconds: 3),
          );

          // Navigate to ticket detail view after a short delay
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offNamed('/tickets/:id', arguments: {'ticket': updatedTicket});
        } else {
          // Show warning if ticket details not found
          showTopSnackBar(
            context,
            'Ticket updated but could not load details. Please refresh.',
            Colors.orange,
            title: '⚠️ Warning',
            icon: Icons.warning,
            duration: const Duration(seconds: 3),
          );
          await Future.delayed(const Duration(milliseconds: 3500));
          Get.offAllNamed('/main_screen');
        }
      } else {
        // Show error if respondToSOS failed
        showTopSnackBar(
          context,
          'Failed to respond to SOS. Please try again.',
          Colors.red,
          title: '❌ Error',
          icon: Icons.error,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      showTopSnackBar(
        context,
        'Something went wrong: ${e.toString()}',
        Colors.red,
        title: '❌ Error',
        icon: Icons.error,
        duration: const Duration(seconds: 3),
      );
    }
  }
}