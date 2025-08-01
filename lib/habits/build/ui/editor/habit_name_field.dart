import 'package:darrt/habits/build/ui/editor/habit_text_field.dart';
import 'package:darrt/helpers/globals.dart' as g show buildHabitSc;
import 'package:flutter/material.dart';

class HabitNameField extends StatelessWidget {
  const HabitNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return HabitTextField(
      controller: g.buildHabitSc.textController,
      focusNode: g.buildHabitSc.textFieldNode,
      autoFocus: true,
      labelText: 'Habit Name',
    );
  }
}
