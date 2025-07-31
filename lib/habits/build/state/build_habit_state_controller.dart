import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/build_habit_repeat_config.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state.dart';
import 'package:darrt/app/state/controllers/state_controller.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:flutter/material.dart';
import 'package:darrt/helpers/globals.dart' as g;

class BuildHabitStateController extends StateController<BuildHabitState, BuildHabit> {

  // Additional controllers for description and unit
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode descriptionNode = FocusNode();
  final TextEditingController unitController = TextEditingController();
  final FocusNode unitNode = FocusNode();

  @override
  BuildHabit buildModel({required bool edit, BuildHabit? model}) {
    BuildHabit habit;

    if (edit) {
      habit = model!;
      habit.name = textController.text;
      habit.description = descriptionController.text.isEmpty ? null : descriptionController.text;
      habit.measurementUnit = unitController.text;
      habit.measurementType = state.measurementType;
      habit.color = state.color;
      habit.startDate = state.startDate;
      habit.endDate = state.endDate;
      habit.startTime = state.startTime;
      habit.endTime = state.endTime;
      habit.reminders = Reminder.remindersToJsonString(state.reminders);
    } else {
      habit = BuildHabit(
        name: textController.text,
        description: descriptionController.text.isEmpty ? null : descriptionController.text,
        measurementType: state.measurementType,
        measurementUnit: unitController.text,
        color: state.color,
        startDate: state.startDate,
        endDate: state.endDate,
        startTime: state.startTime,
        endTime: state.endTime,
        reminders: Reminder.remindersToJsonString(state.reminders),
      );
    }

    // Handle categories
    final categories = g.catVm.categories
        .where((c) => state.categorySelection[c] == true)
        .toList();
    habit.categories.clear();
    if (categories.isEmpty) {
      final generalCategory = EntityCategory(id: 1, name: 'General');
      habit.categories.add(generalCategory);
    } else {
      habit.categories.addAll(categories);
    }

    return habit;
  }

  @override
  void clearState() {
    state = BuildHabitState(
      name: '',
      startDate: DateTime.now(),
      color: 'primary',
      measurementType: 'boolean',
      measurementUnit: '',
      categorySelection: {EntityCategory(id: 1, name: 'General'): true},
      reminders: [],
      repeatConfig: BuildHabitRepeatConfig(),
    );
    textController.clear();
    descriptionController.clear();
    unitController.clear();
  }

  @override
  void initState(bool edit, [BuildHabit? model]) {
    if (edit && model != null) {
      textController.text = model.name;
      descriptionController.text = model.description ?? '';
      unitController.text = model.measurementUnit ?? '';

      final categories = g.catVm.categories;
      state = BuildHabitState(
        name: model.name,
        startDate: model.startDate,
        color: model.color ?? 'primary',
        measurementType: model.measurementType,
        measurementUnit: model.measurementUnit ?? '',
        categorySelection: {for (var cat in categories) cat: model.categories.contains(cat)},
        reminders: model.reminderObjects,
        repeatConfig: BuildHabitRepeatConfig(), // You can add repeat config to BuildHabit model later
        endDate: model.endDate,
        startTime: model.startTime,
        endTime: model.endTime,
        description: model.description,
      );
    } else {
      clearState();
    }
  }

  // State setters
  void setColor(String color) {
    state = state.copyWith(color: color);
    notifyListeners();
  }

  void setMeasurementType(String type) {
    state = state.copyWith(measurementType: type);
    notifyListeners();
  }

  void setMeasurementUnit(String unit) {
    state = state.copyWith(measurementUnit: unit);
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    state = state.copyWith(startDate: date);
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
    notifyListeners();
  }

  void setStartTime(DateTime? time) {
    state = state.copyWith(startTime: time);
    notifyListeners();
  }

  void setEndTime(DateTime? time) {
    state = state.copyWith(endTime: time);
    notifyListeners();
  }

  void setRepeatConfig(BuildHabitRepeatConfig config) {
    state = state.copyWith(repeatConfig: config);
    notifyListeners();
  }

  void setCategory(EntityCategory category, bool value) {
    state = state.copyWith(categorySelection: {...state.categorySelection, category: value});
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    descriptionNode.dispose();
    unitController.dispose();
    unitNode.dispose();
    super.dispose();
  }
}

// Extension for easy access
extension AccessBuildHabitState on BuildHabitStateController {
  String get color => state.color;
  String get measurementType => state.measurementType;
  String get measurementUnit => state.measurementUnit;
  DateTime get startDate => state.startDate;
  DateTime? get endDate => state.endDate;
  DateTime? get startTime => state.startTime;
  DateTime? get endTime => state.endTime;
  BuildHabitRepeatConfig get repeatConfig => state.repeatConfig;
  List<Reminder> get reminders => state.reminders;
  Map<EntityCategory, bool> get categorySelection => state.categorySelection;
}
