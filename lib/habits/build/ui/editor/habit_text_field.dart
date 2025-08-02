import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class HabitTextField extends StatelessWidget {
  const HabitTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.focusNode,
    this.autoFocus = false,
    this.hintText,
    this.enabled,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });
  final TextEditingController? controller;
  final String labelText;
  final FocusNode? focusNode;
  final bool autoFocus;
  final String? hintText;
  final bool? enabled;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

    return SizedBox(
      height: 55,
      child: TextField(
        keyboardType: keyboardType,
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autoFocus,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(color: color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: color,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: color,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
