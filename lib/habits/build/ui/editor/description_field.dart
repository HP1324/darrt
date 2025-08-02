import 'package:darrt/habits/build/ui/editor/habit_text_field.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:flutter/material.dart';

class HabitDescriptionField extends StatelessWidget {
  const HabitDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    return HabitTextField(
      controller: g.buildHabitSc.descriptionController,
      focusNode: g.buildHabitSc.descriptionFocusNode,
      autoFocus: false,
      labelText: 'Description (Optional)',
      hintText: "Why is this habit important to you?",
    );
  }
}
