import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/mini_storage.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/database_service.dart';
import 'package:minimaltodo/test_app.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/navigation/finished_tasks_page.dart';
import 'package:minimaltodo/views/widgets/selectable_task_item.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
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
      title: Consumer<CalendarViewModel>(
          builder: (context, calVM, _) {
            final isBefore = calVM.selectedDate.isBefore(DateTime.now());
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

                if (child.key == ValueKey<DateTime>(calVM.selectedDate)) {
                  // This is the new date coming in
                  return ClipRect(
                    child: SlideTransition(
                      position:isBefore ?  inAnimation :outAnimation,
                      child: child,
                    ),
                  );
                } else {
                  // This is the old date going out
                  return ClipRect(
                    child: SlideTransition(
                      position:isBefore ? outAnimation:inAnimation,
                      child: child,
                    ),
                  );
                }
              },
              child: Text(
                formatDateWith(calVM.selectedDate, 'EEE, d MMM, yyyy'),
                key: ValueKey<DateTime>(calVM.selectedDate),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
      ),
      actions: [
        _MiniAppBarAction(
          icon: Icon(Icons.flutter_dash),
          onTap: ()async {
            // final db = await DatabaseService.openDb();
            // await db.delete('tasks');
            // await TestApp.insertTestTasks(db);
            // if(context.mounted) {
            //   context.read<TaskViewModel>().testRefreshTasks();
            // }
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
                      initialDate: null,
                      firstDate: DateTime.parse(MiniBox.read(mFirstInstallDate)).subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 18263)),
                      onDateChanged: (selectedDate) {
                        context.read<CalendarViewModel>().scrollToDate(selectedDate);
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
                PopupMenuItem(
                  onTap: () {
                    MiniRouter.to(context, child: FinishedTasksPage());
                  },
                  child: Text('Finished Tasks'),
                ),
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
