
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/features/cms/data/models/timeLine_model.dart';

// update
class TimelineView extends StatelessWidget {
  final String ticketId;
  final TicketController controller;

  const TimelineView({
    super.key,
    required this.ticketId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Load timeline when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadModuleTimeline('Ticket', ticketId);
    });

    return Obx(() {
      if (controller.timelineLoading.value) {
        return Center(
          child: SpinKitWave(
            color: AppColors.primaryColor,
            size: 24.0,
          ),
        );
      }

      if (controller.timeline.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: AppColors.textSecondaryColor),
              SizedBox(height: 16),
              Text(
                'No timeline data available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }

      // Build custom vertical timeline with left rail and single Card per step
      final List<TimeLineModel> items = List<TimeLineModel>.from(controller.timeline);
      return RefreshIndicator(
        onRefresh: () => controller.loadModuleTimeline('Ticket', ticketId),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return _StartRail();
            }
            final item = items[index];
            final actionStyle = _styleForAction(item.action, item.description);
            final nameColor = _colorForName(item.username);
            final isFirst = index == 0;
            final isLast = index == items.length - 1;
            return _TimelineStepCard(
              description: item.description,
              ticketId: ticketId,
              isFirst: isFirst,
              isLast: isLast,
              railColor: nameColor, // rail color per user
              badgeColor: _getBadgeColor(item.action, item.newstatus, item.newpriority),
              //badgeIcon: _getBadgeIcon(item.action, item.newstatus, item.newpriority),
              dateTime: _formatFullDateTime(item.createdAt),
              username: item.username.isNotEmpty ? item.username : 'Unknown User',
              usernameColor: nameColor,
              phoneNo: item.phoneNo,
              cardColor: nameColor.withOpacity(0.08),
              actionLabel: _getActionLabel(item.action, item.newstatus, item.newpriority),
              actionColor: actionStyle.color,
              module: item.module,
              badgeInitial: _getBadgeIcon(item.action, item.newstatus, item.newpriority),
              // action: item.action,
              // newStatus: item.newstatus,
              // newPriority: item.newpriority,
            );
          },
        ),
      );
    });
  }
}

String _formatFullDateTime(DateTime dateTime) {
  // Example: 12:11 pm 28/08/25
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final ampm = dateTime.hour >= 12 ? 'pm' : 'am';
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = (dateTime.year % 100).toString().padLeft(2, '0');
  return '$day/$month/$year :: $hour:$minute $ampm ';
}

// Get badge color based on action, status, and priority
Color _getBadgeColor(String action, String? status, String? priority) {
  action = action.toLowerCase();

  // Action-based colors
  if (action == 'created') return Colors.green;
  if (action == 'assigned') return Colors.purple;
  if (action == 'update') {
    // For update, check status or priority
    if (status != null && status.isNotEmpty) {
      // Status-based colors
      switch (status.toLowerCase()) {
        case 'open':
          return Colors.blue;
        case 'in progress':
          return Colors.orange;
        case 'done':
          return Colors.green;
        case 'closed':
          return Colors.red;
        default:
          return Colors.orange;
      }
    } else if (priority != null && priority.isNotEmpty) {
      // Priority-based colors
      switch (priority.toLowerCase()) {
        case 'low':
          return Colors.green;
        case 'medium':
          return Colors.yellow[700]!;
        case 'high':
          return Colors.orange;
        case 'critical':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }
    return Colors.orange; // Default for update
  }
  return Colors.blue; // Default color
}

// Get badge icon based on action, status, and priority
IconData _getBadgeIcon(String action, String? status, String? priority) {
  action = action.toLowerCase();

  if (action == 'created') {
    return Icons.add_circle;
  }

  if (action == 'assigned') {
    return Icons.person_add;
  }

  if (action == 'update') {
    if (status != null && status.isNotEmpty) {
      // Status-based icons
      switch (status.toLowerCase()) {
        case 'open':
          return Icons.lock_open;
        case 'in progress':
          return Icons.play_circle_fill;
        case 'done':
          return Icons.check_circle;
        case 'closed':
          return Icons.lock;
        default:
          return Icons.edit;
      }
    } else if (priority != null && priority.isNotEmpty) {
      // Priority-based icons
      switch (priority.toLowerCase()) {
        case 'low':
          return Icons.flag;
        case 'medium':
          return Icons.flag;
        case 'high':
          return Icons.flag;
        case 'critical':
          return Icons.warning;
        default:
          return Icons.edit;
      }
    }
    return Icons.edit; // Default for update
  }

  return Icons.info; // Default icon
}

// Get action label with status/priority info
String _getActionLabel(String action, String? status, String? priority) {
  action = action.toLowerCase();
  String label = action.toUpperCase();

  if (status != null && status.isNotEmpty) {
    label += ' . STATUS: ${status.toUpperCase()}';
  }

  if (priority != null && priority.isNotEmpty) {
    if (status != null && status.isNotEmpty) {
      label += ' & PRIORITY: ${priority.toLowerCase()}';
    } else {
      label += ' . PRIORITY: ${priority.toLowerCase()}';
    }
  }

  return label;
}

Color _colorForName(String name) {
  final n = name.isEmpty ? 'u' : name.toLowerCase();
  int hash = 0;
  for (int i = 0; i < n.length; i++) {
    hash = 31 * hash + n.codeUnitAt(i);
  }
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.5, 0.45).toColor();
}

