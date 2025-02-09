import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_enums.dart';



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
    Offset? tapPosition,
  }) {
    PageRouteBuilder route;

    switch (type) {
      case MiniPageTransitionType.jumpFromRight:
        route = _createJumpFromRightTransition(page);
        break;
      case MiniPageTransitionType.popFromCenter:
        route = _createPopFromCenterTransition(page);
        break;
      case MiniPageTransitionType.popFromTap:
        route = _createPopFromTapTransition(page, tapPosition);
        break;
      case MiniPageTransitionType.fadeIn:
        route = _createFadeInTransition(page);
        break;
      case MiniPageTransitionType.slideFromBottom:
        route = _createSlideFromBottomTransition(page);
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

  static PageRouteBuilder _createPopFromCenterTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder _createPopFromTapTransition(Widget page, Offset? tapPosition) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );

        return Stack(
          children: [
            Positioned(
              left: tapPosition?.dx ?? 0,
              top: tapPosition?.dy ?? 0,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Container(
                  width: 0, // Start with no width
                  height: 0, // Start with no height
                  color: Colors.transparent, // Transparent to avoid visual artifacts
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }

  static PageRouteBuilder _createFadeInTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );

        return FadeTransition(
        opacity: fadeAnimation,
        child: child,
        );
      },
    );
  }

  static PageRouteBuilder _createSlideFromBottomTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final slideAnimation = Tween<Offset>(
          begin: Offset(0, 1), // Start from the bottom
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}