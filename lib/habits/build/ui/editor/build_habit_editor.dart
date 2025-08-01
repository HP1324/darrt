import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/habits/build/ui/editor/date_pickers.dart';
import 'package:darrt/habits/build/ui/editor/habit_color_picker.dart';
import 'package:darrt/habits/build/ui/editor/habit_description_field.dart';
import 'package:darrt/habits/build/ui/editor/habit_name_field.dart';
import 'package:darrt/habits/build/ui/editor/habit_text_field.dart';
import 'package:darrt/habits/build/ui/editor/measurement_type_selector.dart';
import 'package:darrt/habits/build/ui/editor/time_pickers.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class BuildHabitEditor extends StatefulWidget {
  const BuildHabitEditor({super.key, required this.edit, this.habit, this.category})
    : assert(!edit || habit != null);

  final BuildHabit? habit;
  final bool edit;

  final EntityCategory? category;
  @override
  State<BuildHabitEditor> createState() => _BuildHabitEditorState();
}

class _BuildHabitEditorState extends State<BuildHabitEditor> {
  @override
  void initState() {
    super.initState();
    g.buildHabitSc.initState(widget.edit, widget.habit, widget.category);
  }

  @override
  void dispose() {
    debugPrint("dispose called");
    g.buildHabitSc.clearState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: getLerpedColor(context, getColorFromString(g.buildHabitSc.color)),
          appBar: AppBar(
            backgroundColor: getLerpedColor(context, getColorFromString(g.buildHabitSc.color)),
            leading: BackButton(),
            title: FittedBox(child: Text(widget.edit ? widget.habit!.name : 'Build A New Habit')),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                spacing: 20,
                children: [
                  const SizedBox(),
                  Row(
                    children: [
                      Expanded(child: HabitNameField()),
                      const SizedBox(width: 12),
                      HabitColorPicker(),
                    ],
                  ),
                  HabitDescriptionField(),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(child: StartDatePicker()),
                      Expanded(child: EndDatePicker()),
                    ],
                  ),
                  MeasurementTypeSelector(),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: g.buildHabitSc.measurementType == MeasurementType.boolean
                        ? Row(
                            spacing: 8,
                            children: [
                              Expanded(child: StartTimePicker()),
                              Expanded(child: EndTimePicker()),
                            ],
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}











