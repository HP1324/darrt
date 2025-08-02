import 'package:darrt/habits/build/ui/editor/habit_text_field.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:flutter/material.dart';

class UnitField extends StatelessWidget {
  const UnitField({super.key});

  @override
  Widget build(BuildContext context) {
    return HabitTextField(
      controller: g.buildHabitSc.unitController,
      focusNode: g.buildHabitSc.unitFocusNode,
      autoFocus: false,
      labelText: 'Unit of Measurement',
      hintText: 'e.g. Miles, Hours, Glasses, Pages',
    );
  }
}
