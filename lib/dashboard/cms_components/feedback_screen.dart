import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../colors.dart';
import '../../controllers/tickets_controller.dart';
import '../../customs/widgets/app_text_field.dart';
import '../../function/screen_helper.dart';
import '../../models/ticket_models.dart';

class FeedbackScreen extends StatefulWidget {
  final TicketModel ticket;
  final TicketController controller;
  const FeedbackScreen({super.key, required this.ticket, required this.controller});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() { _commentController.dispose(); super.dispose(); }

  Future<void> _submitFeedback() async {
    if (_rating == 0) { widget.controller.showErrorDialog('Please select a rating to submit feedback'); return; }
    setState(() => _isSubmitting = true);
    try {
      final success = await widget.controller.submitFeedbackAndCloseTicket(ticketId: widget.ticket.id, rating: _rating, priority: widget.ticket.ticketPriority, comment: _commentController.text.trim());
      if (success) Future.delayed(const Duration(milliseconds: 500), () => Get.until((route) => route.isFirst));
    } catch (e) { print('Feedback submission error: $e'); }
    finally { if (mounted) setState(() => _isSubmitting = false); }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () => Get.offAllNamed('/main_screen'), icon: Icon(Icons.arrow_back_outlined, size: isTV ? 30 : 24)),
        title: Padding(
          padding: EdgeInsets.only(left: size.width * 0.12),
          child: Text('Feedback & Close', style: TextStyle(fontSize: isTV ? 22 : 16)),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        toolbarHeight: isTV ? 70 : kToolbarHeight,
        elevation: 0,
      ),
      body: Stack(children: [
        isTV ? _buildTVLayout(context) : _buildMobileLayout(context),
        if (_isSubmitting) Container(color: Colors.black.withOpacity(0.3), child: Center(child: SpinKitWave(color: AppColors.primaryColor, size: 50.0))),
      ]),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildContent(context, isTV: false),
    );
  }

  Widget _buildTVLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(children: [
      // Left — ticket info
      Container(
        width: size.width * 0.35,
        padding: EdgeInsets.all(24),
        color: Colors.grey[50],
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.feedback_outlined, size: 60, color: AppColors.primaryColor),
          SizedBox(height: 20),
          Text('Ticket ID', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text(widget.ticket.id, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
          SizedBox(height: 16),
          Text('Please share your experience with this ticket resolution.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 15)),
        ]),
      ),
      // Right — form
      Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(32), child: _buildContent(context, isTV: true))),
    ]);
  }

  Widget _buildContent(BuildContext context, {required bool isTV}) {
    final size = MediaQuery.of(context).size;
    final starSize = isTV ? 56.0 : 40.0;
    final titleSize = isTV ? 22.0 : 18.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!isTV) ...[
        Card(
          elevation: 2,
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ID: ${widget.ticket.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please share your experience with this ticket resolution.', style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 14)),
          ])),
        ),
        const SizedBox(height: 24),
      ],
      Text('Overall Rating (1-5 stars) *', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Please select your rating to close the ticket', style: const TextStyle(color: Colors.grey, fontSize: 14)),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return GestureDetector(
            onTap: _isSubmitting ? null : () => setState(() => _rating = index + 1),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTV ? 8 : 4),
              child: Column(children: [
                Icon(index < _rating ? Icons.star : Icons.star_border, size: starSize, color: index < _rating ? Colors.amber : Colors.grey),
                Text((index + 1).toString(), style: TextStyle(fontSize: isTV ? 16 : 14, fontWeight: FontWeight.bold, color: index < _rating ? Colors.black : Colors.grey)),
              ]),
            ),
          );
        }),
      ),
      SizedBox(height: isTV ? 32 : 24),
      Text('Remarks (optional)', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold)),
      SizedBox(height: isTV ? 20 : 16),
      AppTextField(controller: _commentController, label: '', hint: 'Share your thoughts...', maxLines: isTV ? 6 : 5, maxLength: 1000, showCounter: true, enabled: !_isSubmitting),
      SizedBox(height: isTV ? 40 : 32),
      SizedBox(
        width: double.infinity,
        height: isTV ? 60 : 50,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitFeedback,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), disabledBackgroundColor: Colors.grey),
          child: _isSubmitting
              ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20), SizedBox(width: 8), Text('Submitting...')])
              : Text('Submit', style: TextStyle(fontSize: isTV ? 20 : 16, fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }
}