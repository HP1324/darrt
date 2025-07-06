import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/app/services/google_sign_in_service.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';

class MiniAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MiniAppBar({super.key});
  // final GlobalKey _popupKey = GlobalKey();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: g.navMan.currentDestination,
      builder: (context, value, child) {
        if (value == 0) {
          return AppBar(
            elevation: 0,
            title: InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(),
                      child: CalendarDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: getFirstDate(),
                        lastDate: getMaxDate(),
                        onDateChanged: (selectedDate) {
                          final date = DateUtils.dateOnly(selectedDate);
                          g.calMan.scrollToDate(date);
                        },
                      ),
                    );
                  },
                );
              },
              child: Row(
                children: [
                  ListenableBuilder(
                    listenable: g.calMan,
                    builder: (context, child) {
                      final selectedDate = g.calMan.selectedDate;
                      final isBefore = selectedDate.isBefore(g.calMan.previousSelectedDate);
                      final title = DateUtils.isSameDay(selectedDate, DateTime.now())
                          ? 'Today'
                          : formatDateNoJm(selectedDate, 'EEE, d MMM, yyyy');
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          final inAnimation = Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          final outAnimation = Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          if (child.key == ValueKey<DateTime>(selectedDate)) {
                            // This is the new date coming in
                            return ClipRect(
                              child: SlideTransition(
                                position: isBefore ? inAnimation : outAnimation,
                                child: child,
                              ),
                            );
                          } else {
                            // This is the old date going out
                            return ClipRect(
                              child: SlideTransition(
                                position: isBefore ? outAnimation : inAnimation,
                                child: child,
                              ),
                            );
                          }
                        },
                        child: Text(
                          title,
                          key: ValueKey<DateTime>(selectedDate),
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
            actions: [
              if (kDebugMode)
                _MiniAppBarAction(
                  icon: Icon(Icons.handyman),
                  onTap: () async {
                    if (kDebugMode) {
                      final user = GoogleSignInService().currentUser;
                      MiniLogger.dp(user?.email ?? 'No user is currently logged in');
                    }
                    final path = ObjectBox().store!.directoryPath;
                    debugPrint('ObjectBox path: $path');
                    final docsDir = await getApplicationDocumentsDirectory();
                    debugPrint('App docs dir: ${docsDir.path}/objectbox');

                    await createNotification();
                  },
                ),
              TimelineFilterButton(),
              _MiniAppBarAction(
                onTap: () async {
                  showQuickReminderDialog() async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return QuickReminderDialog();
                      },
                    );
                  }

                  bool allowed = true;
                  if (!await AwesomeNotifications().isNotificationAllowed()) {
                    if (!context.mounted) return; // Check before using context
                    allowed = await NotificationService.showNotificationRationale(context);
                  }
                  if (!context.mounted) return; // Check again after async call

                  if (allowed) {
                    await showQuickReminderDialog();
                  } else {
                    showToast(
                      context,
                      type: ToastificationType.error,
                      description: 'Notification permission denied!',
                    );
                  }
                },
                icon: Tooltip(
                  waitDuration: Duration(milliseconds: 500),
                  message: 'Quick reminder',
                  child: Icon(Icons.alarm_add_sharp),
                ),
              ),

              // _MiniAppBarAction(
              //   key: _popupKey,
              //   icon: Icon(Icons.more_vert),
              //   onTap: () {
              //     final (offset, size) = getOffsetAndSize(_popupKey);
              //     showMenu(
              //       context: context,
              //       elevation: 1,
              //       popUpAnimationStyle: AnimationStyle(duration: Duration(milliseconds: 100)),
              //       position: getRelativeRectFromOffsetAndSize(offset, size),
              //       items: [
              //         PopupMenuItem(child: Text('Notifications')),
              //         PopupMenuItem(child: Text('Rate Us')),
              //         PopupMenuItem(child: Text('Give Feedback')),
              //         PopupMenuItem(child: Text('Settings')),
              //       ],
              //     );
              //   },
              // ),
            ],
          );
        }
        return AppBar(
          title: Text('Categories', style: Theme.of(context).textTheme.titleMedium),
        );
      },
    );
  }

  Future<void> createNotification() async {
    final int notifId = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    const totalDuration = Duration(minutes: 5); // 5 minutes

    DateTime startTime = DateTime.now();

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifId,
        channelKey: notifChannelKey,
        autoDismissible: false,
        locked: true,
        body: 'Progress notification in progress...',
        chronometer: Duration.zero,
        timeoutAfter: totalDuration,
        // category: NotificationCategory.Service,
        showWhen: true,
        progress: 0,
        notificationLayout: NotificationLayout.ProgressBar,
      ),
    );

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final elapsed = DateTime.now().difference(startTime);
      final progressPercent = (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100)
          .clamp(0, 100)
          .toDouble();

      // Update the notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: notifChannelKey,
          title: 'Elapsed time: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
          progress: progressPercent,
          locked: true,
          autoDismissible: false,
          chronometer: Duration.zero,
          timeoutAfter: totalDuration,
          category: NotificationCategory.Service,
          notificationLayout: NotificationLayout.ProgressBar,
        ),
      );

      if (progressPercent >= 100) {
        timer.cancel();
        // optionally cancel the notification or mark it as done
        // AwesomeNotifications().cancel(notifId);
      }
    });
  }
}

