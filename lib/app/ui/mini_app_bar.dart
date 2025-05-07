import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:minimaltodo/app/state/managers/calendar_manager.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:provider/provider.dart';

class MiniAppBar extends StatelessWidget implements PreferredSizeWidget {
  MiniAppBar({super.key});
  final GlobalKey _popupKey = GlobalKey();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  AppBar build(BuildContext context) {
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
                    context.read<CalendarManager>().scrollToDate(date);
                  },
                ),
              );
            },
          );
        },
        child: Row(
          children: [
            Selector<CalendarManager, DateTime>(
                selector: (context, calVM) => calVM.selectedDate,
                builder: (context, selectedDate, _) {
                  final isBefore = selectedDate.isBefore(DateTime.now());
                  final title = DateUtils.isSameDay(selectedDate, DateTime.now()) ? 'Today': formatDate(selectedDate, 'EEE, d MMM, yyyy');
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, animation) {
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
                }),
            Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
      actions: [
        _MiniAppBarAction(
          icon: Icon(Icons.flutter_dash),
          onTap: () async {
            if(kDebugMode){
              debugPrint('${SchedulerBinding.instance.lifecycleState}');
              debugPrint('${WidgetsBinding.instance.lifecycleState}');
            }
            // final scheduledNotifs = await AwesomeNotifications().listScheduledNotifications();
            // for (var notif in scheduledNotifs) {
            //   debugPrint('Group key: ${notif.content!.groupKey}');
            // }
            // print(
            //     scheduledNotifs.where((notif) => notif.content!.groupKey == 34.toString()).length);
            // scheduledNotifs.where((t) => t.content!.groupKey == 34.toString()).forEach((element) {
            //   print('${element.content!.title}');
            // });
            // debugPrint('Active notifications: $scheduledNotifs');
            // AwesomeNotifications().createNotification(
            //     content: NotificationContent(
            //       id: 1,
            //       channelKey: 'task_alarm',
            //       title: 'Test Notification',
            //       body: 'This is a test notification',
            //     ),
            //     schedule: NotificationCalendar.fromDate(
            //       date: DateTime.now().add(Duration(seconds: 5)),
            //     ),
            //     actionButtons: [
            //       NotificationActionButton(
            //         key: 'FINISHED',
            //         label: 'Finished',
            //         actionType: ActionType.SilentAction,
            //       ),
            //     ]);
          },
        ),
        _MiniAppBarAction(
          key: _popupKey,
          icon: Icon(Icons.more_vert),
          onTap: () {
            final (position, size) = getPositionAndSize(_popupKey);
            showMenu(
              context: context,
              color: Theme.of(context).colorScheme.onPrimary,
              elevation: 1,
              popUpAnimationStyle: AnimationStyle(duration: Duration(milliseconds: 100)),
              position: RelativeRect.fromLTRB(
                position.dx,
                position.dy + size.height,
                position.dx + size.width,
                position.dy,
              ),
              items: [
                PopupMenuItem(child: Text('Notifications')),
                PopupMenuItem(child: Text('Rate Us')),
                PopupMenuItem(child: Text('Give Feedback')),
                PopupMenuItem(child: Text('Settings')),
              ],
            );
          },
        ),
      ],
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
