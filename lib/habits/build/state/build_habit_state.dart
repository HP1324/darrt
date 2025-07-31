import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit_repeat_config.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'build_habit_state.freezed.dart';

@freezed
abstract class BuildHabitState with _$BuildHabitState {
  const factory BuildHabitState({
    required String name,
    required DateTime startDate,
    required String color,
    required String measurementType,
    required String measurementUnit,
    required Map<EntityCategory, bool> categorySelection,
    required List<Reminder> reminders,
    required BuildHabitRepeatConfig repeatConfig,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    DateTime? endDate,
  }) = _BuildHabitState;

  const BuildHabitState._();
}