class _ActionStyle {
  final Color color;
  final IconData icon;
  final StepState stepState;
  final String label;
  const _ActionStyle(this.color, this.icon, this.stepState, this.label);
}

_ActionStyle _styleForAction(String action, String description) {
  final text = '${action.toLowerCase()} ${description.toLowerCase()}';
  if (text.contains('created')) {
    return _ActionStyle(Colors.green, Icons.add_circle, StepState.complete, 'Create');
  }
  if (text.contains('update')) {
    return _ActionStyle(Colors.orange, Icons.edit, StepState.indexed, 'Update');
  }
  if (text.contains('assigned')) {
    return _ActionStyle(Colors.purple, Icons.person_add, StepState.indexed, 'Assigned');
  }
  if (text.contains('closed')) {
    return _ActionStyle(Colors.red, Icons.lock, StepState.disabled, 'Close');
  }
  return _ActionStyle(Colors.blue, Icons.info, StepState.indexed, 'Action');
}

class _TimelineStepCard extends StatelessWidget {
  final String ticketId;
  final bool isFirst;
  final bool isLast;
  final String module;
  final IconData? icon;
  final Color railColor;
  final Color badgeColor;
  //final String badgeInitial;
  final IconData badgeInitial;
  final String dateTime;
  final String username;
  final Color usernameColor;
  final String? description;
  //final String role;
  final String phoneNo;
  final Color cardColor;
  final String actionLabel;
  final Color actionColor;

  const _TimelineStepCard({
    required this.ticketId,
    required this.isFirst,
    required this.isLast,
    required this.module,
    this.icon,
    required this.railColor,
    required this.badgeColor,
    required this.badgeInitial,
    required this.dateTime,
    required this.username,
    required this.usernameColor,
    this.description,
    //required this.role,
    required this.phoneNo,
    required this.cardColor,
    required this.actionLabel,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final moduleTag =
    module.isNotEmpty ? ' [${module.toUpperCase()}]' : '';
    return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: isFirst ? 12 : 18,
                    color: isFirst ? Colors.transparent : railColor,
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(badgeInitial, size: 16, color: badgeColor),



                    // Text(
                    //   badgeInitial,
                    //   style: TextStyle(
                    //     color: badgeColor,
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 12,
                    //   ),
                    // ),
                  ),
                  // Fill remaining height with rail segment; IntrinsicHeight bounds it
                  Flexible(
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 2,
                        color: isLast ? Colors.transparent : railColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                elevation: 0,
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$username',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(icon, size: 16, color: actionColor),
                        ],
                      ),

                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          Text(
                            '${description?.toLowerCase()}',
                            //'${actionLabel.toLowerCase()} Ticket ID: $ticketId',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black),
                          ),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('[$dateTime]', style:
                          TextStyle(
                            color: Colors.black,
                            fontSize: 12,

                          )),
                        ],
                      ),
                      if ( phoneNo.isNotEmpty) ...[
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            // if (role.isNotEmpty)
                            //   Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       const Icon(Icons.badge, size: 14, color: Colors.grey),
                            //       const SizedBox(width: 6),
                            //       Text(role, style: TextStyle(color: AppColors.textSecondaryColor)),
                            //     ],
                            //   ),
                            // if (phoneNo.isNotEmpty)
                            //   Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       const Icon(Icons.phone, size: 14, color: Colors.grey),
                            //       const SizedBox(width: 6),
                            //       Text(phoneNo, style: TextStyle(color: AppColors.textSecondaryColor)),
                            //     ],
                            //   ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 0),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class _StartRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(width: 2, height: 18, color: Colors.grey.shade400),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow, size: 14, color: Colors.green),
                ),
                Container(width: 2, height: 8, color: Colors.transparent),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Timeline Start',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}