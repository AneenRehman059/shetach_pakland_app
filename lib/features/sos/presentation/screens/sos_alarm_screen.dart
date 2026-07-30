import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/core/widgets/widgets/app_bar.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/tickets/data/repositories/ticket_repo.dart';

class SOSAlarmScreen extends StatelessWidget {
  final TicketModel ticket;
  const SOSAlarmScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final SOSController sosController = Get.find<SOSController>();
    final storage = const FlutterSecureStorage();

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
        child: CustomAppBar(title: 'SOS'),
      ),
      body: isTV
          ? _buildTVLayout(context, sosController, storage)
          : _buildMobileLayout(context, sosController, storage),
    );
  }

  // ─── MOBILE — same as before ───
  Widget _buildMobileLayout(BuildContext context, SOSController sosController, FlutterSecureStorage storage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 100, horizontal: 24),
        child: Column(children: [
          Text("🚨 ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 30),
          Text('EMERGENCY', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 20),
          Text('User needs immediate assistance!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.red[700], fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Text('Ticket ID: ${ticket.id}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 50),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: () async => await _handleGoAndRespond(context, sosController, storage),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('ACCEPT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(
              onPressed: () async { await _handleCancel(context, sosController); Get.offNamed('/main_screen'); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('CANCEL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          ]),
        ]),
      ),
    );
  }

  // ─── TV — wide layout ───
  Widget _buildTVLayout(BuildContext context, SOSController sosController, FlutterSecureStorage storage) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 800),
        padding: EdgeInsets.all(48),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Left — emergency info
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("🚨", style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text('EMERGENCY', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 16),
            Text('User needs immediate assistance!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Colors.red[700], fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Text('Ticket ID: ${ticket.id}', style: TextStyle(fontSize: 20, color: Colors.grey[700], fontWeight: FontWeight.bold)),
            ),
          ])),
          const SizedBox(width: 60),
          // Right — action buttons
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 240,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () async => await _handleGoAndRespond(context, sosController, storage),
                icon: Icon(Icons.check_circle, size: 28),
                label: Text('ACCEPT', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 240,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () async { await _handleCancel(context, sosController); Get.offNamed('/main_screen'); },
                icon: Icon(Icons.cancel, size: 28),
                label: Text('CANCEL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context, SOSController sosController) async {
    try {
      await sosController.stopAdminAlarm();
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      showTopSnackBar(context, 'Something went wrong: $e', Colors.red, title: '❌ Error', icon: Icons.error, duration: const Duration(seconds: 3));
    }
  }

  Future<void> _handleGoAndRespond(BuildContext context, SOSController sosController, FlutterSecureStorage storage) async {
    if (Get.isDialogOpen ?? false) return;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final ticketRepo = TicketRepository();
      final latestTicket = await ticketRepo.getTicket(ticket.id);
      if (Get.isDialogOpen ?? false) Get.back();
      if (latestTicket != null && latestTicket.status == "In Progress") {
        await sosController.stopAdminAlarm();
        showTopSnackBar(context, 'This ticket is already In Progress.', Colors.orange, title: '⚠️ Already Assigned', icon: Icons.warning, duration: const Duration(seconds: 3));
        await Future.delayed(const Duration(milliseconds: 3500));
        if (Get.context != null) Get.offAllNamed('/main_screen');
        return;
      }
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final responderUserId = await storage.read(key: 'user_id') ?? '';
      final responderName = await storage.read(key: 'user_name') ?? 'Admin';
      await sosController.stopAdminAlarm();
      final success = await sosController.respondToSOS(ticketId: ticket.id, responderUserId: responderUserId, responderName: responderName);
      if (Get.isDialogOpen ?? false) Get.back();
      if (success) {
        final ticketController = TicketController();
        await ticketController.assignTicket(brn_code: ticket.brn_code, ticketId: ticket.id, departmentId: ticket.title, assignedToUserId: ticketController.userId.toString(), category: 'SOS', dueDate: DateTime.now(), remarks: "");
        final updatedTicket = await ticketRepo.getTicket(ticket.id);
        if (updatedTicket != null) {
          showTopSnackBar(context, 'Ticket #${ticket.id} has been assigned to you.', Colors.green, title: '✅ SOS Ticket Assigned!', icon: Icons.check_circle, duration: const Duration(seconds: 3));
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offNamed('/tickets/:id', arguments: {'ticket': updatedTicket});
        } else {
          showTopSnackBar(context, 'Ticket updated but could not load details.', Colors.orange, title: '⚠️ Warning', icon: Icons.warning, duration: const Duration(seconds: 3));
          await Future.delayed(const Duration(milliseconds: 3500));
          Get.back();
        }
      } else {
        showTopSnackBar(context, 'Failed to respond to SOS. Please try again.', Colors.red, title: '❌ Error', icon: Icons.error, duration: const Duration(seconds: 3));
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      showTopSnackBar(context, 'Something went wrong: ${e.toString()}', Colors.red, title: '❌ Error', icon: Icons.error, duration: const Duration(seconds: 3));
    }
  }
}