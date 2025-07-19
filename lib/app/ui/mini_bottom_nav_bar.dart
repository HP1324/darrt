import 'package:flutter/material.dart';
import 'package:darrt/helpers/globals.dart' as g;

class MiniBottomNavBar extends StatefulWidget {
  const MiniBottomNavBar({super.key, required this.children});
  final List<Widget> children;

  @override
  State<MiniBottomNavBar> createState() => _MiniBottomNavBarState();
}

class _MiniBottomNavBarState extends State<MiniBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.09,
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
    required this.onTap,
    this.i,
  });

  final IconData icon;

  final String? label;

  final VoidCallback onTap;

  final int? i;
  @override
  State<MiniBottomNavBarItem> createState() => _MiniBottomNavBarItemState();
}

class _MiniBottomNavBarItemState extends State<MiniBottomNavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ValueListenableBuilder(
      valueListenable: g.navMan.currentDestination,
      builder: (context,value, child) {
        final isSelected = widget.i == value;

        return InkWell(
          splashColor: primary.withAlpha(26),
          highlightColor: primary.withAlpha(52),
          hoverColor: primary.withAlpha(14),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 100),
            scale: _isPressed ? 0.6 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AnimatedScale(
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
                ),
                if (widget.label != null)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      widget.label!,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.labelSmall!.fontSize! + 1,
                        color: isSelected ? primary : onSurface.withAlpha(150),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