class TimelineFilterButton extends StatelessWidget {
  const TimelineFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        return PopupMenuButton<bool>(
          icon: Icon(
            g.taskVm.isTimelineView ? Icons.timeline : Icons.view_agenda,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'View Mode',
          onSelected: (value) {
            g.taskVm.setViewMode(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem<bool>(
              value: false,
              child: Row(
                children: [
                  Icon(
                    Icons.view_agenda,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  const Text('List View'),
                  const Spacer(),
                  if (!g.taskVm.isTimelineView)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
            PopupMenuItem<bool>(
              value: true,
              child: Row(
                children: [
                  Icon(
                    Icons.timeline,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  const Text('Timeline View'),
                  const Spacer(),
                  if (g.taskVm.isTimelineView)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuickReminderDialog extends StatefulWidget {
  const QuickReminderDialog({super.key});

  @override
  State<QuickReminderDialog> createState() => _QuickReminderDialogState();
}

class _QuickReminderDialogState extends State<QuickReminderDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  Set<String> reminderTypes = {notifReminderType, alarmReminderType};
  late String reminderType = notifReminderType;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog.adaptive(
      shape: OutlineInputBorder(),
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quick reminder',
            style: textTheme.titleMedium,
          ),
          Tooltip(
            showDuration: Duration(milliseconds: 6000),
            triggerMode: TooltipTriggerMode.tap,
            message: Messages.mQuickReminderMessage,
            child: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      content: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reminder type selection segmented buttons string
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: notifReminderType,
                label: FittedBox(child: Text('Notification')),
              ),
              ButtonSegment(value: alarmReminderType, label: Text('Alarm')),
            ],
            selected: {reminderType},
            onSelectionChanged: (selected) {
              setState(() {
                reminderType = selected.first;
              });
            },
          ),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title (optional)',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Remind me after'),
                SizedBox(width: 8),
                Flexible(
                  child: IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 40,
                        maxWidth: 80,
                      ),
                      child: TextField(
                        controller: _minutesController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          isDense: true,
                          counterText: '',
                          errorText: null,
                        ),
                        style: TextStyle(fontSize: 16, height: 1.2),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              // Don't allow starting with 0
                              if (newValue.text.startsWith('0') && newValue.text.isNotEmpty) {
                                return oldValue;
                              }

                              if (newValue.text.isEmpty) return newValue;
                              final intValue = int.tryParse(newValue.text);
                              if (intValue != null && intValue > 999) {
                                return oldValue;
                              }
                              return newValue;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text('minutes'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final title = _titleController.text;
            final minutes = int.parse(_minutesController.text);
            showToast(
              context,
              type: ToastificationType.success,
              description:
                  'Reminder set after ${minutes > 1 ? '$minutes minutes' : '$minutes minute'}',
            );
            Navigator.pop(context);
            await NotificationService.scheduleQuickReminder(title, minutes, type: reminderType);
            MiniLogger.dp('title: $title, minutes: $minutes, type: ${minutes.runtimeType}');
          },
          child: Text('Set Reminder'),
        ),
      ],
    );
  }
}

class _MiniAppBarAction extends StatelessWidget {
  const _MiniAppBarAction({required this.icon, required this.onTap});
  final Widget icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: icon,
      ),
    );
  }
}
