import 'package:flutter/material.dart';

class DarrtFilledButton extends StatelessWidget {
  const DarrtFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
  });

  final VoidCallback onPressed;

  final Widget child;

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(5),
          ),
        ),
      ),
      child: FilledButton(onPressed: onPressed, child: child),
    );
  }
}
