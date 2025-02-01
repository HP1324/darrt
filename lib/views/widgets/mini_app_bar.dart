import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_page_transition.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/views/pages/navigation/finished_tasks_page.dart';
import 'package:minimaltodo/views/pages/search_page.dart';

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
          key: _popupKey,
          icon: Icon(Icons.more_vert),
          onTap: () {
            final RenderBox renderBox = _popupKey.currentContext!.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;
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
