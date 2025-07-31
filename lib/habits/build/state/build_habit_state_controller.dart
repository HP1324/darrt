import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state.dart';
import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:darrt/task/models/repeat_config.dart';
import 'package:flutter/material.dart';

class BuildHabitStateController extends StateController<BuildHabitState, BuildHabit> {
  final descriptionController = TextEditingController();
  final descriptionFocusNode = FocusNode();
  final unitController = TextEditingController();
  final unitFocusNode = FocusNode();

  @override
  BuildHabit buildModel({required bool edit, BuildHabit? model}) {
    throw UnimplementedError();
  }

  @override
  void clearState() {
    state = state.copyWith(
      categorySelection: {EntityCategory(id: 1, name: 'General'): true},
      startDate: DateTime.now(),
      endDate: null,
      endTime: null,
      repeatConfig: RepeatConfig(),
      reminders: [],
    );
  }

  @override
  void initState(bool edit, [BuildHabit? habit]) {
    textController.text = edit ? habit!.name : '';
    descriptionController.text = edit ? habit!.description ?? '' : '';
    unitController.text = edit ? habit!.unit ?? '' : '';

    final categories = g.catVm.categories;

    state = BuildHabitState(
      categorySelection: edit
          ? {for (var cat in categories) cat: habit!.categories.contains(cat)}
          : {EntityCategory(id: 1, name: 'General'): true},
      startDate: edit ? habit!.startDate : DateTime.now(),
      color: edit ? habit!.color! : 'primary',
      reminders: edit ? Reminder.getReminderObjects(habit!.reminders) : [],
      repeatConfig: edit ? RepeatConfig.fromJsonString(habit!.repeatConfig) : RepeatConfig(),
      endDate: edit ? habit!.endDate : null,
      endTime: edit ? habit!.endTime : null,
    );
  }
}
