import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/app/ui/motivation_dialog.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/quickreminder/ui/quick_reminder_dialog.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MiniAppBar extends StatelessWidget implements PreferredSizeWidget {
  MiniAppBar({super.key});
  final GlobalKey _popupKey = GlobalKey();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: g.navMan.currentDestination,
      builder: (context, value, child) {
        final backgroundColor = getSurfaceColor(context);
        if (value == 0) {
          return AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: getFirstDate(),
                      lastDate: getMaxDate(),
                      onDateChanged: (selectedDate) {
                        final date = DateUtils.dateOnly(selectedDate);
                        g.calMan.scrollToDate(date);
                      },
                    );
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListenableBuilder(
                    listenable: g.calMan,
                    builder: (context, child) {
                      final selectedDate = g.calMan.selectedDate;
                      final isBefore = selectedDate.isBefore(
                        g.calMan.previousSelectedDate,
                      );
                      final title =
                          DateUtils.isSameDay(selectedDate, DateTime.now())
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
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
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
              _MiniAppBarAction(
                icon: Icon(Icons.lightbulb_outline),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return MotivationDialog();
                    },
                  );
                },
              ),

              TimelineFilterButton(),
              _MiniAppBarAction(
                onTap: () async {
                  showQuickReminderDialog() async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return QuickReminderDialog(edit: false);
                      },
                    );
                  }

                  bool? allowed = true;
                  if (!await AwesomeNotifications().isNotificationAllowed()) {
                    if (!context.mounted) return; // Check before using context
                    allowed =
                        await NotificationService.showNotificationRationale(
                          context,
                        );
                  }
                  if (!context.mounted) return; // Check again after async call

                  if (allowed == null || !allowed) {
                    showErrorToast(context, 'Notification permission denied!');
                  } else {
                    await showQuickReminderDialog();
                  }
                },
                icon: Tooltip(
                  waitDuration: Duration(milliseconds: 500),
                  message: 'Quick reminder',
                  child: Icon(Icons.alarm_add_sharp),
                ),
              ),
              if (kDebugMode)
                _MiniAppBarAction(
                  key: _popupKey,
                  icon: Icon(Icons.more_vert),
                  onTap: () {
                    final (offset, size) = getOffsetAndSize(_popupKey);
                    showMenu(
                      context: context,
                      elevation: 1,
                      popUpAnimationStyle: AnimationStyle(
                        duration: Duration(milliseconds: 100),
                      ),
                      position: getRelativeRectFromOffsetAndSize(offset, size),
                      items: [
                        PopupMenuItem(
                          child: _MiniAppBarAction(
                            icon: Icon(Icons.handyman),
                            onTap: () async {
                              try {
                                throw StateError('Sentry Test Exception');
                              } catch (exception, stackTrace) {
                                await Sentry.captureException(
                                  exception,
                                  stackTrace: stackTrace,
                                );
                                return;
                              }
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: IconButton(
                            onPressed: () async {
                              await AwesomeNotifications().cancelSchedule(10);
                            },
                            icon: Icon(Icons.abc),
                          ),
                        ),
                        PopupMenuItem(
                          child: IconButton(
                            onPressed: () async {
                              final list = await AwesomeNotifications()
                                  .listScheduledNotifications();
                              for (final notif in list) {
                                MiniLogger.dp(
                                  '${notif.content?.id} ${notif.content?.title} ${notif.content?.body}',
                                );
                              }
                            },
                            icon: Icon(Icons.list),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          );
        } else if (value == 1)
          return AppBar(
            backgroundColor: backgroundColor,
            title: Text('Focus'),
            actions: [
              _MiniAppBarAction(
                icon: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.question_mark),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        content: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "If notification permissions are granted, you can see persistent timer notification after enabling it from settings. Go to app's Settings > Timer Settings >Enable \"Show timer as notification in notification bar until ends.\"",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        return AppBar(
          backgroundColor: backgroundColor,
          title: Text(
            'Categories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      },
    );
  }

  Future<void> createNotification() async {
    final int notifId = DateTime.now().millisecondsSinceEpoch.remainder(
      1000000,
    );
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
      final progressPercent =
          (elapsed.inMilliseconds / totalDuration.inMilliseconds * 100)
              .clamp(0, 100)
              .toDouble();

      // Update the notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: notifChannelKey,
          title:
              'Elapsed time: ${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
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
    final scheme = ColorScheme.of(context);
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        return PopupMenuButton<bool>(
          icon: Icon(
            g.taskVm.isTimelineView ? Icons.timeline : Icons.view_agenda,
            color: scheme.onSurface,
          ),
          tooltip: 'View Mode',
          onSelected: (value) {
            g.taskVm.setViewMode(value);
          },
          itemBuilder: (context) => [
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
            PopupMenuItem<bool>(
              value: false,
              child: Row(
                children: [
                  Icon(
                    Icons.view_agenda,
                    color: scheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  const Text('List View'),
                  const Spacer(),
                  if (!g.taskVm.isTimelineView)
                    Icon(
                      Icons.check,
                      color: scheme.primary,
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

class _MiniAppBarAction extends StatelessWidget {
  const _MiniAppBarAction({super.key, required this.icon, required this.onTap});
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
