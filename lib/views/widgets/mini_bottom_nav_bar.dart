import 'package:flutter/material.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/test_page.dart';
import 'package:minimaltodo/view_models/navigation_view_model.dart';
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
      height: MediaQuery.sizeOf(context).height * 0.08,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(15),
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
  const MiniBottomNavBarItem({super.key, required this.icon, required this.label, required this.i});
  final IconData icon;
  final String label;
  final int i;
  @override
  State<MiniBottomNavBarItem> createState() => _MiniBottomNavBarItemState();
}

class _MiniBottomNavBarItemState extends State<MiniBottomNavBarItem> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).colorScheme.primary;
    Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Consumer<NavigationViewModel>(builder: (context, navVM, _) {
      final isSelected = widget.i == navVM.currentDestination;
      return InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () {
          if(widget.i != -1) {
            navVM.onDestinationChanged(widget.i);
          }else{
            AppRouter.to(context, child: TestPage(),type: PageTransitionType.rightToLeft,);
          }
        },
        child: Column(
          spacing: 3,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                padding: EdgeInsets.all(5),
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: isSelected ? primary : onSurface.withAlpha(150),
                )),
            Text(
                widget.label,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelSmall!.fontSize!+1,
                  color: isSelected ? primary : onSurface.withAlpha(150),
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      );
    });
  }
}
