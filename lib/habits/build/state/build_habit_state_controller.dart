import 'dart:convert';

import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/models/build_habit_target.dart';
import 'package:darrt/habits/build/state/build_habit_state.dart';
import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/task/models/reminder.dart';
import 'package:darrt/task/models/repeat_config.dart';
import 'package:flutter/material.dart';

class BuildHabitStateController extends StateController<BuildHabitState, BuildHabit> {
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode descriptionFocusNode = FocusNode();
  final TextEditingController unitController = TextEditingController();
  final FocusNode unitFocusNode = FocusNode();

  @override
  BuildHabit buildModel({required bool edit, BuildHabit? model}) {
    BuildHabit habit;
    if (edit) {
      habit = model!;
      habit.name = textController.text;
      habit.description = descriptionController.text;
      habit.unit = unitController.text;
      habit.startDate = startDate;
      habit.endDate = endDate;
      habit.endTime = endTime;
      habit.repeatConfig = repeatConfig.toJsonString();
      habit.reminders = Reminder.remindersToJsonString(reminders);
    } else {
      habit = BuildHabit(
        name: textController.text,
        description: descriptionController.text,
        unit: unitController.text,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        repeatConfig: repeatConfig.toJsonString(),
        reminders: Reminder.remindersToJsonString(reminders),
        measurementType: measurementType.name,
        target: target.toJsonString(),
      );
    }
    return habit;
  }

  @override
  void clearState() {
    state = state.copyWith(
      categorySelection: {EntityCategory(id: 1, name: 'General'): true},
      startDate: DateTime.now(),
      endDate: null,
      startTime: null,
      endTime: null,
      repeatConfig: RepeatConfig(),
      reminders: [],
      color: 'primary',
      target: BuildHabitTarget(),
    );
    textController.clear();
    descriptionController.clear();
    unitController.clear();
  }


  @override
  void initState(bool edit, [BuildHabit? habit, EntityCategory? category]) {
    textController.text = edit ? habit!.name : '';
    descriptionController.text = edit ? habit!.description ?? '' : '';
    unitController.text = edit ? habit!.unit ?? '' : '';

    final categories = g.catVm.categories;

    state = BuildHabitState(
      categorySelection: category == null
          ? edit
                ? {for (var cat in categories) cat: habit!.categories.contains(cat)}
                : {EntityCategory(id: 1, name: 'General'): true}
          : {category: true},
      startDate: edit ? habit!.startDate : DateTime.now(),
      color: edit ? habit!.color! : 'primary',
      reminders: edit ? Reminder.getReminderObjects(habit!.reminders) : [],
      repeatConfig: edit ? RepeatConfig.fromJsonString(habit!.repeatConfig) : RepeatConfig(),
      endDate: edit ? habit!.endDate : null,
      endTime: edit ? habit!.endTime : null,
      target: edit ? BuildHabitTarget.fromJsonString(habit!.target!) : BuildHabitTarget(),
      measurementType: edit ? habit!.getMeasurementType() : MeasurementType.count,
    );
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
    notifyListeners();
  }

  void resetStartDate() {
    state = state.copyWith(startDate: DateTime.now());
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
    notifyListeners();
  }

  void resetEndDate() {
    state = state.copyWith(endDate: null);
    notifyListeners();
  }

  void setStartTime(TimeOfDay selectedTime) {
    final dateTime = DateTime(1970, 1, 1, selectedTime.hour, selectedTime.minute);
    state = state.copyWith(startTime: dateTime);
    notifyListeners();
  }

  void resetStartTime() {
    state = state.copyWith(startTime: null);
    notifyListeners();
  }

  void setEndTime(TimeOfDay selectedTime) {
    final dateTime = DateTime(1970, 1, 1, selectedTime.hour, selectedTime.minute);
    state = state.copyWith(endTime: dateTime);
    notifyListeners();
  }

  void resetEndTime() {
    state = state.copyWith(endTime: null);
    notifyListeners();
  }

  void setRepeatConfig(RepeatConfig config) {
    state = state.copyWith(repeatConfig: config);
    notifyListeners();
  }

  void setTarget(BuildHabitTarget target) {
    state = state.copyWith(target: target);
    notifyListeners();
  }

  void setMeasurementType(MeasurementType type) {
    state = state.copyWith(measurementType: type);
    notifyListeners();
  }

  void setCategory(EntityCategory category, bool value) {
    state = state.copyWith(categorySelection: {...categorySelection, category: value});
    notifyListeners();
  }

  void putReminder({required Reminder reminder, required bool edit}) {
    List<Reminder> updatedReminders = List.from(reminders);
    if (edit) {
      final index = updatedReminders.indexWhere((r) => r.time == reminder.time);
      if (index != -1) {
        updatedReminders[index] = reminder;
      }
    } else {
      updatedReminders = [...updatedReminders, reminder];
    }
    state = state.copyWith(reminders: updatedReminders);
    notifyListeners();
  }

  void removeReminder(Reminder reminder) {
    List<Reminder> updatedReminders = List.from(reminders);
    updatedReminders.remove(reminder);
    state = state.copyWith(reminders: updatedReminders);
    notifyListeners();
  }

  void setColor(String color) {
    state = state.copyWith(color: color);
    notifyListeners();
  }
}

extension AccessBuildHabitState on BuildHabitStateController {
  DateTime get startDate => state.startDate;
  DateTime? get endDate => state.endDate;
  DateTime? get endTime => state.endTime;
  DateTime? get startTime => state.startTime;
  RepeatConfig get repeatConfig => state.repeatConfig;
  List<Reminder> get reminders => state.reminders;
  String get color => state.color;
  BuildHabitTarget get target => state.target;
  Map<EntityCategory, bool> get categorySelection => state.categorySelection;
  MeasurementType get measurementType => state.measurementType;
}
