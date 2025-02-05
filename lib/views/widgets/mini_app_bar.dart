import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_page_transition.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/mini_storage.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/views/pages/navigation/finished_tasks_page.dart';
import 'package:minimaltodo/views/pages/navigation/pending_tasks_page.dart';
import 'package:minimaltodo/views/pages/search_page.dart';
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
      title: Text('MinimalTodo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      // centerTitle: true,
      actions: [
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
                        onDateChanged: (selectedDate){
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
                // PopupMenuItem(
                //   onTap: () {
                //     MiniRouter.to(context, child: PendingTasksPage());
                //   },
                //   child: Text('Pending Tasks'),
                // ),
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
