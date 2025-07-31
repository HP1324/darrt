import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:darrt/task/models/repeat_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
part 'build_habit_state.freezed.dart';

@freezed
abstract class BuildHabitState with _$BuildHabitState {
  const factory BuildHabitState({
    required DateTime startDate,
    required String color,
    required Map<EntityCategory, bool> categorySelection,
    required List<Reminder> reminders,
    required RepeatConfig repeatConfig,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? endDate,
  }) = _BuildHabitState;

  const BuildHabitState._();
}
