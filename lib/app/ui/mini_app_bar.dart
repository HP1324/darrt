import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:minimaltodo/helpers/object_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
                      : formatDate(selectedDate, 'EEE, d MMM, yyyy');
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
                }),
            Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
      actions: [
        _MiniAppBarAction(
          icon: Icon(Icons.flutter_dash),
          onTap: () async {
            if (kDebugMode) {
              final databaseDir = ObjectBox.store.directoryPath;
              debugPrint("This is database path: $databaseDir");
              debugPrint("App docs dir: ${await getApplicationDocumentsDirectory()}");
              final path = join(databaseDir,'data.mdb');
              File database = File(path);
              if(await database.exists()){
                debugPrint("Database exists");
              }else{
                debugPrint("Database does not exist");
              }
              debugPrint('${await database.length()}');
            }
          },
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
