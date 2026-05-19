import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../../controllers/tickets_controller.dart';
import '../../customs/widgets/app_text_field.dart';
import '../../models/ticket_models.dart';


class FeedbackScreen extends StatefulWidget {
  final TicketModel ticket;
  final TicketController controller;

  const FeedbackScreen({
    super.key,
    required this.ticket,
    required this.controller,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      // Use controller's showErrorDialog method
      widget.controller.showErrorDialog('Please select a rating to submit feedback');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Submit feedback and close ticket
      final success = await widget.controller.submitFeedbackAndCloseTicket(
        ticketId: widget.ticket.id,
        rating: _rating,
        priority: widget.ticket.ticketPriority,
        comment: _commentController.text.trim(),
      );

      if (success) {
        // Success message controller se hi show hoga automatically
        // Dashboard par redirect karo
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.until((route) => route.isFirst); // Dashboard tak wapas jao
        });
      }
      // Error message bhi controller se hi show hoga automatically
    } catch (e) {
      // Exception bhi controller handle karega
      print('Feedback submission error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //leading: IconButton(onPressed: () => Get.back(),
        leading: IconButton(onPressed: () => Get.offAllNamed('/main_screen'),
            icon:Icon(Icons.arrow_back_outlined)),
        title: Padding(
          padding: EdgeInsets.only(left:MediaQuery.of(context).size.width * 0.12, ),
          child: Row(
            children: [
              Text('Feedback & Close'),
            ],
          ),
        ),
        //   Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        // children: [
        //   Center(
        //     child: Text(
        //       _getAppBarTitle(ticketController.userType.toString()),
        //     ),
        //   ),

        //     SOSButtonClone(
        //       onTap: ()=> Get.toNamed('/UserSOS'), isActive: false,
        //     ),
        //     if (ticketController.userType == "Admin" ||
        //         (ticketController.userType == "Customer" &&
        //             ticketController.canReceiveSOS.value)) ...[
        //       GestureDetector(
        //         onTap: () => Get.toNamed('/SOSListView'),
        //         child: Stack(
        //           clipBehavior: Clip.none,
        //           children: [
        //             IconButton(
        //               onPressed: () => Get.toNamed('/SOSListView'),
        //               icon: Icon(Icons.notifications, color: Colors.yellowAccent.shade700, size: 28),
        //             ),
        //             // Badge
        //             Positioned(
        //               right: 6,
        //               top: 6,
        //               child: Container(
        //                 padding: EdgeInsets.all(4),
        //                 decoration: BoxDecoration(
        //                   color: Colors.red,
        //                   borderRadius: BorderRadius.circular(12),
        //                 ),
        //                 constraints: BoxConstraints(
        //                   minWidth: 20,
        //                   minHeight: 20,
        //                 ),
        //                 child: Text(
        //                   ticketController.sosTicketsCount.string,
        //                   style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 12,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                   textAlign: TextAlign.center,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       )
        //     ],
        //   ],
        // )),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Ticket: ${widget.ticket.title}',
                        //   style: const TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${widget.ticket.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please share your experience with this ticket resolution.',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Rating Scale
                const Text(
                  'Overall Rating (1-5 stars) *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select your rating to close the ticket',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: _isSubmitting ? null : () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              size: 40,
                              color: index < _rating ? Colors.amber : Colors.grey,
                            ),
                            Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: index < _rating ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Comment Box
                const Text(
                  'Remarks (optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _commentController,
                  label: '',
                  hint: 'Share your thoughts...',
                  maxLines: 5,
                  maxLength: 1000,
                  showCounter: true,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _isSubmitting
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 8),
                        Text('Submitting...'),
                      ],
                    )
                        : const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Loading Overlay
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: SpinKitWave(
                  color: AppColors.primaryColor,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}