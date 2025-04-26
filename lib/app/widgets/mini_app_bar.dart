import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/calendar_view_model.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
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
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(14),
      elevation: 0,
      title: Selector<CalendarViewModel, DateTime>(
          selector: (context, calVM) => calVM.selectedDate,
          builder: (context, selectedDate, _) {
            final isBefore = selectedDate.isBefore(DateTime.now());
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
                formatDate(selectedDate, 'EEE, d MMM, yyyy'),
                key: ValueKey<DateTime>(selectedDate),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }),
      actions: [
        _MiniAppBarAction(
          icon: Icon(Icons.flutter_dash),
          onTap: () async {
            final scheduledNotifs = await AwesomeNotifications().listScheduledNotifications();
            for(var notif in scheduledNotifs){
              debugPrint('Group key: ${notif.content!.groupKey}');
            }
            print(scheduledNotifs.where((notif) => notif.content!.groupKey == 34.toString()).length);
            scheduledNotifs.where((t) => t.content!.groupKey == 34.toString()).forEach((element) {
              print('${element.content!.title}');
            });
            debugPrint('Active notifications: $scheduledNotifs');
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 1,
                channelKey: 'task_alarm',
                title: 'Test Notification',
                body: 'This is a test notification',
              ),
              schedule: NotificationCalendar.fromDate(
                date: DateTime.now().add(Duration(seconds: 5)),
              ),
              actionButtons: [
                NotificationActionButton(
                  key: 'FINISHED',
                  label: 'Finished',
                  actionType: ActionType.SilentAction,
                ),
              ]
            );
          },
        ),
        _MiniAppBarAction(
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(),
                    child: CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate:DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate)),
                      lastDate: DateTime.now().add(Duration(days: maxExtentDateDays)),
                      onDateChanged: (selectedDate) {
                        final date = DateUtils.dateOnly(selectedDate);
                        context.read<CalendarViewModel>().scrollToDate(date);
                      },
                    ),
                  );
                });
          },
          icon: Icon(Icons.calendar_month_outlined),
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
