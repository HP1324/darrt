import 'package:flutter/material.dart';
import 'package:minimaltodo/app/state/managers/navigation_manager.dart';
import 'package:minimaltodo/note/ui/notes_page.dart';
import 'package:minimaltodo/task/ui/task_search_page.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MiniBottomNavBar extends StatefulWidget {
  const MiniBottomNavBar({super.key, required this.children});
  final List<Widget> children;

  @override
  State<MiniBottomNavBar> createState() => _MiniBottomNavBarState();
}

class _MiniBottomNavBarState extends State<MiniBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(right: 20,left: 20,bottom: 7),
      height: MediaQuery.sizeOf(context).height * 0.075,
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.primary.withAlpha(20),
        // borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.children,
        ),
      ),
    );
  }
}

class MiniBottomNavBarItem extends StatefulWidget {
  const MiniBottomNavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.i,
  });

  final IconData icon;
  final String? label;
  final int i;

  @override
  State<MiniBottomNavBarItem> createState() => _MiniBottomNavBarItemState();
}

class _MiniBottomNavBarItemState extends State<MiniBottomNavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Consumer<NavigationManager>(
      builder: (context, navVM, _) {
        final isSelected = widget.i == navVM.currentDestination;

        return InkWell(
          splashColor: primary.withAlpha(26),
          highlightColor: primary.withAlpha(52),
          hoverColor: primary.withAlpha(14),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            if(widget.i == -1){
              MiniRouter.to(context,TaskSearchPage(),type: PageTransitionType.bottomToTop);
            } else if(widget.i == -2){
              MiniRouter.to(context,NotesPage(),type: PageTransitionType.rightToLeft);
            } else {
              navVM.onDestinationChanged(widget.i);
            }
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _isPressed ? 0.6 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.15 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: isSelected ? primary : onSurface.withAlpha(150),
                    ),
                  ),
                ),
                if(widget.label != null)
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize:
                    Theme.of(context).textTheme.labelSmall!.fontSize! + 1,
                    color: isSelected ? primary : onSurface.withAlpha(150),
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(widget.label!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}