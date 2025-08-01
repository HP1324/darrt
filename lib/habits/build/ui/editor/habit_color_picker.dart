import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class HabitColorPicker extends StatelessWidget {
  const HabitColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outline,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            g.buildHabitSc.textFieldNode.unfocus();
            showColorPicker(
              context,
              onColorSelected: (color) {
                g.buildHabitSc.setColor(color);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
