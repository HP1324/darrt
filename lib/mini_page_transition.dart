import 'package:flutter/material.dart';

enum MiniPageTransitionType {
  jumpFromRight,
  // Add more transition types here later
}

class MiniPageTransition {
  final BuildContext context;
  final Widget child;

  MiniPageTransition({
    required this.context,
    required this.child,
  });

  static void push({
    required BuildContext context,
    required Widget page,
    MiniPageTransitionType type = MiniPageTransitionType.jumpFromRight,
  }) {
    PageRouteBuilder route;

    switch (type) {
      case MiniPageTransitionType.jumpFromRight:
        route = _createJumpFromRightTransition(page);
        break;
    }

    Navigator.push(context, route);
  }

  static PageRouteBuilder _createJumpFromRightTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(2.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
  }
}
